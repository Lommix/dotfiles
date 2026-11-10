---
name: feature
description: "Run a new feature as a gated flow: grill, spec, tickets, build, review. One lead subagent owns the flow; the main agent spawns it and relays the report."
disable-model-invocation: true
---

# Feature flow

The main agent launches one `lead` subagent. The lead owns every phase and talks to the user. Workers read shared artifacts and never talk to the user.

## Main agent

1. If the user gave no feature idea, ask for one. Do not start with an empty idea.
2. Spawn one `lead` agent with this prompt:

```
Idea: <the user's idea, verbatim>
Skill: <absolute path of this skill file>
Project root: <cwd>

Read the skill file. Follow the Lead section. You own the flow. Use the ask tool for every user gate. Return the final contract.
```

3. Keep the lead's `agent_id`. Call `idle`. Forward every user message to the lead with `message_agent`, then call `idle` again. The lead owns the flow; do not grill, spec, build, or review yourself.
4. When the lead reports, give the user the report path and the lead's summary. If `report.md` does not exist, message the lead with the missing phase.

## Lead

Read these files before phase 0. Use the `read` tool; they are user-invoked skills.

- `<skill dir>/grilling.md`
- `<skill dir>/tospec.md`
- `<skill dir>/toticket.md`
- `<skill dir>/review.md`
- `<skill dir>/orchistrate.md`

The skill directory is the parent of the skill file path in the spawn prompt.

You write the brief, spec, build plan, findings, and report yourself. You do not write production code.

Pick a kebab-case `<slug>` from the feature title. Use `/tmp/blitzdenk/feature-<slug>/` as the session directory. If it exists, add a numeric suffix. Create it. Write `state.md` with the six phases and update it after each phase. Put all artifacts in the session directory:

- `brief.md`: the grill record.
- `spec.draft.md` and `spec.md`: the draft and the approved spec.
- `tickets/`: the cut tickets, one file per ticket.
- `build-plan.md`: work items, write sets, verification.
- `diff.patch`: the frozen diff.
- `changed-files.txt`: tracked and untracked files.
- `findings.md`: the review ledger.
- `report.md`: the final report.
- `reports/`: full worker reports.

Before phase 0, run `git status --porcelain`. The tree must be clean. If it is dirty, ask the user to commit or stash. Record `git rev-parse HEAD` in `state.md`.

### Phase 0: Grill

Use `grilling.md`. Build the design tree. Find facts with `researcher` agents. Put decisions to the user with `ask`.

- Put the recommended answer in the first option and add `(recommended)` to its label. The custom-message row carries the user's nuance.
- Ask up to 8 independent questions per `ask` call. If the frontier is larger, ask the highest-impact 8 and carry the rest to the next round.
- Do not ask the user for a fact a subagent can find.
- When the frontier is empty, write `brief.md`: problem, users, settled decisions with reasons, rejected options, constraints, acceptance criteria, repo facts, and no open questions.
- Ask the user to confirm the brief. Exit: the user confirms the brief. Mark `grill: done` in `state.md`.

### Phase 1: Spec

Use `tospec.md`. You write the spec. You are the only agent with the grill context.

1. Reuse the grill facts. Explore only the gaps with `researcher` agents: the current state, the domain vocabulary, the ADRs, and the highest existing seam.
2. Write `spec.draft.md` with the `tospec.md` template. Add a seam sketch at the top. Ask the user to approve the seams and the draft in one `ask` call. Give the draft path in the question text.
3. After approval, write `spec.md`. Make it self-contained: no conversation references, no file paths, no code snippets except a decision-rich prototype fragment.
4. Publish the spec to the repo at `./<slug>_spec.md`, or where the repo keeps specs if it has a convention.
5. Exit: the user approves the seams and the spec. Mark `spec: frozen` in `state.md`. Do not edit the spec after this gate. If a decision changes, reopen the gate.

### Phase 1.5: Tickets

Use `toticket.md` on `spec.md`; you already hold the codebase context from the grill and spec phases, so draft the slices directly.

Run its quiz through `ask`. Write one file per ticket under `<session>/tickets/`.

Exit: the user approves the breakdown and every ticket file exists. Mark `tickets: cut` in `state.md`. Do not edit the tickets after this gate. If the breakdown changes, reopen the gate.

### Phase 2: Build

Write `build-plan.md` before you spawn any builder. One item per ticket. Create `reports/`. Each item has:

- id and one-line outcome
- write set: exact files or globs
- dependencies: the blocking edges of its ticket
- verification: one exact command
- done criterion: the acceptance criteria of its ticket

Rules:

- Write sets are disjoint. One writer per file. If two items need the same file, sequence them.
- The plan covers every ticket. No item adds scope the spec does not name.
- If the spec names tests, the write set includes the test files. Otherwise builders add no tests.

Spawn one `builder` per ready item. Each brief contains:

```
# Task: <item id>: <outcome>
Read <spec path>. Read ticket <id> in <tickets path>. Read item <id> in <build-plan path>.
Write set: <files>. Touch no other file. Do not reformat or revert other builders' edits.
Active builders: <id: write set>.
Verification: <exact command>.
Report: <reports/item.md>.
Return exactly: status, files changed, verification command, result, blockers, report path.
```

Run independent items in parallel. Call `idle` when only builder results remain. Do not poll.

When a builder returns, run the exact verification command, check `git status --short` and `git diff --stat` against the write set, and read the report. The published spec file is an artifact; ignore it in the write-set check. If a builder fails, message the same builder with the exact failure. Do not redo its work. If an item is blocked, sequence it or reopen the ticket gate.

Exit: every item is green or explicitly deferred, the build verification passes, and the diff is frozen. Mark `build: green` in `state.md`.

### Phase 3: Review

Use `review.md`. Freeze the diff first:

- `git diff -- . ':(exclude)<slug>_spec.md' > <session>/diff.patch`
- `{ git diff --name-only -- . ':(exclude)<slug>_spec.md'; git ls-files --others --exclude-standard | grep -vxF '<slug>_spec.md'; } | sort -u > <session>/changed-files.txt`
- append untracked files to the patch or list them.
- The spec file is an artifact; reviewers read it separately. If the repo puts the spec elsewhere, use that path in the exclude.

Spawn 3 `code-reviewer` agents in parallel:

1. Correctness: logic, errors, edge cases.
2. Spec alignment: every spec decision implemented; no scope creep.
3. Simplification: over-engineering, needless abstraction, dead code.

One reviewer is spec-blind. It gets only the diff packet (`diff.patch` and `changed-files.txt`) and the acceptance criteria. The other two get `spec.md`, the original idea, and the diff packet.

Each reviewer brief:

```
# Task: Review <perspective>
Read <diff.patch> and <changed-files.txt>. <perspective rules>.
Return findings only. Order by severity: critical, major, minor. Each finding: severity, file:line, defect, concrete fix. Flag only actionable defects the author would fix. No style nits. "No findings" is valid.
```

Add a fourth reviewer only when the diff spans unrelated subsystems or touches security-sensitive code. Perspectives: edge cases, security.

Write every finding to `findings.md`: id, severity (critical, major, minor), file:line, status (`open`, `fixed`, `rejected`, `accepted`). Verify each finding against the code. Reject false positives with a one-line reason. If the spec alignment reviewer finds a gap in the spec, reopen the spec gate before you change code. Fix critical and major through the original builder. Keep each fix inside that builder's write set; if a fix needs another file, widen the write set and tell the builder. Fix minor or accept it with a reason.

After fixes, update `diff.patch`, re-run the build verification, and re-review the changed hunks. Exit: no open critical or major, every minor fixed or accepted, verification green. Mark `review: clear` in `state.md`.

### Phase 4: Report

Write `report.md`:

- status: done, partial, or blocked
- spec path
- files changed
- verification command and result
- findings: fixed, rejected, accepted
- residual risks
- follow-ups

Return exactly:

```
status
spec path
report path
files changed
verification command and result
open findings
blockers
```
