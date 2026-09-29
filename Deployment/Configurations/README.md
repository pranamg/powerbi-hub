---
title: Configurations
tags: [deployment, ci-cd]
audience: [developer]
difficulty: advanced
last_verified: 2026-09-29
---

# Configurations

> Deployment configuration files.

## What belongs here

Configuration that describes *how* something is deployed rather than *what* is
deployed: pipeline definitions, deployment parameters, and settings shared
across environments.

## Keeping configuration out of content

Environment-specific values — workspace names, connection strings, URLs —
belong in parameters, not in the report or model definition. This is what lets
the same artefact be promoted from development to production unchanged. See
[Environments](../Environments/).

## Sensitive values

Never commit credentials, connection strings with passwords, or tokens. Use
pipeline secrets or environment variables, and keep a `.template` file in the
repository for anything that needs a per-developer copy.

## Related

- [Environments](../Environments/)
- [Pipelines](../Pipelines/)
- [Deployment folder overview](../)
