/// Stub implementation for unsupported platforms
/// This file will be replaced by generated bindings on supported platforms

// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'rp3d_base.dart';

// Re-export the base types
export 'rp3d_base.dart';

// ==================== Stub Implementations ====================

Never _unsupported() {
  throw UnsupportedError('ReactPhysics3D is not supported on this platform');
}

class RP3D_PhysicsCommonStub implements RP3D_PhysicsCommonBase {
  @override
  RP3D_PhysicsWorldBase createPhysicsWorld() => _unsupported();

  @override
  void destroyPhysicsWorld(RP3D_PhysicsWorldBase world) => _unsupported();

  @override
  RP3D_BoxShapeBase createBoxShape(RP3D_Vector3 halfExtents) => _unsupported();

  @override
  RP3D_SphereShapeBase createSphereShape(double radius) => _unsupported();

  @override
  RP3D_CapsuleShapeBase createCapsuleShape(double radius, double height) => _unsupported();

  @override
  void destroyBoxShape(RP3D_BoxShapeBase shape) => _unsupported();

  @override
  void destroySphereShape(RP3D_SphereShapeBase shape) => _unsupported();

  @override
  void destroyCapsuleShape(RP3D_CapsuleShapeBase shape) => _unsupported();

  @override
  void destroy() => _unsupported();
}

class RP3D_PhysicsWorldStub implements RP3D_PhysicsWorldBase {
  @override
  void update(double timeStep) => _unsupported();

  @override
  void setGravity(RP3D_Vector3 gravity) => _unsupported();

  @override
  RP3D_Vector3 getGravity() => _unsupported();

  @override
  RP3D_RigidBodyBase createRigidBody(RP3D_Transform transform) => _unsupported();

  @override
  void destroyRigidBody(RP3D_RigidBodyBase body) => _unsupported();
}

class RP3D_RigidBodyStub implements RP3D_RigidBodyBase {
  @override
  RP3D_Transform getTransform() => _unsupported();

  @override
  void setTransform(RP3D_Transform transform) => _unsupported();

  @override
  RP3D_Vector3 getPosition() => _unsupported();

  @override
  RP3D_Quaternion getOrientation() => _unsupported();

  @override
  void setType(RP3D_BodyType type) => _unsupported();

  @override
  RP3D_BodyType getType() => _unsupported();

  @override
  void setMass(double mass) => _unsupported();

  @override
  double getMass() => _unsupported();

  @override
  void setLinearVelocity(RP3D_Vector3 velocity) => _unsupported();

  @override
  RP3D_Vector3 getLinearVelocity() => _unsupported();

  @override
  void applyForce(RP3D_Vector3 force) => _unsupported();

  @override
  RP3D_ColliderBase addCollider(
      RP3D_CollisionShapeBase shape, RP3D_Transform transform) => _unsupported();
}

class RP3D_ColliderStub implements RP3D_ColliderBase {
  @override
  RP3D_MaterialBase getMaterial() => _unsupported();

  @override
  void setIsTrigger(bool isTrigger) => _unsupported();

  @override
  bool getIsTrigger() => _unsupported();
}

class RP3D_MaterialStub implements RP3D_MaterialBase {
  @override
  void setBounciness(double bounciness) => _unsupported();

  @override
  double getBounciness() => _unsupported();

  @override
  void setFrictionCoefficient(double friction) => _unsupported();

  @override
  double getFrictionCoefficient() => _unsupported();

  @override
  void setMassDensity(double density) => _unsupported();

  @override
  double getMassDensity() => _unsupported();
}

class RP3D_CollisionShapeStub implements RP3D_CollisionShapeBase {}

class RP3D_BoxShapeStub extends RP3D_CollisionShapeStub
    implements RP3D_BoxShapeBase {}

class RP3D_SphereShapeStub extends RP3D_CollisionShapeStub
    implements RP3D_SphereShapeBase {}

class RP3D_CapsuleShapeStub extends RP3D_CollisionShapeStub
    implements RP3D_CapsuleShapeBase {}

// ==================== Factory Function ====================

/// Create a PhysicsCommon instance (stub implementation)
RP3D_PhysicsCommonBase rp3d_physics_common_create() {
  return RP3D_PhysicsCommonStub();
}
