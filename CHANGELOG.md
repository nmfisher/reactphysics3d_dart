## 0.1.0

- Initial release with physics worlds, rigid bodies, box, sphere and capsule shapes.
- Bundle the ReactPhysics3D engine for macOS arm64, Linux arm64/x86_64, and Windows x64.
- Bundle the Emscripten browser module and static archives.
- Add idempotent public teardown, ownership checks, and invalidation of borrowed handles.
- Copy mesh descriptor buffers into native ownership and fix polygon face counts.
- Deliver contact/trigger events through per-listener queues and real Dart port notifications.
- Implement angular velocity, torque, force-at-position, body lookup and collider transforms.
- Report unsupported impulses and rolling resistance explicitly.
- Restore browser bindings, WASM initialization, and temporary allocation cleanup.
- Correct usage examples, ownership documentation, and rectangular heightfield indexing.
- Rebuild pre-release C bridge binaries to match the updated Dart bindings.
