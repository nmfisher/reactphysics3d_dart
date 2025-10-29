import 'dart:ffi' as ffi;
import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;
import 'ffi_material.dart';
import '../../reactphysics3d_dart.dart';

/// FFI implementation of Collider
class FFICollider implements Collider {
  final ffi.Pointer<ffi_gen.RP3D_Collider> _ptr;

  FFICollider(this._ptr);

  @override
  ffi.Pointer<ffi_gen.RP3D_Collider> get handle => _ptr;

  @override
  Material get material {
    final materialPtr = ffi_gen.rp3d_collider_get_material(_ptr);
    return FFIMaterial(materialPtr);
  }

  @override
  set material(Material value) {
    ffi_gen.rp3d_collider_set_material(_ptr, value.handle);
  }

  @override
  CollisionShape get shape {
    // TODO: Implement shape getter
    throw UnimplementedError('Collider shape getter not yet implemented');
  }

  @override
  Vector3 get localPosition {
    // TODO: Implement localPosition getter
    throw UnimplementedError('Collider localPosition getter not yet implemented');
  }

  @override
  set localPosition(Vector3 value) {
    // TODO: Implement localPosition setter
    throw UnimplementedError('Collider localPosition setter not yet implemented');
  }

  @override
  Transform get localOrientation {
    // TODO: Implement localOrientation getter
    throw UnimplementedError('Collider localOrientation getter not yet implemented');
  }

  @override
  set localOrientation(Transform value) {
    // TODO: Implement localOrientation setter
    throw UnimplementedError('Collider localOrientation setter not yet implemented');
  }

  @override
  void setAsTrigger(bool isTrigger) {
    ffi_gen.rp3d_collider_set_is_trigger(_ptr, isTrigger ? 1 : 0);
  }

  @override
  bool get isTrigger {
    return ffi_gen.rp3d_collider_get_is_trigger(_ptr) != 0;
  }
}