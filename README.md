# reactphysics3d_dart

Dart bindings for [ReactPhysics3D](https://www.reactphysics3d.com) - A C++ 3D physics engine for simulations and games.

## Features

- **Cross-platform**: Native (iOS, Android, macOS, Linux, Windows) and Web (WASM) support
- **Rigid body dynamics**: Dynamic, kinematic, and static bodies
- **Collision detection**: Discrete collision detection with multiple shape types
- **Collision shapes**: Box, Sphere, Capsule, Convex Mesh, Concave Mesh, Height Field
- **Constraints**: Ball and Socket, Hinge, Slider, Fixed joints
- **Raycasting**: Efficient ray casting queries
- **Performance**: Minimal FFI overhead with direct C API bindings

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

## Quick Start

```dart
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void main() {
  // Create physics common (factory)
  final physicsCommon = PhysicsCommon();

  // Create a physics world
  final world = physicsCommon.createPhysicsWorld();

  // Create a rigid body
  final position = Vector3(0, 20, 0);
  final orientation = Quaternion.identity();
  final transform = Transform(position, orientation);
  final body = world.createRigidBody(transform);

  // Simulation loop
  const timeStep = 1.0 / 60.0;
  for (int i = 0; i < 20; i++) {
    world.update(timeStep);

    final bodyTransform = body.getTransform();
    final bodyPosition = bodyTransform.getPosition();
    print('Body Position: (${bodyPosition.x}, ${bodyPosition.y}, ${bodyPosition.z})');
  }

  // Cleanup
  physicsCommon.destroyPhysicsWorld(world);
}
```

## License

This package uses ReactPhysics3D which is licensed under the [ZLib license](http://opensource.org/licenses/zlib).

## Credits

- ReactPhysics3D by [Daniel Chappuis](https://github.com/DanielChappuis)
