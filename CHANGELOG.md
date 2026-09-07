## Unreleased

- Add idempotent public teardown, ownership checks, and invalidation of borrowed handles.
- Copy mesh descriptor buffers into native ownership and fix polygon face counts.
- Deliver contact/trigger events through per-listener queues and real Dart port notifications.
- Implement angular velocity, torque, force-at-position, body lookup and collider transforms.
- Report unsupported impulses and rolling resistance explicitly.
- Restore browser bindings, WASM initialization, and temporary allocation cleanup.
- Correct usage examples, ownership documentation, and rectangular heightfield indexing.
- C bridge ABI changed: rebuild native/WASM binaries and regenerate both bindings.

## 0.1.0

* Initial release
* Basic physics world and rigid body support
* Collision shapes: Box, Sphere, Capsule
* Cross-platform support (native + web)
