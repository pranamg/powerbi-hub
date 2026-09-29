---
title: Azure Automation
tags: [automation, devops]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# Azure Automation

> Runbooks for Azure Automation.

## Status

This folder is a stub. No content has been written yet.

## When to use this rather than PowerShell

Azure Automation suits **scheduled, unattended, long-running** work tied to
Azure resources — runbooks that are triggered by a schedule or a webhook and
run in the cloud. For local and CI automation, the
[PowerShell scripts](../PowerShell/) are usually simpler and easier to test.

## What would belong here

- Runbooks for tenant or capacity maintenance.
- Scheduled export and distribution jobs.
- Alert-handling automation.

## Related

- [PowerShell](../PowerShell/) · [C#](../CSharp/)
- [Deployment pipelines](../../Deployment/Pipelines/)
- [Monitoring](../../Monitoring/)
