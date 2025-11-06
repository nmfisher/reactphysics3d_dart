import '../bindings/src/bindings.dart' as ffi;
import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart' as ffi;

/// Interface for rigid bodies
abstract class RigidBody extends BaseRP3DType<ffi.Pointer<ffi.RP3D_RigidBody>> {
  /// Get the body type
  BodyType get type;

  /// Set the body type
  set type(BodyType value);

  /// Get the transform
  Transform get transform;

  /// Set the transform (alternative method)
  void setTransform(Transform value);

  /// Get the mass
  double get mass;

  /// Set the mass
  set mass(double value);

  /// Get the linear velocity
  Vector3 get linearVelocity;

  /// Set the linear velocity
  set linearVelocity(Vector3 value);

  /// Get the angular velocity
  Vector3 get angularVelocity;

  /// Set the angular velocity
  set angularVelocity(Vector3 value);

  /// Apply a force to the rigid body
  void applyForce(Vector3 force, [Vector3? point]);

  /// Apply a torque to the rigid body
  void applyTorque(Vector3 torque);

  /// Apply an impulse to the rigid body
  void applyImpulse(Vector3 impulse, [Vector3? point]);

  /// Add a collider to this rigid body
  Collider addCollider(
    CollisionShape shape, {
    Transform? transform,
  });

  /// Remove a collider from this rigid body
  void removeCollider(Collider collider);

  /// Get whether gravity is enabled for this rigid body
  bool get isGravityEnabled;

  /// Set whether gravity is enabled for this rigid body
  set isGravityEnabled(bool value);

  /// Enable or disable gravity for this rigid body
  void enableGravity(bool enable);

  /// Enable/disable debug rendering for this rigid body
  void setIsDebugEnabled(bool isEnabled);

  /// Get whether debug rendering is enabled for this rigid body
  bool getIsDebugEnabled();
}