import 'dart:ffi' as ffi;
import 'package:vector_math/vector_math.dart';
import '../interfaces/transform.dart';
import '../transform.dart' as original;

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// Concrete implementation of a physics transform
class FFITransform implements Transform {
  final Vector3 _position;
  final Quaternion _orientation;

  FFITransform(this._position, this._orientation);

  /// Create from vector_math transform
  factory FFITransform.fromTransform(original.Transform transform) {
    return FFITransform(transform.position, transform.orientation);
  }

  @override
  Vector3 get position => _position;

  @override
  Quaternion get orientation => _orientation;

  @override
  ffi.Pointer<ffi_gen.RP3D_Transform> get handle => ffi.nullptr; // No native handle for pure Dart transform
}