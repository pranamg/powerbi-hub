---
title: "Preparing a Semantic Model for AI"
tags: [copilot, ai, modeling, governance]
audience: [model-author]
difficulty: intermediate
last_verified: 2026-09-29
---

# Preparing a Semantic Model for AI

Copilot and Fabric data agents do not read your model. They read its
**metadata** — names, descriptions, and the configuration you set in *Prep
data for AI*. An undocumented model produces an ungrounded answer, and the
failure looks like a Copilot bug rather than a metadata gap.

This page is about making the model legible to an LLM.

> **Status.** These features are in preview and the surface is changing.
> Verify current behaviour against
> [Microsoft Learn](https://learn.microsoft.com/en-us/power-bi/create-reports/copilot-prepare-data-ai)
> — in particular, names have already shifted once: the model setting
> previously called *prepped for AI* is now **Approved for Copilot**.

---

## The four configuration components

Reached from the **Home** ribbon in Desktop, or the semantic model page in the
service, under **Prep data for AI**:

| Component | Tab | What it does |
|-----------|-----|--------------|
| **AI data schema** | Simplify data schema | Chooses which tables, columns, and measures the AI may use |
| **AI instructions** | Add AI instructions | Business context, terminology, and analysis guidance |
| **Verified answers** | (per report page) | Pinned, trusted answers for known questions |
| **Indexing** | Settings | Whether metadata and values are indexed for retrieval |

Plus one model-level flag: **Approved for Copilot**, which marks the model as
ready for consumption.

Two prerequisites: the model must be in a **Copilot-enabled workspace**, and
**Power BI Q&A must be enabled** for the model — without Q&A, the Prep dialog's
tabs are disabled.

---

## Order of work

Follow this order. Each step makes the next one meaningful, and skipping ahead
wastes effort — instructions written against a badly-shaped model describe
the wrong thing.

### 1. Fix the model

No amount of AI configuration compensates for a slow or badly-shaped model.
When a data agent answers badly, the first suspect is the model, not the
prompt.

- Star schema, active relationships, no unnecessary bidirectional filters
- Marked date table, correctly typed columns
- Measures that are not doing full-column scans
- **No high-cardinality columns** the AI has no business reasoning about

Use the **Best Practice Analyzer** and the **Semantic Model Memory Analyzer**
(available in a Fabric notebook) to find incorrect data types, unnecessary
columns, high-cardinality columns, and inefficient DAX.

### 2. Write descriptions

Descriptions are the single highest-leverage change. An LLM has no way to
infer that `Amt` means net revenue after returns and discounts.

Document every table, column, and measure in **plain business language**:

| Instead of | Write |
|------------|-------|
| `Amt` | `Net revenue after returns, discounts, and credits. Excludes tax.` |
| (no description) | `Total orders that shipped. Counts rows, not distinct customers.` |
| `CY` | `Calendar year of the transaction date, not the ship date.` |

Describe the **business meaning and the logic**, not the DAX syntax. The model
already has the expression.

### 3. Narrow the AI data schema

Every object in the schema is context the LLM must consider. A model with 200
tables and 600 measures gets worse answers than one with 40 tables and 80
measures.

Remove from the AI data schema:

- Report-only helper columns
- Legacy measures kept for a retired report
- Audit and technical tables
- ID columns with no analytical value

This is the highest-leverage change after descriptions, and the one most often
skipped.

### 4. Write AI instructions

AI instructions are **prompt-based**, so prompt engineering applies. They are
unstructured guidance the LLM interprets — there is no guarantee it follows
them, so clear and specific beats long and comprehensive.

Structure that works:

```
## Product metrics
- "Revenue" always means net revenue after returns.
- Use Sales Amount, never Gross Amount, unless the user says gross.

## Analysis defaults
- Default to calendar year unless a fiscal calendar is requested.
- Show currency in GBP; the model stores GBP.

## Data quality
- Region excludes the 'Unknown' category. Flag it when material.
```

Rules learned the hard way:

- **Fewer, focused instructions beat many broad ones.** Conflicts and
  complexity confuse the model.
- State what to prefer, not only what to avoid.
- Do not restate the schema — the model already has it.
- Users cannot see these instructions, so they are safe to be blunt.
- Test after every change; a previously-good answer can break.

### 5. Set up verified answers

For questions you know the right answer to, pin it. A verified answer attaches
a trigger phrase to a specific visual, so the same question always returns the
same grounded result.

Use them for the questions users ask constantly and get subtly wrong. Do not
use them to paper over a model problem — the next question will still fail.

### 6. Check indexing

Copilot indexing makes metadata and column values retrievable, improving both
speed and accuracy. It is enabled automatically after migrating to the new
Copilot file format.

In Desktop there is an additional **Local Desktop Indexing** setting, editable
per machine, which lets Desktop index external sources (DirectQuery, live
connection) locally.

### 7. Approve and validate

Set **Approved for Copilot** once the model is genuinely ready. It takes a few
minutes to take effect.

Then validate with representative questions:

- In Desktop, the Copilot report pane. Refresh the pane by closing and
  reopening it after each change.
- **HCAAT** — *How Copilot arrived at that* — shows the columns and filters
  behind an answer. When an answer is wrong, HCAAT is how you find out which
  part of the model misled it.

---

## Data agents: where instructions belong

This trips people up, so it is worth stating plainly.

When a data agent queries a semantic model, the DAX generation tool relies
**only** on the semantic model's metadata and its Prep for AI configuration.
**Data agent-level instructions are not passed to that tool and are ignored**
for semantic model questions.

So: put semantic-model guidance in **Prep for AI → AI instructions**, not in
the data agent's own instruction field. Data agent instructions configure the
agent's behaviour in other ways; they do not inform semantic model query
generation.

---

## When answers are still wrong

Work outward from the model:

| Symptom | Likely cause |
|---|---|
| Wrong measure chosen | Two measures plausibly match; disambiguate in AI instructions |
| Wrong column used | Missing or ambiguous description |
| Ignores a business rule | Instruction not specific enough, or conflicts with another |
| Answer ignores a filter | Filter not expressed in the model, or RLS/OLS interfering |
| Sluggish or truncated | Schema too large; narrow the AI data schema |
| Right answer, wrong visual | Not a model problem — the report layer |

If it persists after all of the above, review the questions users actually ask
with them, and simplify the model where it is doing too much.

---

## Security and governance

Prep data for AI changes what the AI can see and say.

- **AI data schema is a control, not a convenience.** Objects you remove are
  invisible to Copilot. Treat removal as an access decision.
- **Verified answers are user-visible** in a published report. Do not pin an
  answer that reveals data the viewer should not see.
- **RLS still applies** to Copilot's answers — the AI does not bypass security.
  Confirm this holds for your configuration rather than assuming it.
- Approving a model for Copilot is a governance event. Record who approved it
  and when. See [Data Classification](../../Governance/DataClassification.md)
  and [Development Standards](../../Governance/DevelopmentStandards.md).
- Model metadata and query results flow to the LLM provider your tenant is
  configured to use. Confirm that against your data-handling policy.

---

## Related

- [Copilot in Power BI](../../Documentation/UserGuides/Copilot.md) — what Copilot does and does not do
- [DAX Best Practices](../../Queries/DAX/BestPractices/README.md) — step 1
- [Development Standards](../../Governance/DevelopmentStandards.md)
- [RLS Patterns](../../Governance/RLSPatterns.md)
- [Data Classification](../../Governance/DataClassification.md)
- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) — the
  `semantic-model-authoring` skill runs this as its *AI Readiness* workflow
