import 'package:reactphysics3d_dart/src/interfaces/physics_common.dart';
import '../reactphysics3d_dart.dart';
import 'interfaces/physics_world.dart';
import 'interfaces/collision_shape.dart';
import 'interfaces/rigid_body.dart';
import 'interfaces/material.dart';
import 'interfaces/transform.dart';
import 'implementation/ffi_physics_common.dart';

class FFIReactPhysics3D implements ReactPhysics3D {
  final FFIPhysicsCommon _physicsCommon;

  PhysicsCommon get physicsCommon => _physicsCommon;

  FFIReactPhysics3D() : _physicsCommon = FFIPhysicsCommon();

  @override
  PhysicsWorld createWorld() {
    return _physicsCommon.createPhysicsWorld();
  }

  @override
  BoxShape createBoxShape(Vector3 extent) {
    return _physicsCommon.createBoxShape(extent);
  }

  @override
  SphereShape createSphereShape(double radius) {
    return _physicsCommon.createSphereShape(radius);
  }

  @override
  CapsuleShape createCapsuleShape(double radius, double height) {
    return _physicsCommon.createCapsuleShape(radius, height);
  }

  @override
  RigidBody createRigidBody(
    PhysicsWorld world, {
    Transform? transform,
    RP3D_BodyType type = RP3D_BodyType.RP3D_BODY_TYPE_DYNAMIC,
    double mass = 1.0,
  }) {
    final finalTransform = transform ?? Transform.identity();
    final rigidBody = world.createRigidBody(finalTransform);
    rigidBody.mass = mass;
    return rigidBody;
  }

  @override
  Material createMaterial({
    double bounciness = 0.0,
    double frictionCoefficient = 0.3,
    double rollingResistance = 0.0,
    double massDensity = 1.0,
  }) {
    // Material creation not yet implemented in FFI bindings
    throw UnimplementedError(
      'Material creation not yet implemented in FFI bindings',
    );
  }

  /// Dispose of the ReactPhysics3D instance
  void dispose() {
    _physicsCommon.dispose();
  }
}
