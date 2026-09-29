---
title: "Power BI Enhanced Report Format (PBIR)"
tags: [pbir, pbip, reports, tmdl]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# Power BI Enhanced Report Format (PBIR)

PBIR is the report half of [PBIP](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview)
(Power BI Project). The model half is [TMDL](https://learn.microsoft.com/en-us/analysis-services/tmdl/tmdl-overview);
PBIR is its counterpart on the report side.

PBIR replaces the single monolithic `report.json` with a folder of small JSON
files — one per page, one per visual. That is what makes report-level source
control, code review, and agentic authoring practical.

> **Status: preview.** PBIR is a Power BI Desktop preview feature. It is
> scheduled to become the default report format at GA, but that rollout has
> been **paused** since it was announced — see
> [PBIR rollout status](#pbir-rollout-status) below.

---

## The problem PBIR solves

| | PBIR-Legacy (`report.json`) | PBIR (`definition/` folder) |
|---|---|---|
| Structure | One file, entire report | One file per page, per visual, per bookmark |
| Merge conflicts | Whole-file — any two people editing different visuals conflict | Line-level — different visuals rarely overlap |
| Review | A 5 MB diff nobody reads | A 40-line diff for one visual's formatting |
| Editing outside Power BI | Unsupported | Public JSON schemas, editor-validated |
| Git | Practically unusable | Designed for it |

The last row is the point. Code-development-friendly formats are what unblock
"co-development", which is what makes report work reviewable.

---

## Folder structure

A PBIP project with both a semantic model and a report:

```
PBIPFolder/
├── [Name].pbip                  # Shortcut file, optional but conventional
├── [Name].SemanticModel/
│   ├── definition/              # TMDL — the model, REQUIRED
│   ├── definition.pbism         # Model definition file, REQUIRED
│   └── ...
└── [Name].Report/
    ├── definition/              # PBIR — REQUIRED when using PBIR
    ├── definition.pbir          # Report definition, REQUIRED
    ├── StaticResources/         # Themes, images, custom visuals (optional)
    ├── .platform                # Fabric system file
    └── ...
```

A report-only project (live connection) omits the `.SemanticModel/` folder and
uses a `byConnection` reference in `definition.pbir`.

### Inside `definition/`

```
definition/
├── version.json                 # Content version, REQUIRED
├── report.json                  # Report-level properties, REQUIRED
├── pages/
│   ├── pages.json
│   └── [pageName]/
│       ├── page.json
│       └── visuals/
│           └── [visualName]/
│               ├── visual.json  # REQUIRED if the visual folder exists
│               └── mobile.json  # Optional mobile layout
└── bookmarks/
    ├── bookmarks.json
    └── [bookmarkName].bookmark.json
```

| File | Required | Purpose |
|------|:--------:|---------|
| `version.json` | Yes | Schema content version — `"2.0.0"` for current Desktop |
| `report.json` | Yes | Report-level settings (not the PBIR-Legacy file) |
| `pages/pages.json` | Yes | List of pages |
| `pages/[page]/page.json` | Yes, per page | Page-level properties |
| `pages/[page]/visuals/[visual]/visual.json` | Yes, per visual | The visual definition and its bindings |
| `pages/[page]/visuals/[visual]/mobile.json` | No | Mobile position and formatting |
| `bookmarks/bookmarks.json` | No | List of bookmarks |

**The `report.json` name is reused.** Inside `definition/` it is a small
report-level file. The PBIR-Legacy monolith is a *different* `report.json` at
the report-folder root. The two are mutually exclusive — a report uses one
format or the other, never both.

---

## `definition.pbir` and the version matrix

`definition.pbir` is the report's entry point. It also holds the reference to
the semantic model, which is how you rebind a report to a different model.

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/pbip/pbipProperties/1.0.0/schema.json",
  "version": "1.0",
  "artifacts": [
    {
      "report": {
        "path": "MyModel.Report"
      }
    }
  ],
  "settings": {
    "enableAutoRecovery": true
  }
}
```

> In the `artifacts` array, only `report` is valid. Do not add `dataset` or a
> top-level `name` — the schema sets `additionalProperties: false` and will
> reject it.

### Version matrix

| `definition.pbir` version | Report format |
|---|---|
| `1.0` | Must be PBIR-Legacy (`report.json` at the report root) |
| `4.0` or higher | Either PBIR-Legacy **or** PBIR (`definition/` folder) |

### Local model versus Fabric model

Two different reference styles, chosen by `datasetReference`:

**`byPath`** — the model is a sibling folder in the same project. This is the
normal case for a project that owns its model:

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json",
  "version": "4.0",
  "datasetReference": {
    "byPath": {
      "path": "../MyModel.SemanticModel"
    }
  }
}
```

**`byConnection`** — the model lives in a Fabric workspace. Used by report-only
projects:

```json
{
  "datasetReference": {
    "byConnection": {
      "workspaceId": "<workspace-guid>",
      "semanticModelId": "<model-guid>"
    }
  }
}
```

For `byPath`, use forward slashes and relative paths only. Absolute paths do
not survive a clone.

---

## JSON schemas and editor validation

Every PBIR file has a published JSON schema in
[microsoft/json-schemas](https://github.com/microsoft/json-schemas). Point your
editor at the `$schema` property and it validates as you type — the same thing
Power BI Desktop does on open.

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.7.0/schema.json",
  ...
}
```

This is what makes hand-editing safe, and what the `pbip` plugin's PBIR
validation hook checks in CI. See [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md).

---

## Enabling PBIR

PBIR is a Desktop preview feature. You can only create or convert a project
using Power BI Desktop — there is no command-line route.

1. Power BI Desktop → **File → Options and settings → Options → Preview features**
2. Tick **Store reports using enhanced metadata format (PBIR)**
3. Save the project. The report is written into `definition/` instead of `report.json`.

For PBIX files specifically, the option is labelled **Store PBIR reports using
enhanced metadata format (PBIR)**, which makes PBIR also apply inside `.pbix`
files rather than only in PBIP projects.

Converting an existing report: save the project with the preview enabled and
Desktop rewrites the report into the PBIR structure.

---

## PBIR rollout status

This is worth understanding, because it is a common source of wrong advice.

Microsoft announced in January 2026 that PBIR would become the default report
format, starting in the service. **That rollout was paused** because
default-on exposed problems. As of the last verification (2026-09-29), PBIR
remains opt-in.

Two further caveats during preview:

- **Fabric Git Integration and the Fabric REST APIs continue to export
  PBIR-Legacy** (`report.json`) — *unless* the report was imported into Fabric
  using PBIR format. Once a report is in Fabric as PBIR, both export PBIR.
- The PBIR default is still the stated direction of travel at GA.

So: if you are building a pipeline today, check what format your report
actually exports as rather than assuming from the announcement.

---

## Migrating an existing report

1. **Commit it first.** You want a revert point.
2. Enable the PBIR preview in Desktop and save the project.
3. Open the new `definition/` folder — this is your new source of truth.
4. Check the schemas resolve in your editor.
5. Commit the conversion **separately** from any content change, so the diff
   shows "format migration" rather than mixing it with real edits. The first
   commit will be large; that is expected and it is a one-off.
6. After that, review diffs get small again.

If a `byPath` reference breaks after moving folders, check the relative path
and the forward slashes first — those are the usual causes.

---

## Working with PBIR day to day

```bash
# Bulk formatting change with the CLI, then validate
pbir set "Sales.Report/**/*.Visual.title.fontSize" --value 14 -f
pbir validate "Sales.Report"
```

See [pbir-cli](../../AgenticDevelopment/AgentSkills/pbir-cli.md) for the full command set and the
backup/validate/restore loop.

From an agent, the flow is: **Model with MCP → edit PBIR with the report skill
→ `pbir validate` → reload Desktop → screenshot → review.** The last step is
the point; the rest exists to make it fast.

---

## Known limitations

- Preview only; no CLI or API route to create or convert.
- `semanticModelDiagramLayout.json` and `mobileState.json` do not support
  external editing during preview.
- Fabric Git Integration and REST APIs export PBIR-Legacy unless the report
  was imported as PBIR.
- The default-format rollout is paused.
- Schema versions move — a file written for one Desktop version may reference
  a schema URL a newer Desktop rejects. Keep Desktop reasonably current, and
  pin it in CI.

---

## Related

- [pbir-cli](../../AgenticDevelopment/AgentSkills/pbir-cli.md) — command-line access
- [TMDL View](../../Documentation/UserGuides/TMDLView.md) — the model-side equivalent
- [Fabric Git Integration](../../Documentation/UserGuides/FabricGitIntegration.md)
- [Deployment Pipelines](../../Deployment/Pipelines/README.md)
- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) — validation hooks for PBIR
- [PBIP, TMDL & Git learning path](../../Documentation/LearningPaths/README.md#3-pbip-tmdl--git)
