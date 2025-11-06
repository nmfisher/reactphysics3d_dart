import '../bindings/src/bindings.dart' as ffi;
import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart' as ffi;

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

  /// Get the local orientation
  Transform get localOrientation;

  /// Set the local orientation
  set localOrientation(Transform value);

  /// Set this collider as a trigger
  void setAsTrigger(bool isTrigger);

  /// Check if this collider is a trigger
  bool get isTrigger;
}