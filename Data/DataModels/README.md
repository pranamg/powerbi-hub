# Data Models

> Starter and example semantic model structures.

## Folders

| Folder | Description |
|--------|-------------|
| [Model1/](./Model1/README.md) | Minimal star schema: one fact table, three dimensions, calculated date table |
| [Model2/](./Model2/README.md) | Two fact tables at different grains, role-playing dates, calculation groups |
| [Templates/](./Templates/README.md) | Model scaffolding to copy for new work |

## Where to start

Read [Model 1](./Model1/) first. It is a complete, readable star schema and
doubles as a review checklist for a real model. [Model 2](./Model2/) then adds
the complications that appear in most production models: a second fact table
at a different grain, a date dimension playing two roles, and calculation
groups.

Both are written in TMDL, the format used by
[TMDL templates](../../Scripts/TMDL/). Each is a structural example: the
date tables are calculated and need no source, while the dimension and fact
partitions use placeholder paths that must be replaced before the model will
load.
