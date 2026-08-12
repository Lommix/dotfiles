---
name: zig
description: >
    MUST load this skill when any .zig file is read, written, or modified, or when any build/run/test command involves zig.
    If you see zig code and have NOT loaded this skill, stop and load it immediately.
---

# Zig guidelines

## Memory

- Pass a single GeneralPurposeAllocator (`gpa`) around explicitly; never use a global allocator.
- Use an `ArenaAllocator` for each scoped task, and group allocations by lifecycle: e.g. a `scene_arena` (per scene), `frame_arena` (per frame), `app_arena` (app lifetime).
- Never nest arenas inside arenas. One arena per scope; free by dropping the arena.
- Prefer arena allocators by default; fall back to `gpa` directly only for long-lived or size-changing allocations.
- When using `ArenaAllocator`, keep the allocator pointer (`arena.allocator()`) around, not the arena itself, when passing it down.
- Reset arenas at scope boundaries (`arena.reset(.retain_capacity)` where reuse is beneficial, `.free_all` otherwise) instead of creating new ones.
- Follow Zig best practices: defer `gpa.deinit()` and `arena.deinit()` in reverse order of creation, and use `defer` immediately after allocation.
- Minimize allocations everywhere: prefer stack buffers (`var buf: [4096]u8`), fixed-size arrays, and reused buffers over heap allocations.

## errdefer

- `defer` runs on both the success and error path; `errdefer` runs only on the error path (verified on 0.16.0).
- Use `errdefer` for cleanup that must run only when the function returns an error, e.g. `errdefer allocator.free(buf)` after allocating, when success transfers ownership to the caller.
- Pair `defer`/`errdefer` with the resource acquisition, exactly like `defer` but on the error branch.

## Streams over allocation

- Prefer streaming I/O over reading/writing whole payloads into memory: `file.reader(file, io, buffer)` / `file.writer(file, io, buffer)` (0.16: `std.Io.Reader`/`std.Io.Writer`, `writeAll`).
- Process data in chunks with a stack buffer instead of `readAlloc`/`readToEndAlloc` into an `ArrayList` when the full payload is not needed in memory.

## Search

- Linear search (`std.mem.indexOf`, `std.mem.eql`, plain loops) beats hash maps (`std.StringHashMap`/`std.AutoHashMap`) for fewer than ~200 elements; only use maps for large collections or many repeated lookups.

## Version

- Installed Zig is 0.16.0. The std API churns every release; verify signatures against `/usr/lib/zig/std/` before trusting examples from memory.
- Confirm semantics empirically with `zig run` when in doubt; behavior (e.g. `defer`/`errdefer`) has changed between releases.

## Verify

You have full read access to the [Zig std](/usr/lib/zig/std/)

## Test

If you need to confirm behavior create zig files under `/tmp/{reason_with_snake}/files.zig` and run them directly with the zig cli.
Use your normal write/edit/read tools for this.

## Format

Always apply formatting after making any change to a zig file with `zig fmt`
