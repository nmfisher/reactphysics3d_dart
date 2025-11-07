/*
 * ReactPhysics3D C API
 *
 * This header provides a C-compatible API wrapper around the ReactPhysics3D C++ library.
 * It enables FFI bindings for Dart and WASM/Emscripten compilation.
 */

#pragma once

#include <stdint.h>
#include <stddef.h>

#ifdef __EMSCRIPTEN__
#include <emscripten/emscripten.h>
#endif

#ifndef EMSCRIPTEN_KEEPALIVE
#define EMSCRIPTEN_KEEPALIVE
#endif

#ifdef __cplusplus
extern "C" {
#endif

// ==================== Opaque Type Declarations ====================
// These represent C++ objects but are exposed as opaque pointers to C/FFI

typedef struct RP3D_PhysicsCommon RP3D_PhysicsCommon;
typedef struct RP3D_PhysicsWorld RP3D_PhysicsWorld;
typedef struct RP3D_RigidBody RP3D_RigidBody;
typedef struct RP3D_Collider RP3D_Collider;
typedef struct RP3D_CollisionShape RP3D_CollisionShape;
typedef struct RP3D_BoxShape RP3D_BoxShape;
typedef struct RP3D_SphereShape RP3D_SphereShape;
typedef struct RP3D_CapsuleShape RP3D_CapsuleShape;
typedef struct RP3D_ConvexMeshShape RP3D_ConvexMeshShape;
typedef struct RP3D_ConcaveMeshShape RP3D_ConcaveMeshShape;
typedef struct RP3D_HeightFieldShape RP3D_HeightFieldShape;
typedef struct RP3D_TriangleMesh RP3D_TriangleMesh;
typedef struct RP3D_TriangleVertexArray RP3D_TriangleVertexArray;
typedef struct RP3D_PolygonVertexArray RP3D_PolygonVertexArray;
typedef struct RP3D_ConvexMesh RP3D_ConvexMesh;
typedef struct RP3D_HeightField RP3D_HeightField;
typedef struct RP3D_Material RP3D_Material;
typedef struct RP3D_BallAndSocketJoint RP3D_BallAndSocketJoint;
typedef struct RP3D_HingeJoint RP3D_HingeJoint;
typedef struct RP3D_SliderJoint RP3D_SliderJoint;
typedef struct RP3D_FixedJoint RP3D_FixedJoint;
typedef struct RP3D_DebugRenderer RP3D_DebugRenderer;

// ==================== Enums ====================

typedef enum {
    RP3D_BODY_TYPE_STATIC = 1,
    RP3D_BODY_TYPE_KINEMATIC = 2,
    RP3D_BODY_TYPE_DYNAMIC = 3
} RP3D_BodyType;

typedef enum {
    RP3D_DEBUG_ITEM_COLLIDER_AABB = 1,
    RP3D_DEBUG_ITEM_COLLIDER_BROADPHASE_AABB = 2,
    RP3D_DEBUG_ITEM_COLLISION_SHAPE = 4,
    RP3D_DEBUG_ITEM_CONTACT_POINT = 8,
    RP3D_DEBUG_ITEM_CONTACT_NORMAL = 16
} RP3D_DebugItem;

// ==================== Value Types (POD Structs) ====================

typedef struct {
    float x;
    float y;
    float z;
} RP3D_Vector3;

typedef struct {
    float x;
    float y;
    float z;
    float w;
} RP3D_Quaternion;

typedef struct {
    RP3D_Vector3 position;
    RP3D_Quaternion orientation;
} RP3D_Transform;

typedef struct {
    RP3D_Vector3 min;
    RP3D_Vector3 max;
} RP3D_AABB;

typedef struct {
    RP3D_Vector3 point1;
    RP3D_Vector3 point2;
    float maxFraction;
} RP3D_Ray;

typedef struct {
    RP3D_RigidBody* body;
    RP3D_Collider* collider;
    RP3D_Vector3 worldPoint;
    RP3D_Vector3 worldNormal;
    float hitFraction;
} RP3D_RaycastInfo;

// Joint info structures
typedef struct {
    RP3D_Vector3 anchorPointWorldSpace;
    RP3D_RigidBody* body1;
    RP3D_RigidBody* body2;
    uint8_t isCollisionEnabled;
} RP3D_BallAndSocketJointInfo;

typedef struct {
    RP3D_Vector3 anchorPointWorldSpace;
    RP3D_Vector3 rotationAxisWorld;
    RP3D_RigidBody* body1;
    RP3D_RigidBody* body2;
    uint8_t isCollisionEnabled;
    uint8_t isLimitEnabled;
    uint8_t isMotorEnabled;
    float minAngleLimit;
    float maxAngleLimit;
    float motorSpeed;
    float maxMotorTorque;
} RP3D_HingeJointInfo;

typedef struct {
    RP3D_Vector3 anchorPointWorldSpace;
    RP3D_Vector3 sliderAxisWorldSpace;
    RP3D_RigidBody* body1;
    RP3D_RigidBody* body2;
    uint8_t isCollisionEnabled;
    uint8_t isLimitEnabled;
    uint8_t isMotorEnabled;
    float minTranslationLimit;
    float maxTranslationLimit;
    float motorSpeed;
    float maxMotorForce;
} RP3D_SliderJointInfo;

typedef struct {
    RP3D_Vector3 anchorPointWorldSpace;
    RP3D_RigidBody* body1;
    RP3D_RigidBody* body2;
    uint8_t isCollisionEnabled;
} RP3D_FixedJointInfo;

// ==================== PhysicsCommon (Factory) ====================

EMSCRIPTEN_KEEPALIVE RP3D_PhysicsCommon* rp3d_physics_common_create(void);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy(RP3D_PhysicsCommon* common);

EMSCRIPTEN_KEEPALIVE RP3D_PhysicsWorld* rp3d_physics_common_create_physics_world(RP3D_PhysicsCommon* common);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_physics_world(RP3D_PhysicsCommon* common, RP3D_PhysicsWorld* world);

// Shape creation through PhysicsCommon
EMSCRIPTEN_KEEPALIVE RP3D_BoxShape* rp3d_physics_common_create_box_shape(RP3D_PhysicsCommon* common, const RP3D_Vector3* halfExtents);
EMSCRIPTEN_KEEPALIVE RP3D_SphereShape* rp3d_physics_common_create_sphere_shape(RP3D_PhysicsCommon* common, float radius);
EMSCRIPTEN_KEEPALIVE RP3D_CapsuleShape* rp3d_physics_common_create_capsule_shape(RP3D_PhysicsCommon* common, float radius, float height);

// HeightField creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_HeightField* rp3d_physics_common_create_height_field(
    RP3D_PhysicsCommon* common,
    uint32_t nbRows,
    uint32_t nbColumns,
    const float* heights,
    float minHeight,
    float maxHeight
);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_height_field(RP3D_PhysicsCommon* common, RP3D_HeightField* heightField);

// HeightFieldShape creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_HeightFieldShape* rp3d_physics_common_create_height_field_shape(RP3D_PhysicsCommon* common, RP3D_HeightField* heightField);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_height_field_shape(RP3D_PhysicsCommon* common, RP3D_HeightFieldShape* heightFieldShape);

// TriangleVertexArray creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_TriangleVertexArray* rp3d_triangle_vertex_array_create(
    uint32_t nbVertices,
    const float* verticesStart,
    uint32_t verticesStride,
    uint32_t nbIndices,
    const uint32_t* indicesStart,
    uint32_t indicesStride
);
EMSCRIPTEN_KEEPALIVE void rp3d_triangle_vertex_array_destroy(RP3D_TriangleVertexArray* triangleVertexArray);

// TriangleVertexArray accessors
EMSCRIPTEN_KEEPALIVE uint32_t rp3d_triangle_vertex_array_get_nb_vertices(const RP3D_TriangleVertexArray* triangleVertexArray);
EMSCRIPTEN_KEEPALIVE uint32_t rp3d_triangle_vertex_array_get_nb_triangles(const RP3D_TriangleVertexArray* triangleVertexArray);
EMSCRIPTEN_KEEPALIVE const float* rp3d_triangle_vertex_array_get_vertices_start(const RP3D_TriangleVertexArray* triangleVertexArray);
EMSCRIPTEN_KEEPALIVE const uint32_t* rp3d_triangle_vertex_array_get_indices_start(const RP3D_TriangleVertexArray* triangleVertexArray);
EMSCRIPTEN_KEEPALIVE void rp3d_triangle_vertex_array_get_triangle_vertices_indices(
    const RP3D_TriangleVertexArray* triangleVertexArray,
    uint32_t triangleIndex,
    uint32_t* out
);

// PolygonVertexArray creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_PolygonVertexArray* rp3d_polygon_vertex_array_create(
    uint32_t nbVertices,
    const float* verticesStart,
    uint32_t verticesStride,
    uint32_t nbIndices,
    const uint32_t* indicesStart,
    uint32_t indicesStride,
    const uint32_t* polygonIndicesStart,
    uint32_t polygonIndicesStride
);
EMSCRIPTEN_KEEPALIVE void rp3d_polygon_vertex_array_destroy(RP3D_PolygonVertexArray* polygonVertexArray);

// TriangleMesh creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_TriangleMesh* rp3d_physics_common_create_triangle_mesh(
    RP3D_PhysicsCommon* common,
    RP3D_TriangleVertexArray* triangleVertexArray
);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_triangle_mesh(RP3D_PhysicsCommon* common, RP3D_TriangleMesh* triangleMesh);

// TriangleMesh accessors
EMSCRIPTEN_KEEPALIVE uint32_t rp3d_triangle_mesh_get_nb_vertices(const RP3D_TriangleMesh* triangleMesh);
EMSCRIPTEN_KEEPALIVE uint32_t rp3d_triangle_mesh_get_nb_triangles(const RP3D_TriangleMesh* triangleMesh);
EMSCRIPTEN_KEEPALIVE void rp3d_triangle_mesh_get_vertex(
    const RP3D_TriangleMesh* triangleMesh,
    uint32_t vertexIndex,
    RP3D_Vector3* outVertex
);
EMSCRIPTEN_KEEPALIVE void rp3d_triangle_mesh_get_triangle_vertices_indices(
    const RP3D_TriangleMesh* triangleMesh,
    uint32_t triangleIndex,
    uint32_t *indices
);

// ConvexMesh creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_ConvexMesh* rp3d_physics_common_create_convex_mesh_from_triangles(
    RP3D_PhysicsCommon* common,
    RP3D_TriangleVertexArray* triangleVertexArray
);
EMSCRIPTEN_KEEPALIVE RP3D_ConvexMesh* rp3d_physics_common_create_convex_mesh_from_polygons(
    RP3D_PhysicsCommon* common,
    RP3D_PolygonVertexArray* polygonVertexArray
);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_convex_mesh(RP3D_PhysicsCommon* common, RP3D_ConvexMesh* convexMesh);

// ConvexMeshShape creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_ConvexMeshShape* rp3d_physics_common_create_convex_mesh_shape(
    RP3D_PhysicsCommon* common,
    RP3D_ConvexMesh* convexMesh
);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_convex_mesh_shape(RP3D_PhysicsCommon* common, RP3D_ConvexMeshShape* convexMeshShape);

// ConcaveMeshShape creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_ConcaveMeshShape* rp3d_physics_common_create_concave_mesh_shape(
    RP3D_PhysicsCommon* common,
    RP3D_TriangleMesh* triangleMesh,
    const RP3D_Vector3* scaling
);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_concave_mesh_shape(RP3D_PhysicsCommon* common, RP3D_ConcaveMeshShape* concaveMeshShape);

// Mesh/shape destruction
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_box_shape(RP3D_PhysicsCommon* common, RP3D_BoxShape* shape);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_sphere_shape(RP3D_PhysicsCommon* common, RP3D_SphereShape* shape);
EMSCRIPTEN_KEEPALIVE void rp3d_physics_common_destroy_capsule_shape(RP3D_PhysicsCommon* common, RP3D_CapsuleShape* shape);

// ==================== PhysicsWorld ====================

EMSCRIPTEN_KEEPALIVE void rp3d_world_update(RP3D_PhysicsWorld* world, float timeStep);
EMSCRIPTEN_KEEPALIVE void rp3d_world_set_gravity(RP3D_PhysicsWorld* world, const RP3D_Vector3* gravity);
EMSCRIPTEN_KEEPALIVE void rp3d_world_get_gravity(const RP3D_PhysicsWorld* world, RP3D_Vector3* outGravity);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_world_get_is_sleeping_enabled(const RP3D_PhysicsWorld* world);
EMSCRIPTEN_KEEPALIVE void rp3d_world_set_is_sleeping_enabled(RP3D_PhysicsWorld* world, uint8_t isSleepingEnabled);

// Gravity and sleep control
EMSCRIPTEN_KEEPALIVE void rp3d_world_set_is_gravity_enabled(RP3D_PhysicsWorld* world, uint8_t isGravityEnabled);
EMSCRIPTEN_KEEPALIVE void rp3d_world_set_sleep_linear_velocity(RP3D_PhysicsWorld* world, float sleepLinearVelocity);
EMSCRIPTEN_KEEPALIVE void rp3d_world_set_sleep_angular_velocity(RP3D_PhysicsWorld* world, float sleepAngularVelocity);
EMSCRIPTEN_KEEPALIVE void rp3d_world_set_time_before_sleep(RP3D_PhysicsWorld* world, float timeBeforeSleep);

// Debug rendering
EMSCRIPTEN_KEEPALIVE void rp3d_world_set_is_debug_rendering_enabled(RP3D_PhysicsWorld* world, uint8_t isEnabled);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_world_get_is_debug_rendering_enabled(const RP3D_PhysicsWorld* world);
EMSCRIPTEN_KEEPALIVE RP3D_DebugRenderer* rp3d_world_get_debug_renderer(RP3D_PhysicsWorld* world);

EMSCRIPTEN_KEEPALIVE uint32_t rp3d_world_get_nb_rigid_bodies(const RP3D_PhysicsWorld* world);
EMSCRIPTEN_KEEPALIVE RP3D_RigidBody* rp3d_world_get_rigid_body(RP3D_PhysicsWorld* world, uint32_t index);

// Body creation/destruction
EMSCRIPTEN_KEEPALIVE RP3D_RigidBody* rp3d_world_create_rigid_body(RP3D_PhysicsWorld* world, const RP3D_Transform* transform);
EMSCRIPTEN_KEEPALIVE void rp3d_world_destroy_rigid_body(RP3D_PhysicsWorld* world, RP3D_RigidBody* body);

// Raycasting
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_world_raycast(const RP3D_PhysicsWorld* world, const RP3D_Ray* ray, RP3D_RaycastInfo* raycastInfo);

// ==================== RigidBody ====================

EMSCRIPTEN_KEEPALIVE void rp3d_body_get_transform(const RP3D_RigidBody* body, RP3D_Transform* outTransform);
EMSCRIPTEN_KEEPALIVE void rp3d_body_set_transform(RP3D_RigidBody* body, float posX, float posY, float posZ, float quatX, float quatY, float quatZ, float quatW);

EMSCRIPTEN_KEEPALIVE void rp3d_body_get_position(const RP3D_RigidBody* body, RP3D_Vector3* outPosition);
EMSCRIPTEN_KEEPALIVE void rp3d_body_get_orientation(const RP3D_RigidBody* body, RP3D_Quaternion* outOrientation);

EMSCRIPTEN_KEEPALIVE void rp3d_body_set_type(RP3D_RigidBody* body, RP3D_BodyType type);
EMSCRIPTEN_KEEPALIVE RP3D_BodyType rp3d_body_get_type(const RP3D_RigidBody* body);

EMSCRIPTEN_KEEPALIVE void rp3d_body_set_mass(RP3D_RigidBody* body, float mass);
EMSCRIPTEN_KEEPALIVE float rp3d_body_get_mass(const RP3D_RigidBody* body);

EMSCRIPTEN_KEEPALIVE void rp3d_body_set_linear_velocity(RP3D_RigidBody* body, const RP3D_Vector3* linearVelocity);
EMSCRIPTEN_KEEPALIVE void rp3d_body_get_linear_velocity(const RP3D_RigidBody* body, RP3D_Vector3* outLinearVelocity);

EMSCRIPTEN_KEEPALIVE void rp3d_body_set_angular_velocity(RP3D_RigidBody* body, const RP3D_Vector3* angularVelocity);
EMSCRIPTEN_KEEPALIVE void rp3d_body_get_angular_velocity(const RP3D_RigidBody* body, RP3D_Vector3* outAngularVelocity);

EMSCRIPTEN_KEEPALIVE void rp3d_body_apply_force(RP3D_RigidBody* body, const RP3D_Vector3* force);
EMSCRIPTEN_KEEPALIVE void rp3d_body_apply_force_at_position(RP3D_RigidBody* body, const RP3D_Vector3* force, const RP3D_Vector3* position);
EMSCRIPTEN_KEEPALIVE void rp3d_body_apply_torque(RP3D_RigidBody* body, const RP3D_Vector3* torque);

EMSCRIPTEN_KEEPALIVE void rp3d_body_set_is_active(RP3D_RigidBody* body, uint8_t isActive);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_body_get_is_active(const RP3D_RigidBody* body);

EMSCRIPTEN_KEEPALIVE void rp3d_body_set_is_sleeping_allowed(RP3D_RigidBody* body, uint8_t isAllowed);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_body_get_is_sleeping_allowed(const RP3D_RigidBody* body);

// Gravity control
EMSCRIPTEN_KEEPALIVE void rp3d_body_enable_gravity(RP3D_RigidBody* body, uint8_t enableGravity);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_body_is_gravity_enabled(const RP3D_RigidBody* body);

// Debug rendering
EMSCRIPTEN_KEEPALIVE void rp3d_body_set_is_debug_enabled(RP3D_RigidBody* body, uint8_t isEnabled);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_body_get_is_debug_enabled(const RP3D_RigidBody* body);

// Mass properties
EMSCRIPTEN_KEEPALIVE void rp3d_body_update_mass_properties_from_colliders(RP3D_RigidBody* body);

// Collider management
EMSCRIPTEN_KEEPALIVE RP3D_Collider* rp3d_body_add_collider(RP3D_RigidBody* body, RP3D_CollisionShape* shape, const RP3D_Transform* transform);
EMSCRIPTEN_KEEPALIVE void rp3d_body_remove_collider(RP3D_RigidBody* body, RP3D_Collider* collider);

EMSCRIPTEN_KEEPALIVE void rp3d_collider_set_material(RP3D_Collider* collider, const RP3D_Material* material);

// ==================== Collider ====================

EMSCRIPTEN_KEEPALIVE RP3D_Material* rp3d_collider_get_material(RP3D_Collider* collider);
EMSCRIPTEN_KEEPALIVE void rp3d_collider_get_local_bounds(const RP3D_Collider* collider, RP3D_AABB* outAABB);

EMSCRIPTEN_KEEPALIVE void rp3d_collider_set_is_trigger(RP3D_Collider* collider, uint8_t isTrigger);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_collider_get_is_trigger(const RP3D_Collider* collider);

// ==================== Material ====================
EMSCRIPTEN_KEEPALIVE void rp3d_material_destroy(RP3D_Material* material);

EMSCRIPTEN_KEEPALIVE void rp3d_material_set_bounciness(RP3D_Material* material, float bounciness);
EMSCRIPTEN_KEEPALIVE float rp3d_material_get_bounciness(const RP3D_Material* material);

EMSCRIPTEN_KEEPALIVE void rp3d_material_set_friction_coefficient(RP3D_Material* material, float frictionCoefficient);
EMSCRIPTEN_KEEPALIVE float rp3d_material_get_friction_coefficient(const RP3D_Material* material);

EMSCRIPTEN_KEEPALIVE void rp3d_material_set_mass_density(RP3D_Material* material, float massDensity);
EMSCRIPTEN_KEEPALIVE float rp3d_material_get_mass_density(const RP3D_Material* material);

// ==================== CollisionShape (base) ====================

EMSCRIPTEN_KEEPALIVE void rp3d_shape_get_local_bounds(const RP3D_CollisionShape* shape, RP3D_AABB* outAABB);
EMSCRIPTEN_KEEPALIVE void rp3d_concave_shape_set_scale(RP3D_HeightFieldShape *shape, const RP3D_Vector3* scale);

// ==================== HeightFieldShape ====================

EMSCRIPTEN_KEEPALIVE void rp3d_height_field_shape_get_vertex_at(
    const RP3D_HeightFieldShape* heightFieldShape,
    uint32_t row,
    uint32_t column,
    RP3D_Vector3* outVertex
);

// ==================== Math Utilities ====================

// Vector3
EMSCRIPTEN_KEEPALIVE void rp3d_vector3_zero(RP3D_Vector3* v);
EMSCRIPTEN_KEEPALIVE float rp3d_vector3_length(const RP3D_Vector3* v);
EMSCRIPTEN_KEEPALIVE void rp3d_vector3_normalize(RP3D_Vector3* v);
EMSCRIPTEN_KEEPALIVE float rp3d_vector3_dot(const RP3D_Vector3* v1, const RP3D_Vector3* v2);
EMSCRIPTEN_KEEPALIVE void rp3d_vector3_cross(const RP3D_Vector3* v1, const RP3D_Vector3* v2, RP3D_Vector3* outResult);

// Quaternion
EMSCRIPTEN_KEEPALIVE void rp3d_quaternion_identity(RP3D_Quaternion* q);
EMSCRIPTEN_KEEPALIVE void rp3d_quaternion_from_axis_angle(const RP3D_Vector3* axis, float angle, RP3D_Quaternion* outQuat);
EMSCRIPTEN_KEEPALIVE void rp3d_quaternion_normalize(RP3D_Quaternion* q);

// Transform
EMSCRIPTEN_KEEPALIVE void rp3d_transform_identity(RP3D_Transform* t);
EMSCRIPTEN_KEEPALIVE void rp3d_transform_inverse(const RP3D_Transform* t, RP3D_Transform* outInverse);
EMSCRIPTEN_KEEPALIVE void rp3d_transform_get_opengl_matrix(const RP3D_Transform* t, float* outMatrix);

// ==================== DebugRenderer ====================

EMSCRIPTEN_KEEPALIVE void rp3d_debug_renderer_set_is_debug_item_displayed(RP3D_DebugRenderer* renderer, RP3D_DebugItem item, uint8_t isDisplayed);
EMSCRIPTEN_KEEPALIVE uint8_t rp3d_debug_renderer_get_is_debug_item_displayed(const RP3D_DebugRenderer* renderer, RP3D_DebugItem item);
EMSCRIPTEN_KEEPALIVE uint32_t rp3d_debug_renderer_get_nb_lines(const RP3D_DebugRenderer* renderer);
EMSCRIPTEN_KEEPALIVE uint32_t rp3d_debug_renderer_get_nb_triangles(const RP3D_DebugRenderer* renderer);
EMSCRIPTEN_KEEPALIVE void rp3d_debug_renderer_get_lines_array(const RP3D_DebugRenderer* renderer, float* outVertices, uint32_t* outColors);
EMSCRIPTEN_KEEPALIVE void rp3d_debug_renderer_get_triangles_array(const RP3D_DebugRenderer* renderer, float* outVertices, uint32_t* outColors);

// ==================== Joints ====================

EMSCRIPTEN_KEEPALIVE RP3D_BallAndSocketJoint* rp3d_world_create_ball_and_socket_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_BallAndSocketJointInfo* jointInfo
);

EMSCRIPTEN_KEEPALIVE RP3D_HingeJoint* rp3d_world_create_hinge_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_HingeJointInfo* jointInfo
);

EMSCRIPTEN_KEEPALIVE RP3D_SliderJoint* rp3d_world_create_slider_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_SliderJointInfo* jointInfo
);

EMSCRIPTEN_KEEPALIVE RP3D_FixedJoint* rp3d_world_create_fixed_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_FixedJointInfo* jointInfo
);

EMSCRIPTEN_KEEPALIVE void rp3d_world_destroy_joint(RP3D_PhysicsWorld* world, void* joint);

#ifdef __cplusplus
}
#endif
