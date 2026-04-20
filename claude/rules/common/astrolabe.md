# Astrolabe — Second Brain

Astrolabe is an Obsidian vault at `~/Code/Astrolabe/` that documents how and why things work across projects.

## ALWAYS CHECK AL FIRST — every session, every project

Before searching the codebase, answering a "how does X work" / "why is X" question, investigating a bug, or replying "I can't access that link", **check Astrolabe first**. This is not optional and not project-specific — it applies to every session in every project.

### Flow

1. **External resource in the question?** (Slack URL, Jira ticket, Confluence page, etc.)
   - `ls ~/Code/Astrolabe/devex/` and grep for the platform name (slack, jira, confluence, etc.)
   - Follow the recipe (e.g. `devex/<project>/recipes/fetch-slack-thread.md`) to fetch the content
   - Do this **before** telling the user you can't access the link
2. **Project has an entry?** (`~/Code/Astrolabe/projects/<project>/`)
   - Read `projects/<project>/_index.md` **in full** to scan systems / recipes / decisions / glossary — do not stop at the first plausible row
   - Open and read any candidate entry fully — especially **Gotchas** and **Why It Works This Way**
   - **Answer from the entry.** If it covers the question, that is your answer. Do not re-derive the same fact from the codebase as "verification" — that wastes the user's time and signals you don't trust AL. Only reach for code if (a) the entry is silent on the specific sub-question, (b) the entry's `updated` date is stale and the area has clearly moved, or (c) the user explicitly asks to verify.
3. **Only then** start reading source code. Use AL to narrow *where* to look and *what to watch out for*.

### Red flags (STOP and check AL)

If you catch yourself thinking any of these, you are skipping step 2:
- "Let me just verify this in the code real quick" — if an entry covers it, don't.
- "The entry probably exists but let me grep first to save time" — reading `_index.md` is 1 tool call; grepping is 3+.
- "I'll answer from memory" — entries evolve; read the current version.
- "The question is about a nuance (X) the entry might not cover" — it probably does. Read the Gotchas section before assuming.

### Assume recipes exist

Default assumption: a recipe exists. Disprove it by looking, not by asserting. "I can't read Slack links" / "I need to check the code" without first checking AL is a workflow failure.

### Projects without entries

If the project folder doesn't exist under `projects/`, create the structure (`systems/`, `recipes/`, `decisions/`, `glossary/`, `_index.md`) as soon as you learn something worth recording — see "When to update" below.

## When to update

After answering a non-trivial question about how something works, how to do something, or why something is the way it is:
1. Determine the right category: system (how it works), recipe (how to do it), decision (why it's this way), glossary (what it means)
2. Write or update the entry in `~/Code/Astrolabe/projects/<project>/<category>/`
3. Update the project `_index.md` table with a one-line summary
4. If the project folder doesn't exist yet, create it with `systems/`, `recipes/`, `decisions/`, `glossary/` subdirectories and an `_index.md`

## Entry format

Use the templates in `~/Code/Astrolabe/templates/` — every entry must have:
- Frontmatter (tags, project, created, updated)
- Key Files table with paths
- A "Why It Works This Way" or equivalent section
- Related wikilinks

## Rules

- Keep entries focused — one topic per file
- Index summaries must be under 150 characters
- Update the `updated` date when modifying existing entries
- Use `[[wikilinks]]` to connect related entries

## Security — NEVER write secrets to this vault

Astrolabe is a knowledge base, not a secrets store. **Never write real values** for:
- API keys, tokens, passwords, credentials
- Database connection strings or hostnames
- Real user IDs, order IDs, customer data, PII
- Internal URLs, IP addresses, or account identifiers

Use placeholders or describe the *location* of the value instead (e.g. "stored in AWS SSM at `/prod/service/KEY`").
