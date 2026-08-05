---
name: zig
description: >
    MUST load this skill when any .zig file is read, written, or modified, or when any build/run/test command involves zig.
    If you see zig code and have NOT loaded this skill, stop and load it immediately.
---

# Zig guidelines

## Verify

You have full read access to the [Zig std](/usr/lib/zig/std/)

## Test

If you need to confirm behavior create zig files under `/tmp/{reason_with_snake}/files.zig` and run them directly with the zig cli.
Use your normal write/edit/read tools for this.

## Lsp

Enable the lsp to confirm reference and find symbols.

## Format

Always apply formatting after making any change to a zig file with `zig fmt`
