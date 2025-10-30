import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'package:ffi/ffi.dart' as ffi_mem;
import 'package:vector_math/vector_math.dart' hide Vector3;

import '../../reactphysics3d_dart.dart';
import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;
import '../ffi_reactphysics3d.dart';

import 'ffi_collider.dart';

/// FFI implementation of RigidBody
class FFIRigidBody implements RigidBody {
  final ffi.Pointer<ffi_gen.RP3D_RigidBody> _ptr;

  FFIRigidBody(this._ptr);

  @override
  ffi.Pointer<ffi_gen.RP3D_RigidBody> get handle => _ptr;

  @override
  BodyType get type {
    final typeInt = ffi_gen.rp3d_body_get_type(_ptr);
    switch (typeInt) {
      case ffi_gen.RP3D_BodyType.RP3D_BODY_TYPE_STATIC:
        return BodyType.STATIC;
      case ffi_gen.RP3D_BodyType.RP3D_BODY_TYPE_KINEMATIC:
        return BodyType.KINEMATIC;
      case ffi_gen.RP3D_BodyType.RP3D_BODY_TYPE_DYNAMIC:
        return BodyType.DYNAMIC;
      default:
        return BodyType.DYNAMIC;
    }
  }

  @override
  set type(BodyType value) {
    int typeInt;
    switch (value) {
      case BodyType.STATIC:
        typeInt = ffi_gen.RP3D_BodyType.RP3D_BODY_TYPE_STATIC;
        break;
      case BodyType.KINEMATIC:
        typeInt = ffi_gen.RP3D_BodyType.RP3D_BODY_TYPE_KINEMATIC;
        break;
      case BodyType.DYNAMIC:
        typeInt = ffi_gen.RP3D_BodyType.RP3D_BODY_TYPE_DYNAMIC;
        break;
    }
    ffi_gen.rp3d_body_set_type(_ptr, typeInt);
  }

  @override
  Transform get transform {
    final out = Struct.create<ffi_gen.RP3D_Transform>();
    ffi_gen.rp3d_body_get_transform(_ptr, out.address);
    return out.toDart();
  }

  @override
  set transform(Transform value) {
    ffi_gen.rp3d_body_set_transform(_ptr, value.position.x, value.position.y, value.position.z, value.orientation.x, value.orientation.y, value.orientation.z, value.orientation.z);
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
    Transform? transform,
  }) {
    // Default transform if not provided
    final colliderTransform = transform ?? TransformIdentity.identity();

    // Add collider to the rigid body
    final transformStruct = colliderTransform.toStruct();
    final colliderPtr = ffi_gen.rp3d_body_add_collider(
      _ptr,
      shape.handle,
      transformStruct.address,
    );

    final collider = FFICollider(colliderPtr);

    // Set material if provided
    if (material != null) {
      collider.material = material;
    }

    return collider;
  }

  @override
  void removeCollider(Collider collider) {
    // Not implemented yet
    throw UnimplementedError('Collider implementation not yet complete');
  }

  @override
  bool get isGravityEnabled {
    return ffi_gen.rp3d_body_is_gravity_enabled(_ptr) != 0;
  }

  @override
  set isGravityEnabled(bool value) {
    enableGravity(value);
  }

  @override
  void enableGravity(bool enable) {
    ffi_gen.rp3d_body_enable_gravity(_ptr, enable ? 1 : 0);
  }

  /// Helper function to convert Vector3 to FFI Vector3
  ffi.Pointer<ffi_gen.RP3D_Vector3> _toFFIVector3(Vector3 v) {
    final ptr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    ptr.ref.x = v.x;
    ptr.ref.y = v.y;
    ptr.ref.z = v.z;
    return ptr;
  }
}
