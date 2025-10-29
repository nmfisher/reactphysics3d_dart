import 'package:vector_math/vector_math_64.dart';

import 'ffi_reactphysics3d.dart' show FFIReactPhysics3D;
import 'interfaces/interfaces.dart';

export 'package:vector_math/vector_math_64.dart'
    show Vector3, Quaternion, Aabb3;
export 'exceptions.dart';
export 'ffi_reactphysics3d.dart' show FFIReactPhysics3D;
export 'interfaces/interfaces.dart';

typedef Transform = ({Vector3 position, Quaternion orientation});

extension TransformIdentity on Transform {
  static Transform identity() {
    return (position: Vector3.zero(), orientation: Quaternion.identity());
  }
}

/// Body type enumeration
enum BodyType {
  STATIC,
  KINEMATIC,
  DYNAMIC,
}

/// Abstract interface for ReactPhysics3D physics engine
abstract class ReactPhysics3D {
  PhysicsCommon get physicsCommon;
  PhysicsWorld createWorld();
  BoxShape createBoxShape(Vector3 extent);
  SphereShape createSphereShape(double radius);
  CapsuleShape createCapsuleShape(double radius, double height);
  
  RigidBody createRigidBody(
    PhysicsWorld world, {
    Transform? transform,
    BodyType type = BodyType.DYNAMIC,
    double mass = 1.0,
  });

}

/// Factory function to create the FFI implementation of ReactPhysics3D
ReactPhysics3D createReactPhysics3D() {
  return FFIReactPhysics3D();
}
