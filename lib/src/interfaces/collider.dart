import '../bindings/src/bindings.dart' as ffi;
import '../../reactphysics3d_dart.dart';

/// Interface for colliders
abstract class Collider extends BaseRP3DType<ffi.Pointer<ffi.RP3D_Collider>> {
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

  /// Get the full local-to-body transform (the name is historical).
  Transform get localOrientation;

  /// Set the full local-to-body transform. Recompute body mass properties as needed.
  set localOrientation(Transform value);

  /// Set this collider as a trigger
  void setAsTrigger(bool isTrigger);

  /// Check if this collider is a trigger
  bool get isTrigger;

  /// Set whether this collider will be part of world query results
  void setIsWorldQueryCollider(bool isWorldQueryCollider);

  /// Check if this collider will be part of world query results
  bool get isWorldQueryCollider;

  /// Get the collision category bits
  int get collisionCategoryBits;

  /// Set the collision category bits
  set collisionCategoryBits(int value);

  /// Get the collide with mask bits
  int get collideWithMaskBits;

  /// Set the collide with mask bits
  set collideWithMaskBits(int value);
}
