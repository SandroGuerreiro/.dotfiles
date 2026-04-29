---
name: AL write-check at end of every non-trivial task
description: After any implementation, bug fix, or investigation, self-check whether new knowledge should be written to Astrolabe — do not wait to be asked
type: feedback
---
At the end of every implementation, bug fix, or non-trivial investigation, run an explicit self-check: **"is there anything important or new from this work that should be captured in Astrolabe?"** This is the *write* check — separate from the *read* check at the start of a task.

**Why:** Without this prompt, non-obvious gotchas (hidden constraints, system-level decisions, surprising interactions) evaporate and future sessions re-derive or repeat the same mistakes. The `astrolabe.md` rule already mandates updating AL after non-trivial answers — this feedback reinforces that the update pass is mandatory, not optional.

**How to apply:**
- Before reporting a task done, ask: "Did I learn anything non-obvious that future-me would want?" Examples: a gotcha hidden by build environment, a non-obvious dependency interaction, a system-level decision, a new recipe.
- If yes: update or create the relevant entry under `~/Code/Astrolabe/projects/<project>/{systems,recipes,decisions,glossary}/`, bump `updated`, and update `_index.md` if the summary changed.
- If genuinely no (cosmetic refactor, doc-only edit, trivial rename): say so explicitly rather than skipping silently.
- This applies to **every project**, not just pronto.
