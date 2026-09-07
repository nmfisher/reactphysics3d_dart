import '../bindings/src/bindings.dart' as ffi;
import '../../reactphysics3d_dart.dart';

/// A world-owned body. Destroy through PhysicsWorld.destroyRigidBody.
/// Its colliders and borrowed material views expire when it is destroyed.
abstract class RigidBody extends BaseRP3DType<ffi.Pointer<ffi.RP3D_RigidBody>> {
  /// Get the body type
  BodyType get type;

  /// Set the body type
  set type(BodyType value);

  /// Get the transform
  Transform get transform;

  /// Set the transform.
  set transform(Transform value);

  /// Recompute mass, inertia and center of mass after editing colliders/density.
  void updateMassPropertiesFromColliders();

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

  /// Apply a world-space force at a world-space point, or at the center of mass.
  /// Forces accumulate until the next update, then are reset.
  void applyForce(Vector3 force, [Vector3? point]);

  /// Apply a world-space torque until the next simulation update.
  void applyTorque(Vector3 torque);

  /// Unsupported by the underlying engine; throws UnsupportedError.
  void applyImpulse(Vector3 impulse, [Vector3? point]);

  /// Add a collider to this rigid body
  Collider addCollider(CollisionShape shape, {Transform? transform});

  /// Remove an owned collider and invalidate its material views. Idempotent.
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
