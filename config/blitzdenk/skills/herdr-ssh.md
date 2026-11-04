---
name: herdr-ssh
description: Run commands through an active SSH session in a herdr pane. Use when the user points at an open SSH pane, session, or host.
disable-model-invocation: true
---

An interactive `ssh` process in a herdr pane is not a ControlMaster socket.
`SSH_AUTH_SOCK` holds keys, not a connection. Use the pane, or a keyed agent
socket for a direct command.

## Find the pane

```bash
herdr pane current
herdr pane list | jq -r '.result.panes[] | [.pane_id,.terminal_title,.foreground_cwd] | @tsv'
```

The user may name the host, the session, or the pane. Match the host in
`terminal_title` (`user@host:~/dir`). `pane current` is the focused pane.
For a named herdr session, put `--session NAME` before `pane`.

## Confirm

```bash
herdr pane process-info --pane PANE
herdr pane read PANE --source visible --format text --lines 6
```

Continue when the foreground process is `ssh <host>` and the tail is a shell
prompt.

## Run and verify

```bash
herdr pane run PANE 'echo __HERDR_CHECK__'
herdr pane read PANE --source visible --format text --lines 8
```

`pane run` sends the text plus Enter. The marker appears in the echoed input
and in the output. It runs on the remote host, in the remote shell's cwd.

For literal text, several lines, or shell characters that must survive:

```bash
herdr pane send-text PANE 'echo __HERDR_CHECK__'
herdr pane send-keys PANE Enter
```

## Direct route

When the host trusts a key already loaded in an agent, skip the pane:

```bash
export SSH_AUTH_SOCK=$HOME/.ssh/agent/SOCKET
ssh -o BatchMode=yes HOST 'COMMAND'
```

Find keyed sockets:

```bash
for s in "$HOME"/.ssh/agent/*; do
  SSH_AUTH_SOCK=$s ssh-add -l 2>/dev/null | grep -q SHA256 && echo "$s"
done
```

Use the pane route when the host rejects the agent keys.

## Rules

- Use only the pane or host the user names. If no pane or several panes match, ask.
- Read first. Write only into a shell prompt; if the foreground process is not
  `ssh`, or the screen shows an editor, pager, `sudo` prompt, or a running
  command, wait or ask.
- Single-quote the command in your local shell. The remote shell expands it.
- Check `pwd` when the directory matters.
- Leave `exit`, interrupts, and destructive commands to the user unless asked.
