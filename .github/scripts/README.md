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
| [check_assets.py](./check_assets.py) | Structural checks on DAX, M, TMDL, PowerShell, Python, JSON, and notebooks |
| [check_external_links.py](./check_external_links.py) | Checks that external URLs still resolve (needs network; run on a schedule) |
| [add_frontmatter.py](./add_frontmatter.py) | Adds frontmatter to new files, derived from path rules |
| [build_index.py](./build_index.py) | Generates `Documentation/Topic_Index.md` from frontmatter |

Run all of them locally before pushing:

```bash
python .github/scripts/add_frontmatter.py   # only needed for new files
python .github/scripts/check_frontmatter.py
python .github/scripts/build_index.py
python .github/scripts/check_links.py
python .github/scripts/check_assets.py
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

## check_assets.py

Structural checks on the repository's code and data. There is no DAX, M, or
PowerShell compiler here — a real one needs Power BI Desktop — so this catches
mechanical failure rather than semantic error:

- JSON and `.ipynb` files parse
- DAX, M, and PowerShell files have balanced brackets, ignoring comments and
  string literals so an apostrophe in prose is not counted as code
- TMDL files declare at least one object, and a file named `DimProduct`
  declares that table
- Python files compile
- Workflow YAML has no tabs and declares a `jobs:` key

Deliberately conservative: it flags what is certainly wrong, not what is merely
unusual, so a clean run means something.

## check_external_links.py

The network half of link checking, which `check_links.py` deliberately skips.
Run on a weekly schedule rather than per-push, because a rate-limited host
should not fail an unrelated build.

```bash
python .github/scripts/check_external_links.py            # all URLs
python .github/scripts/check_external_links.py --file README.md
python .github/scripts/check_external_links.py --limit 50
```

It reports **broken** (a definitive non-2xx/3xx answer) separately from
**unreachable** (the request never completed). The distinction matters: large
hosts like YouTube routinely time out under concurrency without being broken,
and treating that as a dead link produces noise nobody acts on. A 404 *is*
retried, because it is a real answer.

It cannot check whether a page still says what the link claimed when it was
written. Only re-reading catches that, which is what `last_verified` and the
[What's New register](../../Documentation/WhatsNew/README.md) are for.

## build_index.py

Generates `Documentation/Topic_Index.md` — the A–Z listing plus audience, tag,
and difficulty rollups. Paths are emitted relative to the index file's own
location, not the repository root.

**Do not edit the generated index by hand.** Edit the source Markdown, then
re-run the script.

## Related

- [Workflows](../workflows/) — CI definitions that run these scripts
- [Contributing guide](../../Contributions/CONTRIBUTING.md)
