import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_mem;
import 'package:reactphysics3d_dart/src/implementation/ffi_physics_world.dart';

import '../../reactphysics3d_dart.dart';
import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;
import '../interfaces/physics_common.dart';
import '../interfaces/physics_world.dart';
import '../interfaces/collision_shape.dart';
import 'ffi_collision_shape.dart';

/// Concrete implementation of physics common operations
class FFIPhysicsCommon implements PhysicsCommon {
  ffi.Pointer<ffi_gen.RP3D_PhysicsCommon>? _handle;

  @override
  ffi.Pointer<ffi_gen.RP3D_PhysicsCommon> get handle => _handle!;

  FFIPhysicsCommon() {
    _handle = ffi_gen.rp3d_physics_common_create();
    if (_handle!.address == 0) {
      throw Exception('Failed to create PhysicsCommon');
    }
  }

  void dispose() {
    if (_handle != null) {
      ffi_gen.rp3d_physics_common_destroy(_handle!);
      _handle = null;
    }
  }

  @override
  PhysicsWorld createPhysicsWorld() {
    _checkDisposed();
    final worldHandle = ffi_gen.rp3d_physics_common_create_physics_world(_handle!);
    if (worldHandle.address == 0) {
      throw Exception('Failed to create PhysicsWorld');
    }
    return FFIPhysicsWorld(worldHandle);
  }

  @override
  BoxShape createBoxShape(Vector3 extent) {
    _checkDisposed();
    final extentsPtr = _toFFIVector3(extent);
    try {
      final shapeHandle = ffi_gen.rp3d_physics_common_create_box_shape(_handle!, extentsPtr);
      if (shapeHandle.address == 0) {
        throw Exception('Failed to create BoxShape');
      }
      return FFIBoxShape.internal(shapeHandle, this);
    } finally {
      ffi_mem.calloc.free(extentsPtr);
    }
  }

  @override
  SphereShape createSphereShape(double radius) {
    _checkDisposed();
    final shapeHandle = ffi_gen.rp3d_physics_common_create_sphere_shape(_handle!, radius);
    if (shapeHandle.address == 0) {
      throw Exception('Failed to create SphereShape');
    }
    return FFISphereShape.internal(shapeHandle, this);
  }

  @override
  CapsuleShape createCapsuleShape(double radius, double height) {
    _checkDisposed();
    final shapeHandle = ffi_gen.rp3d_physics_common_create_capsule_shape(_handle!, radius, height);
    if (shapeHandle.address == 0) {
      throw Exception('Failed to create CapsuleShape');
    }
    return FFICapsuleShape.internal(shapeHandle, this);
  }

  void _checkDisposed() {
    if (_handle == null) {
      throw Exception('PhysicsCommon has been disposed');
    }
  }

  /// Internal getter for shape classes to call destroy methods
  ffi.Pointer<ffi_gen.RP3D_PhysicsCommon>? get handleForShapes => _handle;

  /// Helper function to convert Vector3 to FFI Vector3
  ffi.Pointer<ffi_gen.RP3D_Vector3> _toFFIVector3(Vector3 v) {
    final ptr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    ptr.ref.x = v.x;
    ptr.ref.y = v.y;
    ptr.ref.z = v.z;
    return ptr;
  }
}