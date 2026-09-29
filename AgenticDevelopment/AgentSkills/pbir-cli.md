---
title: "pbir-cli: Report Automation from the Terminal"
tags: [agentic, ai, tooling, automation]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# pbir-cli: Report Automation from the Terminal

`pbir` treats a Power BI report as files and folders rather than something you
click through in Desktop. It is built for humans and optimised for agents.

From [github.com/maxanatsko/pbir.tools](https://github.com/maxanatsko/pbir.tools),
by Maxim Anatsko and Kurt Buhler (Data Goblins).

> **The tool is in beta.** The authors recommend taking a manual backup of any
> report folder before first use, and treating bulk formatting, conversion,
> merge, and publish as higher-risk workflows. See
> [Safety](#safety) below.

---

## When it is worth using

Three situations justify the switch from clicking:

1. You need to understand an unfamiliar report quickly
2. You want the same change applied across many visuals or pages
3. You want a repeatable validate → backup → publish → recover loop

For a one-off change to one visual, Desktop is faster.

---

## Install

```bash
uv tool install pbir-cli      # recommended
```

or:

```bash
pip install pbir-cli
```

Verify — you need a **new terminal** so `PATH` picks up the install:

```bash
pbir --version
```

### Native installers

GitHub Releases has signed macOS and Windows installers if you would rather not
use Python. On macOS you will need to approve the installer under
**System Settings → Privacy & Security → Open Anyway** if it is unsigned or
unnotarised. On Windows, SmartScreen may require **More info → Run anyway**.

### Pair it with the skills

`pbir` on its own is a command-line tool. To let an agent drive it well,
install the Data Goblins marketplace, which includes a dedicated `pbir-cli`
skill and report-authoring skills built on it:

```bash
claude plugin marketplace add data-goblin/power-bi-agentic-development
```

```bash
copilot plugin install data-goblin/power-bi-agentic-development
```

> In Copilot CLI, the bare command above installs nothing useful — the repo
> root is a marketplace catalogue, not a plugin. Either register the
> marketplace first and install a named child plugin, or point at a
> subdirectory:
>
> ```bash
> copilot plugin marketplace add data-goblin/power-bi-agentic-development
> copilot plugin install tabular-editor@power-bi-agentic-development
> # or
> copilot plugin install data-goblin/power-bi-agentic-development:plugins/pbip
> ```

See [Agent Skills](../AgentSkills/README.md) for the full plugin inventory.

---

## Path syntax

`pbir` addresses report objects with filesystem-style paths:

```text
Report.Report/Page.Page/Visual.Visual
```

| Path | Refers to |
|------|-----------|
| `Sales.Report` | The whole report |
| `Sales.Report/Overview.Page` | One page |
| `Sales.Report/Overview.Page/Revenue.Visual` | One visual |
| `Sales.Report/**/*.Visual` | Every visual, all pages |
| `My Workspace.Workspace/Sales.Report` | A report in Fabric, not on disk |

The `.Workspace` form targets Fabric. The bare form targets a local folder.

---

## First five minutes

```bash
cd "C:\Users\YourName\Documents\My Reports"   # must contain the report folder
pbir ls                                        # list reports
pbir tree "Sales.Report" -v                    # pages, visuals, and the fields each uses
pbir model "Sales.Report" -d                   # the semantic model schema
```

Always run `pbir model` before adding or rebinding a visual. It tells you the
table, column, and measure names actually available, rather than the ones you
assume exist.

Then make one change:

```bash
pbir add visual card "Sales.Report/Overview.Page" --title "Revenue" -d "Values:Sales.Revenue"
```

And check it:

```bash
pbir validate "Sales.Report"
```

---

## Command groups

| Group | Commands | Use for |
|---|---|---|
| Browse and query | `ls`, `tree`, `find`, `cat`, `get`, `model` | Understanding a report before editing it |
| Create and duplicate | `new`, `add`, `cp`, `mv` | Reports, pages, visuals; duplicating existing objects |
| Modify and format | `set`, `rm`, `visuals`, `pages` | Formatting, layout, visibility, object state |
| Data and state | `fields`, `filters`, `dax`, `bookmarks`, `annotations` | Bindings, filters, measures, bookmarks, metadata |
| Theme and schema | `theme`, `schema` | Applying defaults at scale; discovering valid property names |
| Operations | `validate`, `backup`, `restore`, `download`, `publish`, `open` | Protecting, verifying, moving, shipping |
| Config | `config` | CLI behaviour |
| Report-wide | `report` | Rename, rebind, convert, merge, split |
| Desktop bridge | Desktop refresh and page screenshots | Live verification against Desktop |

---

## Bulk formatting

This is the clearest win, and also the highest-risk category:

```bash
pbir set "Sales.Report/**/*.Visual.title.fontSize" --value 14 -f
```

A glob path with `-f` applies the change across every match. The `-f` flag is
the destructive-operation marker — it is deliberately required, so a broad
change cannot happen by accident.

Discover valid property names before writing them:

```bash
pbir schema "Sales.Report"
```

---

## Publish

```bash
pbir publish "Workspace.Workspace/Sales.Report"
```

`publish` is a higher-risk workflow. Validate and back up first.

---

## Safety

The authors' recommended habit, and a good one:

```bash
pbir tree "Sales.Report" -v
pbir backup "Sales.Report" -m "Before edits"
# ... make changes ...
pbir validate "Sales.Report"
pbir restore "Sales.Report"    # if it went wrong
```

Rules that follow from that:

- Take a **manual** copy of the report folder before first use. `pbir backup`
  is not a substitute for a copy you control.
- Run `pbir validate` after every mutation, not just at the end.
- Use `-f` only when you mean bulk or destructive.
- Treat `publish`, `convert`, `merge`, and `split` as higher-risk. Commit to
  Git before running them.

The tool is provided as-is, with no warranty. You are responsible for backups
before bulk operations, format conversion, merge, and publish.

---

## Driving it from an agent

Give the agent the report folder as its working directory — it needs to be in
the right place to find reports.

```bash
cd "path/to/my/reports"
```

Then, in Claude Code or GitHub Copilot:

```text
"List all reports and show me the structure of Sales.Report"
"Add a card visual showing Revenue to the Overview page"
"Set all title font sizes to 14 across the report"
"Add a TopN filter for the top 10 customers by revenue"
"Validate the report and fix any issues"
```

The agent discovers properties, binds fields, and formats visuals through the
CLI. It discovers the valid property names itself, so it does not need to know
the schema in advance.

**Always ask it to validate afterwards.** A PBIR change that parses is not
necessarily a change that renders correctly.

---

## The end-to-end agentic loop

Combining the pieces covered elsewhere in this hub:

```
1. MCP server        → ensure the semantic model has the tables, columns,
                       and measures the report needs
2. Report skill      → edit PBIR files for pages, visuals, formatting
3. pbir validate     → catch structural problems
4. Desktop Bridge    → reload Desktop, capture a screenshot
5. Human review      → look at the screenshot
```

Step 5 is the point. The earlier steps exist to make step 5 fast.

---

## Known limitations

- **Beta.** Schemas and behaviour may change.
- Bulk formatting, conversion, merge, and publish carry real corruption risk
  on a malformed report.
- Agent-driven use assumes the agent validates; unchecked bulk edits are the
  most likely way to end up with a broken report.

---

## Related

- [PBIR format](../../Documentation/UserGuides/PBIR.md) — what the CLI is editing
- [Agent Skills](../AgentSkills/README.md) — the marketplace that provides the `pbir-cli` skill
- [MCP Servers](../../Integrations/MCP/README.md)
- [Hooks](../Hooks/README.md) — the same validation as a CI gate
- [Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md) — committing what `pbir` changes
