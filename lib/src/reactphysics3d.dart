/// High-level Dart API for ReactPhysics3D physics engine
///
/// This provides a clean, type-safe wrapper around the FFI bindings.

import 'bindings/src/bindings.dart' as bindings;

export 'bindings/src/bindings.dart' show RP3D_BodyType;

// ==================== Exceptions ====================

/// Exception thrown by ReactPhysics3D operations
class ReactPhysics3DException implements Exception {
  final String message;

  const ReactPhysics3DException(this.message);

  @override
  String toString() => 'ReactPhysics3DException: $message';
}

// ==================== Math Types ====================

/// 3D Vector
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  static const Vector3 zero = Vector3(0, 0, 0);

  @override
  String toString() => 'Vector3($x, $y, $z)';

  @override
  bool operator ==(Object other) =>
      other is Vector3 && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// Quaternion for rotations
class Quaternion {
  final double x;
  final double y;
  final double z;
  final double w;

  const Quaternion(this.x, this.y, this.z, this.w);

  static Quaternion identity() => const Quaternion(0, 0, 0, 1);

  factory Quaternion.fromAxisAngle(Vector3 axis, double angle) {
    return Quaternion(axis.x, axis.y, axis.z, angle);
  }

  @override
  String toString() => 'Quaternion($x, $y, $z, $w)';

  @override
  bool operator ==(Object other) =>
      other is Quaternion &&
      x == other.x &&
      y == other.y &&
      z == other.z &&
      w == other.w;

  @override
  int get hashCode => Object.hash(x, y, z, w);
}

/// 3D Transform (position + orientation)
class Transform {
  final Vector3 position;
  final Quaternion orientation;

  const Transform(this.position, this.orientation);

  static Transform identity() =>
      Transform(Vector3.zero, Quaternion.identity());

  Vector3 getPosition() => position;
  Quaternion getOrientation() => orientation;

  @override
  String toString() => 'Transform(position: $position, orientation: $orientation)';

  @override
  bool operator ==(Object other) =>
      other is Transform &&
      position == other.position &&
      orientation == other.orientation;

  @override
  int get hashCode => Object.hash(position, orientation);
}

/// Axis-Aligned Bounding Box
class AABB {
  final Vector3 min;
  final Vector3 max;

  const AABB(this.min, this.max);

  @override
  String toString() => 'AABB(min: $min, max: $max)';
}

// ==================== PhysicsCommon (Factory) ====================

/// Factory class for creating physics objects
///
/// This is the main entry point for using ReactPhysics3D.
/// Create one instance and use it to create physics worlds and shapes.
class PhysicsCommon {
  bindings.RP3D_PhysicsCommon? _handle;

  PhysicsCommon() {
    _handle = bindings.rp3d_physics_common_create();
    if (_handle == null) {
      throw ReactPhysics3DException('Failed to create PhysicsCommon');
    }
  }

  void dispose() {
    if (_handle != null) {
      bindings.rp3d_physics_common_destroy(_handle!);
      _handle = null;
    }
  }

  /// Create a new physics world
  PhysicsWorld createPhysicsWorld() {
    _checkDisposed();
    final worldHandle = bindings.rp3d_physics_common_create_physics_world(_handle!);
    if (worldHandle == null) {
      throw ReactPhysics3DException('Failed to create PhysicsWorld');
    }
    return PhysicsWorld._(worldHandle, this);
  }

  /// Destroy a physics world
  void destroyPhysicsWorld(PhysicsWorld world) {
    _checkDisposed();
    bindings.rp3d_physics_common_destroy_physics_world(_handle!, world._handle!);
    world._handle = null;
  }

  /// Create a box collision shape
  BoxShape createBoxShape(Vector3 halfExtents) {
    _checkDisposed();
    final shapeHandle = bindings.rp3d_physics_common_create_box_shape(
      _handle!,
      _toNativeVector3(halfExtents),
    );
    if (shapeHandle == null) {
      throw ReactPhysics3DException('Failed to create BoxShape');
    }
    return BoxShape._(shapeHandle, this);
  }

  /// Create a sphere collision shape
  SphereShape createSphereShape(double radius) {
    _checkDisposed();
    final shapeHandle = bindings.rp3d_physics_common_create_sphere_shape(_handle!, radius);
    if (shapeHandle == null) {
      throw ReactPhysics3DException('Failed to create SphereShape');
    }
    return SphereShape._(shapeHandle, this);
  }

  /// Create a capsule collision shape
  CapsuleShape createCapsuleShape(double radius, double height) {
    _checkDisposed();
    final shapeHandle = bindings.rp3d_physics_common_create_capsule_shape(_handle!, radius, height);
    if (shapeHandle == null) {
      throw ReactPhysics3DException('Failed to create CapsuleShape');
    }
    return CapsuleShape._(shapeHandle, this);
  }

  void _checkDisposed() {
    if (_handle == null) {
      throw ReactPhysics3DException('PhysicsCommon has been disposed');
    }
  }
}

// ==================== PhysicsWorld ====================

/// Physics simulation world
class PhysicsWorld {
  bindings.RP3D_PhysicsWorld? _handle;
  final PhysicsCommon _common;

  PhysicsWorld._(this._handle, this._common);

  /// Update the physics simulation
  void update(double timeStep) {
    _checkDisposed();
    bindings.rp3d_world_update(_handle!, timeStep);
  }

  /// Set gravity vector
  void setGravity(Vector3 gravity) {
    _checkDisposed();
    bindings.rp3d_world_set_gravity(_handle!, _toNativeVector3(gravity));
  }

  /// Get gravity vector
  Vector3 getGravity() {
    _checkDisposed();
    final native = bindings.RP3D_Vector3();
    bindings.rp3d_world_get_gravity(_handle!, native);
    return _fromNativeVector3(native);
  }

  /// Create a rigid body
  RigidBody createRigidBody(Transform transform) {
    _checkDisposed();
    final bodyHandle = bindings.rp3d_world_create_rigid_body(
      _handle!,
      _toNativeTransform(transform),
    );
    if (bodyHandle == null) {
      throw ReactPhysics3DException('Failed to create RigidBody');
    }
    return RigidBody._(bodyHandle, this);
  }

  /// Destroy a rigid body
  void destroyRigidBody(RigidBody body) {
    _checkDisposed();
    bindings.rp3d_world_destroy_rigid_body(_handle!, body._handle!);
    body._handle = null;
  }

  void _checkDisposed() {
    if (_handle == null) {
      throw ReactPhysics3DException('PhysicsWorld has been disposed');
    }
  }
}

// ==================== RigidBody ====================

/// Rigid body in the physics simulation
class RigidBody {
  bindings.RP3D_RigidBody? _handle;
  final PhysicsWorld _world;

  RigidBody._(this._handle, this._world);

  /// Get the current transform
  Transform getTransform() {
    _checkDisposed();
    final native = bindings.RP3D_Transform();
    bindings.rp3d_body_get_transform(_handle!, native);
    return _fromNativeTransform(native);
  }

  /// Set the transform
  void setTransform(Transform transform) {
    _checkDisposed();
    bindings.rp3d_body_set_transform(_handle!, _toNativeTransform(transform));
  }

  /// Get position
  Vector3 getPosition() {
    _checkDisposed();
    final native = bindings.RP3D_Vector3();
    bindings.rp3d_body_get_position(_handle!, native);
    return _fromNativeVector3(native);
  }

  /// Get orientation
  Quaternion getOrientation() {
    _checkDisposed();
    final native = bindings.RP3D_Quaternion();
    bindings.rp3d_body_get_orientation(_handle!, native);
    return _fromNativeQuaternion(native);
  }

  /// Set body type (static, kinematic, dynamic)
  void setType(bindings.RP3D_BodyType type) {
    _checkDisposed();
    bindings.rp3d_body_set_type(_handle!, type);
  }

  /// Get body type
  bindings.RP3D_BodyType getType() {
    _checkDisposed();
    return bindings.rp3d_body_get_type(_handle!);
  }

  /// Set mass
  void setMass(double mass) {
    _checkDisposed();
    bindings.rp3d_body_set_mass(_handle!, mass);
  }

  /// Get mass
  double getMass() {
    _checkDisposed();
    return bindings.rp3d_body_get_mass(_handle!);
  }

  /// Set linear velocity
  void setLinearVelocity(Vector3 velocity) {
    _checkDisposed();
    bindings.rp3d_body_set_linear_velocity(_handle!, _toNativeVector3(velocity));
  }

  /// Get linear velocity
  Vector3 getLinearVelocity() {
    _checkDisposed();
    final native = bindings.RP3D_Vector3();
    bindings.rp3d_body_get_linear_velocity(_handle!, native);
    return _fromNativeVector3(native);
  }

  /// Apply force at center of mass
  void applyForce(Vector3 force) {
    _checkDisposed();
    bindings.rp3d_body_apply_force(_handle!, _toNativeVector3(force));
  }

  /// Add a collider to this body
  Collider addCollider(CollisionShape shape, Transform transform) {
    _checkDisposed();
    final colliderHandle = bindings.rp3d_body_add_collider(
      _handle!,
      shape._handle,
      _toNativeTransform(transform),
    );
    if (colliderHandle == null) {
      throw ReactPhysics3DException('Failed to add collider');
    }
    return Collider._(colliderHandle, this);
  }

  void _checkDisposed() {
    if (_handle == null) {
      throw ReactPhysics3DException('RigidBody has been disposed');
    }
  }
}

// ==================== Collision Shapes ====================

/// Base class for collision shapes
abstract class CollisionShape {
  final bindings.RP3D_CollisionShape _handle;
  final PhysicsCommon _common;

  CollisionShape._(this._handle, this._common);
}

/// Box collision shape
class BoxShape extends CollisionShape {
  BoxShape._(super.handle, super.common) : super._();

  void dispose() {
    bindings.rp3d_physics_common_destroy_box_shape(
      _common._handle!,
      _handle as bindings.RP3D_BoxShape,
    );
  }
}

/// Sphere collision shape
class SphereShape extends CollisionShape {
  SphereShape._(super.handle, super.common) : super._();

  void dispose() {
    bindings.rp3d_physics_common_destroy_sphere_shape(
      _common._handle!,
      _handle as bindings.RP3D_SphereShape,
    );
  }
}

/// Capsule collision shape
class CapsuleShape extends CollisionShape {
  CapsuleShape._(super.handle, super.common) : super._();

  void dispose() {
    bindings.rp3d_physics_common_destroy_capsule_shape(
      _common._handle!,
      _handle as bindings.RP3D_CapsuleShape,
    );
  }
}

// ==================== Collider ====================

/// Collider attached to a rigid body
class Collider {
  final bindings.RP3D_Collider _handle;
  final RigidBody _body;

  Collider._(this._handle, this._body);

  /// Get material
  Material getMaterial() {
    final materialHandle = bindings.rp3d_collider_get_material(_handle);
    if (materialHandle == null) {
      throw ReactPhysics3DException('Failed to get material');
    }
    return Material._(materialHandle);
  }

  /// Set as trigger
  void setIsTrigger(bool isTrigger) {
    bindings.rp3d_collider_set_is_trigger(_handle, isTrigger ? 1 : 0);
  }

  /// Check if is trigger
  bool getIsTrigger() {
    return bindings.rp3d_collider_get_is_trigger(_handle) != 0;
  }
}

// ==================== Material ====================

/// Material properties for collision
class Material {
  final bindings.RP3D_Material _handle;

  Material._(this._handle);

  /// Set bounciness (0.0 to 1.0)
  void setBounciness(double bounciness) {
    bindings.rp3d_material_set_bounciness(_handle, bounciness);
  }

  /// Get bounciness
  double getBounciness() {
    return bindings.rp3d_material_get_bounciness(_handle);
  }

  /// Set friction coefficient
  void setFrictionCoefficient(double friction) {
    bindings.rp3d_material_set_friction_coefficient(_handle, friction);
  }

  /// Get friction coefficient
  double getFrictionCoefficient() {
    return bindings.rp3d_material_get_friction_coefficient(_handle);
  }

  /// Set mass density
  void setMassDensity(double density) {
    bindings.rp3d_material_set_mass_density(_handle, density);
  }

  /// Get mass density
  double getMassDensity() {
    return bindings.rp3d_material_get_mass_density(_handle);
  }
}

// ==================== Helper Functions ====================

bindings.RP3D_Vector3 _toNativeVector3(Vector3 v) {
  final native = bindings.RP3D_Vector3();
  native.x = v.x;
  native.y = v.y;
  native.z = v.z;
  return native;
}

Vector3 _fromNativeVector3(bindings.RP3D_Vector3 native) {
  return Vector3(native.x, native.y, native.z);
}

bindings.RP3D_Quaternion _toNativeQuaternion(Quaternion q) {
  final native = bindings.RP3D_Quaternion();
  native.x = q.x;
  native.y = q.y;
  native.z = q.z;
  native.w = q.w;
  return native;
}

Quaternion _fromNativeQuaternion(bindings.RP3D_Quaternion native) {
  return Quaternion(native.x, native.y, native.z, native.w);
}

bindings.RP3D_Transform _toNativeTransform(Transform t) {
  final native = bindings.RP3D_Transform();
  native.position = _toNativeVector3(t.position);
  native.orientation = _toNativeQuaternion(t.orientation);
  return native;
}

Transform _fromNativeTransform(bindings.RP3D_Transform native) {
  return Transform(
    _fromNativeVector3(native.position),
    _fromNativeQuaternion(native.orientation),
  );
}
