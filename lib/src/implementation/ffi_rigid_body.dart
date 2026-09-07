import '../bindings/src/bindings.dart';
import 'ffi_physics_world.dart';
import 'ffi_collision_shape.dart';
import 'native_lifetime.dart';
import '../../reactphysics3d_dart.dart';
import '../ffi_reactphysics3d.dart';

import 'ffi_collider.dart';

/// FFI implementation of RigidBody
class FFIRigidBody implements RigidBody {
  final Pointer<RP3D_RigidBody> _raw;
  final FFIPhysicsWorld world;
  late final lifetime = NativeLifetime(world.lifetime);
  final colliders = <FFICollider>{};
  FFIRigidBody(this._raw, this.world);
  Pointer<RP3D_RigidBody> get _ptr {
    lifetime.check();
    return _raw;
  }

  void invalidate() {
    for (final collider in colliders) {
      world.colliders.remove(collider.rawHandle.address);
      collider.invalidate();
    }
    colliders.clear();
    lifetime.invalidate();
  }

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
    final stack = saveNativeStack();
    try {
      final out = StructAllocator.create<RP3D_Transform>();
      rp3d_body_get_transform(_ptr, out.address);
      return out.toDart();
    } finally {
      restoreNativeStack(stack);
    }
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
    final stack = saveNativeStack();
    try {
      final outPtr = StructAllocator.create<RP3D_Vector3>();
      rp3d_body_get_linear_velocity(_ptr, outPtr.address);
      return Vector3(outPtr.x, outPtr.y, outPtr.z);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  set linearVelocity(Vector3 value) {
    final stack = saveNativeStack();
    try {
      final velocityPtr = _toFFIVector3(value);

      rp3d_body_set_linear_velocity(_ptr, velocityPtr.address);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  Vector3 get angularVelocity {
    final stack = saveNativeStack();
    try {
      final out = StructAllocator.create<RP3D_Vector3>();
      rp3d_body_get_angular_velocity(_ptr, out.address);
      return Vector3(out.x, out.y, out.z);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  set angularVelocity(Vector3 value) {
    final stack = saveNativeStack();
    try {
      final v = _toFFIVector3(value);
      rp3d_body_set_angular_velocity(_ptr, v.address);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  void applyForce(Vector3 force, [Vector3? point]) {
    final stack = saveNativeStack();
    try {
      final forcePtr = _toFFIVector3(force);
      if (point == null) {
        rp3d_body_apply_force(_ptr, forcePtr.address);
      } else {
        final position = _toFFIVector3(point);
        rp3d_body_apply_force_at_position(
          _ptr,
          forcePtr.address,
          position.address,
        );
      }
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  void applyTorque(Vector3 torque) {
    final stack = saveNativeStack();
    try {
      final v = _toFFIVector3(torque);
      rp3d_body_apply_torque(_ptr, v.address);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  void applyImpulse(Vector3 impulse, [Vector3? point]) {
    lifetime.check();
    throw UnsupportedError(
      'ReactPhysics3D does not expose impulses; use velocity or forces',
    );
  }

  @override
  void updateMassPropertiesFromColliders() =>
      rp3d_body_update_mass_properties_from_colliders(_ptr);

  @override
  Collider addCollider(CollisionShape shape, {Transform? transform}) {
    final stack = saveNativeStack();
    try {
      lifetime.check();
      if (shape is! FFICollisionShape)
        throw ArgumentError('Unsupported collision shape');
      shape.requireSameCommon(world.common);
      // Default transform if not provided
      final colliderTransform = transform ?? TransformIdentity.identity();

      // Add collider to the rigid body
      final transformStruct = colliderTransform.toStruct();
      final colliderPtr = rp3d_body_add_collider(
        _ptr,
        shape.handle,
        transformStruct.address,
      );

      if (colliderPtr == nullptr) throw StateError('Failed to create collider');
      final collider = FFICollider(colliderPtr, this, shape);
      colliders.add(collider);
      shape.users.add(collider);
      world.colliders[colliderPtr.address] = collider;

      return collider;
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  void removeCollider(Collider collider) {
    final stack = saveNativeStack();
    try {
      lifetime.check();
      if (collider is! FFICollider || !identical(collider.body, this)) {
        throw ArgumentError('Collider must be an FFICollider instance');
      }

      if (collider.lifetime.isDisposed) return;
      world.discardPendingEvents();
      rp3d_body_remove_collider(_ptr, collider.handle);
      world.colliders.remove(collider.rawHandle.address);
      colliders.remove(collider);
      collider.invalidate();
    } finally {
      restoreNativeStack(stack);
    }
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
