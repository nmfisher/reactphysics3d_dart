/// Stub implementation for unsupported platforms
/// This file will be replaced by generated bindings on supported platforms

// ignore_for_file: camel_case_types, non_constant_identifier_names

class RP3D_PhysicsCommon {}
class RP3D_PhysicsWorld {}
class RP3D_RigidBody {}
class RP3D_Collider {}
class RP3D_CollisionShape {}
class RP3D_BoxShape extends RP3D_CollisionShape {}
class RP3D_SphereShape extends RP3D_CollisionShape {}
class RP3D_CapsuleShape extends RP3D_CollisionShape {}
class RP3D_Material {}

enum RP3D_BodyType {
  RP3D_BODY_TYPE_STATIC,
  RP3D_BODY_TYPE_KINEMATIC,
  RP3D_BODY_TYPE_DYNAMIC,
}

class RP3D_Vector3 {
  double x = 0;
  double y = 0;
  double z = 0;
}

class RP3D_Quaternion {
  double x = 0;
  double y = 0;
  double z = 0;
  double w = 1;
}

class RP3D_Transform {
  RP3D_Vector3 position = RP3D_Vector3();
  RP3D_Quaternion orientation = RP3D_Quaternion();
}

// Stub functions that throw
Never _unsupported() {
  throw UnsupportedError('ReactPhysics3D is not supported on this platform');
}

// PhysicsCommon
RP3D_PhysicsCommon? rp3d_physics_common_create() => _unsupported();
void rp3d_physics_common_destroy(RP3D_PhysicsCommon common) => _unsupported();
RP3D_PhysicsWorld? rp3d_physics_common_create_physics_world(RP3D_PhysicsCommon common) => _unsupported();
void rp3d_physics_common_destroy_physics_world(RP3D_PhysicsCommon common, RP3D_PhysicsWorld world) => _unsupported();
RP3D_BoxShape? rp3d_physics_common_create_box_shape(RP3D_PhysicsCommon common, RP3D_Vector3 halfExtents) => _unsupported();
RP3D_SphereShape? rp3d_physics_common_create_sphere_shape(RP3D_PhysicsCommon common, double radius) => _unsupported();
RP3D_CapsuleShape? rp3d_physics_common_create_capsule_shape(RP3D_PhysicsCommon common, double radius, double height) => _unsupported();
void rp3d_physics_common_destroy_box_shape(RP3D_PhysicsCommon common, RP3D_BoxShape shape) => _unsupported();
void rp3d_physics_common_destroy_sphere_shape(RP3D_PhysicsCommon common, RP3D_SphereShape shape) => _unsupported();
void rp3d_physics_common_destroy_capsule_shape(RP3D_PhysicsCommon common, RP3D_CapsuleShape shape) => _unsupported();

// PhysicsWorld
void rp3d_world_update(RP3D_PhysicsWorld world, double timeStep) => _unsupported();
void rp3d_world_set_gravity(RP3D_PhysicsWorld world, RP3D_Vector3 gravity) => _unsupported();
void rp3d_world_get_gravity(RP3D_PhysicsWorld world, RP3D_Vector3 outGravity) => _unsupported();
RP3D_RigidBody? rp3d_world_create_rigid_body(RP3D_PhysicsWorld world, RP3D_Transform transform) => _unsupported();
void rp3d_world_destroy_rigid_body(RP3D_PhysicsWorld world, RP3D_RigidBody body) => _unsupported();

// RigidBody
void rp3d_body_get_transform(RP3D_RigidBody body, RP3D_Transform outTransform) => _unsupported();
void rp3d_body_set_transform(RP3D_RigidBody body, RP3D_Transform transform) => _unsupported();
void rp3d_body_get_position(RP3D_RigidBody body, RP3D_Vector3 outPosition) => _unsupported();
void rp3d_body_get_orientation(RP3D_RigidBody body, RP3D_Quaternion outOrientation) => _unsupported();
void rp3d_body_set_type(RP3D_RigidBody body, RP3D_BodyType type) => _unsupported();
RP3D_BodyType rp3d_body_get_type(RP3D_RigidBody body) => _unsupported();
void rp3d_body_set_mass(RP3D_RigidBody body, double mass) => _unsupported();
double rp3d_body_get_mass(RP3D_RigidBody body) => _unsupported();
void rp3d_body_set_linear_velocity(RP3D_RigidBody body, RP3D_Vector3 velocity) => _unsupported();
void rp3d_body_get_linear_velocity(RP3D_RigidBody body, RP3D_Vector3 outVelocity) => _unsupported();
void rp3d_body_apply_force(RP3D_RigidBody body, RP3D_Vector3 force) => _unsupported();
RP3D_Collider? rp3d_body_add_collider(RP3D_RigidBody body, RP3D_CollisionShape shape, RP3D_Transform transform) => _unsupported();

// Collider
RP3D_Material? rp3d_collider_get_material(RP3D_Collider collider) => _unsupported();
void rp3d_collider_set_is_trigger(RP3D_Collider collider, int isTrigger) => _unsupported();
int rp3d_collider_get_is_trigger(RP3D_Collider collider) => _unsupported();

// Material
void rp3d_material_set_bounciness(RP3D_Material material, double bounciness) => _unsupported();
double rp3d_material_get_bounciness(RP3D_Material material) => _unsupported();
void rp3d_material_set_friction_coefficient(RP3D_Material material, double friction) => _unsupported();
double rp3d_material_get_friction_coefficient(RP3D_Material material) => _unsupported();
void rp3d_material_set_mass_density(RP3D_Material material, double density) => _unsupported();
double rp3d_material_get_mass_density(RP3D_Material material) => _unsupported();
