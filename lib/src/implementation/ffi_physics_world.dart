import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_mem;
import 'package:reactphysics3d_dart/src/implementation/ffi_rigid_body.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

import '../ffi_reactphysics3d.dart';
import '../reactphysics3d.dart';

/// FFI implementation of PhysicsWorld
class FFIPhysicsWorld implements PhysicsWorld {
  final ffi.Pointer<ffi_gen.RP3D_PhysicsWorld> _ptr;

  FFIPhysicsWorld(this._ptr);

  @override
  ffi.Pointer<ffi_gen.RP3D_PhysicsWorld> get handle => _ptr;

  @override
  void update(double timeStep) {
    ffi_gen.rp3d_world_update(_ptr, timeStep);
  }

  @override
  void setGravity(Vector3 gravity) {
    final gravityPtr = _toFFIVector3(gravity);
    try {
      ffi_gen.rp3d_world_set_gravity(_ptr, gravityPtr);
    } finally {
      ffi_mem.calloc.free(gravityPtr);
    }
  }

  @override
  Vector3 getGravity() {
    final outPtr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    try {
      ffi_gen.rp3d_world_get_gravity(_ptr, outPtr);
      return Vector3(outPtr.ref.x, outPtr.ref.y, outPtr.ref.z);
    } finally {
      ffi_mem.calloc.free(outPtr);
    }
  }

  @override
  RigidBody createRigidBody({Transform? transform}) {
    transform ??= (
      orientation: Quaternion.identity(),
      position: Vector3.zero(),
    );
    final struct = transform.toStruct();

    final bodyPtr = ffi_gen.rp3d_world_create_rigid_body(_ptr, struct.address);
    if (bodyPtr.address == 0) {
      throw Exception('Failed to create RigidBody');
    }
    return FFIRigidBody(bodyPtr);
  }

  @override
  void destroyRigidBody(RigidBody body) {
    throw UnimplementedError('RigidBody destruction not yet implemented');
  }

  @override
  void setIsGravityEnabled(bool isEnabled) {
    ffi_gen.rp3d_world_set_is_gravity_enabled(_ptr, isEnabled ? 1 : 0);
  }

  @override
  void enableSleeping(bool isSleepingEnabled) {
    ffi_gen.rp3d_world_set_is_sleeping_enabled(_ptr, isSleepingEnabled ? 1 : 0);
  }

  @override
  void setSleepLinearVelocity(double sleepLinearVelocity) {
    ffi_gen.rp3d_world_set_sleep_linear_velocity(_ptr, sleepLinearVelocity);
  }

  @override
  void setSleepAngularVelocity(double sleepAngularVelocity) {
    ffi_gen.rp3d_world_set_sleep_angular_velocity(_ptr, sleepAngularVelocity);
  }

  @override
  void setTimeBeforeSleep(double timeBeforeSleep) {
    ffi_gen.rp3d_world_set_time_before_sleep(_ptr, timeBeforeSleep);
  }

  @override
  int getNbRigidBodies() {
    return ffi_gen.rp3d_world_get_nb_rigid_bodies(_ptr);
  }

  @override
  RigidBody getRigidBody(int index) {
    final bodyPtr = ffi_gen.rp3d_world_get_rigid_body(_ptr, index);
    if (bodyPtr.address == 0) {
      throw Exception('Failed to get RigidBody at index $index');
    }
    // TODO: Return FFIRigidBody implementation when created
    throw UnimplementedError('RigidBody implementation not yet created');
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
