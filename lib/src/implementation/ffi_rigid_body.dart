import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_mem;
import 'package:vector_math/vector_math.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;
import '../interfaces/rigid_body.dart';
import '../interfaces/transform.dart';
import '../interfaces/collision_shape.dart';
import '../interfaces/collider.dart';
import '../interfaces/material.dart';

/// FFI implementation of RigidBody
class FFIRigidBody implements RigidBody {
  final ffi.Pointer<ffi_gen.RP3D_RigidBody> _ptr;

  FFIRigidBody(this._ptr);

  @override
  ffi.Pointer<ffi_gen.RP3D_RigidBody> get handle => _ptr;

  @override
  Transform get transform {
    final outPtr = ffi_mem.calloc<ffi_gen.RP3D_Transform>();
    try {
      ffi_gen.rp3d_body_get_transform(_ptr, outPtr);
      return _createTransform(outPtr);
    } finally {
      ffi_mem.calloc.free(outPtr);
    }
  }

  @override
  set transform(Transform value) {
    final transformPtr = _toFFITransform(value);
    try {
      ffi_gen.rp3d_body_set_transform(_ptr, transformPtr);
    } finally {
      ffi_mem.calloc.free(transformPtr);
    }
  }

  @override
  double get mass => ffi_gen.rp3d_body_get_mass(_ptr);

  @override
  set mass(double value) => ffi_gen.rp3d_body_set_mass(_ptr, value);

  @override
  Vector3 get linearVelocity {
    final outPtr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    try {
      ffi_gen.rp3d_body_get_linear_velocity(_ptr, outPtr);
      return Vector3(outPtr.ref.x, outPtr.ref.y, outPtr.ref.z);
    } finally {
      ffi_mem.calloc.free(outPtr);
    }
  }

  @override
  set linearVelocity(Vector3 value) {
    final velocityPtr = _toFFIVector3(value);
    try {
      ffi_gen.rp3d_body_set_linear_velocity(_ptr, velocityPtr);
    } finally {
      ffi_mem.calloc.free(velocityPtr);
    }
  }

  @override
  Vector3 get angularVelocity => Vector3.zero(); // Not implemented yet

  @override
  set angularVelocity(Vector3 value) {
    // Not implemented yet
  }

  @override
  void applyForce(Vector3 force, [Vector3? point]) {
    final forcePtr = _toFFIVector3(force);
    try {
      ffi_gen.rp3d_body_apply_force(_ptr, forcePtr);
    } finally {
      ffi_mem.calloc.free(forcePtr);
    }
  }

  @override
  void applyTorque(Vector3 torque) {
    // Not implemented yet
  }

  @override
  void applyImpulse(Vector3 impulse, [Vector3? point]) {
    // Not implemented yet
  }

  @override
  Collider addCollider(
    CollisionShape shape, {
    Material? material,
    Vector3? position,
    Transform? orientation,
  }) {
    // Not implemented yet
    throw UnimplementedError('Collider implementation not yet complete');
  }

  @override
  void removeCollider(Collider collider) {
    // Not implemented yet
    throw UnimplementedError('Collider implementation not yet complete');
  }

  /// Helper function to convert Vector3 to FFI Vector3
  ffi.Pointer<ffi_gen.RP3D_Vector3> _toFFIVector3(Vector3 v) {
    final ptr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    ptr.ref.x = v.x;
    ptr.ref.y = v.y;
    ptr.ref.z = v.z;
    return ptr;
  }

  /// Helper function to convert Transform to FFI Transform
  ffi.Pointer<ffi_gen.RP3D_Transform> _toFFITransform(Transform transform) {
    final ptr = ffi_mem.calloc<ffi_gen.RP3D_Transform>();
    ptr.ref.position.x = transform.position.x;
    ptr.ref.position.y = transform.position.y;
    ptr.ref.position.z = transform.position.z;
    ptr.ref.orientation.x = transform.orientation.x;
    ptr.ref.orientation.y = transform.orientation.y;
    ptr.ref.orientation.z = transform.orientation.z;
    ptr.ref.orientation.w = transform.orientation.w;
    return ptr;
  }

  /// Create a Transform from FFI data
  Transform _createTransform(ffi.Pointer<ffi_gen.RP3D_Transform> ffiTransform) {
    // Create a simple transform implementation here
    return _SimpleTransform(
      Vector3(ffiTransform.ref.position.x, ffiTransform.ref.position.y, ffiTransform.ref.position.z),
      Quaternion(ffiTransform.ref.orientation.x, ffiTransform.ref.orientation.y,
                 ffiTransform.ref.orientation.z, ffiTransform.ref.orientation.w),
    );
  }
}

/// Simple Transform implementation for internal use
class _SimpleTransform implements Transform {
  @override
  final Vector3 position;
  @override
  final Quaternion orientation;

  _SimpleTransform(this.position, this.orientation);

  @override
  ffi.Pointer<ffi_gen.RP3D_Transform> get handle => ffi.nullptr; // No native handle for internal transform
}