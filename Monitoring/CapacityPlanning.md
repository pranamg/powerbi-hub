---
title: "Capacity Planning and Monitoring"
tags: [monitoring, performance, governance]
audience: [bi-admin]
difficulty: advanced
last_verified: 2026-09-29
---

# Capacity Planning and Monitoring

Sizing a Fabric capacity, and working out whether slowness is your model or your
capacity. The second question comes up far more often than the first, and it
has a short answer that is worth knowing before you optimise anything.

---

## First: is it the model or the capacity?

When a report is slow, the instinct is to rewrite DAX. Check this first.

| Finding | Meaning | Action |
|---|---|---|
| CU utilisation never exceeded 100% | **Not a capacity problem** | Optimise the model. Stop looking at the capacity |
| Utilisation > 100%, no throttling recorded | Utilisation is high but not the cause | Keep looking — likely the model |
| Utilisation > 100% **and** interactive delay or rejection | Throttling | Fix scheduling, scale, or both |

That third row is the one that matters. Throttling is what capacity causes;
high utilisation on its own is not throttling.

> Note the distinction that trips people up: on the Metrics app, **Background
> %** operations such as refreshes are *smoothed* — spread evenly across 24
> hours. Only **interactive** operations are subject to 30-second timepoint
> throttling. A capacity can look busy all day from background work while
> interactive users are entirely unaffected.

---

## The Fabric Capacity Metrics app

Microsoft's own Power BI report for capacity administration. Install it from
the
[Fabric admin portal](https://learn.microsoft.com/en-us/fabric/admin/capacity-settings);
you need admin or contributor access to the capacity.

You see only capacities you administer.

### Health page

The overview. Each capacity gets a state:

| State | Meaning |
|---|---|
| Healthy | No throttling |
| At Risk of Throttling | A 30-second window exceeded 90% over 10 minutes, and overage isn't enabled |
| Throttling | A 30-second window exceeded 100% over 10 minutes |
| At Risk of Interactive Rejection | A 30-second window exceeded 90% over 60 minutes |
| Background Rejection | A 30-second window exceeded 100% over 24 hours |
| Suspended | Capacity is paused |

Also shows average utilisation, throttled-capacity counts over 7 days, and a
cumulative-debt sparkline. Filter by capacity, SKU, or region — one region at a
time.

### Compute page

The main analysis surface.

- **Average and peak utilisation** cards, computed against **base CUs only** —
  autoscale CUs are excluded, so a capacity riding on autoscale looks busier
  than it is billed for
- **Capacity utilisation and throttling** chart, with a linear or logarithmic
  scale
- **Items matrix**, ranking every item by CU consumption — this is how you find
  the actual culprit

> Filter out **paused events** in the visual-level filter pane. They are
> included by default and will otherwise look like real consumption.

### Timepoint and timepoint summary pages

The forensic view. Pick a specific 30-second window and see every interactive
operation that contributed, ranked by CU seconds, plus which operation *types*
were most expensive.

The colour scheme is consistent across these pages:

| Colour | Meaning |
|---|---|
| Green | CU consumption |
| Red | CU consumption limit |
| Yellow | CU consumption that was autoscaled |

**If the yellow line is above the red line, the capacity is overloaded.**

### How the health states are actually computed

Worth knowing, because it explains why a capacity can be flagged as throttled
without anyone noticing:

| Signal | Window | Threshold |
|---|---|---|
| Interactive delay | 30-second window, 10-minute average | > 100% |
| Interactive rejection | 30-second window, 60-minute average | > 100% |
| Background rejection | 30-second window, 24-hour average | > 100% |

CU seconds for a completed operation are attributed to the timepoint in which
it *finished*, not when it started. A long operation that starts at 09:00 and
finishes at 09:30 lands entirely in a 09:30 window.

---

## Diagnosing a slow report

1. **Note the specifics** — workspace, capacity, and the exact time. Without
   these you cannot filter the metrics correctly.
2. Open the Metrics app, **Compute** page, filter to that capacity and date
   range.
3. Check whether **CU % over time** exceeded 100% during the window.
   - It did not → not throttling. Optimise the model instead.
4. If it did, check the **throttling** metrics for interactive delay or
   rejection at that time.
   - Utilisation high but no throttling → not throttling.
5. If throttling, use **Timepoint** to see which operations drove it, and the
   **Items** matrix to see which items.

If the semantic models involved have no log analytics or workspace monitoring
enabled, this capacity-side check is the only evidence available — which is
itself an argument for enabling them. See [Logs](./Logs/README.md).

---

## Responding to throttling

Three strategies, in the order you should try them.

### 1. Optimise

Almost always worth doing first, because it is free.

- Move refreshes out of business hours — refresh is a **background** operation
  and competes for the same CUs
- Fix the models driving the top CU consumers; the Items matrix tells you which
- Remove unused content; an estate that has never been pruned always has
  low-hanging fruit
- Set workload-specific limits, such as a Power BI query timeout or row limit,
  so one runaway report cannot consume the capacity

### 2. Scale up

Increase the SKU, permanently or temporarily. Straightforward and immediate,
and it costs more whether or not you need it.

### 3. Scale out (autoscale)

**Autoscale** adds CU on demand for 24 hours, bounded by a maximum you set. The
CU Limit line rises and the CU card turns yellow.

The trade-off is deliberate:

| | Autoscale enabled | Autoscale off |
|---|---|---|
| Overload | Adds a CU for the next 24 hours, up to your maximum | Throttles **every** interactive operation in that timepoint |
| Beyond the maximum | Throttling applies | Throttling applies |
| Cost | Bursty, only for the hours you spike | Flat |

So autoscale converts *throttling into cost* for genuine peaks, and throttling
is usually the worse outcome. It is the right setting for a capacity with a
predictable daily spike — month-end processing, a Monday-morning dashboard
stampede.

---

## Sizing a capacity

There is no formula. Measure.

1. **Start small.** F SKUs can be resized, paused, and resumed to match
   consumption patterns.
2. **Measure before committing.** Provision trial capacities, or use pay-as-you-go
   F SKUs, to see what you actually need.
3. **Look at the shape, not just the peak.** A 10-minute spike needs a
   different SKU than a sustained load. The Heartbeat line chart in the
   Timepoint page shows peak duration.
4. **Budget for autoscale** if you enable it, or for the throttling you accept
   if you don't.

Watch the weekly and monthly patterns as well as the daily ones — month-end and
quarter-end behave nothing like a Tuesday.

---

## Workspace-level contention

On a shared capacity, one workspace can crowd out another. The
[job concurrency and queuing](https://learn.microsoft.com/en-us/fabric/data-engineering/job-concurrency-queue-monitoring)
views show the **maximum CUs used by each workspace** and how usage trends over
24 hours, 7 days, and 30 days — which is how you tell a one-off spike from a
recurring pipeline collision.

The fixes:

- Set **workspace-level pool limits** so one workspace cannot starve the others
- Raise capacity-level limits or enable autoscale when demand is sustained
- **Reschedule** heavy workloads to smooth peaks

Spark jobs that hit a limit return **HTTP 429**, so watch for that in pipeline
logs as well as in the metrics.

---

## Estate metrics worth tracking

| Metric | Why |
|---|---|
| Peak CU utilisation, by capacity | The leading indicator of throttling |
| Percentage of time throttled | The number that justifies buying capacity |
| Top CU consumers by item | Where optimisation effort actually pays |
| Refresh duration trend | Degradation is usually visible before an outage |
| Datasets failing or never refreshed | Invisible failures otherwise |
| Active users per report | Identifies content worth retiring |
| Unused content count | The usual answer to "the estate has grown too large" |

**Track trends, not point values.** A single day's utilisation says little.
Segment by capacity and owning team, because aggregate figures hide the problem —
and pair usage with an ownership register, since high usage on an unowned dataset
is a risk as much as a success.

---

## Related

- [Alerts](./Alerts/README.md) — alerting on the thresholds above
- [Logs](./Logs/README.md) — semantic model logs and workspace monitoring
- [Performance Tuning](../Optimization/PerformanceTuning/README.md)
- [Memory Optimization](../Optimization/MemoryOptimization/README.md)
- [Get-TenantInventory.ps1](../Scripts/PowerShell/Admin/Get-TenantInventory.ps1)
- [Metrics app docs](https://learn.microsoft.com/en-us/fabric/enterprise/metrics-app-health-page) ·
  [throttling policy](https://learn.microsoft.com/en-us/fabric/enterprise/throttling)
