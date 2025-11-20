import '../bindings/src/bindings.dart';
import 'package:vector_math/vector_math.dart' hide Vector3;
import '../../reactphysics3d_dart.dart';
import '../ffi_reactphysics3d.dart';

import 'ffi_collider.dart';

/// FFI implementation of RigidBody
class FFIRigidBody implements RigidBody {
  final Pointer<RP3D_RigidBody> _ptr;

  FFIRigidBody(this._ptr);

  @override
  Pointer<RP3D_RigidBody> get handle => _ptr;

  @override
  BodyType get type {
    final typeInt = rp3d_body_get_type(_ptr);
    switch (typeInt) {
      case RP3D_BodyType.RP3D_BODY_TYPE_STATIC:
        return BodyType.STATIC;
      case RP3D_BodyType.RP3D_BODY_TYPE_KINEMATIC:
        return BodyType.KINEMATIC;
      case RP3D_BodyType.RP3D_BODY_TYPE_DYNAMIC:
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
        typeInt = RP3D_BodyType.RP3D_BODY_TYPE_STATIC;
        break;
      case BodyType.KINEMATIC:
        typeInt = RP3D_BodyType.RP3D_BODY_TYPE_KINEMATIC;
        break;
      case BodyType.DYNAMIC:
        typeInt = RP3D_BodyType.RP3D_BODY_TYPE_DYNAMIC;
        break;
    }
    rp3d_body_set_type(_ptr, typeInt);
  }

  @override
  Transform get transform {
    final out = StructAllocator.create<RP3D_Transform>();
    rp3d_body_get_transform(_ptr, out.address);
    return out.toDart();
  }

  @override
  set transform(Transform value) {
    setTransform(value);
  }

  @override
  void setTransform(Transform value) {
    rp3d_body_set_transform(
      _ptr,
      value.position.x,
      value.position.y,
      value.position.z,
      value.orientation.x,
      value.orientation.y,
      value.orientation.z,
      value.orientation.w,
    );
  }

  @override
  double get mass => rp3d_body_get_mass(_ptr);

  @override
  set mass(double value) => rp3d_body_set_mass(_ptr, value);

  @override
  Vector3 get linearVelocity {
    final outPtr = StructAllocator.create<RP3D_Vector3>();
    rp3d_body_get_linear_velocity(_ptr, outPtr.address);
    return Vector3(outPtr.x, outPtr.y, outPtr.z);
  }

  @override
  set linearVelocity(Vector3 value) {
    final velocityPtr = _toFFIVector3(value);

    rp3d_body_set_linear_velocity(_ptr, velocityPtr.address);
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
    rp3d_body_apply_force(_ptr, forcePtr.address);
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
  Collider addCollider(CollisionShape shape, {Transform? transform}) {
    // Default transform if not provided
    final colliderTransform = transform ?? TransformIdentity.identity();

    // Add collider to the rigid body
    final transformStruct = colliderTransform.toStruct();
    final colliderPtr = rp3d_body_add_collider(
      _ptr,
      shape.handle,
      transformStruct.address,
    );

    final collider = FFICollider(colliderPtr);

    return collider;
  }

  @override
  void removeCollider(Collider collider) {
    if (collider is! FFICollider) {
      throw ArgumentError('Collider must be an FFICollider instance');
    }

    rp3d_body_remove_collider(_ptr, collider.handle);
  }

  @override
  bool get isGravityEnabled {
    return rp3d_body_is_gravity_enabled(_ptr) != 0;
  }

  @override
  set isGravityEnabled(bool value) {
    enableGravity(value);
  }

  @override
  void enableGravity(bool enable) {
    rp3d_body_enable_gravity(_ptr, enable ? 1 : 0);
  }

  @override
  void setIsDebugEnabled(bool isEnabled) {
    rp3d_body_set_is_debug_enabled(_ptr, isEnabled ? 1 : 0);
  }

  @override
  bool getIsDebugEnabled() {
    return rp3d_body_get_is_debug_enabled(_ptr) != 0;
  }

  /// Helper function to convert Vector3 to FFI Vector3
  RP3D_Vector3 _toFFIVector3(Vector3 v) {
    final ptr = StructAllocator.create<RP3D_Vector3>();
    ptr.x = v.x;
    ptr.y = v.y;
    ptr.z = v.z;
    return ptr;
  }
}
