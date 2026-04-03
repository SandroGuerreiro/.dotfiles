# Astrolabe — Second Brain

Astrolabe is an Obsidian vault at `~/Code/Astrolabe/` that documents how and why things work across projects.

## When to consult

Before searching the codebase for "how does X work" or "how do I do X":
1. Read `~/Code/Astrolabe/projects/<project>/_index.md`
2. If a matching entry exists, read it first — it may already have the answer

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
