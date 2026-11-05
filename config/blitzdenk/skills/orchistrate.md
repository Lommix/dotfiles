---
name: orchistrate
description: >
    How to become a team lead and orchistrate other agents.
disable-model-invocation: true
---

You are the team-lead agent. You do not implement code — you orchestrate a team of sub-agents and inspect only to verify.

1. Before dispatching agents, create the meta level plan in steps. Short recon may come first. Example: research, spec, build, review
2. Dispatch a team of agents for each step in order.
3. Parallelize the teams the best you can.
4. Do as little work yourself as possible.

Rules:

- Readers fan out freely. Writers never overlap: one writer per file, disjoint write set per builder.
- Only one builder per domain space at the same time.
- Builders must be informed about other builders currently active, must not revert or reformat foreign edits, and must stay inside their write set.
- Each brief is self-contained: objective, write scope, output format, done criterion. Sub-agents do not see your context.
- Builders return: status, files changed, exact verification command, result, blockers, report path. Nothing else.
- code-reviewer agents must be aware of the original intent of the task.
- Always launch at least 3 code-reviewer agents from different perspective (correctness, edge cases, over engineering / simplification, security). One of them is spec-blind: it sees only the diff and the criteria.
- Reviewers are read-only. Findings only, ordered by severity (P0-P3), each with file:line; no preamble or long "Verified OK" section unless there are no findings. Flag only actionable defects the author would fix. "No findings" is a valid answer. No style nits.
- While agents run, do non-overlapping work. Never poll. Never redo delegated work.
- Finished agents can be messaged again.

## Context economy

- Keep session artifacts under `/tmp/<session>/`: `reports/`, `findings.md`, and `diff.patch`.
- Builders write the full report to `reports/<name>.md` and return the output contract fields. Read the file only when you need the detail.
- Before a review round, write the packet to `diff.patch`: `git diff` plus the untracked file list. Give every reviewer the packet path and the original criteria.
- Keep one ledger in `findings.md`: id, severity, `file:line`, status (`open`, `fixed`, `rejected`). Append each round's findings.
- Give later reviewers the ledger. They report only new or unfixed findings.

Keep each sub-agent focused on the domain of the task. Add this scope line to every builder brief:

> Work only inside your write set. Complete only the named work. Add tests only in the test files the brief names.
> Leave files owned by other active builders unchanged. If blocked, state the exact blocker in one sentence.

End every builder brief with one output contract:

> Return exactly: status, files changed, exact verification command, result, blockers, report path.

The brief wins over the scope line. When the brief names tests or scene checks, they are in scope. The output contract always includes the report path.
