import 'dart:ffi' as ffi;
import 'package:vector_math/vector_math.dart';
import 'transform.dart';
import 'collider.dart';
import 'collision_shape.dart';
import 'material.dart';
import 'base_rp3d_type.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// Interface for rigid bodies
abstract class RigidBody extends BaseRP3DType<ffi.Pointer<ffi_gen.RP3D_RigidBody>> {
  /// Get the transform
  Transform get transform;

  /// Set the transform
  set transform(Transform value);

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
    Material? material,
    Vector3? position,
    Transform? orientation,
  });

  /// Remove a collider from this rigid body
  void removeCollider(Collider collider);
}