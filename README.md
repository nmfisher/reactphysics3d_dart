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

## Documentation

See [DART_PACKAGE_PLAN.md](../reactphysics3d/DART_PACKAGE_PLAN.md) for implementation details.

## License

This package uses ReactPhysics3D which is licensed under the [ZLib license](http://opensource.org/licenses/zlib).

## Credits

- ReactPhysics3D by [Daniel Chappuis](https://github.com/DanielChappuis)
- Dart bindings by the reactphysics3d_dart contributors
