---
title: Scripts
tags: [documentation]
audience: [all]
difficulty: beginner
last_verified: 2026-09-29
---

# Scripts

> Repository tooling used by CI. All Python, no third-party dependencies.

| Script | Description |
|--------|-------------|
| [check_links.py](./check_links.py) | Validates that every relative link in every Markdown file resolves |
| [check_frontmatter.py](./check_frontmatter.py) | Validates frontmatter values against the hub's schema |
| [add_frontmatter.py](./add_frontmatter.py) | Adds frontmatter to new files, derived from path rules |
| [build_index.py](./build_index.py) | Generates `Documentation/Topic_Index.md` from frontmatter |

Run all of them locally before pushing:

```bash
python .github/scripts/add_frontmatter.py   # only needed for new files
python .github/scripts/check_frontmatter.py
python .github/scripts/build_index.py
python .github/scripts/check_links.py
```

`build_index.py --check` and `add_frontmatter.py --check` are the CI variants:
they exit `1` without writing anything when something is out of date.

## check_links.py

Exits `0` when all links resolve and `1` otherwise, printing each failure as
`path:line  [label](target)`.

### What it checks

- Relative links resolve, using GitHub's own resolution rules: `./Guide` finds
  `Guide.md`, and `./Folder/` renders that folder's `README.md` or, failing
  that, a file listing.
- The fragment in a same-file or relative link matches a heading in the
  target, using an approximation of GitHub's anchor slug rules.

### What it skips

- External URLs (`http`, `https`, `mailto`, `tel`, `ftp`) — these need network
  access.
- Code spans and fenced code blocks. Markdown examples such as
  `` `[My UDF](parameter)` `` are not links, and this repository contains
  several.

Inline code and fenced blocks are masked with a state machine rather than a
regular expression, because prose containing a literal run of backticks
desynchronises naive pairing and silently unmasks the rest of a file.

## check_frontmatter.py

Checks values, not just presence. A typo in a tag, an unknown `difficulty`, or
a malformed `last_verified` date silently breaks filtering in the generated
index, so each value is checked against a controlled vocabulary.

The vocabulary of valid tags and audiences lives in this script. **Adding a
tag means adding it there too**, otherwise CI will reject it.

The two GitHub issue templates in `../ISSUE_TEMPLATE/` are exempt — they use
GitHub's own frontmatter schema.

## add_frontmatter.py

Derives `title`, `tags`, `audience`, and `difficulty` from a file's path, so a
folder's tags stay consistent as files are added to it. `title` comes from the
document's own H1 when there is one.

Idempotent: a file that already has frontmatter is never rewritten, so
hand-tuned tags are safe. Review new files before committing, and adjust
`OVERRIDES` in the script when a specific file deserves different metadata
than its path implies.

## build_index.py

Generates `Documentation/Topic_Index.md` — the A–Z listing plus audience, tag,
and difficulty rollups. Paths are emitted relative to the index file's own
location, not the repository root.

**Do not edit the generated index by hand.** Edit the source Markdown, then
re-run the script.

## Related

- [Workflows](../workflows/) — CI definitions that run these scripts
- [Contributing guide](../../Contributions/CONTRIBUTING.md)
