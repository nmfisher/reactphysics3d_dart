# reactphysics3d_dart

Dart wrappers for ReactPhysics3D 0.10.2: rigid bodies, collision shapes, raycasts,
collision/trigger events, materials, and debug geometry.

Native builds use Dart FFI and build hooks. macOS arm64 and Linux arm64/x86_64
archives are included. Browser builds use a separately built Emscripten module.
See [BUILDING.md](BUILDING.md) for prerequisites, platform limits, and regeneration.
The high-level wrapper does not expose joints. Impulses and rolling resistance
throw `UnsupportedError` rather than silently ignoring calls.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  reactphysics3d_dart: ^0.1.0
```

## Prebuilt libraries

The ReactPhysics3D C++ engine itself is not published to a package registry:
the Dart package compiles the C API wrapper (`native/src/rp3d_c_api.cpp`) from
source and links it against a prebuilt `libreactphysics3d.a` per platform.
Those libraries are built and published by the
[Build artifacts workflow](.github/workflows/build-artifacts.yml):

```
https://github.com/nmfisher/reactphysics3d_dart/releases/download/<tag>/reactphysics3d_dart-<version>-<platform>.zip
```

with `platform` one of `web-emscripten`, `web-module`, `linux-x86_64`,
`linux-aarch64`, `macos-arm64`, `macos-x86_64`, `windows-x64`. See
[BUILDING.md](BUILDING.md#release-artifacts) for the contents of each zip and
how to build them locally.

## Quick start

Add this package to your dependencies, then run `dart pub get`.
The following example is also available as [example/quick_start.dart](example/quick_start.dart).

```dart
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void main() {
  final physics = createReactPhysics3D();
  try {
    final world = physics.createWorld();
    final body = world.createRigidBody(transform: (
      position: Vector3(0, 20, 0),
      orientation: Quaternion.identity(),
    ));
    body.addCollider(physics.createBoxShape(Vector3.all(0.5)));
    body.updateMassPropertiesFromColliders();
    for (var i = 0; i < 60; i++) {
      world.update(1 / 60);
    }
    print(body.transform.position);
  } finally {
    physics.dispose();
  }
}
```

## Ownership and lifecycle

Native resources require explicit cleanup; Dart garbage collection does not
release them. Keep the engine alive for the simulation and call `dispose()` in a
`finally` block. Both `ReactPhysics3D` and `PhysicsCommon` expose this method.
Factory shutdown destroys worlds first, then shapes and their backing data.
All disposal methods are idempotent. Wrapper access after destruction throws
`StateError`. Direct use of raw native handles bypasses these checks.

| Object | Owner and cleanup |
| --- | --- |
| World | Factory-owned; `world.dispose()` or `physics.physicsCommon.destroyPhysicsWorld(world)` |
| Body | World-owned; `world.destroyRigidBody(body)` also destroys its colliders |
| Collider | Body-owned; `body.removeCollider(collider)` |
| Material / debug renderer | Borrowed from a collider / world; no independent disposal |
| Shape | Factory-owned; remove every collider using it before `shape.dispose()` |
| Mesh / heightfield | Factory-owned; dispose every dependent shape before disposing the data |
| Vertex-array descriptors | Factory-owned native copies; disposable after mesh construction |
| Event listener | Caller-owned; `listener.dispose()` detaches it and closes its port/timer |

Shapes can be shared among bodies and worlds from the same factory. The wrapper
rejects attaching a shape from another factory, removing another body's collider,
and destroying another world's body. Disposing a shape or mesh while it is in use
throws `StateError`.

Raycasts, body lookup, and event callbacks return the same body/collider wrappers
created by the world. References to bodies, colliders, materials, and debug
renderers expire with their owner. Event point values are copied, but event body
and collider references are live borrowed objects.

## Simulation and geometry

Use a consistent length/mass/time system and a fixed positive timestep in seconds.
Serialize access to each world: do not update, query, or destroy it concurrently
from different threads/isolates. Forces and torques are world-space values applied
for the next step; the optional force point is a world-space position. Call
`updateMassPropertiesFromColliders()` after adding/removing colliders or changing
density/local transforms when mass and inertia should be recomputed.

- Box dimensions are **half-extents**. Capsule height is the distance between the
  centers of its hemispheres; total height is `height + 2 * radius`.
- Transforms are named records: `(position: Vector3(...), orientation: Quaternion(...))`.
  Use normalized quaternions. Collider `localOrientation` historically names the
  full local-to-body transform; `localPosition` changes only its translation.
- Mesh vertices are finite XYZ triples. Triangle indices are groups of three.
  Polygon descriptors are `[vertexCount, indexBase, ...]`, with one pair per face.
  Input arrays are copied; later changes to them do not modify the native mesh.
- Height samples are row-major: `heights[row * columns + column]`. Columns run along
  X and rows along Z. Integer samples are multiplied by `integerHeightScale`.
  Bounds are computed from the samples and recentered around zero; the retained
  `minHeight`/`maxHeight` arguments do not override them. Add the appropriate body
  translation if you need the original elevation. Use heightfields/concave meshes
  for static terrain.

## Collision and trigger events

```dart
class Contacts extends CollisionCallback {
  @override
  void onContact(ContactCallbackData data) {
    for (final pair in data.contactPairs) {
      print('${pair.eventType}: ${pair.nbContactPoints} points');
    }
  }
}

// Within a simulation's lifetime:
final listener = SendPortEventListener(Contacts());
try {
  world.setEventListener(listener);
  world.update(1 / 60);
  listener.poll(); // Optional: deliver immediately, before yielding to the event loop.
} finally {
  listener.dispose(); // Also detaches from a live world.
}
```

Native automatic delivery uses a Dart ReceivePort. Browsers drain the queue on a
16 ms timer. Each listener has its own queue and may attach to one world at a time.
Both contacts and triggers reach `onContact`; trigger pairs contain no contact
points. `poll()` is useful in synchronous loops where the event loop cannot run.
Callback exceptions propagate to the caller of `poll()` or the asynchronous zone.

Detaching/disposal and body/collider destruction discard queued events. World
shutdown detaches its listener; callers must still dispose that listener.
For immediate queries, use `testCollision`, `testCollisionBody`,
`testCollisionTwoBodies`, or `testOverlap`; these invoke the callback synchronously.

## Browser initialization

Build and serve the Emscripten `.js` and `.wasm` files, then instantiate the module
before starting the compiled Dart application:

```html
<script src="reactphysics3d_dart.js"></script>
<script>
  reactphysics3d_dart().then(module => {
    globalThis.rp3d = module;
    const app = document.createElement('script');
    app.src = 'main.dart.js';
    document.body.appendChild(app);
  });
</script>
```

Call `initializeReactPhysics3DWeb()` at the beginning of your Dart browser entry
point, before `createReactPhysics3D()`. Pass `moduleName` if the global is named
something other than `rp3d`. The supplied build uses shared WebAssembly memory,
so serve it with cross-origin isolation headers as described in BUILDING.md.

## License

ReactPhysics3D is by Daniel Chappuis and uses the Zlib license.
