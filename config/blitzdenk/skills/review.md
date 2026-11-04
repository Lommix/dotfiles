---
name: review
description: "start a code review on the current diff"
disable-model-invocation: true
---

Start 3 code-reviewer agents on the current diff. Add a fourth only when the diff
spans unrelated subsystems. Write the scoped diff and changed-file list to one
temp file and give each reviewer the path, plus the original task and intent.

Reviewers work read-only: they read the provided diff and repository files.
They skip `git diff`, builds, and tests.

Verify each finding against the code. Fix critical issues.

Depending on the Task, these are the different perspectives:

1. Correctness
2. Alignment
3. Over engineering
4. Security
5. Edge cases
