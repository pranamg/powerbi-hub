---
title: Workflows
tags: [documentation]
audience: [all]
difficulty: beginner
last_verified: 2026-09-29
---

# Workflows

> Continuous integration definitions.

| Workflow | Description |
|----------|-------------|
| [ci.yml](./ci.yml) | Runs on pushes and pull requests to `main` |

## What CI checks

1. **Super Linter** — general Markdown and file hygiene.
2. **Link validation** — runs [`check_links.py`](../scripts/check_links.py) to
   confirm every relative link in the repository points at a file that exists.

The link check is also runnable locally:

```bash
python .github/scripts/check_links.py
```

It exits non-zero on any broken relative link, so a broken cross-reference
fails the build rather than being discovered in review.

## Adding a workflow

Place the YAML in this folder and reference it from the repository's Actions
tab. Keep secrets in repository or environment secrets rather than in the
workflow file.
