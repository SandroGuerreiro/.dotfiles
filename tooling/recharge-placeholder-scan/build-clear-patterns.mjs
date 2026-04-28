#!/usr/bin/env node
// Reads needs-attention.csv and writes lang+country-scoped backend Valkey
// patterns to clear-patterns.txt. One pattern per hit (not per country), so
// we only clear what was actually stale. Frontend cache is not cleared — the
// stale render comes from the backend, and the FE will repopulate from
// refreshed backend data on the next request/deploy.
//
// Backend cache key format (product-information-service):
//   ...getproductbrandsbycategoryandcountry-<categorySlug>-<country>-<lang>-<...>-<hash>
//   Country comes BEFORE lang — argument order in the resolver DTO.
//   So we match on both country and lang: *-<country>-<lang>-*

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const HITS = join(HERE, 'needs-attention.csv');
const OUT = join(HERE, 'clear-patterns.txt');

const raw = readFileSync(HITS, 'utf8').trim().split('\n');
if (raw.length <= 1) {
  process.stderr.write('No hits in needs-attention.csv — nothing to clear.\n');
  process.exit(1);
}

// CSV columns: country_code, country_name, lang_code, lang_name, status, matches, sample, url
const parseRow = (line) => {
  const cols = line.split(',');
  return {
    country: cols[0]?.trim().toLowerCase(),
    lang: cols[2]?.trim().toLowerCase(),
  };
};

const hits = [
  ...new Map(
    raw
      .slice(1)
      .map(parseRow)
      .filter((h) => h.country && h.lang)
      .map((h) => [`${h.lang}/${h.country}`, h]),
  ).values(),
].sort(
  (a, b) => a.lang.localeCompare(b.lang) || a.country.localeCompare(b.country),
);

const patterns = hits.map(
  (h) => `*getproductbrandsbycategoryandcountry*-${h.country}-${h.lang}-*`,
);

const text = [
  `# Generated ${new Date().toISOString()}`,
  `# ${hits.length} unique lang/country hits from ${HITS}`,
  `# Key format: ...getproductbrandsbycategoryandcountry-<category>-<country>-<lang>-<...>-<hash>`,
  `# Backend only — FE cache repopulates from refreshed backend, no need to clear it.`,
  ``,
  ...patterns,
  ``,
].join('\n');

writeFileSync(OUT, text);

process.stdout.write(
  `Wrote ${patterns.length} backend patterns to:\n  ${OUT}\n\n` +
    `Run automatically (5s gap between patterns):\n` +
    `  cd ~/Code/cache-clearance\n` +
    `  pnpm exec tsx src/clear-from-file.ts ${OUT}           # dry-run, PROD\n` +
    `  pnpm exec tsx src/clear-from-file.ts ${OUT} --apply   # actual delete\n`,
);
