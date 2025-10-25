/// Physics simulation test
///
/// Tests the ReactPhysics3D Dart bindings by running a simple physics simulation:
/// - Creates a static floor
/// - Creates a dynamic sphere above the floor
/// - Runs simulation and verifies the sphere falls due to gravity
library;

import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:reactphysics3d_dart/src/bindings/src/rp3d_ffi.g.dart';

void main() {
  print('ReactPhysics3D Dart Package - Physics Test');
  print('=' * 60);

  // Test 1: Basic library loading
  print('\n[Test 1] Loading ReactPhysics3D library...');
  try {
    final common = rp3d_physics_common_create();
    if (common == ffi.nullptr) {
      print('✗ FAILED: Could not create PhysicsCommon');
      exit(1);
    }
    print('✓ PASSED: PhysicsCommon created successfully');

    // Clean up for next test
    rp3d_physics_common_destroy(common);
  } catch (e) {
    print('✗ FAILED: Error loading library - $e');
    exit(1);
  }

  // Test 2: Create physics world
  print('\n[Test 2] Creating physics world...');
  final common = rp3d_physics_common_create();
  final world = rp3d_physics_common_create_physics_world(common);

  if (world == ffi.nullptr) {
    print('✗ FAILED: Could not create PhysicsWorld');
    rp3d_physics_common_destroy(common);
    exit(1);
  }
  print('✓ PASSED: PhysicsWorld created successfully');

  // Test 3: Set gravity
  print('\n[Test 3] Setting gravity...');
  final gravity = calloc<RP3D_Vector3>();
  gravity.ref.x = 0.0;
  gravity.ref.y = -9.81;
  gravity.ref.z = 0.0;
  rp3d_world_set_gravity(world, gravity);
  print('✓ PASSED: Gravity set to (0, -9.81, 0)');

  // Test 4: Create static floor
  print('\n[Test 4] Creating static floor...');

  // Create floor transform (at y = 0)
  final floorTransform = calloc<RP3D_Transform>();
  floorTransform.ref.position.x = 0.0;
  floorTransform.ref.position.y = 0.0;
  floorTransform.ref.position.z = 0.0;
  floorTransform.ref.orientation.x = 0.0;
  floorTransform.ref.orientation.y = 0.0;
  floorTransform.ref.orientation.z = 0.0;
  floorTransform.ref.orientation.w = 1.0;

  // Create floor body
  final floorBody = rp3d_world_create_rigid_body(world, floorTransform);
  if (floorBody == ffi.nullptr) {
    print('✗ FAILED: Could not create floor body');
    cleanup(common, world, gravity, floorTransform);
    exit(1);
  }

  // Set as static body (type = 1)
  rp3d_body_set_type(floorBody, 1); // RP3D_BODY_TYPE_STATIC = 1

  // Create box shape for floor (10x0.5x10 meters)
  final floorHalfExtents = calloc<RP3D_Vector3>();
  floorHalfExtents.ref.x = 10.0;
  floorHalfExtents.ref.y = 0.5;
  floorHalfExtents.ref.z = 10.0;
  final floorShape = rp3d_physics_common_create_box_shape(common, floorHalfExtents);

  // Add collider to floor
  final floorColliderTransform = calloc<RP3D_Transform>();
  floorColliderTransform.ref.position.x = 0.0;
  floorColliderTransform.ref.position.y = 0.0;
  floorColliderTransform.ref.position.z = 0.0;
  floorColliderTransform.ref.orientation.x = 0.0;
  floorColliderTransform.ref.orientation.y = 0.0;
  floorColliderTransform.ref.orientation.z = 0.0;
  floorColliderTransform.ref.orientation.w = 1.0;

  final floorCollider = rp3d_body_add_collider(floorBody, floorShape.cast(), floorColliderTransform);
  if (floorCollider == ffi.nullptr) {
    print('✗ FAILED: Could not create floor collider');
    cleanup(common, world, gravity, floorTransform, floorHalfExtents, floorColliderTransform);
    exit(1);
  }
  print('✓ PASSED: Static floor created at y=0');

  // Test 5: Create dynamic sphere
  print('\n[Test 5] Creating dynamic sphere...');

  // Create sphere transform (5 meters above floor)
  final sphereTransform = calloc<RP3D_Transform>();
  sphereTransform.ref.position.x = 0.0;
  sphereTransform.ref.position.y = 5.0;
  sphereTransform.ref.position.z = 0.0;
  sphereTransform.ref.orientation.x = 0.0;
  sphereTransform.ref.orientation.y = 0.0;
  sphereTransform.ref.orientation.z = 0.0;
  sphereTransform.ref.orientation.w = 1.0;

  // Create sphere body
  final sphereBody = rp3d_world_create_rigid_body(world, sphereTransform);
  if (sphereBody == ffi.nullptr) {
    print('✗ FAILED: Could not create sphere body');
    cleanup(common, world, gravity, floorTransform, floorHalfExtents,
            floorColliderTransform, sphereTransform);
    exit(1);
  }

  // Set as dynamic body (type = 3)
  rp3d_body_set_type(sphereBody, 3); // RP3D_BODY_TYPE_DYNAMIC = 3
  rp3d_body_set_mass(sphereBody, 1.0); // 1 kg mass

  // Create sphere shape (0.5 meter radius)
  final sphereShape = rp3d_physics_common_create_sphere_shape(common, 0.5);

  // Add collider to sphere
  final sphereColliderTransform = calloc<RP3D_Transform>();
  sphereColliderTransform.ref.position.x = 0.0;
  sphereColliderTransform.ref.position.y = 0.0;
  sphereColliderTransform.ref.position.z = 0.0;
  sphereColliderTransform.ref.orientation.x = 0.0;
  sphereColliderTransform.ref.orientation.y = 0.0;
  sphereColliderTransform.ref.orientation.z = 0.0;
  sphereColliderTransform.ref.orientation.w = 1.0;

  final sphereCollider = rp3d_body_add_collider(sphereBody, sphereShape.cast(), sphereColliderTransform);
  if (sphereCollider == ffi.nullptr) {
    print('✗ FAILED: Could not create sphere collider');
    cleanup(common, world, gravity, floorTransform, floorHalfExtents,
            floorColliderTransform, sphereTransform, sphereColliderTransform);
    exit(1);
  }

  // Enable gravity and update mass properties
  rp3d_body_enable_gravity(sphereBody, 1);
  rp3d_body_update_mass_properties_from_colliders(sphereBody);

  print('✓ PASSED: Dynamic sphere created at y=5.0');

  // Test 6: Run physics simulation
  print('\n[Test 6] Running physics simulation...');
  print('-' * 60);

  final position = calloc<RP3D_Vector3>();
  final velocity = calloc<RP3D_Vector3>();

  double timeStep = 1.0 / 60.0; // 60 FPS
  int steps = 120; // 2 seconds of simulation

  print('Time(s)  | Position Y | Velocity Y | Status');
  print('-' * 60);

  double initialY = 5.0;
  double previousY = initialY;
  bool hasStartedFalling = false;
  bool hasHitFloor = false;

  for (int i = 0; i < steps; i++) {
    // Update physics
    rp3d_world_update(world, timeStep);

    // Get sphere position and velocity
    rp3d_body_get_position(sphereBody, position);
    rp3d_body_get_linear_velocity(sphereBody, velocity);

    double currentY = position.ref.y;
    double velY = velocity.ref.y;

    // Print every 10 steps (every ~0.167 seconds)
    if (i % 10 == 0) {
      double time = i * timeStep;
      String status = '';

      if (currentY < previousY - 0.01) {
        hasStartedFalling = true;
        status = 'Falling';
      }

      if (hasStartedFalling && currentY <= 1.0 && !hasHitFloor) {
        hasHitFloor = true;
        status = 'Hit floor!';
      } else if (hasHitFloor) {
        status = 'On floor';
      }

      print('${time.toStringAsFixed(2).padLeft(7)} | '
            '${currentY.toStringAsFixed(4).padLeft(10)} | '
            '${velY.toStringAsFixed(4).padLeft(10)} | '
            '$status');
    }

    previousY = currentY;
  }

  // Verify sphere has fallen
  rp3d_body_get_position(sphereBody, position);
  double finalY = position.ref.y;

  print('-' * 60);
  print('\nSimulation Results:');
  print('  Initial Y: ${initialY.toStringAsFixed(2)}');
  print('  Final Y:   ${finalY.toStringAsFixed(2)}');
  print('  Distance fallen: ${(initialY - finalY).toStringAsFixed(2)} meters');

  // Cleanup
  calloc.free(position);
  calloc.free(velocity);

  // Verify physics worked
  print('\n[Test 7] Verifying physics simulation...');
  if (finalY < initialY - 2.0) {
    print('✓ PASSED: Sphere fell due to gravity');
    print('✓ PASSED: Physics simulation working correctly!');
  } else {
    print('✗ FAILED: Sphere did not fall as expected');
    print('  Expected final Y < ${initialY - 2.0}, got $finalY');
    cleanup(common, world, gravity, floorTransform, floorHalfExtents,
            floorColliderTransform, sphereTransform, sphereColliderTransform);
    exit(1);
  }

  // Final cleanup
  print('\n[Test 8] Cleaning up...');
  cleanup(common, world, gravity, floorTransform, floorHalfExtents,
          floorColliderTransform, sphereTransform, sphereColliderTransform);
  print('✓ PASSED: All resources cleaned up');

  // Summary
  print('\n' + '=' * 60);
  print('ALL TESTS PASSED! ✓');
  print('=' * 60);
  print('\nReactPhysics3D Dart bindings are working correctly!');
  print('You can now:');
  print('  1. Create complex physics simulations');
  print('  2. Build games with realistic physics');
  print('  3. Add collision detection to your apps');
}

void cleanup(
  ffi.Pointer<RP3D_PhysicsCommon> common,
  ffi.Pointer<RP3D_PhysicsWorld> world,
  ffi.Pointer<RP3D_Vector3> gravity,
  ffi.Pointer<RP3D_Transform> floorTransform, [
  ffi.Pointer<RP3D_Vector3>? floorHalfExtents,
  ffi.Pointer<RP3D_Transform>? floorColliderTransform,
  ffi.Pointer<RP3D_Transform>? sphereTransform,
  ffi.Pointer<RP3D_Transform>? sphereColliderTransform,
]) {
  calloc.free(gravity);
  calloc.free(floorTransform);
  if (floorHalfExtents != null) calloc.free(floorHalfExtents);
  if (floorColliderTransform != null) calloc.free(floorColliderTransform);
  if (sphereTransform != null) calloc.free(sphereTransform);
  if (sphereColliderTransform != null) calloc.free(sphereColliderTransform);

  if (world != ffi.nullptr) {
    rp3d_physics_common_destroy_physics_world(common, world);
  }
  if (common != ffi.nullptr) {
    rp3d_physics_common_destroy(common);
  }
}
