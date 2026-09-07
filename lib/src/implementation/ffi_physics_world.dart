import 'native_lifetime.dart';
import 'ffi_physics_common.dart';
import 'sendport_event_listener.dart';
import 'package:reactphysics3d_dart/src/implementation/ffi_rigid_body.dart';
import 'package:reactphysics3d_dart/src/implementation/ffi_debug_renderer.dart';
import 'package:reactphysics3d_dart/src/implementation/ffi_collider.dart';
import 'package:reactphysics3d_dart/src/interfaces/event_listener.dart';
import '../bindings/src/bindings.dart';
import '../ffi_reactphysics3d.dart';
import '../reactphysics3d.dart';

/// FFI implementation of PhysicsWorld
class FFIPhysicsWorld implements PhysicsWorld {
  final Pointer<RP3D_PhysicsWorld> _raw;
  final FFIPhysicsCommon common;
  late final lifetime = NativeLifetime(common.lifetime);
  final bodies = <int, FFIRigidBody>{};
  final colliders = <int, FFICollider>{};
  EventListener? _listener;
  FFIPhysicsWorld(this._raw, this.common);
  Pointer<RP3D_PhysicsWorld> get _ptr {
    lifetime.check();
    return _raw;
  }

  FFIRigidBody bodyAtAddress(int address) {
    lifetime.check();
    return bodies[address] ?? (throw StateError('Body is no longer alive'));
  }

  FFICollider colliderAtAddress(int address) {
    lifetime.check();
    return colliders[address] ??
        (throw StateError('Collider is no longer alive'));
  }

  void discardPendingEvents() {
    final listener = _listener;
    if (listener is SendPortEventListener) listener.discardPendingEvents();
  }

  void _checkBody(RigidBody body) {
    lifetime.check();
    if (body is! FFIRigidBody || !identical(body.world, this)) {
      throw ArgumentError('Body belongs to another world');
    }
    body.lifetime.check();
  }

  @override
  Pointer<RP3D_PhysicsWorld> get handle => _ptr;

  @override
  void update(double timeStep) {
    if (!timeStep.isFinite || timeStep <= 0) {
      throw ArgumentError.value(
        timeStep,
        'timeStep',
        'Must be finite and positive',
      );
    }
    rp3d_world_update(_ptr, timeStep);
  }

  @override
  void setGravity(Vector3 gravity) {
    final stack = saveNativeStack();
    try {
      final gravityPtr = _toFFIVector3(gravity);

      rp3d_world_set_gravity(_ptr, gravityPtr.address);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  Vector3 getGravity() {
    final stack = saveNativeStack();
    try {
      final outPtr = StructAllocator.create<RP3D_Vector3>();
      rp3d_world_get_gravity(_ptr, outPtr.address);
      return Vector3(outPtr.x, outPtr.y, outPtr.z);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  RigidBody createRigidBody({Transform? transform}) {
    final stack = saveNativeStack();
    try {
      transform ??= (
        orientation: Quaternion.identity(),
        position: Vector3.zero(),
      );
      final struct = transform.toStruct();

      final bodyPtr = rp3d_world_create_rigid_body(_ptr, struct.address);
      if (bodyPtr.address == 0) {
        throw Exception('Failed to create RigidBody');
      }
      final body = FFIRigidBody(bodyPtr, this);
      bodies[bodyPtr.address] = body;
      return body;
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  void destroyRigidBody(RigidBody body) {
    final stack = saveNativeStack();
    try {
      lifetime.check();
      if (body is! FFIRigidBody || !identical(body.world, this)) {
        throw ArgumentError('Body belongs to another world');
      }
      if (body.lifetime.isDisposed) return;
      discardPendingEvents();
      final pointer = body.handle;
      rp3d_world_destroy_rigid_body(_ptr, pointer);
      body.invalidate();
      bodies.remove(pointer.address);
    } finally {
      restoreNativeStack(stack);
    }
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
    final stack = saveNativeStack();
    try {
      RangeError.checkValueInInterval(
        index,
        0,
        getNbRigidBodies() - 1,
        'index',
      );
      final bodyPtr = rp3d_world_get_rigid_body(_ptr, index);
      if (bodyPtr.address == 0) {
        throw Exception('Failed to get RigidBody at index $index');
      }
      return bodyAtAddress(bodyPtr.address);
    } finally {
      restoreNativeStack(stack);
    }
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
    final stack = saveNativeStack();
    try {
      final rendererPtr = rp3d_world_get_debug_renderer(_ptr);
      if (rendererPtr.address == 0) {
        throw Exception('Failed to get DebugRenderer');
      }
      return FFIDebugRenderer(rendererPtr, lifetime);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  RaycastInfo? raycast(Ray ray) {
    final stack = saveNativeStack();
    try {
      // Create FFI ray struct
      final rayStruct = StructAllocator.create<RP3D_Ray>();
      rayStruct.point1.x = ray.point1.x;
      rayStruct.point1.y = ray.point1.y;
      rayStruct.point1.z = ray.point1.z;
      rayStruct.point2.x = ray.point2.x;
      rayStruct.point2.y = ray.point2.y;
      rayStruct.point2.z = ray.point2.z;
      rayStruct.maxFraction = 1.0;

      // Create raycast info struct to receive results
      final raycastInfoStruct = StructAllocator.create<RP3D_RaycastInfo>();

      // Perform raycast
      final hasHit = rp3d_world_raycast(
        _ptr,
        rayStruct.address,
        raycastInfoStruct.address,
      );

      if (hasHit == 0) {
        return null;
      }

      // Convert results to Dart objects
      final body = raycastInfoStruct.body.address != 0
          ? bodyAtAddress(raycastInfoStruct.body.address)
          : null;
      final collider = raycastInfoStruct.collider.address != 0
          ? colliderAtAddress(raycastInfoStruct.collider.address)
          : null;

      return RaycastInfo(
        body: body,
        collider: collider,
        worldPoint: Vector3(
          raycastInfoStruct.worldPoint.x,
          raycastInfoStruct.worldPoint.y,
          raycastInfoStruct.worldPoint.z,
        ),
        worldNormal: Vector3(
          raycastInfoStruct.worldNormal.x,
          raycastInfoStruct.worldNormal.y,
          raycastInfoStruct.worldNormal.z,
        ),
        hitFraction: raycastInfoStruct.hitFraction,
      );
    } finally {
      restoreNativeStack(stack);
    }
  }

  /// Helper function to convert Vector3 to FFI Vector3
  RP3D_Vector3 _toFFIVector3(Vector3 v) {
    final ptr = StructAllocator.create<RP3D_Vector3>();
    ptr.x = v.x;
    ptr.y = v.y;
    ptr.z = v.z;
    return ptr;
  }

  /// Convert FFI collision callback data to Dart ContactCallbackData
  ContactCallbackData _convertToContactCallbackData(
    Pointer<RP3D_CollisionCallbackData> dataPtr,
  ) {
    if (dataPtr == nullptr) throw StateError('Collision query failed');
    final data = dataPtr.ref;
    final contactPairs = <ContactPair>[];

    for (var i = 0; i < data.nbContactPairs; i++) {
      final pairData = data.contactPairs[i];

      // Skip pairs with invalid body/collider pointers
      if (pairData.body1.address == 0 ||
          pairData.body2.address == 0 ||
          pairData.collider1.address == 0 ||
          pairData.collider2.address == 0) {
        continue;
      }

      // Convert contact points
      final contactPoints = <ContactPoint>[];
      for (var j = 0; j < pairData.nbContactPoints; j++) {
        final pointData = pairData.contactPoints[j];
        contactPoints.add(
          ContactPoint(
            penetrationDepth: pointData.penetrationDepth,
            worldNormal: Vector3(
              pointData.worldNormal.x,
              pointData.worldNormal.y,
              pointData.worldNormal.z,
            ),
            localPointOnCollider1: Vector3(
              pointData.localPointOnCollider1.x,
              pointData.localPointOnCollider1.y,
              pointData.localPointOnCollider1.z,
            ),
            localPointOnCollider2: Vector3(
              pointData.localPointOnCollider2.x,
              pointData.localPointOnCollider2.y,
              pointData.localPointOnCollider2.z,
            ),
          ),
        );
      }

      // Convert event type
      final eventType = switch (pairData.eventType) {
        0 => ContactEventType.contactStart,
        1 => ContactEventType.contactStay,
        2 => ContactEventType.contactExit,
        _ => ContactEventType.contactStart,
      };

      // Create body/collider wrappers
      final body1 = bodyAtAddress(pairData.body1.address);
      final body2 = bodyAtAddress(pairData.body2.address);
      final collider1 = colliderAtAddress(pairData.collider1.address);
      final collider2 = colliderAtAddress(pairData.collider2.address);

      contactPairs.add(
        ContactPair(
          body1: body1,
          body2: body2,
          collider1: collider1,
          collider2: collider2,
          eventType: eventType,
          contactPoints: contactPoints,
        ),
      );
    }

    return ContactCallbackData(contactPairs: contactPairs);
  }

  @override
  void testCollisionTwoBodies(
    RigidBody body1,
    RigidBody body2,
    CollisionCallback callback,
  ) {
    _checkBody(body1);
    _checkBody(body2);
    final resultPtr = rp3d_test_collision_two_bodies_sync(
      _ptr,
      body1.handle.cast<RP3D_Body>(),
      body2.handle.cast<RP3D_Body>(),
    );

    try {
      final callbackData = _convertToContactCallbackData(resultPtr);
      callback.onContact(callbackData);
    } finally {
      rp3d_free_collision_callback_data(resultPtr);
    }
  }

  @override
  void testCollisionBody(RigidBody body, CollisionCallback callback) {
    _checkBody(body);
    final resultPtr = rp3d_test_collision_body_sync(
      _ptr,
      body.handle.cast<RP3D_Body>(),
    );

    try {
      final callbackData = _convertToContactCallbackData(resultPtr);
      callback.onContact(callbackData);
    } finally {
      rp3d_free_collision_callback_data(resultPtr);
    }
  }

  @override
  void testCollision(CollisionCallback callback) {
    final resultPtr = rp3d_test_collision_world_sync(_ptr);

    try {
      final callbackData = _convertToContactCallbackData(resultPtr);
      callback.onContact(callbackData);
    } finally {
      rp3d_free_collision_callback_data(resultPtr);
    }
  }

  @override
  void testOverlap(CollisionCallback callback) {
    final stack = saveNativeStack();
    try {
      final resultPtr = rp3d_test_overlap_world_sync(_ptr);

      try {
        // Convert overlap data to contact callback data (with empty contact points)
        final data = resultPtr.ref;
        final contactPairs = <ContactPair>[];

        for (var i = 0; i < data.nbOverlapPairs; i++) {
          final pairData = data.overlapPairs[i];

          // Skip pairs with invalid body/collider pointers
          if (pairData.body1.address == 0 ||
              pairData.body2.address == 0 ||
              pairData.collider1.address == 0 ||
              pairData.collider2.address == 0) {
            continue;
          }

          // Convert event type
          final eventType = switch (pairData.eventType) {
            0 => ContactEventType.contactStart,
            1 => ContactEventType.contactStay,
            2 => ContactEventType.contactExit,
            _ => ContactEventType.contactStart,
          };

          // Create body/collider wrappers
          final body1 = bodyAtAddress(pairData.body1.address);
          final body2 = bodyAtAddress(pairData.body2.address);
          final collider1 = colliderAtAddress(pairData.collider1.address);
          final collider2 = colliderAtAddress(pairData.collider2.address);

          contactPairs.add(
            ContactPair(
              body1: body1,
              body2: body2,
              collider1: collider1,
              collider2: collider2,
              eventType: eventType,
              contactPoints: [], // Overlaps don't have contact points
            ),
          );
        }

        final callbackData = ContactCallbackData(contactPairs: contactPairs);
        callback.onContact(callbackData);
      } finally {
        rp3d_free_overlap_callback_data(resultPtr);
      }
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  void setEventListener(EventListener? listener) {
    lifetime.check();
    if (identical(listener, _listener)) return;
    // Validate before detaching the current listener.
    if (listener is SendPortEventListener) listener.checkCanAttach(this);
    final pointer = listener?.pointer ?? nullptr;
    final previous = _listener;
    rp3d_world_set_event_listener(_ptr, pointer);
    if (previous is SendPortEventListener) previous.detachFromWorld(this);
    _listener = listener;
    if (listener is SendPortEventListener) listener.attachToWorld(this);
  }

  @override
  void dispose() {
    if (lifetime.isDisposed) return;
    setEventListener(null);
    rp3d_physics_common_destroy_physics_world(common.handle, _raw);
    for (final body in bodies.values) {
      body.invalidate();
    }
    bodies.clear();
    colliders.clear();
    lifetime.invalidate();
    common.worlds.remove(this);
  }
}
