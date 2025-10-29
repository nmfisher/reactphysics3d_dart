import 'dart:ffi' as ffi;
import '../../reactphysics3d_dart.dart';
import 'collision_shape.dart';
import 'physics_world.dart';
import 'base_rp3d_type.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// Interface for physics common operations
abstract class PhysicsCommon extends BaseRP3DType<ffi.Pointer<ffi_gen.RP3D_PhysicsCommon>> {
  /// Create a new physics world
  PhysicsWorld createPhysicsWorld();

  /// Create a box shape
  BoxShape createBoxShape(Vector3 extent);

  /// Create a sphere shape
  SphereShape createSphereShape(double radius);

  /// Create a capsule shape
  CapsuleShape createCapsuleShape(double radius, double height);
}