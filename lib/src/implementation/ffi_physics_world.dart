import 'package:reactphysics3d_dart/src/implementation/ffi_rigid_body.dart';
import 'package:reactphysics3d_dart/src/implementation/ffi_debug_renderer.dart';
import '../bindings/src/bindings.dart';
import '../ffi_reactphysics3d.dart';
import '../reactphysics3d.dart';

/// FFI implementation of PhysicsWorld
class FFIPhysicsWorld implements PhysicsWorld {
  final Pointer<RP3D_PhysicsWorld> _ptr;

  FFIPhysicsWorld(this._ptr);

  @override
  Pointer<RP3D_PhysicsWorld> get handle => _ptr;

  @override
  void update(double timeStep) {
    rp3d_world_update(_ptr, timeStep);
  }

  @override
  void setGravity(Vector3 gravity) {
    final gravityPtr = _toFFIVector3(gravity);

    rp3d_world_set_gravity(_ptr, gravityPtr.address);
  }

  @override
  Vector3 getGravity() {
    final outPtr = StructAllocator.create<RP3D_Vector3>();
    rp3d_world_get_gravity(_ptr, outPtr.address);
    return Vector3(outPtr.x, outPtr.y, outPtr.z);
  }

  @override
  RigidBody createRigidBody({Transform? transform}) {
    transform ??= (
      orientation: Quaternion.identity(),
      position: Vector3.zero(),
    );
    final struct = transform.toStruct();

    final bodyPtr = rp3d_world_create_rigid_body(_ptr, struct.address);
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
    rp3d_world_set_is_gravity_enabled(_ptr, isEnabled ? 1 : 0);
  }

  @override
  void enableSleeping(bool isSleepingEnabled) {
    rp3d_world_set_is_sleeping_enabled(_ptr, isSleepingEnabled ? 1 : 0);
  }

  @override
  void setSleepLinearVelocity(double sleepLinearVelocity) {
    rp3d_world_set_sleep_linear_velocity(_ptr, sleepLinearVelocity);
  }

  @override
  void setSleepAngularVelocity(double sleepAngularVelocity) {
    rp3d_world_set_sleep_angular_velocity(_ptr, sleepAngularVelocity);
  }

  @override
  void setTimeBeforeSleep(double timeBeforeSleep) {
    rp3d_world_set_time_before_sleep(_ptr, timeBeforeSleep);
  }

  @override
  int getNbRigidBodies() {
    return rp3d_world_get_nb_rigid_bodies(_ptr);
  }

  @override
  RigidBody getRigidBody(int index) {
    final bodyPtr = rp3d_world_get_rigid_body(_ptr, index);
    if (bodyPtr.address == 0) {
      throw Exception('Failed to get RigidBody at index $index');
    }
    // TODO: Return FFIRigidBody implementation when created
    throw UnimplementedError('RigidBody implementation not yet created');
  }

  @override
  void setIsDebugRenderingEnabled(bool isEnabled) {
    rp3d_world_set_is_debug_rendering_enabled(_ptr, isEnabled ? 1 : 0);
  }

  @override
  bool getIsDebugRenderingEnabled() {
    final result = rp3d_world_get_is_debug_rendering_enabled(_ptr);
    return result != 0;
  }

  @override
  DebugRenderer getDebugRenderer() {
    final rendererPtr = rp3d_world_get_debug_renderer(_ptr);
    if (rendererPtr.address == 0) {
      throw Exception('Failed to get DebugRenderer');
    }
    return FFIDebugRenderer(rendererPtr);
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
