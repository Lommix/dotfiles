---
name: zig
description: >
    Current Zig language patterns and guidelines. Load this skill if any .zig file is read, written, or modified, or any zig build/run/test command is involved.
---

# Zig guidelines

## Memory

- Use `std.heap.SafeAllocator` for debug builds.

  ```zig
  var gpa: std.heap.SafeAllocator = .init(std.heap.page_allocator, .{});
  defer std.debug.assert(gpa.deinit() == 0);
  const allocator = gpa.allocator();
  ```

- In a `main(init: std.process.Init)` entry point, use `init.gpa`. The runtime owns and frees it.
- Use `std.heap.smp_allocator` for ReleaseFast builds with threads. It is a singleton with global state.
- `std.mem.Allocator` is the allocator type. Pass one allocator explicitly through the call chain.
- Use one `ArenaAllocator` per scoped task, and group allocations by lifecycle: e.g. a `scene_arena` (per scene), `frame_arena` (per frame), `app_arena` (app lifetime). Free it by dropping the arena.
- `init.arena` is the process-lifetime arena; `init.arena.allocator()` gives its allocator.
- Prefer arena allocators by default; use `gpa` directly only for long-lived or size-changing allocations.
- Reset arenas at scope boundaries with `.free_all`, `.retain_capacity`, or `.{ .retain_with_limit = N }`.
- `std.ArrayList(T)` is unmanaged: start with `.empty` and pass the allocator to each method.

  ```zig
  var list: std.ArrayList(u8) = .empty;
  defer list.deinit(allocator);
  try list.append(allocator, 1);
  ```

- Use `std.AutoArrayHashMapUnmanaged` / `std.StringArrayHashMapUnmanaged` for array-backed maps and pass the allocator to each method. `std.AutoHashMap` / `std.StringHashMap` are managed maps.
- Minimize allocations everywhere: prefer stack buffers (`var buf: [4096]u8`), fixed-size arrays, and reused buffers over heap allocations.

## errdefer

- `defer` runs on both the success and error path; `errdefer` runs only on the error path.
- Use `errdefer` for cleanup that must run only when the function returns an error, e.g. `errdefer allocator.free(buf)` after allocating, when success transfers ownership to the caller.
- Pair `defer`/`errdefer` with the resource acquisition.

## Streams over allocation

- File I/O uses `std.Io`. Get the `Io` value from `init.io` in `main` and pass it to every file operation.
- File and directory types live in `std.Io`: `std.Io.File`, `std.Io.Dir`, and path helpers in `std.Io.Dir.path`.
- `file.reader(io, buffer)` and `file.writer(io, buffer)` return `std.Io.File.Reader` / `std.Io.File.Writer`. The streaming interface is the `.interface` field (`std.Io.Reader` / `std.Io.Writer`).

  ```zig
  var file = try std.Io.Dir.cwd().openFile(io, "data.txt", .{});
  defer file.close(io);
  var buf: [4096]u8 = undefined;
  var reader = file.reader(io, &buf);
  ```

- Write with `writer.interface.writeAll(bytes)` and call `writer.interface.flush()` before the writer goes out of scope.
- Read a whole stream with `reader.interface.allocRemaining(gpa, .limited(max_bytes))`.
- Write to stdout with `std.Io.File.Writer.init(.stdout(), io, &buf)`; print with `.interface.print(...)`.
- Process data in chunks with a stack buffer when the full payload is not needed in memory.

## Entry point

- Define the entry point as `pub fn main(init: std.process.Init) !void`.
- `init` provides `gpa`, `io`, `arena`, `environ_map`, and `minimal.args`. Get arguments with `init.minimal.args.toSlice(init.arena.allocator())`, because they live for the whole process.
- `std.debug.print` takes no `Io` and writes to stderr directly.

## Reflection and builtins

- `@"struct"` type info carries `field_names`, `field_types`, `field_attrs`; `@"enum"` carries `field_names`, `field_values`; `@"fn"` carries `param_types` (`[]const ?type`) and `param_attrs`.
- `@backingInt(e)` reads an enum as its backing integer; `@fromBackingInt(i)` builds an enum from a backing integer.
- `@splat(v)` builds an array or a vector value: `@as([N]T, @splat(v))`.
- `extern struct` fields use arrays with an explicit `align`; `@Vector` has no guaranteed memory layout. Arrays and vectors coerce on assignment.
- `&array[i]` carries index metadata, and `@ptrCast` keeps only the base address. Take a many-pointer view and index that: `const p: [*]f32 = @ptrCast(&vec); p[1] = 2;`
- `void` has one value: `{}`. C headers come from a generated translate-c module (`b.addTranslateC`), not `@cImport`.
- Build scripts: `b.root` is the package root; a configure-time value comes from `b.option`; runtime `--` args come from `Run.addPassthruArgs`; file arguments from `addFileArg` / `addRunFile`.

## Search

- Linear search (`std.mem.find`/`std.mem.indexOf`, `std.mem.eql`, plain loops) beats hash maps (`std.StringHashMap`/`std.AutoHashMap`) for fewer than ~200 elements; use maps for large collections or many repeated lookups.
- `std.mem.indexOf` is an alias of `std.mem.find`.

## Version

- Installed Zig is 0.17.0.
- Verify signatures against `/usr/lib/zig/std/` before trusting examples from memory.
- Run `zig env` for `std_dir`; do not derive the std path from `which zig`.
- Confirm semantics empirically with `zig run` when in doubt.

## Verify

You have full read access to the [Zig std](/usr/lib/zig/std/)

- `zig build` prints nothing on success. Add `--summary all` to see the steps, and `--cache-dir /tmp/zigcheck` to force a real compile: a cached run proves nothing.
- `zig build --help` exits 0 when `build.zig` configures, without compiling. Use it to separate build-script errors from source errors.
- Zig stops after about a dozen errors, and a syntax error in one root file hides every deeper error.

## Format

Always apply formatting after making any change to a zig file with `zig fmt`.
`zig fmt` writes `@intFromEnum` as `@backingInt` and `@enumFromInt` as `@fromBackingInt(@intCast(...))`.
