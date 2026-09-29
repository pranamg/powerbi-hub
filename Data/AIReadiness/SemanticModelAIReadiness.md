---
title: "Semantic Model AI Readiness"
tags: [copilot, ai, modeling]
audience: [model-author]
difficulty: intermediate
last_verified: 2026-09-29
---

# Semantic Model AI Readiness

The model-side work of making a semantic model usable by Copilot and Fabric
data agents.

> This is the shorter, task-focused companion to
> [Preparing a Semantic Model for AI](./PrepForAI.md), which covers the
> configuration features in full (AI data schema, verified answers, indexing,
> Approved for Copilot). This page is about the *work* — what to fix, in what
> order, and how to know you are done.

---

## The core finding

Poor data agent performance usually comes from a **poorly designed semantic
model**, an **inefficient DAX measure**, or a mix of the two — not from a weak
prompt. When a data agent answers badly, audit the model before you rewrite
the instructions.

The reason is mechanical: to answer a question, the agent generates a DAX query
and runs it against your model. A badly-shaped model produces a bad query no
matter how well the question is understood, and no matter how clear your
instructions are.

---

## Readiness checklist

Work in this order. Each step makes the ones after it meaningful.

### 1. Model shape

- [ ] Star schema — dimensions filter, facts summarise
- [ ] Relationships active with the correct cardinality
- [ ] No unnecessary bidirectional filtering
- [ ] A marked date table
- [ ] No high-cardinality columns the AI has no business reasoning about
- [ ] No report-only helper columns or legacy measures in the AI data schema

### 2. Performance

- [ ] No full-column scans in hot measures
- [ ] Storage-engine queries where the work is aggregable
- [ ] Measures do not iterate unnecessarily
- [ ] Column data types are correct (`Int64` and `date`, not `number` and
      `datetime`)

Run the **Best Practice Analyzer** and the **Semantic Model Memory Analyzer**
(in a Fabric notebook) to surface incorrect types, unnecessary columns, and
inefficient DAX. Fix what they find before touching configuration.

### 3. Descriptions

- [ ] Every table, column, and measure in the AI data schema has a description
- [ ] Descriptions state **business meaning and logic**, not DAX syntax
- [ ] Ambiguous column names are disambiguated (`Amt` → `Net revenue after
      returns and discounts`)

This is the single highest-leverage item. An LLM cannot infer that a short
column name means something specific.

### 4. AI data schema

- [ ] Legacy and audit tables removed
- [ ] Retired measures removed
- [ ] Only what an agent genuinely needs to answer business questions remains

Every object in the schema is context the LLM must consider. A smaller, cleaner
schema produces better answers.

### 5. AI instructions

- [ ] Business terminology defined
- [ ] Analysis defaults stated (default year type, default currency, default measure)
- [ ] Data quality caveats recorded
- [ ] Instructions placed in **Prep for AI**, not in the data agent — see below
- [ ] Tested with real questions after each change

### 6. Validate

- [ ] Tested with representative real questions
- [ ] HCAAT used to diagnose wrong answers
- [ ] Model marked **Approved for Copilot**

---

## Where instructions belong

This is the detail most often gotten wrong.

When a data agent queries a semantic model, the DAX generation tool relies
**only** on the semantic model's metadata and its Prep for AI configuration.
**Data agent-level instructions are not passed to that tool and are ignored**
for semantic model questions.

So: semantic model guidance goes in **Prep for AI → AI instructions**. Data
agent instructions configure the agent's behaviour in other ways; they do not
influence semantic model query generation.

---

## The validation loop

1. **Test before you write instructions.** Establish the baseline. Without
   this you cannot tell whether an instruction helped.
2. **Ask the question a user would actually ask.** Not "query the sales table"
   but "why did revenue drop last quarter".
3. **When the answer is wrong, use HCAAT** — *How Copilot arrived at that*. It
   shows which columns and filters the AI used, which tells you which part of
   the model misled it.
4. **Change one thing.** Schema, descriptions, or instructions — not all three.
5. **Re-test the same question.** Instructions interact; a change that fixes
   one question can break another.

### A DAX-inspection step

Because the agent generates DAX, inspecting the query it produced is the most
direct feedback available. A Fabric notebook can capture and examine it. Where
the generated DAX is wrong, the answer is that the model did not give the
agent enough to be right — not that the agent reasoned badly.

---

## Doing this with an agent

The `semantic-model-authoring` skill has a dedicated workflow for this. See
[Agent Skills](../../AgenticDevelopment/AgentSkills/README.md).

```text
/semantic-model-authoring Connect to Power BI Desktop and prepare the semantic model for AI
```

It inventories the model, evaluates it against the readiness checklist, and
presents findings **grouped by severity and tagged as either
agent-applicable or user-action-required**. You approve which fixes to apply,
then test representative prompts.

The approve-then-apply step matters: the agent proposes, a human decides. That
is the right division of labour for a change this broad.

---

## What "ready" means

A model is ready when:

- A data agent answers common business questions correctly without you
  rephrasing
- You can point at why it answered what it did (HCAAT gives you this)
- Adding a new question does not require adding instructions
- The schema stays small enough that the agent picks the right measure

If every question needs a new instruction, the model is not ready — the
instructions are compensating for a modelling problem.

---

## Related

- [Preparing a Semantic Model for AI](./PrepForAI.md) — the configuration features
- [DAX Best Practices](../../Queries/DAX/BestPractices/README.md)
- [Performance Tuning](../../Optimization/PerformanceTuning/README.md)
- [Memory Optimization](../../Optimization/MemoryOptimization/README.md)
- [Development Standards](../../Governance/DevelopmentStandards.md)
- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md)
