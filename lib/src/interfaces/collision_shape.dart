import 'dart:ffi' as ffi;
import 'base_rp3d_type.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// Interface for collision shapes
abstract class CollisionShape extends BaseRP3DType<ffi.Pointer<ffi_gen.RP3D_CollisionShape>> {
  /// Dispose of the collision shape
  void dispose();
}

/// Interface for box collision shapes
abstract class BoxShape extends CollisionShape {}

/// Interface for sphere collision shapes
abstract class SphereShape extends CollisionShape {}

/// Interface for capsule collision shapes
abstract class CapsuleShape extends CollisionShape {}