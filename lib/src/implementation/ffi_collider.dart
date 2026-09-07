import 'ffi_rigid_body.dart';
import 'ffi_collision_shape.dart';
import 'native_lifetime.dart';
import '../ffi_reactphysics3d.dart';
import '../bindings/src/bindings.dart' as ffi;
import 'ffi_material.dart';
import '../../reactphysics3d_dart.dart';

/// FFI implementation of Collider
class FFICollider implements Collider {
  final ffi.Pointer<ffi.RP3D_Collider> rawHandle;
  final FFIRigidBody body;
  final FFICollisionShape collisionShape;
  late final lifetime = NativeLifetime(body.lifetime);
  FFICollider(this.rawHandle, this.body, this.collisionShape);
  ffi.Pointer<ffi.RP3D_Collider> get _ptr {
    lifetime.check();
    return rawHandle;
  }

  void invalidate() {
    collisionShape.users.remove(this);
    lifetime.invalidate();
  }

  @override
  ffi.Pointer<ffi.RP3D_Collider> get handle => _ptr;

  @override
  Material get material {
    lifetime.check();
    return FFIMaterial(() => ffi.rp3d_collider_get_material(_ptr), lifetime);
  }

  @override
  set material(Material value) {
    ffi.rp3d_collider_set_material(_ptr, value.handle);
  }

  @override
  CollisionShape get shape {
    lifetime.check();
    return collisionShape;
  }

  @override
  Vector3 get localPosition => localOrientation.position;
  @override
  set localPosition(Vector3 value) {
    localOrientation = (
      position: value,
      orientation: localOrientation.orientation,
    );
  }

  @override
  Transform get localOrientation {
    final stack = ffi.saveNativeStack();
    try {
      final out = ffi.StructAllocator.create<ffi.RP3D_Transform>();
      ffi.rp3d_collider_get_local_transform(_ptr, out.address);
      return out.toDart();
    } finally {
      ffi.restoreNativeStack(stack);
    }
  }

  @override
  set localOrientation(Transform value) {
    final stack = ffi.saveNativeStack();
    try {
      final input = value.toStruct();
      ffi.rp3d_collider_set_local_transform(_ptr, input.address);
    } finally {
      ffi.restoreNativeStack(stack);
    }
  }

  @override
  void setAsTrigger(bool isTrigger) {
    ffi.rp3d_collider_set_is_trigger(_ptr, isTrigger ? 1 : 0);
  }

  @override
  bool get isTrigger {
    return ffi.rp3d_collider_get_is_trigger(_ptr) != 0;
  }

  @override
  void setIsWorldQueryCollider(bool isWorldQueryCollider) {
    ffi.rp3d_collider_set_is_world_query_collider(
      _ptr,
      isWorldQueryCollider ? 1 : 0,
    );
  }

  @override
  bool get isWorldQueryCollider {
    return ffi.rp3d_collider_get_is_world_query_collider(_ptr) != 0;
  }

  @override
  int get collisionCategoryBits {
    return ffi.rp3d_collider_get_collision_category_bits(_ptr);
  }

  @override
  set collisionCategoryBits(int value) {
    ffi.rp3d_collider_set_collision_category_bits(_ptr, value);
  }

  @override
  int get collideWithMaskBits {
    return ffi.rp3d_collider_get_collide_with_mask_bits(_ptr);
  }

  @override
  set collideWithMaskBits(int value) {
    ffi.rp3d_collider_set_collide_with_mask_bits(_ptr, value);
  }
}
