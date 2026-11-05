---
name: cmp
description: "Compare two similar repos: improve the leader, adopt challenger wins."
disable-model-invocation: true
---

The user has asked for a **comparison** between a **leader** repo and a **challenger** repo. The goal is to improve the leader. The challenger is a source of ideas, not a target shape: a challenger feature that does not serve a goal the leader already has is noise, and listing it is a failure.

## Steps

1. **Fix the pair.** Confirm which repo is the leader and which is the challenger. Read the leader first, so the challenger is read through the leader's shape. If the user did not name the second repo, ask.

2. **Map both feature surfaces.** Build one capability list per repo, keyed by capability, not by file. Read entry points, README, config schema, CLI help, directory layout. Mark each capability shared, leader-only, or challenger-only. The pass is done when every top-level capability sits in one of the three classes.

3. **Pass 1: shared capabilities, their way.** For each shared capability, read both implementations side by side. A **cheap win** is a difference whose adoption costs less than it returns: fewer moving parts, a better default, a clearer extension point, a safer failure mode, less config, less code. Record the file on both sides, the concrete change, and the cost (small, medium, large). Use the lenses below where a capability looks even.

4. **Pass 2: challenger-only capabilities.** For each one, record what it does, the value to the leader's users, the adoption cost, and the porting tax: how tightly it couples to the challenger's design. Then filter against the leader's goals. Keep the ones that pay. Name the dropped ones in one line each, so the user sees they were considered.

5. **Rank each section by priority.** Priority is value to the leader divided by adoption cost. Break ties towards the lower-risk change. A cheap win outranks a new feature of equal value, because it is live sooner.

6. **Write the summary** in the sections below, in this order. Every finding names a concrete change or a concrete feature, never a direction. Cite the file path on both sides.

## Cheap-win lenses

- **Default**: same capability, better out-of-box result.
- **Surface**: fewer options, files, or steps to reach the same result.
- **Failure**: clearer error, safer degradation, fewer silent paths.
- **Extension**: a seam where the leader forks or hand-edits code the challenger plugs into.
- **Guardrail**: an automated check the challenger wires (CI, hook, lint) that the leader lacks.

Before a lens reports a win, check the leader's docs, commits, and issues for an intentional rejection. A deliberate trade-off is not a defect.

## Output

```
## Improve what we have
1. **<finding>** — leader `path`, challenger `path`. Change: <one line>. Cost: small|medium|large.

## Features to adopt
1. **<feature>** — challenger `path`. Value: <one line>. Cost: small|medium|large. Porting tax: low|medium|high.

## Dropped
- <feature>: <one line reason it does not serve the leader>
```
