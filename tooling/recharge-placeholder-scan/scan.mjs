#!/usr/bin/env node
import { createWriteStream, existsSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const BASE_URL = 'https://www.recharge.com';
const TIMEOUT = Number(process.env.TIMEOUT ?? 15_000);
const RPS = Number(process.env.RPS ?? 0); // required — caps requests per second
const LIMIT = Number(process.env.LIMIT ?? 0); // 0 = no cap
// Pool size follows RPS: enough headroom so slow upstreams don't starve the
// rate limiter, but bounded so a stall doesn't balloon in-flight requests.
const POOL_SIZE = Math.max(2, Math.min(50, Math.ceil(RPS * 3)));
const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ' +
  '(KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 placeholder-scan/1.0';

const PROGRESS_PATH = join(HERE, 'progress.ndjson');
const CLEAN_PATH = join(HERE, 'clean.csv');
const HITS_PATH = join(HERE, 'needs-attention.csv');

// Matches typical brand placeholder shapes: {Lycamobile}, {Neosurf Voucher},
// {Paysafecard}. Start with an uppercase letter to avoid CSS/JSON noise.
const PLACEHOLDER_RE = /\{[A-Z][A-Za-z0-9][A-Za-z0-9 \-]{0,40}\}/g;

const HITS_HEADER = [
  'country_code',
  'country_name',
  'lang_code',
  'lang_name',
  'status',
  'matches',
  'sample',
  'url',
];
const CLEAN_HEADER = [
  'country_code',
  'country_name',
  'lang_code',
  'lang_name',
  'status',
  'url',
];

const args = new Set(process.argv.slice(2));
const RESET = args.has('--reset');
const RETRY_ERRORS = !args.has('--skip-errors');

const HELP_REQUESTED = args.has('--help') || args.has('-h');

if (!HELP_REQUESTED && !(RPS > 0)) {
  process.stderr.write(
    `Error: RPS is required.\n\n` +
      `Set RPS=<n> to cap requests per second. Example:\n` +
      `  RPS=5 node scan.mjs\n\n` +
      `Run with --help for all options.\n`,
  );
  process.exit(2);
}

if (HELP_REQUESTED) {
  process.stdout.write(
    `Usage: scan.mjs [flags]\n\n` +
      `Scans https://www.recharge.com/<lang>/<country> for every language × country\n` +
      `combo and reports which ones render brand names with {curly braces}.\n\n` +
      `Flags:\n` +
      `  --reset         Discard existing progress and start over from scratch.\n` +
      `  --skip-errors   Do not retry combos that previously errored (timeout/network).\n` +
      `                  Default: errors are retried on the next run.\n` +
      `  --help, -h      Show this help.\n\n` +
      `Env vars:\n` +
      `  RPS=<n>          Max requests per second. REQUIRED — no default.\n` +
      `                   Pool size is derived from RPS (RPS×3, capped 2–50).\n` +
      `  TIMEOUT=<ms>  Per-request timeout. Default: 15000.\n` +
      `  LIMIT=<n>        Cap number of combos processed this run. Default: 0 (no cap).\n` +
      `                   Useful for smoke tests, e.g. LIMIT=10.\n\n` +
      `Output files (next to this script):\n` +
      `  progress.ndjson       One JSON record per attempt. Authoritative log — used to resume.\n` +
      `  needs-attention.csv   Only combos that matched {placeholders}.\n` +
      `  clean.csv             Combos that fetched OK with no placeholders.\n\n` +
      `Resume behaviour:\n` +
      `  Rerunning without --reset picks up where the previous run left off. Ctrl-C once\n` +
      `  to stop gracefully (in-flight requests finish). Ctrl-C twice to force-quit.\n\n` +
      `Examples:\n` +
      `  RPS=5 node scan.mjs                 # full run, 5 req/s\n` +
      `  RPS=2 LIMIT=20 node scan.mjs        # smoke test, first 20 combos\n` +
      `  RPS=10 node scan.mjs                # faster — use if upstream allows\n` +
      `  RPS=5 node scan.mjs --reset         # wipe progress and start over\n`,
  );
  process.exit(0);
}

const countries = JSON.parse(
  readFileSync(join(HERE, 'countries.json'), 'utf8'),
);
const languages = JSON.parse(
  readFileSync(join(HERE, 'languages.json'), 'utf8'),
);

const key = (lang, country) => `${lang.code}|${country.code}`;

const csvEscape = (v) => {
  const s = String(v ?? '');
  return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
};
const csvRow = (header, obj) =>
  header.map((h) => csvEscape(obj[h])).join(',');

const toHitsRow = (record) => ({
  country_code: record.country.code,
  country_name: record.country.name,
  lang_code: record.language.code,
  lang_name: record.language.name,
  status: record.status,
  matches: record.matchCount,
  sample: record.matches.join(' | '),
  url: record.finalUrl ?? record.url,
});

const toCleanRow = (record) => ({
  country_code: record.country.code,
  country_name: record.country.name,
  lang_code: record.language.code,
  lang_name: record.language.name,
  status: record.status,
  url: record.finalUrl ?? record.url,
});

const shouldSkip = (record) => {
  if (!record) return false;
  if (record.status === 0 && RETRY_ERRORS) return false;
  return true;
};

// Load prior progress, if any.
if (RESET) {
  for (const p of [PROGRESS_PATH, CLEAN_PATH, HITS_PATH]) {
    if (existsSync(p)) writeFileSync(p, '');
  }
}

const prior = new Map();
if (existsSync(PROGRESS_PATH)) {
  const lines = readFileSync(PROGRESS_PATH, 'utf8').split('\n');
  for (const line of lines) {
    if (!line.trim()) continue;
    try {
      const rec = JSON.parse(line);
      prior.set(key(rec.language, rec.country), rec);
    } catch {
      // ignore malformed line
    }
  }
}

// Rebuild CSVs from the canonical ndjson so they never drift.
const rebuildCsvs = () => {
  const hits = [];
  const clean = [];
  for (const rec of prior.values()) {
    if (rec.status > 0 && rec.matchCount > 0) hits.push(toHitsRow(rec));
    else if (rec.status > 0) clean.push(toCleanRow(rec));
  }
  hits.sort(
    (a, b) =>
      a.country_name.localeCompare(b.country_name) ||
      a.lang_name.localeCompare(b.lang_name),
  );
  clean.sort(
    (a, b) =>
      a.country_name.localeCompare(b.country_name) ||
      a.lang_name.localeCompare(b.lang_name),
  );
  writeFileSync(
    HITS_PATH,
    [HITS_HEADER.join(','), ...hits.map((r) => csvRow(HITS_HEADER, r))].join(
      '\n',
    ) + '\n',
  );
  writeFileSync(
    CLEAN_PATH,
    [CLEAN_HEADER.join(','), ...clean.map((r) => csvRow(CLEAN_HEADER, r))].join(
      '\n',
    ) + '\n',
  );
};
rebuildCsvs();

const progressStream = createWriteStream(PROGRESS_PATH, { flags: 'a' });
const hitsStream = createWriteStream(HITS_PATH, { flags: 'a' });
const cleanStream = createWriteStream(CLEAN_PATH, { flags: 'a' });

const combos = [];
for (const lang of languages) {
  for (const country of countries) {
    const existing = prior.get(key(lang, country));
    if (!shouldSkip(existing)) combos.push({ lang, country });
  }
}
const fullRemaining = combos.length;
if (LIMIT > 0 && combos.length > LIMIT) {
  combos.length = LIMIT;
}

const totalCombos = languages.length * countries.length;
const priorHits = [...prior.values()].filter(
  (r) => r.status > 0 && r.matchCount > 0,
).length;
const priorClean = [...prior.values()].filter(
  (r) => r.status > 0 && r.matchCount === 0,
).length;

process.stdout.write(
  `Total combos: ${totalCombos} — already done: ${totalCombos - fullRemaining} (${priorHits} hits, ${priorClean} clean) — remaining: ${fullRemaining}\n`,
);
if (combos.length === 0) {
  process.stdout.write(`Nothing to do. Use --reset to restart.\n`);
  process.exit(0);
}
if (LIMIT > 0 && fullRemaining > LIMIT) {
  process.stdout.write(`LIMIT=${LIMIT} — processing only the first ${LIMIT} of ${fullRemaining} remaining combos.\n`);
}
process.stdout.write(
  `Rate ${RPS} req/s (pool ${POOL_SIZE}), timeout ${TIMEOUT}ms. Ctrl-C is safe — rerun to resume.\n`,
);

const minIntervalMs = 1000 / RPS;
let nextSlot = Date.now();
const acquireSlot = async () => {
  const now = Date.now();
  const slot = Math.max(nextSlot, now);
  nextSlot = slot + minIntervalMs;
  const waitMs = slot - now;
  if (waitMs > 0) await new Promise((resolve) => setTimeout(resolve, waitMs));
};

const fetchOne = async ({ lang, country }) => {
  const url = `${BASE_URL}/${lang.code}/${country.code.toLowerCase()}`;
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT);
  try {
    const res = await fetch(url, {
      redirect: 'follow',
      headers: {
        'User-Agent': USER_AGENT,
        'Accept-Language': `${lang.code},en;q=0.5`,
      },
      signal: controller.signal,
    });
    const html = await res.text();
    const matches = [...html.matchAll(PLACEHOLDER_RE)].map((m) => m[0]);
    const unique = [...new Set(matches)];
    return {
      url,
      status: res.status,
      finalUrl: res.url,
      matchCount: unique.length,
      matches: unique.slice(0, 20),
    };
  } catch (err) {
    return {
      url,
      status: 0,
      error: err.name === 'AbortError' ? 'timeout' : err.message,
      matchCount: 0,
      matches: [],
    };
  } finally {
    clearTimeout(timer);
  }
};

let stopRequested = false;
let idx = 0;
let done = 0;
let hits = priorHits;
let clean = priorClean;
const startedAt = Date.now();

process.on('SIGINT', () => {
  if (stopRequested) process.exit(130);
  stopRequested = true;
  process.stdout.write(
    `\nStop requested — finishing in-flight requests. Ctrl-C again to force.\n`,
  );
});

const worker = async () => {
  while (!stopRequested) {
    const myIdx = idx++;
    if (myIdx >= combos.length) return;
    const combo = combos[myIdx];
    await acquireSlot();
    const result = await fetchOne(combo);
    done++;

    const record = {
      country: combo.country,
      language: combo.lang,
      ...result,
    };
    progressStream.write(JSON.stringify(record) + '\n');

    if (result.status > 0 && result.matchCount > 0) {
      hits++;
      hitsStream.write(csvRow(HITS_HEADER, toHitsRow(record)) + '\n');
      process.stdout.write(
        `[HIT] ${combo.lang.code}/${combo.country.code} → ${result.matchCount} (${result.matches.slice(0, 3).join(', ')})\n`,
      );
    } else if (result.status > 0) {
      clean++;
      cleanStream.write(csvRow(CLEAN_HEADER, toCleanRow(record)) + '\n');
    }

    if (done % 100 === 0 || done === combos.length) {
      const elapsed = ((Date.now() - startedAt) / 1000).toFixed(1);
      process.stdout.write(
        `[progress] ${done}/${combos.length} this run — ${elapsed}s — ${hits} hits, ${clean} clean total\n`,
      );
    }
  }
};

await Promise.all(Array.from({ length: POOL_SIZE }, () => worker()));

await Promise.all(
  [progressStream, hitsStream, cleanStream].map(
    (s) =>
      new Promise((resolve) => {
        s.end(resolve);
      }),
  ),
);

// Re-sort CSVs at the end for a clean, alphabetised final file.
const reload = new Map();
const lines = readFileSync(PROGRESS_PATH, 'utf8').split('\n');
for (const line of lines) {
  if (!line.trim()) continue;
  try {
    const rec = JSON.parse(line);
    reload.set(key(rec.language, rec.country), rec);
  } catch {
    // ignore
  }
}
prior.clear();
for (const [k, v] of reload) prior.set(k, v);
rebuildCsvs();

process.stdout.write(
  stopRequested
    ? `\nStopped. Rerun to resume. ${hits} hits, ${clean} clean so far.\n`
    : `\nDone. ${hits} hits, ${clean} clean.\n`,
);
process.stdout.write(`Hits:  ${HITS_PATH}\nClean: ${CLEAN_PATH}\nRaw:   ${PROGRESS_PATH}\n`);
