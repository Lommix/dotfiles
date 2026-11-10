---
name: production-evidence
description: Read-only production evidence through a user-opened SSH control socket. Use when a bug reproduces only in production, or when live logs, service state, or data hold the answer.
---

Evidence first: read the live host before you theorize from code.

## 1. Name the target

Read the repo: `AGENTS.md`, `scripts/deploy*`, `Makefile`, CI config. Extract
the host, user, service or container name, and data path.

Done when you can fill every placeholder below.

## 2. Ask for one SSH session

Call the `ask` tool. Give the exact command in the question. The user types the
password once; the control socket stays usable after the shell closes.

```
ask(
  header="SSH access",
  question="Open one persistent SSH session to <user>@<host>:
            ssh -M -S /tmp/agent-<host>.sock -o ControlPersist=2h <user>@<host>",
  options=[
    {label: "Session open (recommended)", description: "I ran the command; the socket exists."},
    {label: "Use existing socket",        description: "I have a control socket; my path follows."},
    {label: "No SSH access",              description: "I will paste logs or point to files."},
  ])
```

## 3. Verify the socket

```bash
ssh -S /tmp/agent-<host>.sock <user>@<host> 'hostname'
```

Done when the command returns the remote hostname. On failure, ask again and
include the error text.

## 4. Collect evidence

Filter on the server, not locally:

```bash
S='ssh -S /tmp/agent-<host>.sock <user>@<host>'
$S 'systemctl status <unit> --no-pager'
$S 'journalctl -u <unit> --since "-30 min" --no-pager | tail -200'
$S 'podman ps --format "{{.Names}} {{.Status}}"'
$S 'podman logs --since 30m --tail 500 <container> 2>&1 | tail -200'
$S 'ss -lntup | grep <port>'
$S 'cat <config> | sed -E "s/(KEY|PASS|TOKEN|SECRET)=.*/\1=REDACTED/"'
```

- App logs first. Search for the failure marker; fetch the surrounding lines.
- `podman logs --since` takes a duration (`30m`, `2h`) or RFC3339. A bare time
  such as `21:38:00` fails.
- SQLite: copy `*.db`, `*.db-wal`, and `*.db-shm` together. The main file alone
  can be stale because recent rows sit in the WAL.
- Save each result under `/tmp/<host>-evidence/` with the command that made it.

Done when the failure marker and its timeline are captured.

## 5. Correlate

Match timestamps across app log, service status, and database rows. State the
observed sequence first, then the hypothesis, and quote the exact lines.

Done when the evidence explains the symptom or names the next check.

## Rules

- Treat the remote host as read-only. Ask the user before any state change:
  restart, deploy, delete, write, kill, or config edit.
- Redact keys, passwords, tokens, and caller data the task does not need.
- Use only the target and socket the user names. Leave the session and socket
  as they are.
- With no SSH access, request the smallest artifact: a log excerpt, a copied
  database, or one command's output.
