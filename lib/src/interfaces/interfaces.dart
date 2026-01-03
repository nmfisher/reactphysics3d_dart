/// Barrel export for all ReactPhysics3D interface classes
///
/// This file provides a single convenient import point for all interface
/// classes used in the ReactPhysics3D Dart binding.
library;

// Base interface
export 'base_rp3d_type.dart';

// Core physics interfaces
export 'physics_common.dart';
export 'physics_world.dart';

// Body and component interfaces
export 'rigid_body.dart';
export 'collider.dart';

// Shape and material interfaces
export 'collision_shape.dart';
export 'material.dart';

// Collision callback interfaces
export 'collision_callback.dart';
export 'overlap_callback.dart';

// Debug rendering interfaces
export 'debug_renderer.dart';
export 'debug_item.dart';
export 'debug_structures.dart';

// Math and transform interfaces
export 'transform.dart';