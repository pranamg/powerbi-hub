# Scripts

> Repository tooling used by CI.

| Script | Description |
|--------|-------------|
| [check_links.py](./check_links.py) | Validates that every relative link in every Markdown file resolves to a file that exists |

## check_links.py

Run locally before pushing:

```bash
python .github/scripts/check_links.py
```

Exits `0` when all links resolve and `1` otherwise, printing each failure as
`path:line  [label](target)`. It has no third-party dependencies.

### What it checks

- Relative links resolve to an existing file or directory.
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

## Related

- [Workflows](../workflows/) — CI definitions that run this script
- [Contributing guide](../../Contributions/CONTRIBUTING.md)
