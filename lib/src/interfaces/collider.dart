import 'dart:ffi' as ffi;
import 'package:vector_math/vector_math.dart';
import 'material.dart';
import 'collision_shape.dart';
import 'transform.dart';
import 'base_rp3d_type.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// Interface for colliders
abstract class Collider extends BaseRP3DType<ffi.Pointer<ffi_gen.RP3D_Collider>> {
  /// Get the material
  Material get material;

  /// Set the material
  set material(Material value);

  /// Get the collision shape
  CollisionShape get shape;

  /// Get the local position
  Vector3 get localPosition;

  /// Set the local position
  set localPosition(Vector3 value);

  /// Get the local orientation
  Transform get localOrientation;

  /// Set the local orientation
  set localOrientation(Transform value);

  /// Set this collider as a trigger
  void setAsTrigger(bool isTrigger);

  /// Check if this collider is a trigger
  bool get isTrigger;
}