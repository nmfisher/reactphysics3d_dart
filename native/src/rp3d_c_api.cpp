/*
 * ReactPhysics3D C API Implementation
 *
 * This file implements the C wrapper around ReactPhysics3D C++ library.
 * Only implements minimal functionality needed for collision detection.
 */

#include "c_api/rp3d_c_api.h"
#include <reactphysics3d/reactphysics3d.h>
#include <cstring>

using namespace reactphysics3d;

// ==================== Type Conversions ====================

static Vector3 to_rp3d_vector3(const RP3D_Vector3* v) {
    return Vector3(v->x, v->y, v->z);
}

static void from_rp3d_vector3(const Vector3& v, RP3D_Vector3* out) {
    out->x = v.x;
    out->y = v.y;
    out->z = v.z;
}

static Quaternion to_rp3d_quaternion(const RP3D_Quaternion* q) {
    return Quaternion(q->x, q->y, q->z, q->w);
}

static void from_rp3d_quaternion(const Quaternion& q, RP3D_Quaternion* out) {
    out->x = q.x;
    out->y = q.y;
    out->z = q.z;
    out->w = q.w;
}

static Transform to_rp3d_transform(const RP3D_Transform* t) {
    return Transform(to_rp3d_vector3(&t->position), to_rp3d_quaternion(&t->orientation));
}

static void from_rp3d_transform(const Transform& t, RP3D_Transform* out) {
    from_rp3d_vector3(t.getPosition(), &out->position);
    from_rp3d_quaternion(t.getOrientation(), &out->orientation);
}

// ==================== PhysicsCommon (Factory) ====================

RP3D_PhysicsCommon* rp3d_physics_common_create(void) {
    return reinterpret_cast<RP3D_PhysicsCommon*>(new PhysicsCommon());
}

void rp3d_physics_common_destroy(RP3D_PhysicsCommon* common) {
    delete reinterpret_cast<PhysicsCommon*>(common);
}

RP3D_PhysicsWorld* rp3d_physics_common_create_physics_world(RP3D_PhysicsCommon* common) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    PhysicsWorld* world = pc->createPhysicsWorld();
    return reinterpret_cast<RP3D_PhysicsWorld*>(world);
}

void rp3d_physics_common_destroy_physics_world(RP3D_PhysicsCommon* common, RP3D_PhysicsWorld* world) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pc->destroyPhysicsWorld(pw);
}

// Shape creation through PhysicsCommon
RP3D_BoxShape* rp3d_physics_common_create_box_shape(RP3D_PhysicsCommon* common, const RP3D_Vector3* halfExtents) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    Vector3 extents = to_rp3d_vector3(halfExtents);
    BoxShape* shape = pc->createBoxShape(extents);
    return reinterpret_cast<RP3D_BoxShape*>(shape);
}

RP3D_SphereShape* rp3d_physics_common_create_sphere_shape(RP3D_PhysicsCommon* common, float radius) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    SphereShape* shape = pc->createSphereShape(radius);
    return reinterpret_cast<RP3D_SphereShape*>(shape);
}

RP3D_CapsuleShape* rp3d_physics_common_create_capsule_shape(RP3D_PhysicsCommon* common, float radius, float height) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    CapsuleShape* shape = pc->createCapsuleShape(radius, height);
    return reinterpret_cast<RP3D_CapsuleShape*>(shape);
}

// Shape destruction
void rp3d_physics_common_destroy_box_shape(RP3D_PhysicsCommon* common, RP3D_BoxShape* shape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    BoxShape* bs = reinterpret_cast<BoxShape*>(shape);
    pc->destroyBoxShape(bs);
}

void rp3d_physics_common_destroy_sphere_shape(RP3D_PhysicsCommon* common, RP3D_SphereShape* shape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    SphereShape* ss = reinterpret_cast<SphereShape*>(shape);
    pc->destroySphereShape(ss);
}

void rp3d_physics_common_destroy_capsule_shape(RP3D_PhysicsCommon* common, RP3D_CapsuleShape* shape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    CapsuleShape* cs = reinterpret_cast<CapsuleShape*>(shape);
    pc->destroyCapsuleShape(cs);
}

// ==================== PhysicsWorld ====================

void rp3d_world_update(RP3D_PhysicsWorld* world, float timeStep) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->update(timeStep);
}

void rp3d_world_set_gravity(RP3D_PhysicsWorld* world, const RP3D_Vector3* gravity) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setGravity(to_rp3d_vector3(gravity));
}

void rp3d_world_get_gravity(const RP3D_PhysicsWorld* world, RP3D_Vector3* outGravity) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);
    from_rp3d_vector3(pw->getGravity(), outGravity);
}

uint8_t rp3d_world_get_is_sleeping_enabled(const RP3D_PhysicsWorld* world) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);
    return pw->isSleepingEnabled() ? 1 : 0;
}

void rp3d_world_set_is_sleeping_enabled(RP3D_PhysicsWorld* world, uint8_t isSleepingEnabled) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->enableSleeping(isSleepingEnabled != 0);
}

// Gravity and sleep control
void rp3d_world_set_is_gravity_enabled(RP3D_PhysicsWorld* world, uint8_t isGravityEnabled) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setIsGravityEnabled(isGravityEnabled != 0);
}

void rp3d_world_set_sleep_linear_velocity(RP3D_PhysicsWorld* world, float sleepLinearVelocity) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setSleepLinearVelocity(sleepLinearVelocity);
}

void rp3d_world_set_sleep_angular_velocity(RP3D_PhysicsWorld* world, float sleepAngularVelocity) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setSleepAngularVelocity(sleepAngularVelocity);
}

void rp3d_world_set_time_before_sleep(RP3D_PhysicsWorld* world, float timeBeforeSleep) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setTimeBeforeSleep(timeBeforeSleep);
}

uint32_t rp3d_world_get_nb_rigid_bodies(const RP3D_PhysicsWorld* world) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);
    return pw->getNbRigidBodies();
}

RP3D_RigidBody* rp3d_world_get_rigid_body(RP3D_PhysicsWorld* world, uint32_t index) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    RigidBody* body = pw->getRigidBody(index);
    return reinterpret_cast<RP3D_RigidBody*>(body);
}

// Body creation/destruction
RP3D_RigidBody* rp3d_world_create_rigid_body(RP3D_PhysicsWorld* world, const RP3D_Transform* transform) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    Transform t = to_rp3d_transform(transform);
    RigidBody* body = pw->createRigidBody(t);
    return reinterpret_cast<RP3D_RigidBody*>(body);
}

void rp3d_world_destroy_rigid_body(RP3D_PhysicsWorld* world, RP3D_RigidBody* body) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    pw->destroyRigidBody(rb);
}

// Raycasting helper class
class SingleRaycastCallback : public RaycastCallback {
    public:
        Vector3 worldPoint;
        Vector3 worldNormal;
        decimal hitFraction;
        Body* body;
        Collider* collider;
        bool hasHit;

        SingleRaycastCallback() : hitFraction(-1), body(nullptr), collider(nullptr), hasHit(false) {}

        virtual decimal notifyRaycastHit(const RaycastInfo& info) override {
            worldPoint = info.worldPoint;
            worldNormal = info.worldNormal;
            hitFraction = info.hitFraction;
            body = info.body;
            collider = info.collider;
            hasHit = true;
            // Return the hit fraction to clip the ray at this point
            return info.hitFraction;
        }
};

// Raycasting
uint8_t rp3d_world_raycast(const RP3D_PhysicsWorld* world, const RP3D_Ray* ray, RP3D_RaycastInfo* raycastInfo) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);

    Ray r(to_rp3d_vector3(&ray->point1), to_rp3d_vector3(&ray->point2));
    SingleRaycastCallback callback;

    pw->raycast(r, &callback);

    if (callback.hasHit) {
        raycastInfo->body = reinterpret_cast<RP3D_RigidBody*>(callback.body);
        raycastInfo->collider = reinterpret_cast<RP3D_Collider*>(callback.collider);
        from_rp3d_vector3(callback.worldPoint, &raycastInfo->worldPoint);
        from_rp3d_vector3(callback.worldNormal, &raycastInfo->worldNormal);
        raycastInfo->hitFraction = callback.hitFraction;
        return 1;
    }

    return 0;
}

// ==================== RigidBody ====================

void rp3d_body_get_transform(const RP3D_RigidBody* body, RP3D_Transform* outTransform) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_transform(rb->getTransform(), outTransform);
}

void rp3d_body_set_transform(RP3D_RigidBody* body, const RP3D_Transform* transform) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setTransform(to_rp3d_transform(transform));
}

void rp3d_body_get_position(const RP3D_RigidBody* body, RP3D_Vector3* outPosition) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_vector3(rb->getTransform().getPosition(), outPosition);
}

void rp3d_body_get_orientation(const RP3D_RigidBody* body, RP3D_Quaternion* outOrientation) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_quaternion(rb->getTransform().getOrientation(), outOrientation);
}

void rp3d_body_set_type(RP3D_RigidBody* body, RP3D_BodyType type) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    BodyType bt;

    switch (type) {
        case RP3D_BODY_TYPE_STATIC:
            bt = BodyType::STATIC;
            break;
        case RP3D_BODY_TYPE_KINEMATIC:
            bt = BodyType::KINEMATIC;
            break;
        case RP3D_BODY_TYPE_DYNAMIC:
            bt = BodyType::DYNAMIC;
            break;
        default:
            bt = BodyType::DYNAMIC;
            break;
    }

    rb->setType(bt);
}

RP3D_BodyType rp3d_body_get_type(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    BodyType bt = rb->getType();

    switch (bt) {
        case BodyType::STATIC:
            return RP3D_BODY_TYPE_STATIC;
        case BodyType::KINEMATIC:
            return RP3D_BODY_TYPE_KINEMATIC;
        case BodyType::DYNAMIC:
            return RP3D_BODY_TYPE_DYNAMIC;
        default:
            return RP3D_BODY_TYPE_DYNAMIC;
    }
}

void rp3d_body_set_mass(RP3D_RigidBody* body, float mass) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setMass(mass);
}

float rp3d_body_get_mass(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->getMass();
}

void rp3d_body_set_linear_velocity(RP3D_RigidBody* body, const RP3D_Vector3* linearVelocity) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setLinearVelocity(to_rp3d_vector3(linearVelocity));
}

void rp3d_body_get_linear_velocity(const RP3D_RigidBody* body, RP3D_Vector3* outLinearVelocity) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_vector3(rb->getLinearVelocity(), outLinearVelocity);
}

void rp3d_body_set_angular_velocity(RP3D_RigidBody* body, const RP3D_Vector3* angularVelocity) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setAngularVelocity(to_rp3d_vector3(angularVelocity));
}

void rp3d_body_get_angular_velocity(const RP3D_RigidBody* body, RP3D_Vector3* outAngularVelocity) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_vector3(rb->getAngularVelocity(), outAngularVelocity);
}

void rp3d_body_apply_force(RP3D_RigidBody* body, const RP3D_Vector3* force) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->applyWorldForceAtCenterOfMass(to_rp3d_vector3(force));
}

void rp3d_body_apply_force_at_position(RP3D_RigidBody* body, const RP3D_Vector3* force, const RP3D_Vector3* position) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->applyWorldForceAtWorldPosition(to_rp3d_vector3(force), to_rp3d_vector3(position));
}

void rp3d_body_apply_torque(RP3D_RigidBody* body, const RP3D_Vector3* torque) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->applyWorldTorque(to_rp3d_vector3(torque));
}

void rp3d_body_set_is_active(RP3D_RigidBody* body, uint8_t isActive) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setIsActive(isActive != 0);
}

uint8_t rp3d_body_get_is_active(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->isActive() ? 1 : 0;
}

void rp3d_body_set_is_sleeping_allowed(RP3D_RigidBody* body, uint8_t isAllowed) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setIsAllowedToSleep(isAllowed != 0);
}

uint8_t rp3d_body_get_is_sleeping_allowed(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->isAllowedToSleep() ? 1 : 0;
}

// Gravity control
void rp3d_body_enable_gravity(RP3D_RigidBody* body, uint8_t enableGravity) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->enableGravity(enableGravity != 0);
}

uint8_t rp3d_body_is_gravity_enabled(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->isGravityEnabled() ? 1 : 0;
}

// Mass properties
void rp3d_body_update_mass_properties_from_colliders(RP3D_RigidBody* body) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->updateMassPropertiesFromColliders();
}

// Collider management
RP3D_Collider* rp3d_body_add_collider(RP3D_RigidBody* body, RP3D_CollisionShape* shape, const RP3D_Transform* transform) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    CollisionShape* cs = reinterpret_cast<CollisionShape*>(shape);
    Transform t = to_rp3d_transform(transform);

    Collider* collider = rb->addCollider(cs, t);
    return reinterpret_cast<RP3D_Collider*>(collider);
}

void rp3d_body_remove_collider(RP3D_RigidBody* body, RP3D_Collider* collider) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    Collider* c = reinterpret_cast<Collider*>(collider);
    rb->removeCollider(c);
}

// ==================== Collider ====================

RP3D_Material* rp3d_collider_get_material(RP3D_Collider* collider) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    Material& material = c->getMaterial();
    return reinterpret_cast<RP3D_Material*>(&material);
}

void rp3d_collider_get_local_bounds(const RP3D_Collider* collider, RP3D_AABB* outAABB) {
    const Collider* c = reinterpret_cast<const Collider*>(collider);
    const CollisionShape* shape = c->getCollisionShape();
    AABB aabb = shape->getLocalBounds();
    from_rp3d_vector3(aabb.getMin(), &outAABB->min);
    from_rp3d_vector3(aabb.getMax(), &outAABB->max);
}

void rp3d_collider_set_is_trigger(RP3D_Collider* collider, uint8_t isTrigger) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    c->setIsTrigger(isTrigger != 0);
}

uint8_t rp3d_collider_get_is_trigger(const RP3D_Collider* collider) {
    const Collider* c = reinterpret_cast<const Collider*>(collider);
    return c->getIsTrigger() ? 1 : 0;
}

// ==================== Material ====================

void rp3d_material_set_bounciness(RP3D_Material* material, float bounciness) {
    Material* m = reinterpret_cast<Material*>(material);
    m->setBounciness(bounciness);
}

float rp3d_material_get_bounciness(const RP3D_Material* material) {
    const Material* m = reinterpret_cast<const Material*>(material);
    return m->getBounciness();
}

void rp3d_material_set_friction_coefficient(RP3D_Material* material, float frictionCoefficient) {
    Material* m = reinterpret_cast<Material*>(material);
    m->setFrictionCoefficient(frictionCoefficient);
}

float rp3d_material_get_friction_coefficient(const RP3D_Material* material) {
    const Material* m = reinterpret_cast<const Material*>(material);
    return m->getFrictionCoefficient();
}

void rp3d_material_set_mass_density(RP3D_Material* material, float massDensity) {
    Material* m = reinterpret_cast<Material*>(material);
    m->setMassDensity(massDensity);
}

float rp3d_material_get_mass_density(const RP3D_Material* material) {
    const Material* m = reinterpret_cast<const Material*>(material);
    return m->getMassDensity();
}

// ==================== CollisionShape (base) ====================

void rp3d_shape_get_local_bounds(const RP3D_CollisionShape* shape, RP3D_AABB* outAABB) {
    const CollisionShape* cs = reinterpret_cast<const CollisionShape*>(shape);
    AABB aabb = cs->getLocalBounds();
    from_rp3d_vector3(aabb.getMin(), &outAABB->min);
    from_rp3d_vector3(aabb.getMax(), &outAABB->max);
}

// ==================== Math Utilities ====================

// Vector3
void rp3d_vector3_zero(RP3D_Vector3* v) {
    v->x = 0.0f;
    v->y = 0.0f;
    v->z = 0.0f;
}

float rp3d_vector3_length(const RP3D_Vector3* v) {
    Vector3 vec = to_rp3d_vector3(v);
    return vec.length();
}

void rp3d_vector3_normalize(RP3D_Vector3* v) {
    Vector3 vec = to_rp3d_vector3(v);
    vec = vec.getUnit();
    from_rp3d_vector3(vec, v);
}

float rp3d_vector3_dot(const RP3D_Vector3* v1, const RP3D_Vector3* v2) {
    Vector3 vec1 = to_rp3d_vector3(v1);
    Vector3 vec2 = to_rp3d_vector3(v2);
    return vec1.dot(vec2);
}

void rp3d_vector3_cross(const RP3D_Vector3* v1, const RP3D_Vector3* v2, RP3D_Vector3* outResult) {
    Vector3 vec1 = to_rp3d_vector3(v1);
    Vector3 vec2 = to_rp3d_vector3(v2);
    Vector3 result = vec1.cross(vec2);
    from_rp3d_vector3(result, outResult);
}

// Quaternion
void rp3d_quaternion_identity(RP3D_Quaternion* q) {
    Quaternion quat = Quaternion::identity();
    from_rp3d_quaternion(quat, q);
}

void rp3d_quaternion_from_axis_angle(const RP3D_Vector3* axis, float angle, RP3D_Quaternion* outQuat) {
    Vector3 axisVec = to_rp3d_vector3(axis);
    Quaternion quat(axisVec, angle);
    from_rp3d_quaternion(quat, outQuat);
}

void rp3d_quaternion_normalize(RP3D_Quaternion* q) {
    Quaternion quat = to_rp3d_quaternion(q);
    quat = quat.getUnit();
    from_rp3d_quaternion(quat, q);
}

// Transform
void rp3d_transform_identity(RP3D_Transform* t) {
    Transform transform = Transform::identity();
    from_rp3d_transform(transform, t);
}

void rp3d_transform_inverse(const RP3D_Transform* t, RP3D_Transform* outInverse) {
    Transform transform = to_rp3d_transform(t);
    Transform inverse = transform.getInverse();
    from_rp3d_transform(inverse, outInverse);
}

// ==================== Joints ====================

RP3D_BallAndSocketJoint* rp3d_world_create_ball_and_socket_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_BallAndSocketJointInfo* jointInfo
) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);

    RigidBody* body1 = reinterpret_cast<RigidBody*>(jointInfo->body1);
    RigidBody* body2 = reinterpret_cast<RigidBody*>(jointInfo->body2);
    Vector3 anchorPoint = to_rp3d_vector3(&jointInfo->anchorPointWorldSpace);

    BallAndSocketJointInfo info(body1, body2, anchorPoint);
    info.isCollisionEnabled = jointInfo->isCollisionEnabled != 0;

    BallAndSocketJoint* joint = dynamic_cast<BallAndSocketJoint*>(pw->createJoint(info));
    return reinterpret_cast<RP3D_BallAndSocketJoint*>(joint);
}

RP3D_HingeJoint* rp3d_world_create_hinge_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_HingeJointInfo* jointInfo
) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);

    RigidBody* body1 = reinterpret_cast<RigidBody*>(jointInfo->body1);
    RigidBody* body2 = reinterpret_cast<RigidBody*>(jointInfo->body2);
    Vector3 anchorPoint = to_rp3d_vector3(&jointInfo->anchorPointWorldSpace);
    Vector3 rotationAxis = to_rp3d_vector3(&jointInfo->rotationAxisWorld);

    HingeJointInfo info(body1, body2, anchorPoint, rotationAxis);
    info.isCollisionEnabled = jointInfo->isCollisionEnabled != 0;
    info.isLimitEnabled = jointInfo->isLimitEnabled != 0;
    info.isMotorEnabled = jointInfo->isMotorEnabled != 0;
    info.minAngleLimit = jointInfo->minAngleLimit;
    info.maxAngleLimit = jointInfo->maxAngleLimit;
    info.motorSpeed = jointInfo->motorSpeed;
    info.maxMotorTorque = jointInfo->maxMotorTorque;

    HingeJoint* joint = dynamic_cast<HingeJoint*>(pw->createJoint(info));
    return reinterpret_cast<RP3D_HingeJoint*>(joint);
}

RP3D_SliderJoint* rp3d_world_create_slider_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_SliderJointInfo* jointInfo
) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);

    RigidBody* body1 = reinterpret_cast<RigidBody*>(jointInfo->body1);
    RigidBody* body2 = reinterpret_cast<RigidBody*>(jointInfo->body2);
    Vector3 anchorPoint = to_rp3d_vector3(&jointInfo->anchorPointWorldSpace);
    Vector3 sliderAxis = to_rp3d_vector3(&jointInfo->sliderAxisWorldSpace);

    SliderJointInfo info(body1, body2, anchorPoint, sliderAxis);
    info.isCollisionEnabled = jointInfo->isCollisionEnabled != 0;
    info.isLimitEnabled = jointInfo->isLimitEnabled != 0;
    info.isMotorEnabled = jointInfo->isMotorEnabled != 0;
    info.minTranslationLimit = jointInfo->minTranslationLimit;
    info.maxTranslationLimit = jointInfo->maxTranslationLimit;
    info.motorSpeed = jointInfo->motorSpeed;
    info.maxMotorForce = jointInfo->maxMotorForce;

    SliderJoint* joint = dynamic_cast<SliderJoint*>(pw->createJoint(info));
    return reinterpret_cast<RP3D_SliderJoint*>(joint);
}

RP3D_FixedJoint* rp3d_world_create_fixed_joint(
    RP3D_PhysicsWorld* world,
    const RP3D_FixedJointInfo* jointInfo
) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);

    RigidBody* body1 = reinterpret_cast<RigidBody*>(jointInfo->body1);
    RigidBody* body2 = reinterpret_cast<RigidBody*>(jointInfo->body2);
    Vector3 anchorPoint = to_rp3d_vector3(&jointInfo->anchorPointWorldSpace);

    FixedJointInfo info(body1, body2, anchorPoint);
    info.isCollisionEnabled = jointInfo->isCollisionEnabled != 0;

    FixedJoint* joint = dynamic_cast<FixedJoint*>(pw->createJoint(info));
    return reinterpret_cast<RP3D_FixedJoint*>(joint);
}

void rp3d_world_destroy_joint(RP3D_PhysicsWorld* world, void* joint) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    Joint* j = reinterpret_cast<Joint*>(joint);
    pw->destroyJoint(j);
}
