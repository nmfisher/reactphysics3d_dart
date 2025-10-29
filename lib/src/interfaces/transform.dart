import 'dart:ffi' as ffi;
import 'package:vector_math/vector_math.dart';
import 'base_rp3d_type.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// Interface for a physics transform
abstract class Transform extends BaseRP3DType<ffi.Pointer<ffi_gen.RP3D_Transform>> {
  /// Get the position
  Vector3 get position;

  /// Get the orientation
  Quaternion get orientation;

  /// Create an identity transform (no translation, no rotation)
  static Transform identity() => const TransformIdentity();
}

/// Concrete implementation of identity transform
class TransformIdentity implements Transform {
  const TransformIdentity();

  @override
  Vector3 get position => Vector3.zero();

  @override
  Quaternion get orientation => Quaternion.identity();

  @override
  ffi.Pointer<ffi_gen.RP3D_Transform> get handle => ffi.nullptr; // No native handle for identity transform
}