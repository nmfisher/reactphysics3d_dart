import 'package:vector_math/vector_math_64.dart';

import 'ffi_reactphysics3d.dart' show FFIReactPhysics3D;
import 'interfaces/interfaces.dart';

export 'package:vector_math/vector_math_64.dart' show Vector3, Quaternion, Aabb3;
export 'exceptions.dart';
export 'transform.dart' hide Transform;
export 'ffi_reactphysics3d.dart' show FFIReactPhysics3D;
export 'interfaces/interfaces.dart';

/// Body type enumeration
enum RP3D_BodyType {
  RP3D_BODY_TYPE_STATIC,
  RP3D_BODY_TYPE_KINEMATIC,
  RP3D_BODY_TYPE_DYNAMIC,
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
    RP3D_BodyType type = RP3D_BodyType.RP3D_BODY_TYPE_DYNAMIC,
    double mass = 1.0,
  });
  Material createMaterial({
    double bounciness = 0.0,
    double frictionCoefficient = 0.3,
    double rollingResistance = 0.0,
    double massDensity = 1.0,
  });
}

/// Factory function to create the FFI implementation of ReactPhysics3D
ReactPhysics3D createReactPhysics3D() {
  return FFIReactPhysics3D();
}
