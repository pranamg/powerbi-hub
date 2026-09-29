---
title: "AI Readiness"
tags: [copilot, ai, modeling]
audience: [model-author]
difficulty: beginner
last_verified: 2026-09-29
---

# AI Readiness

Making a semantic model usable by Copilot and Fabric data agents.

An LLM does not read your model. It reads its **metadata** — names,
descriptions, and the configuration you set in *Prep data for AI*. An
undocumented model produces an ungrounded answer, and the failure looks like a
Copilot bug rather than a metadata gap.

## Documents

| Document | Covers |
|---|---|
| [Semantic Model AI Readiness](./SemanticModelAIReadiness.md) | **The work** — a readiness checklist in dependency order, and how to validate |
| [Preparing a Semantic Model for AI](./PrepForAI.md) | **The features** — AI data schema, AI instructions, verified answers, indexing, Approved for Copilot |

Start with the readiness checklist. It tells you whether configuration will
help at all, and in most cases the answer is that the model needs fixing first.

## The short version

Follow this order. Skipping ahead wastes effort — instructions written against
a badly-shaped model describe the wrong thing.

1. **Fix the model.** Star schema, correct types, no high-cardinality columns,
   no scanning measures. No amount of AI configuration compensates for a slow
   or badly-shaped model.
2. **Write descriptions** in plain business language. This is the
   single highest-leverage change.
3. **Narrow the AI data schema.** Every object is context the LLM must weigh.
4. **Write AI instructions** — few, focused, unambiguous. Prompt engineering
   applies.
5. **Set up verified answers** for questions users ask constantly and get
   subtly wrong.
6. **Validate** with real questions, using HCAAT to diagnose wrong answers.
7. **Approve for Copilot** once it is genuinely ready.

## The one thing people get wrong

When a data agent queries a semantic model, its DAX generation relies **only**
on the model's metadata and Prep for AI configuration. **Data agent-level
instructions are ignored** for semantic model questions.

Put semantic model guidance in **Prep for AI → AI instructions**, not in the
data agent's own instruction field.

## Why the model is the variable

A data agent answers by generating DAX and running it. A badly-shaped model
produces a bad query no matter how well the question is understood. So when
answers are wrong, audit the model before rewriting instructions — the common
cause is a modelling problem presenting as a prompt problem.

## Related

- [Copilot in Power BI](../../Documentation/UserGuides/Copilot.md) — what Copilot does
- [Agent Skills](../../AgenticDevelopment/AgentSkills/README.md) — the
  `semantic-model-authoring` skill runs this as a workflow
- [Governance](../../Governance/README.md) — approving a model for AI is a
  governance event
- [DAX Best Practices](../../Queries/DAX/BestPractices/README.md)
