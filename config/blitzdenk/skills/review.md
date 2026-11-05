---
name: review
description: "starting a coding review after a task is finished"
disable-model-invocation: true
---

Start 3 code-reviewer agents on the current diff. Add a fourth only when the diff
spans unrelated subsystems. Write the scoped diff and changed-file list to one
temp file and give each reviewer the path, plus the original task and intent.

- Reviewers work read-only: they read the provided diff and repository files.
- Verify each finding against the code. Fix critical issues.
- Forward generated artifacts like 'pictures from the test harness' to the reviewers.

Depending on the Task, these are the different perspectives:

1. Correctness
2. Alignment
3. Over-engineering/Simplifications
4. Security
5. Edge cases

Keep each sub-agent focused on the domain of the task. Add this scope line to every builder brief:
