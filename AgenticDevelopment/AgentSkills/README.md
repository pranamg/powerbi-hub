---
title: "Agent Skills and Plugin Marketplaces"
tags: [agentic, ai, tooling]
audience: [developer]
difficulty: intermediate
last_verified: 2026-09-29
---

# Agent Skills and Plugin Marketplaces

An **agent skill** is a folder of instructions, scripts, and references that an
AI coding agent loads to learn how to do a specific kind of work. A **plugin**
bundles skills, subagents, hooks, and MCP servers. A **marketplace** is a
registry that hosts plugins.

This distinction matters because the two ecosystems below work differently and
have different stability guarantees.

```
MCP server  → the TOOLS an agent can call (edit a model, run DAX)
Skill       → the GUIDANCE for using those tools well
Plugin      → skills + subagents + hooks + MCP servers, bundled
Marketplace → a registry of plugins you install from
```

Tools alone do not make an agent good at Power BI. The tools are the *what*;
the skills are the *how* — modeling practice, change sequencing, and what a
well-built model looks like.

---

## Two ecosystems

| | Microsoft `powerbi-authoring` | Data Goblins marketplace |
|---|---|---|
| Source | [microsoft/skills-for-fabric](https://github.com/microsoft/skills-for-fabric) | [data-goblin/power-bi-agentic-development](https://github.com/data-goblin/power-bi-agentic-development) |
| Scope | Power BI authoring only | Power BI **and** Fabric, plus Tabular Editor, ETL, custom visuals |
| Skills | 4 | 30+ across 11 plugins |
| Subagents | No | Yes (auditors, reviewers) |
| Hooks | No | Yes (PBIR, TMDL, DAX reference validation) |
| Release cadence | Tied to Microsoft | **Weekly** — see the warning below |
| Best for | The supported path | Breadth, and enforcing quality gates in CI |

**Start with Microsoft's.** It is first-party, narrower, and matches what
Microsoft documents. Add the Data Goblins marketplace when you need something
Microsoft does not cover — Fabric CLI, Tabular Editor scripting, Deneb/R/Python
visual authoring, or a reviewer agent that catches bad SVG before you ship it.

---

## Microsoft's `powerbi-authoring` plugin

### Install

Requires [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli)
and Node.js 18 or later.

```bash
copilot plugin marketplace add microsoft/skills-for-fabric
copilot plugin install powerbi-authoring@fabric-collection
```

Installing the plugin does two things: it makes the skills available, and it
registers the Power BI Authoring MCP server. See
[MCP Servers](../../Integrations/MCP/README.md).

### Verify

```bash
/skills
```

Expect these four:

| Skill | Use it for |
|---|---|
| `semantic-model-authoring` | Tables, columns, measures, DAX, Import/DirectQuery/Direct Lake, deployment, refresh, permissions, DAX optimization |
| `power-bi-report-authoring` | Pages, visuals, filters, slicers, formatting, themes — the PBIR file mechanics |
| `power-bi-report-planner` | Guided workflow: requirements → plan → build from an existing semantic model |
| `power-bi-report-design` | Produces a structured design brief before any PBIR editing happens |

Invoke a skill explicitly with a slash command when you want to be sure it
loads — progressive disclosure means the agent may not select it
automatically:

```text
/semantic-model-authoring Connect to Power BI Desktop and analyze the semantic model against best practices
```

That smoke test should load the skill, connect through MCP, inventory the
model, and report findings grouped by severity. If the agent asks you to
register the MCP server instead, the plugin did not install correctly.

### The three report skills are a sequence, not a menu

```
planner  →  design  →  authoring
   (what)     (how it should look)   (build it)
```

Planner for greenfield work. Design when critiquing or restructuring an
existing report. Authoring once the decisions are made. All three ship in the
same plugin and are designed to be installed together.

### Worked example: prepare a model for AI

```text
/semantic-model-authoring Connect to Power BI Desktop and prepare the semantic model for AI
```

This routes to the skill's *Semantic Model AI Readiness* workflow. The agent
inventories the model, evaluates it against a readiness checklist, and
presents findings **grouped by severity and tagged as either
agent-applicable or user-action-required**. You approve which fixes to apply.

That approve-then-apply step is the design point. The agent proposes; a human
decides.

---

## Data Goblins marketplace

By Kurt Buhler (Data Goblins / Tabular Editor), who wrote the agentic
development material this hub's [Agentic Development](../README.md) is based
on.

> **Read this before installing.** The marketplace ships on a **weekly release
> cadence**, and the maintainers state that versions **26.26 through 26.38
> are a deliberate breaking transition** — skills may be consolidated, renamed,
> or removed within that range. If you need a stable skill structure, **pin
> 26.25 or earlier**. Do not assume compatibility from one transition release
> to the next.

### Install (Claude Code)

```bash
claude plugin marketplace add data-goblin/power-bi-agentic-development
claude plugin install reports@power-bi-agentic-development
claude plugin install semantic-models@power-bi-agentic-development
```

Or install interactively with `/plugin`.

### Install (GitHub Copilot CLI)

```bash
copilot plugin marketplace add data-goblin/power-bi-agentic-development
copilot plugin install pbip@power-bi-agentic-development
```

Two caveats for Copilot CLI specifically:

- **Plugin scope is user-wide.** Plugins install to `~/.copilot/installed-plugins/`
  and their hooks run in **every session on the machine**. There is no
  per-project install. Install a plugin only while you need it.
- **Windows long paths.** TMDL paths exceed 260 characters, and `git clone`
  fails with `Filename too long` unless long path support is enabled at both
  the OS and git level:

  ```powershell
  git config --system core.longpaths true
  ```

  The OS-level registry change additionally needs a reboot.

### Verify (Copilot CLI)

```text
/env              # loaded instructions, MCP servers, skills, agents, plugins
/plugin list      # installed plugins
/skills list      # available skills
/skills info pbip # detail for one skill
```

### Plugin inventory

| Plugin | Covers |
|---|---|
| `goblin-mode` | Onboarding and auditing your whole agent setup |
| `tabular-editor` | BPA rules, C# scripting, Tabular Editor CLI (`te`, TE2) |
| `pbi-desktop` | Connect to, query, and modify models in Desktop; Desktop Bridge reload and screenshot |
| `pbip` | **PBIP, TMDL, and PBIR authoring**, plus a `pbip-validator` subagent and three validation hooks |
| `semantic-models` | DAX, Power Query, naming, lineage, refresh, and a `semantic-model-auditor` subagent |
| `reports` | Building and reviewing reports via the `pbir` CLI, theme work, design canon |
| `paginated-reports` | RDL authoring and validation |
| `custom-visuals` | Deneb, R, Python, SVG, and `.pbiviz` development |
| `fabric-cli` | Fabric CLI (`fab`) — works on Pro and PPU, no Fabric capacity needed |
| `fabric-admin` | Tenant settings audits and delegated overrides |
| `etl` | Spark execution and DuckDB against lakehouse data |

### Why the hooks are the interesting part

Hooks are **deterministic** — they fire on a matched pattern, not on LLM
judgment. That makes them a genuine quality gate rather than a suggestion.
The `pbip` plugin validates PBIR structure, TMDL syntax, and report binding
after every write. The `pbi-desktop` plugin validates DAX references against
the connected model and blocks adding a measure without a description, display
folder, and format string.

Individual checks are togglable in each plugin's `hooks/config.yaml`.

> Install what you need, not everything. Each skill competes for the agent's
> attention and context window. Prefer project scope in Claude Code, and
> install-and-remove in Copilot CLI where scope is user-wide.

---

## Which skills for which job

| Task | Skill |
|---|---|
| Add measures, refactor DAX | `semantic-model-authoring` (Microsoft) or `semantic-models` (Goblins) |
| Audit a model | `semantic-model-authoring` or `semantic-model-auditor` |
| Prepare a model for Copilot | `semantic-model-authoring` → *AI Readiness* workflow |
| Author PBIR pages and visuals | `power-bi-report-authoring` (Microsoft) or `reports`/`pbir` (Goblins) |
| Plan a new report | `power-bi-report-planner` |
| Write a BPA rule | `tabular-editor` → `bpa-rules` |
| Fabric workspace operations | `fabric-cli` |
| Review an SVG measure | `svg-reviewer` (Goblins) |
| Enforce a rule on every save | `pbip` or `pbi-desktop` hooks (Goblins) |

---

## A caution on over-installing

Two failure modes, both common:

1. **Too many skills.** Every installed skill is loaded into context or
   competes for selection. A cluttered agent picks the wrong one more often
   and runs slower.
2. **Skills that contradict each other.** Two skills giving different advice
   on the same operation produce non-deterministic behaviour. Pick one per
   domain.

This is also why Microsoft's plugin ships only four skills. Restraint is a
feature.

---

## Related

- [MCP Servers](../../Integrations/MCP/README.md) — the tools these skills drive
- [Agentic Development](../README.md) — when agentic work is appropriate at all
- [Workflows](../Workflows/README.md) — Direct TMDL, MCP, and CLI patterns
- [Custom Commands](../CustomCommands/README.md) — Tabular Editor CLI automation
- [Hooks](../Hooks/README.md) — deterministic quality gates in CI
- [Prompt Library](../../PromptLibrary/README.md) — prompts to use without any of this
