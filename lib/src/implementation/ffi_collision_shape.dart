import 'dart:ffi' as ffi;
import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;
import '../interfaces/collision_shape.dart';
import 'ffi_physics_common.dart';

/// Base implementation for collision shapes
abstract class FFICollisionShape implements CollisionShape {
  final ffi.Pointer<ffi_gen.RP3D_CollisionShape> _handle;
  final FFIPhysicsCommon _common;

  FFICollisionShape._(this._handle, this._common);

  @override
  ffi.Pointer<ffi_gen.RP3D_CollisionShape> get handle => _handle;

  @override
  void dispose() {
    _destroyShape();
  }

  void _destroyShape();
}

/// Box collision shape implementation
class FFIBoxShape extends FFICollisionShape implements BoxShape {
  FFIBoxShape.internal(ffi.Pointer<ffi_gen.RP3D_BoxShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final boxHandle = _handle.cast<ffi_gen.RP3D_BoxShape>();
    ffi_gen.rp3d_physics_common_destroy_box_shape(_common.handleForShapes!, boxHandle);
  }
}

/// Sphere collision shape implementation
class FFISphereShape extends FFICollisionShape implements SphereShape {
  FFISphereShape.internal(ffi.Pointer<ffi_gen.RP3D_SphereShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final sphereHandle = _handle.cast<ffi_gen.RP3D_SphereShape>();
    ffi_gen.rp3d_physics_common_destroy_sphere_shape(_common.handleForShapes!, sphereHandle);
  }
}

/// Capsule collision shape implementation
class FFICapsuleShape extends FFICollisionShape implements CapsuleShape {
  FFICapsuleShape.internal(ffi.Pointer<ffi_gen.RP3D_CapsuleShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final capsuleHandle = _handle.cast<ffi_gen.RP3D_CapsuleShape>();
    ffi_gen.rp3d_physics_common_destroy_capsule_shape(_common.handleForShapes!, capsuleHandle);
  }
}