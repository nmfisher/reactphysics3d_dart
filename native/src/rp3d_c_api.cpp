#include <stdexcept>
#include <cstring>
/*
 * ReactPhysics3D C API Implementation
 *
 * This file implements the C wrapper around ReactPhysics3D C++ library.
 * Only implements minimal functionality needed for collision detection.
 */

#include "c_api/rp3d_c_api.h"
#include <cstring>
#include <vector>
#include <reactphysics3d/reactphysics3d.h>
#include <reactphysics3d/collision/shapes/ConcaveShape.h>
#include <reactphysics3d/collision/shapes/ConvexMeshShape.h>
#include <reactphysics3d/collision/shapes/ConcaveMeshShape.h>
#include <reactphysics3d/collision/TriangleMesh.h>
#include <reactphysics3d/collision/ConvexMesh.h>
#include <reactphysics3d/collision/TriangleVertexArray.h>
#include <reactphysics3d/collision/PolygonVertexArray.h>
#include <reactphysics3d/collision/VertexArray.h>
#include <reactphysics3d/collision/CollisionCallback.h>
#include <reactphysics3d/collision/OverlapCallback.h>
#include <unordered_map>

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

EMSCRIPTEN_KEEPALIVE
RP3D_PhysicsCommon* rp3d_physics_common_create(void) {
    return reinterpret_cast<RP3D_PhysicsCommon*>(new PhysicsCommon());
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy(RP3D_PhysicsCommon* common) {
    delete reinterpret_cast<PhysicsCommon*>(common);
}

EMSCRIPTEN_KEEPALIVE
RP3D_PhysicsWorld* rp3d_physics_common_create_physics_world(RP3D_PhysicsCommon* common) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    PhysicsWorld* world = pc->createPhysicsWorld();
    return reinterpret_cast<RP3D_PhysicsWorld*>(world);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_physics_world(RP3D_PhysicsCommon* common, RP3D_PhysicsWorld* world) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pc->destroyPhysicsWorld(pw);
}

// Shape creation through PhysicsCommon
EMSCRIPTEN_KEEPALIVE
RP3D_BoxShape* rp3d_physics_common_create_box_shape(RP3D_PhysicsCommon* common, const RP3D_Vector3* halfExtents) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    Vector3 extents = to_rp3d_vector3(halfExtents);
    BoxShape* shape = pc->createBoxShape(extents);
    return reinterpret_cast<RP3D_BoxShape*>(shape);
}

EMSCRIPTEN_KEEPALIVE
RP3D_SphereShape* rp3d_physics_common_create_sphere_shape(RP3D_PhysicsCommon* common, float radius) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    SphereShape* shape = pc->createSphereShape(radius);
    return reinterpret_cast<RP3D_SphereShape*>(shape);
}

EMSCRIPTEN_KEEPALIVE
RP3D_CapsuleShape* rp3d_physics_common_create_capsule_shape(RP3D_PhysicsCommon* common, float radius, float height) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    CapsuleShape* shape = pc->createCapsuleShape(radius, height);
    return reinterpret_cast<RP3D_CapsuleShape*>(shape);
}

// Shape destruction
EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_box_shape(RP3D_PhysicsCommon* common, RP3D_BoxShape* shape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    BoxShape* bs = reinterpret_cast<BoxShape*>(shape);
    pc->destroyBoxShape(bs);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_sphere_shape(RP3D_PhysicsCommon* common, RP3D_SphereShape* shape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    SphereShape* ss = reinterpret_cast<SphereShape*>(shape);
    pc->destroySphereShape(ss);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_capsule_shape(RP3D_PhysicsCommon* common, RP3D_CapsuleShape* shape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    CapsuleShape* cs = reinterpret_cast<CapsuleShape*>(shape);
    pc->destroyCapsuleShape(cs);
}

// HeightField creation (float data type)
EMSCRIPTEN_KEEPALIVE
RP3D_HeightField* rp3d_physics_common_create_height_field_float(
    RP3D_PhysicsCommon* common,
    uint32_t nbRows,
    uint32_t nbColumns,
    const float* heights,
    float minHeight,
    float maxHeight,
    char* errorBuffer,
    uint32_t errorBufferSize
) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);

    // Initialize error buffer with null bytes
    if (errorBuffer != nullptr && errorBufferSize > 0) {
        memset(errorBuffer, 0, errorBufferSize);
    }

    // Create height data array and copy from input
    std::vector<float> heightData(nbRows * nbColumns);
    for (uint32_t i = 0; i < nbRows * nbColumns; ++i) {
        heightData[i] = heights[i];
    }

    // Create height field with float data type
    std::vector<Message> messages;
    HeightField* heightField = pc->createHeightField(
        nbColumns,  // Note: columns first in ReactPhysics3D API
        nbRows,     // Note: rows second in ReactPhysics3D API
        heightData.data(),
        HeightField::HeightDataType::HEIGHT_FLOAT_TYPE,
        messages,
        1.0f        // integerHeightScale parameter
    );

    // Log all messages for debugging
    std::cout << "HeightField creation - Total messages: " << messages.size() << std::endl;
    for(size_t i = 0; i < messages.size(); ++i) {
        const auto& message = messages[i];
        std::string messageTypeStr;
        switch(message.type) {
            case Message::Type::Error: messageTypeStr = "ERROR"; break;
            case Message::Type::Warning: messageTypeStr = "WARNING"; break;
            case Message::Type::Information: messageTypeStr = "INFO"; break;
            default: messageTypeStr = "UNKNOWN"; break;
        }
        std::cout << "Message " << i << " [" << messageTypeStr << "]: " << message.text << std::endl;
    }

    // Copy error messages to buffer if provided
    if (errorBuffer != nullptr && errorBufferSize > 0) {
        uint32_t currentOffset = 0;
        for(const auto & message : messages) {
            // Only copy error messages (not warnings or info)
            if (message.type == Message::Type::Error) {
                uint32_t messageLength = message.text.length();

                // Check if we have space for message + null terminator
                if (currentOffset + messageLength + 1 < errorBufferSize) {
                    strcpy(errorBuffer + currentOffset, message.text.c_str());
                    currentOffset += messageLength + 1; // +1 for null terminator
                } else {
                    // Not enough space, truncate the message
                    uint32_t remainingSpace = errorBufferSize - currentOffset - 1;
                    if (remainingSpace > 0) {
                        strncpy(errorBuffer + currentOffset, message.text.c_str(), remainingSpace);
                        errorBuffer[currentOffset + remainingSpace] = '\0';
                        currentOffset += remainingSpace + 1;
                    }
                    break; // Buffer is full
                }
            }
        }
    }

    return reinterpret_cast<RP3D_HeightField*>(heightField);
}

// HeightField creation (integer data type)
EMSCRIPTEN_KEEPALIVE
RP3D_HeightField* rp3d_physics_common_create_height_field_int(
    RP3D_PhysicsCommon* common,
    uint32_t nbRows,
    uint32_t nbColumns,
    const int32_t* heights,
    float minHeight,
    float maxHeight,
    double integerHeightScale,
    char* errorBuffer,
    uint32_t errorBufferSize
) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);

    // Initialize error buffer with null bytes
    if (errorBuffer != nullptr && errorBufferSize > 0) {
        memset(errorBuffer, 0, errorBufferSize);
    }

    // Create height field with integer data type
    std::vector<Message> messages;
    HeightField* heightField = pc->createHeightField(
        nbColumns,  // Note: columns first in ReactPhysics3D API
        nbRows,     // Note: rows second in ReactPhysics3D API
        heights,
        HeightField::HeightDataType::HEIGHT_INT_TYPE,
        messages,
        static_cast<decimal>(integerHeightScale)
    );

    // Log all messages for debugging
    std::cout << "HeightField creation (int) - Total messages: " << messages.size() << std::endl;
    for(size_t i = 0; i < messages.size(); ++i) {
        const auto& message = messages[i];
        std::string messageTypeStr;
        switch(message.type) {
            case Message::Type::Error: messageTypeStr = "ERROR"; break;
            case Message::Type::Warning: messageTypeStr = "WARNING"; break;
            case Message::Type::Information: messageTypeStr = "INFO"; break;
            default: messageTypeStr = "UNKNOWN"; break;
        }
        std::cout << "Message " << i << " [" << messageTypeStr << "]: " << message.text << std::endl;
    }

    // Copy error messages to buffer if provided
    if (errorBuffer != nullptr && errorBufferSize > 0) {
        uint32_t currentOffset = 0;
        for(const auto & message : messages) {
            // Only copy error messages (not warnings or info)
            if (message.type == Message::Type::Error) {
                uint32_t messageLength = message.text.length();

                // Check if we have space for message + null terminator
                if (currentOffset + messageLength + 1 < errorBufferSize) {
                    strcpy(errorBuffer + currentOffset, message.text.c_str());
                    currentOffset += messageLength + 1; // +1 for null terminator
                } else {
                    // Not enough space, truncate the message
                    uint32_t remainingSpace = errorBufferSize - currentOffset - 1;
                    if (remainingSpace > 0) {
                        strncpy(errorBuffer + currentOffset, message.text.c_str(), remainingSpace);
                        errorBuffer[currentOffset + remainingSpace] = '\0';
                        currentOffset += remainingSpace + 1;
                    }
                    break; // Buffer is full
                }
            }
        }
    }

    return reinterpret_cast<RP3D_HeightField*>(heightField);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_height_field(RP3D_PhysicsCommon* common, RP3D_HeightField* heightField) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    HeightField* hf = reinterpret_cast<HeightField*>(heightField);
    pc->destroyHeightField(hf);
}

// HeightFieldShape creation
EMSCRIPTEN_KEEPALIVE
RP3D_HeightFieldShape* rp3d_physics_common_create_height_field_shape(RP3D_PhysicsCommon* common, RP3D_HeightField* heightField, RP3D_Vector3* scaling) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    HeightField* hf = reinterpret_cast<HeightField*>(heightField);
    Vector3 *rpScaling = reinterpret_cast<Vector3 *>(scaling);
    HeightFieldShape* shape = pc->createHeightFieldShape(hf, *rpScaling);
    return reinterpret_cast<RP3D_HeightFieldShape*>(shape);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_height_field_shape(RP3D_PhysicsCommon* common, RP3D_HeightFieldShape* heightFieldShape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    HeightFieldShape* hfs = reinterpret_cast<HeightFieldShape*>(heightFieldShape);
    pc->destroyHeightFieldShape(hfs);
}

// ==================== PhysicsWorld ====================

EMSCRIPTEN_KEEPALIVE
void rp3d_world_update(RP3D_PhysicsWorld* world, float timeStep) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->update(timeStep);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_world_set_gravity(RP3D_PhysicsWorld* world, const RP3D_Vector3* gravity) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setGravity(to_rp3d_vector3(gravity));
}

EMSCRIPTEN_KEEPALIVE
void rp3d_world_get_gravity(const RP3D_PhysicsWorld* world, RP3D_Vector3* outGravity) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);
    from_rp3d_vector3(pw->getGravity(), outGravity);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_world_get_is_sleeping_enabled(const RP3D_PhysicsWorld* world) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);
    return pw->isSleepingEnabled() ? 1 : 0;
}

EMSCRIPTEN_KEEPALIVE
void rp3d_world_set_is_sleeping_enabled(RP3D_PhysicsWorld* world, uint8_t isSleepingEnabled) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->enableSleeping(isSleepingEnabled != 0);
}

// Gravity and sleep control
EMSCRIPTEN_KEEPALIVE
void rp3d_world_set_is_gravity_enabled(RP3D_PhysicsWorld* world, uint8_t isGravityEnabled) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setIsGravityEnabled(isGravityEnabled != 0);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_world_set_sleep_linear_velocity(RP3D_PhysicsWorld* world, float sleepLinearVelocity) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setSleepLinearVelocity(sleepLinearVelocity);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_world_set_sleep_angular_velocity(RP3D_PhysicsWorld* world, float sleepAngularVelocity) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setSleepAngularVelocity(sleepAngularVelocity);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_world_set_time_before_sleep(RP3D_PhysicsWorld* world, float timeBeforeSleep) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setTimeBeforeSleep(timeBeforeSleep);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_world_set_is_debug_rendering_enabled(RP3D_PhysicsWorld* world, uint8_t isEnabled) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    pw->setIsDebugRenderingEnabled(isEnabled != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_world_get_is_debug_rendering_enabled(const RP3D_PhysicsWorld* world) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);
    return pw->getIsDebugRenderingEnabled() ? 1 : 0;
}

EMSCRIPTEN_KEEPALIVE
RP3D_DebugRenderer* rp3d_world_get_debug_renderer(RP3D_PhysicsWorld* world) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    DebugRenderer& debugRenderer = pw->getDebugRenderer();
    return reinterpret_cast<RP3D_DebugRenderer*>(&debugRenderer);
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_world_get_nb_rigid_bodies(const RP3D_PhysicsWorld* world) {
    const PhysicsWorld* pw = reinterpret_cast<const PhysicsWorld*>(world);
    return pw->getNbRigidBodies();
}

EMSCRIPTEN_KEEPALIVE
RP3D_RigidBody* rp3d_world_get_rigid_body(RP3D_PhysicsWorld* world, uint32_t index) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    RigidBody* body = pw->getRigidBody(index);
    return reinterpret_cast<RP3D_RigidBody*>(body);
}

// Body creation/destruction
EMSCRIPTEN_KEEPALIVE
RP3D_RigidBody* rp3d_world_create_rigid_body(RP3D_PhysicsWorld* world, const RP3D_Transform* transform) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    Transform t = to_rp3d_transform(transform);
    RigidBody* body = pw->createRigidBody(t);
    return reinterpret_cast<RP3D_RigidBody*>(body);
}

EMSCRIPTEN_KEEPALIVE
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
EMSCRIPTEN_KEEPALIVE
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

// ==================== Collision Testing ====================

/**
 * Synchronous CollisionCallback that captures collision data for return to caller.
 */
class SyncCollisionCallback : public reactphysics3d::CollisionCallback
{
public:
    RP3D_CollisionCallbackData* result = nullptr;

    virtual void onContact(const CallbackData &callbackData) override
    {
        uint32_t nbPairs = callbackData.getNbContactPairs();

        // Allocate result structure
        result = new RP3D_CollisionCallbackData();
        result->nbContactPairs = nbPairs;

        if (nbPairs == 0)
        {
            result->contactPairs = nullptr;
            return;
        }

        result->contactPairs = new RP3D_ContactPairData[nbPairs];

        for (uint32_t i = 0; i < nbPairs; i++)
        {
            const ContactPair& pair = callbackData.getContactPair(i);
            RP3D_ContactPairData& outPair = result->contactPairs[i];

            // Get body/collider pointers
            outPair.body1 = reinterpret_cast<void*>(pair.getBody1());
            outPair.body2 = reinterpret_cast<void*>(pair.getBody2());
            outPair.collider1 = reinterpret_cast<void*>(pair.getCollider1());
            outPair.collider2 = reinterpret_cast<void*>(pair.getCollider2());

            // Event type
            switch (pair.getEventType())
            {
                case ContactPair::EventType::ContactStart:
                    outPair.eventType = 0;
                    break;
                case ContactPair::EventType::ContactStay:
                    outPair.eventType = 1;
                    break;
                case ContactPair::EventType::ContactExit:
                    outPair.eventType = 2;
                    break;
            }

            // Contact points
            uint32_t nbPoints = pair.getNbContactPoints();
            outPair.nbContactPoints = nbPoints;

            if (nbPoints == 0)
            {
                outPair.contactPoints = nullptr;
            }
            else
            {
                outPair.contactPoints = new RP3D_ContactPointData[nbPoints];

                for (uint32_t j = 0; j < nbPoints; j++)
                {
                    const ContactPoint& point = pair.getContactPoint(j);
                    RP3D_ContactPointData& outPoint = outPair.contactPoints[j];

                    outPoint.penetrationDepth = point.getPenetrationDepth();

                    const Vector3& normal = point.getWorldNormal();
                    outPoint.worldNormal.x = normal.x;
                    outPoint.worldNormal.y = normal.y;
                    outPoint.worldNormal.z = normal.z;

                    const Vector3& local1 = point.getLocalPointOnCollider1();
                    outPoint.localPointOnCollider1.x = local1.x;
                    outPoint.localPointOnCollider1.y = local1.y;
                    outPoint.localPointOnCollider1.z = local1.z;

                    const Vector3& local2 = point.getLocalPointOnCollider2();
                    outPoint.localPointOnCollider2.x = local2.x;
                    outPoint.localPointOnCollider2.y = local2.y;
                    outPoint.localPointOnCollider2.z = local2.z;
                }
            }
        }
    }
};

/**
 * Synchronous OverlapCallback that captures overlap data for return to caller.
 */
class SyncOverlapCallback : public reactphysics3d::OverlapCallback
{
public:
    RP3D_OverlapCallbackData* result = nullptr;

    virtual void onOverlap(CallbackData &callbackData) override
    {
        uint32_t nbPairs = callbackData.getNbOverlappingPairs();

        // Allocate result structure
        result = new RP3D_OverlapCallbackData();
        result->nbOverlapPairs = nbPairs;

        if (nbPairs == 0)
        {
            result->overlapPairs = nullptr;
            return;
        }

        result->overlapPairs = new RP3D_OverlapPairData[nbPairs];

        for (uint32_t i = 0; i < nbPairs; i++)
        {
            const OverlapCallback::OverlapPair& pair = callbackData.getOverlappingPair(i);
            RP3D_OverlapPairData& outPair = result->overlapPairs[i];

            // Get body/collider pointers
            outPair.body1 = reinterpret_cast<void*>(pair.getBody1());
            outPair.body2 = reinterpret_cast<void*>(pair.getBody2());
            outPair.collider1 = reinterpret_cast<void*>(pair.getCollider1());
            outPair.collider2 = reinterpret_cast<void*>(pair.getCollider2());

            // Event type
            switch (pair.getEventType())
            {
                case OverlapCallback::OverlapPair::EventType::OverlapStart:
                    outPair.eventType = 0;
                    break;
                case OverlapCallback::OverlapPair::EventType::OverlapStay:
                    outPair.eventType = 1;
                    break;
                case OverlapCallback::OverlapPair::EventType::OverlapExit:
                    outPair.eventType = 2;
                    break;
            }
        }
    }
};

/**
 * Test collision between two bodies (synchronous).
 */
EMSCRIPTEN_KEEPALIVE
RP3D_CollisionCallbackData* rp3d_test_collision_two_bodies_sync(
    RP3D_PhysicsWorld *world,
    RP3D_Body *body1,
    RP3D_Body *body2)
{
    if (!world || !body1 || !body2)
    {
        // Return empty result
        RP3D_CollisionCallbackData* result = new RP3D_CollisionCallbackData();
        result->nbContactPairs = 0;
        result->contactPairs = nullptr;
        return result;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::Body *rp3dBody1 = reinterpret_cast<reactphysics3d::Body *>(body1);
    reactphysics3d::Body *rp3dBody2 = reinterpret_cast<reactphysics3d::Body *>(body2);

    SyncCollisionCallback callback;
    rp3dWorld->testCollision(rp3dBody1, rp3dBody2, callback);

    // If callback wasn't invoked, create empty result
    if (callback.result == nullptr)
    {
        RP3D_CollisionCallbackData* result = new RP3D_CollisionCallbackData();
        result->nbContactPairs = 0;
        result->contactPairs = nullptr;
        return result;
    }

    return callback.result;
}

/**
 * Test collision for a body against all others (synchronous).
 */
EMSCRIPTEN_KEEPALIVE
RP3D_CollisionCallbackData* rp3d_test_collision_body_sync(
    RP3D_PhysicsWorld *world,
    RP3D_Body *body)
{
    if (!world || !body)
    {
        RP3D_CollisionCallbackData* result = new RP3D_CollisionCallbackData();
        result->nbContactPairs = 0;
        result->contactPairs = nullptr;
        return result;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::Body *rp3dBody = reinterpret_cast<reactphysics3d::Body *>(body);

    SyncCollisionCallback callback;
    rp3dWorld->testCollision(rp3dBody, callback);

    if (callback.result == nullptr)
    {
        RP3D_CollisionCallbackData* result = new RP3D_CollisionCallbackData();
        result->nbContactPairs = 0;
        result->contactPairs = nullptr;
        return result;
    }

    return callback.result;
}

/**
 * Test collision for all bodies in the world (synchronous).
 */
EMSCRIPTEN_KEEPALIVE
RP3D_CollisionCallbackData* rp3d_test_collision_world_sync(
    RP3D_PhysicsWorld *world)
{
    if (!world)
    {
        RP3D_CollisionCallbackData* result = new RP3D_CollisionCallbackData();
        result->nbContactPairs = 0;
        result->contactPairs = nullptr;
        return result;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);

    SyncCollisionCallback callback;
    rp3dWorld->testCollision(callback);

    if (callback.result == nullptr)
    {
        RP3D_CollisionCallbackData* result = new RP3D_CollisionCallbackData();
        result->nbContactPairs = 0;
        result->contactPairs = nullptr;
        return result;
    }

    return callback.result;
}

/**
 * Test overlap for all trigger colliders (synchronous).
 */
EMSCRIPTEN_KEEPALIVE
RP3D_OverlapCallbackData* rp3d_test_overlap_world_sync(
    RP3D_PhysicsWorld *world)
{
    if (!world)
    {
        RP3D_OverlapCallbackData* result = new RP3D_OverlapCallbackData();
        result->nbOverlapPairs = 0;
        result->overlapPairs = nullptr;
        return result;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);

    SyncOverlapCallback callback;
    rp3dWorld->testOverlap(callback);

    if (callback.result == nullptr)
    {
        RP3D_OverlapCallbackData* result = new RP3D_OverlapCallbackData();
        result->nbOverlapPairs = 0;
        result->overlapPairs = nullptr;
        return result;
    }

    return callback.result;
}

/**
 * Free collision callback data.
 */
EMSCRIPTEN_KEEPALIVE
void rp3d_free_collision_callback_data(RP3D_CollisionCallbackData* data)
{
    if (!data)
    {
        return;
    }

    if (data->contactPairs)
    {
        for (uint32_t i = 0; i < data->nbContactPairs; i++)
        {
            if (data->contactPairs[i].contactPoints)
            {
                delete[] data->contactPairs[i].contactPoints;
            }
        }
        delete[] data->contactPairs;
    }

    delete data;
}

/**
 * Free overlap callback data.
 */
EMSCRIPTEN_KEEPALIVE
void rp3d_free_overlap_callback_data(RP3D_OverlapCallbackData* data)
{
    if (!data)
    {
        return;
    }

    if (data->overlapPairs)
    {
        delete[] data->overlapPairs;
    }

    delete data;
}

// ==================== RigidBody ====================

EMSCRIPTEN_KEEPALIVE
void rp3d_body_get_transform(const RP3D_RigidBody* body, RP3D_Transform* outTransform) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_transform(rb->getTransform(), outTransform);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_set_transform(RP3D_RigidBody* body, float posX, float posY, float posZ, float quatX, float quatY, float quatZ, float quatW) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    Vector3 position(posX, posY, posZ);
    Quaternion orientation(quatX, quatY, quatZ, quatW);
    Transform transform(position, orientation);
    rb->setTransform(transform);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_get_position(const RP3D_RigidBody* body, RP3D_Vector3* outPosition) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_vector3(rb->getTransform().getPosition(), outPosition);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_get_orientation(const RP3D_RigidBody* body, RP3D_Quaternion* outOrientation) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_quaternion(rb->getTransform().getOrientation(), outOrientation);
}

EMSCRIPTEN_KEEPALIVE
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

EMSCRIPTEN_KEEPALIVE
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

EMSCRIPTEN_KEEPALIVE
void rp3d_body_set_mass(RP3D_RigidBody* body, float mass) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setMass(mass);
}

EMSCRIPTEN_KEEPALIVE
float rp3d_body_get_mass(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->getMass();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_set_linear_velocity(RP3D_RigidBody* body, const RP3D_Vector3* linearVelocity) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setLinearVelocity(to_rp3d_vector3(linearVelocity));
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_get_linear_velocity(const RP3D_RigidBody* body, RP3D_Vector3* outLinearVelocity) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_vector3(rb->getLinearVelocity(), outLinearVelocity);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_set_angular_velocity(RP3D_RigidBody* body, const RP3D_Vector3* angularVelocity) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setAngularVelocity(to_rp3d_vector3(angularVelocity));
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_get_angular_velocity(const RP3D_RigidBody* body, RP3D_Vector3* outAngularVelocity) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    from_rp3d_vector3(rb->getAngularVelocity(), outAngularVelocity);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_apply_force(RP3D_RigidBody* body, const RP3D_Vector3* force) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->applyWorldForceAtCenterOfMass(to_rp3d_vector3(force));
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_apply_force_at_position(RP3D_RigidBody* body, const RP3D_Vector3* force, const RP3D_Vector3* position) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->applyWorldForceAtWorldPosition(to_rp3d_vector3(force), to_rp3d_vector3(position));
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_apply_torque(RP3D_RigidBody* body, const RP3D_Vector3* torque) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->applyWorldTorque(to_rp3d_vector3(torque));
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_set_is_active(RP3D_RigidBody* body, uint8_t isActive) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setIsActive(isActive != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_body_get_is_active(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->isActive() ? 1 : 0;
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_set_is_sleeping_allowed(RP3D_RigidBody* body, uint8_t isAllowed) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setIsAllowedToSleep(isAllowed != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_body_get_is_sleeping_allowed(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->isAllowedToSleep() ? 1 : 0;
}

// Gravity control
EMSCRIPTEN_KEEPALIVE
void rp3d_body_enable_gravity(RP3D_RigidBody* body, uint8_t enableGravity) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->enableGravity(enableGravity != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_body_is_gravity_enabled(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->isGravityEnabled() ? 1 : 0;
}

// Debug rendering
EMSCRIPTEN_KEEPALIVE
void rp3d_body_set_is_debug_enabled(RP3D_RigidBody* body, uint8_t isEnabled) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->setIsDebugEnabled(isEnabled != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_body_get_is_debug_enabled(const RP3D_RigidBody* body) {
    const RigidBody* rb = reinterpret_cast<const RigidBody*>(body);
    return rb->isDebugEnabled() ? 1 : 0;
}

// Mass properties
EMSCRIPTEN_KEEPALIVE
void rp3d_body_update_mass_properties_from_colliders(RP3D_RigidBody* body) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    rb->updateMassPropertiesFromColliders();
}

// Collider management
EMSCRIPTEN_KEEPALIVE
RP3D_Collider* rp3d_body_add_collider(RP3D_RigidBody* body, RP3D_CollisionShape* shape, const RP3D_Transform* transform) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    CollisionShape* cs = reinterpret_cast<CollisionShape*>(shape);
    Transform t = to_rp3d_transform(transform);

    Collider* collider = rb->addCollider(cs, t);
    return reinterpret_cast<RP3D_Collider*>(collider);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_body_remove_collider(RP3D_RigidBody* body, RP3D_Collider* collider) {
    RigidBody* rb = reinterpret_cast<RigidBody*>(body);
    Collider* c = reinterpret_cast<Collider*>(collider);
    rb->removeCollider(c);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_collider_set_material(RP3D_Collider* collider, const RP3D_Material* material) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    const Material* m = reinterpret_cast<const Material*>(material);
    c->setMaterial(*m);
}

// ==================== Collider ====================

EMSCRIPTEN_KEEPALIVE
RP3D_Material* rp3d_collider_get_material(RP3D_Collider* collider) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    Material& material = c->getMaterial();
    return reinterpret_cast<RP3D_Material*>(&material);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_collider_get_local_bounds(const RP3D_Collider* collider, RP3D_AABB* outAABB) {
    const Collider* c = reinterpret_cast<const Collider*>(collider);
    const CollisionShape* shape = c->getCollisionShape();
    AABB aabb = shape->getLocalBounds();
    from_rp3d_vector3(aabb.getMin(), &outAABB->min);
    from_rp3d_vector3(aabb.getMax(), &outAABB->max);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_collider_set_is_trigger(RP3D_Collider* collider, uint8_t isTrigger) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    c->setIsTrigger(isTrigger != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_collider_get_is_trigger(const RP3D_Collider* collider) {
    const Collider* c = reinterpret_cast<const Collider*>(collider);
    return c->getIsTrigger() ? 1 : 0;
}

EMSCRIPTEN_KEEPALIVE
void rp3d_collider_set_is_world_query_collider(RP3D_Collider* collider, uint8_t isWorldQueryCollider) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    c->setIsWorldQueryCollider(isWorldQueryCollider != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_collider_get_is_world_query_collider(const RP3D_Collider* collider) {
    const Collider* c = reinterpret_cast<const Collider*>(collider);
    return c->getIsWorldQueryCollider() ? 1 : 0;
}

EMSCRIPTEN_KEEPALIVE
void rp3d_collider_set_collision_category_bits(RP3D_Collider* collider, uint16_t collisionCategoryBits) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    c->setCollisionCategoryBits(collisionCategoryBits);
}

EMSCRIPTEN_KEEPALIVE
uint16_t rp3d_collider_get_collision_category_bits(const RP3D_Collider* collider) {
    const Collider* c = reinterpret_cast<const Collider*>(collider);
    return c->getCollisionCategoryBits();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_collider_set_collide_with_mask_bits(RP3D_Collider* collider, uint16_t collideWithMaskBits) {
    Collider* c = reinterpret_cast<Collider*>(collider);
    c->setCollideWithMaskBits(collideWithMaskBits);
}

EMSCRIPTEN_KEEPALIVE
uint16_t rp3d_collider_get_collide_with_mask_bits(const RP3D_Collider* collider) {
    const Collider* c = reinterpret_cast<const Collider*>(collider);
    return c->getCollideWithMaskBits();
}

// ==================== Material ====================

EMSCRIPTEN_KEEPALIVE
void rp3d_material_destroy(RP3D_Material* material) {
    Material* m = reinterpret_cast<Material*>(material);
    delete m;
}

EMSCRIPTEN_KEEPALIVE
void rp3d_material_set_bounciness(RP3D_Material* material, float bounciness) {
    Material* m = reinterpret_cast<Material*>(material);
    m->setBounciness(bounciness);
}

EMSCRIPTEN_KEEPALIVE
float rp3d_material_get_bounciness(const RP3D_Material* material) {
    const Material* m = reinterpret_cast<const Material*>(material);
    return m->getBounciness();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_material_set_friction_coefficient(RP3D_Material* material, float frictionCoefficient) {
    Material* m = reinterpret_cast<Material*>(material);
    m->setFrictionCoefficient(frictionCoefficient);
}

EMSCRIPTEN_KEEPALIVE
float rp3d_material_get_friction_coefficient(const RP3D_Material* material) {
    const Material* m = reinterpret_cast<const Material*>(material);
    return m->getFrictionCoefficient();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_material_set_mass_density(RP3D_Material* material, float massDensity) {
    Material* m = reinterpret_cast<Material*>(material);
    m->setMassDensity(massDensity);
}

EMSCRIPTEN_KEEPALIVE
float rp3d_material_get_mass_density(const RP3D_Material* material) {
    const Material* m = reinterpret_cast<const Material*>(material);
    return m->getMassDensity();
}

// ==================== CollisionShape (base) ====================

EMSCRIPTEN_KEEPALIVE
void rp3d_shape_get_local_bounds(const RP3D_CollisionShape* shape, RP3D_AABB* outAABB) {
    const CollisionShape* cs = reinterpret_cast<const CollisionShape*>(shape);
    AABB aabb = cs->getLocalBounds();
    from_rp3d_vector3(aabb.getMin(), &outAABB->min);
    from_rp3d_vector3(aabb.getMax(), &outAABB->max);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_concave_shape_set_scale(RP3D_HeightFieldShape* shape, const RP3D_Vector3* scale) {
    ConcaveShape* concaveShape = reinterpret_cast<ConcaveShape*>(shape);
    Vector3 scaleVec = to_rp3d_vector3(scale);

    concaveShape->setScale(scaleVec);
    return;
}

// ==================== Math Utilities ====================

// Vector3
EMSCRIPTEN_KEEPALIVE
void rp3d_vector3_zero(RP3D_Vector3* v) {
    v->x = 0.0f;
    v->y = 0.0f;
    v->z = 0.0f;
}

EMSCRIPTEN_KEEPALIVE
float rp3d_vector3_length(const RP3D_Vector3* v) {
    Vector3 vec = to_rp3d_vector3(v);
    return vec.length();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_vector3_normalize(RP3D_Vector3* v) {
    Vector3 vec = to_rp3d_vector3(v);
    vec = vec.getUnit();
    from_rp3d_vector3(vec, v);
}

EMSCRIPTEN_KEEPALIVE
float rp3d_vector3_dot(const RP3D_Vector3* v1, const RP3D_Vector3* v2) {
    Vector3 vec1 = to_rp3d_vector3(v1);
    Vector3 vec2 = to_rp3d_vector3(v2);
    return vec1.dot(vec2);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_vector3_cross(const RP3D_Vector3* v1, const RP3D_Vector3* v2, RP3D_Vector3* outResult) {
    Vector3 vec1 = to_rp3d_vector3(v1);
    Vector3 vec2 = to_rp3d_vector3(v2);
    Vector3 result = vec1.cross(vec2);
    from_rp3d_vector3(result, outResult);
}

// Quaternion
EMSCRIPTEN_KEEPALIVE
void rp3d_quaternion_identity(RP3D_Quaternion* q) {
    Quaternion quat = Quaternion::identity();
    from_rp3d_quaternion(quat, q);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_quaternion_from_axis_angle(const RP3D_Vector3* axis, float angle, RP3D_Quaternion* outQuat) {
    Vector3 axisVec = to_rp3d_vector3(axis);
    Quaternion quat(axisVec, angle);
    from_rp3d_quaternion(quat, outQuat);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_quaternion_normalize(RP3D_Quaternion* q) {
    Quaternion quat = to_rp3d_quaternion(q);
    quat = quat.getUnit();
    from_rp3d_quaternion(quat, q);
}

// Transform
EMSCRIPTEN_KEEPALIVE
void rp3d_transform_identity(RP3D_Transform* t) {
    Transform transform = Transform::identity();
    from_rp3d_transform(transform, t);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_transform_inverse(const RP3D_Transform* t, RP3D_Transform* outInverse) {
    Transform transform = to_rp3d_transform(t);
    Transform inverse = transform.getInverse();
    from_rp3d_transform(inverse, outInverse);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_transform_get_opengl_matrix(const RP3D_Transform* t, float* outMatrix) {
    Transform transform = to_rp3d_transform(t);
    
    transform.getOpenGLMatrix(outMatrix);
}

// ==================== DebugRenderer ====================

EMSCRIPTEN_KEEPALIVE
void rp3d_debug_renderer_set_is_debug_item_displayed(RP3D_DebugRenderer* renderer, RP3D_DebugItem item, uint8_t isDisplayed) {
    DebugRenderer* dr = reinterpret_cast<DebugRenderer*>(renderer);
    DebugRenderer::DebugItem debugItem;

    switch (item) {
        case RP3D_DEBUG_ITEM_COLLIDER_AABB:
            debugItem = DebugRenderer::DebugItem::COLLIDER_AABB;
            break;
        case RP3D_DEBUG_ITEM_COLLIDER_BROADPHASE_AABB:
            debugItem = DebugRenderer::DebugItem::COLLIDER_BROADPHASE_AABB;
            break;
        case RP3D_DEBUG_ITEM_COLLISION_SHAPE:
            debugItem = DebugRenderer::DebugItem::COLLISION_SHAPE;
            break;
        case RP3D_DEBUG_ITEM_CONTACT_POINT:
            debugItem = DebugRenderer::DebugItem::CONTACT_POINT;
            break;
        case RP3D_DEBUG_ITEM_CONTACT_NORMAL:
            debugItem = DebugRenderer::DebugItem::CONTACT_NORMAL;
            break;
        default:
            return;
    }

    dr->setIsDebugItemDisplayed(debugItem, isDisplayed != 0);
}

EMSCRIPTEN_KEEPALIVE
uint8_t rp3d_debug_renderer_get_is_debug_item_displayed(const RP3D_DebugRenderer* renderer, RP3D_DebugItem item) {
    const DebugRenderer* dr = reinterpret_cast<const DebugRenderer*>(renderer);
    DebugRenderer::DebugItem debugItem;

    switch (item) {
        case RP3D_DEBUG_ITEM_COLLIDER_AABB:
            debugItem = DebugRenderer::DebugItem::COLLIDER_AABB;
            break;
        case RP3D_DEBUG_ITEM_COLLIDER_BROADPHASE_AABB:
            debugItem = DebugRenderer::DebugItem::COLLIDER_BROADPHASE_AABB;
            break;
        case RP3D_DEBUG_ITEM_COLLISION_SHAPE:
            debugItem = DebugRenderer::DebugItem::COLLISION_SHAPE;
            break;
        case RP3D_DEBUG_ITEM_CONTACT_POINT:
            debugItem = DebugRenderer::DebugItem::CONTACT_POINT;
            break;
        case RP3D_DEBUG_ITEM_CONTACT_NORMAL:
            debugItem = DebugRenderer::DebugItem::CONTACT_NORMAL;
            break;
        default:
            return 0;
    }

    return dr->getIsDebugItemDisplayed(debugItem) ? 1 : 0;
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_debug_renderer_get_nb_lines(const RP3D_DebugRenderer* renderer) {
    const DebugRenderer* dr = reinterpret_cast<const DebugRenderer*>(renderer);
    return dr->getNbLines();
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_debug_renderer_get_nb_triangles(const RP3D_DebugRenderer* renderer) {
    const DebugRenderer* dr = reinterpret_cast<const DebugRenderer*>(renderer);
    return dr->getNbTriangles();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_debug_renderer_get_lines_array(const RP3D_DebugRenderer* renderer, float* outVertices, uint32_t* outColors) {
    const DebugRenderer* dr = reinterpret_cast<const DebugRenderer*>(renderer);
    const Array<DebugRenderer::DebugLine>& lines = dr->getLines();

    for (uint32_t i = 0; i < lines.size(); i++) {
        const DebugRenderer::DebugLine& line = lines[i];

        // Point 1
        outVertices[i * 6 + 0] = line.point1.x;
        outVertices[i * 6 + 1] = line.point1.y;
        outVertices[i * 6 + 2] = line.point1.z;

        // Point 2
        outVertices[i * 6 + 3] = line.point2.x;
        outVertices[i * 6 + 4] = line.point2.y;
        outVertices[i * 6 + 5] = line.point2.z;

        // Color (RGBA packed into uint32)
        outColors[i] = line.color1;
    }
}

EMSCRIPTEN_KEEPALIVE
void rp3d_debug_renderer_get_triangles_array(const RP3D_DebugRenderer* renderer, float* outVertices, uint32_t* outColors) {
    const DebugRenderer* dr = reinterpret_cast<const DebugRenderer*>(renderer);
    const Array<DebugRenderer::DebugTriangle>& triangles = dr->getTriangles();

    for (uint32_t i = 0; i < triangles.size(); i++) {
        const DebugRenderer::DebugTriangle& triangle = triangles[i];

        // Point 1
        outVertices[i * 9 + 0] = triangle.point1.x;
        outVertices[i * 9 + 1] = triangle.point1.y;
        outVertices[i * 9 + 2] = triangle.point1.z;

        // Point 2
        outVertices[i * 9 + 3] = triangle.point2.x;
        outVertices[i * 9 + 4] = triangle.point2.y;
        outVertices[i * 9 + 5] = triangle.point2.z;

        // Point 3
        outVertices[i * 9 + 6] = triangle.point3.x;
        outVertices[i * 9 + 7] = triangle.point3.y;
        outVertices[i * 9 + 8] = triangle.point3.z;

        // Color (RGBA packed into uint32)
        outColors[i] = triangle.color1;
    }
}

// ==================== Joints ====================

EMSCRIPTEN_KEEPALIVE
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

EMSCRIPTEN_KEEPALIVE
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

EMSCRIPTEN_KEEPALIVE
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

EMSCRIPTEN_KEEPALIVE
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

EMSCRIPTEN_KEEPALIVE
void rp3d_world_destroy_joint(RP3D_PhysicsWorld* world, void* joint) {
    PhysicsWorld* pw = reinterpret_cast<PhysicsWorld*>(world);
    Joint* j = reinterpret_cast<Joint*>(joint);
    pw->destroyJoint(j);
}

// ==================== HeightFieldShape ====================

EMSCRIPTEN_KEEPALIVE
void rp3d_height_field_shape_get_vertex_at(
    const RP3D_HeightFieldShape* heightFieldShape,
    uint32_t row,
    uint32_t column,
    RP3D_Vector3* outVertex
) {
    const HeightFieldShape* hfs = reinterpret_cast<const HeightFieldShape*>(heightFieldShape);
    Vector3 vertex = hfs->getVertexAt(column, row);
    from_rp3d_vector3(vertex, outVertex);
}

// The descriptor classes retain pointers. Keep native copies in a storage base,
// constructed before the descriptor base and destroyed after it.
struct OwnedVertices {
    std::vector<float> vertices;
    OwnedVertices(uint32_t count, const float* input, uint32_t stride) : vertices(size_t(count) * 3) {
        if (!input || stride < 3 * sizeof(float)) throw std::invalid_argument("Invalid vertices");
        for (uint32_t i = 0; i < count; ++i) {
            std::memcpy(vertices.data() + size_t(i) * 3,
                        reinterpret_cast<const uint8_t*>(input) + size_t(i) * stride, 3 * sizeof(float));
        }
    }
};
struct TriangleStorage : OwnedVertices {
    std::vector<uint32_t> indices;
    TriangleStorage(uint32_t nv, const float* v, uint32_t vs, uint32_t ni, const uint32_t* ix, uint32_t is)
        : OwnedVertices(nv, v, vs), indices(ni) {
        if (!ix || ni == 0 || ni % 3 || is < 3 * sizeof(uint32_t)) throw std::invalid_argument("Invalid triangles");
        for (uint32_t i = 0; i < ni / 3; ++i) {
            std::memcpy(indices.data() + size_t(i) * 3,
                        reinterpret_cast<const uint8_t*>(ix) + size_t(i) * is, 3 * sizeof(uint32_t));
        }
        for (auto i : indices) if (i >= nv) throw std::invalid_argument("Invalid vertex index");
    }
};
struct OwnedTriangleArray : TriangleStorage, TriangleVertexArray {
    OwnedTriangleArray(uint32_t nv, const float* v, uint32_t vs, uint32_t ni, const uint32_t* ix, uint32_t is)
        : TriangleStorage(nv, v, vs, ni, ix, is),
          TriangleVertexArray(nv, vertices.data(), 12, ni / 3, indices.data(), 12,
                              VertexDataType::VERTEX_FLOAT_TYPE, IndexDataType::INDEX_INTEGER_TYPE) {}
};
struct OwnedVertexArray : OwnedVertices, VertexArray {
    OwnedVertexArray(uint32_t nv, const float* v, uint32_t vs)
        : OwnedVertices(nv, v, vs), VertexArray(vertices.data(), 12, nv, DataType::VERTEX_FLOAT_TYPE) {}
};
struct PolygonStorage : OwnedVertices {
    std::vector<uint32_t> indices;
    std::vector<PolygonVertexArray::PolygonFace> faces;
    PolygonStorage(uint32_t nv, const float* v, uint32_t vs, uint32_t ni, const uint32_t* ix, uint32_t is,
                   const uint32_t* desc, uint32_t ds, uint32_t nf)
        : OwnedVertices(nv, v, vs), indices(ni), faces(nf) {
        if (!ix || !desc || !nf || is < sizeof(uint32_t) || ds < 2 * sizeof(uint32_t))
            throw std::invalid_argument("Invalid polygons");
        for (uint32_t i = 0; i < ni; ++i) {
            std::memcpy(&indices[i], reinterpret_cast<const uint8_t*>(ix) + size_t(i) * is, sizeof(uint32_t));
            if (indices[i] >= nv) throw std::invalid_argument("Invalid vertex index");
        }
        for (uint32_t i = 0; i < nf; ++i) {
            uint32_t pair[2];
            std::memcpy(pair, reinterpret_cast<const uint8_t*>(desc) + size_t(i) * ds, sizeof(pair));
            if (pair[0] < 3 || pair[1] > ni || pair[0] > ni - pair[1])
                throw std::invalid_argument("Invalid polygon face");
            faces[i].nbVertices = pair[0];
            faces[i].indexBase = pair[1];
        }
    }
};
struct OwnedPolygonArray : PolygonStorage, PolygonVertexArray {
    OwnedPolygonArray(uint32_t nv, const float* v, uint32_t vs, uint32_t ni, const uint32_t* ix, uint32_t is,
                      const uint32_t* desc, uint32_t ds, uint32_t nf)
        : PolygonStorage(nv, v, vs, ni, ix, is, desc, ds, nf),
          PolygonVertexArray(nv, vertices.data(), 12, indices.data(), 4, nf, faces.data(),
                             VertexDataType::VERTEX_FLOAT_TYPE, IndexDataType::INDEX_INTEGER_TYPE) {}
};

// ==================== TriangleVertexArray ====================

EMSCRIPTEN_KEEPALIVE
RP3D_TriangleVertexArray* rp3d_triangle_vertex_array_create(
    uint32_t nbVertices,
    const float* verticesStart,
    uint32_t verticesStride,
    uint32_t nbIndices,
    const uint32_t* indicesStart,
    uint32_t indicesStride
) {
    try {
        TriangleVertexArray* array = new OwnedTriangleArray(nbVertices, verticesStart, verticesStride,
                                                           nbIndices, indicesStart, indicesStride);
        return reinterpret_cast<RP3D_TriangleVertexArray*>(array);
    } catch (const std::exception&) { return nullptr; }

}

EMSCRIPTEN_KEEPALIVE
void rp3d_triangle_vertex_array_destroy(RP3D_TriangleVertexArray* triangleVertexArray) {
    TriangleVertexArray* tva = reinterpret_cast<TriangleVertexArray*>(triangleVertexArray);
    delete static_cast<OwnedTriangleArray*>(tva);
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_triangle_vertex_array_get_nb_vertices(const RP3D_TriangleVertexArray* triangleVertexArray) {
    const TriangleVertexArray* tva = reinterpret_cast<const TriangleVertexArray*>(triangleVertexArray);
    if (!tva) return 0;
    return tva->getNbVertices();
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_triangle_vertex_array_get_nb_triangles(const RP3D_TriangleVertexArray* triangleVertexArray) {
    const TriangleVertexArray* tva = reinterpret_cast<const TriangleVertexArray*>(triangleVertexArray);
    if (!tva) return 0;
    return tva->getNbTriangles();
}

EMSCRIPTEN_KEEPALIVE
const float* rp3d_triangle_vertex_array_get_vertices_start(const RP3D_TriangleVertexArray* triangleVertexArray) {
    const TriangleVertexArray* tva = reinterpret_cast<const TriangleVertexArray*>(triangleVertexArray);
    if (!tva) return nullptr;
    return static_cast<const float*>(tva->getVerticesStart());
}

EMSCRIPTEN_KEEPALIVE
const uint32_t* rp3d_triangle_vertex_array_get_indices_start(const RP3D_TriangleVertexArray* triangleVertexArray) {
    const TriangleVertexArray* tva = reinterpret_cast<const TriangleVertexArray*>(triangleVertexArray);
    if (!tva) return nullptr;
    return static_cast<const uint32_t*>(tva->getIndicesStart());
}

EMSCRIPTEN_KEEPALIVE
void rp3d_triangle_vertex_array_get_triangle_vertices_indices(
    const RP3D_TriangleVertexArray* triangleVertexArray,
    uint32_t triangleIndex,
    uint32_t* out) {
    const TriangleVertexArray* tva = reinterpret_cast<const TriangleVertexArray*>(triangleVertexArray);
    tva->getTriangleVerticesIndices(triangleIndex, out[0], out[1], out[2]);
}

// ==================== VertexArray ====================

EMSCRIPTEN_KEEPALIVE
RP3D_VertexArray* rp3d_vertex_array_create(
    uint32_t nbVertices,
    const float* verticesStart,
    uint32_t verticesStride
) {
    if (!verticesStart) {
        std::cout << "VertexArray creation failed: null input data" << std::endl;
        return nullptr;
    }

    if (nbVertices < 4) {
        std::cout << "VertexArray creation failed: minimum 4 vertices required for convex hull" << std::endl;
        return nullptr;
    }

    try {
        VertexArray* array = new OwnedVertexArray(nbVertices, verticesStart, verticesStride);
        return reinterpret_cast<RP3D_VertexArray*>(array);
    } catch (const std::exception&) { return nullptr; }

}

EMSCRIPTEN_KEEPALIVE
void rp3d_vertex_array_destroy(RP3D_VertexArray* vertexArray) {
    if (!vertexArray) return;
    VertexArray* va = reinterpret_cast<VertexArray*>(vertexArray);
    delete static_cast<OwnedVertexArray*>(va);
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_vertex_array_get_nb_vertices(const RP3D_VertexArray* vertexArray) {
    if (!vertexArray) return 0;
    const VertexArray* va = reinterpret_cast<const VertexArray*>(vertexArray);
    return va->getNbVertices();
}

EMSCRIPTEN_KEEPALIVE
const float* rp3d_vertex_array_get_vertices_start(const RP3D_VertexArray* vertexArray) {
    if (!vertexArray) return nullptr;
    const VertexArray* va = reinterpret_cast<const VertexArray*>(vertexArray);
    return reinterpret_cast<const float*>(va->getStart());
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_vertex_array_get_stride(const RP3D_VertexArray* vertexArray) {
    if (!vertexArray) return 0;
    const VertexArray* va = reinterpret_cast<const VertexArray*>(vertexArray);
    return va->getStride();
}

// ==================== PolygonVertexArray ====================

EMSCRIPTEN_KEEPALIVE
RP3D_PolygonVertexArray* rp3d_polygon_vertex_array_create(
    uint32_t nbVertices,
    const float* verticesStart,
    uint32_t verticesStride,
    uint32_t nbIndices,
    const uint32_t* indicesStart,
    uint32_t indicesStride,
    const uint32_t* polygonIndicesStart,
    uint32_t polygonIndicesStride,
    uint32_t nbFaces
) {
    try {
        PolygonVertexArray* array = new OwnedPolygonArray(nbVertices, verticesStart, verticesStride,
            nbIndices, indicesStart, indicesStride, polygonIndicesStart, polygonIndicesStride, nbFaces);
        return reinterpret_cast<RP3D_PolygonVertexArray*>(array);
    } catch (const std::exception&) { return nullptr; }

}

EMSCRIPTEN_KEEPALIVE
void rp3d_polygon_vertex_array_destroy(RP3D_PolygonVertexArray* polygonVertexArray) {
    if (!polygonVertexArray) return;

    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    delete static_cast<OwnedPolygonArray*>(pva);
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_polygon_vertex_array_get_nb_vertices(RP3D_PolygonVertexArray* polygonVertexArray) {
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    return pva->getNbVertices();
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_polygon_vertex_array_get_nb_faces(RP3D_PolygonVertexArray* polygonVertexArray) {
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    return pva->getNbFaces();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_polygon_vertex_array_get_vertex(RP3D_PolygonVertexArray* polygonVertexArray, uint32_t vertexIndex, float* outVertex) {
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    Vector3 vertex = pva->getVertex(vertexIndex);
    outVertex[0] = vertex.x;
    outVertex[1] = vertex.y;
    outVertex[2] = vertex.z;
}

EMSCRIPTEN_KEEPALIVE
void rp3d_polygon_vertex_array_get_polygon_face(RP3D_PolygonVertexArray* polygonVertexArray, uint32_t faceIndex, uint32_t* outNbVertices, uint32_t* outIndexBase) {
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    PolygonVertexArray::PolygonFace* face = pva->getPolygonFace(faceIndex);
    *outNbVertices = face->nbVertices;
    *outIndexBase = face->indexBase;
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_polygon_vertex_array_get_indices_stride(RP3D_PolygonVertexArray* polygonVertexArray) {
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    return pva->getIndicesStride();
}

EMSCRIPTEN_KEEPALIVE
const uint32_t* rp3d_polygon_vertex_array_get_indices_start(RP3D_PolygonVertexArray* polygonVertexArray) {
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    return reinterpret_cast<const uint32_t*>(pva->getIndicesStart());
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_polygon_vertex_array_get_vertex_index_in_face(RP3D_PolygonVertexArray* polygonVertexArray, uint32_t faceIndex, uint32_t vertexInFace) {
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);
    return pva->getVertexIndexInFace(faceIndex, vertexInFace);
}

// ==================== TriangleMesh ====================

EMSCRIPTEN_KEEPALIVE
RP3D_TriangleMesh* rp3d_physics_common_create_triangle_mesh(
    RP3D_PhysicsCommon* common,
    RP3D_TriangleVertexArray* triangleVertexArray
) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    TriangleVertexArray* tva = reinterpret_cast<TriangleVertexArray*>(triangleVertexArray);

    std::vector<Message> messages;
    TriangleMesh* triangleMesh = pc->createTriangleMesh(*tva, messages);

    // Output any error messages
    for(const auto & message : messages) {
        std::cout << "TriangleMesh creation: " << message.text << std::endl;
    }

    return reinterpret_cast<RP3D_TriangleMesh*>(triangleMesh);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_triangle_mesh(RP3D_PhysicsCommon* common, RP3D_TriangleMesh* triangleMesh) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    TriangleMesh* tm = reinterpret_cast<TriangleMesh*>(triangleMesh);
    pc->destroyTriangleMesh(tm);
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_triangle_mesh_get_nb_vertices(const RP3D_TriangleMesh* triangleMesh) {
    const TriangleMesh* tm = reinterpret_cast<const TriangleMesh*>(triangleMesh);
    if (!tm) return 0;
    return tm->getNbVertices();
}

EMSCRIPTEN_KEEPALIVE
uint32_t rp3d_triangle_mesh_get_nb_triangles(const RP3D_TriangleMesh* triangleMesh) {
    const TriangleMesh* tm = reinterpret_cast<const TriangleMesh*>(triangleMesh);
    if (!tm) return 0;
    return tm->getNbTriangles();
}

EMSCRIPTEN_KEEPALIVE
void rp3d_triangle_mesh_get_vertex(
    const RP3D_TriangleMesh* triangleMesh,
    uint32_t vertexIndex,
    RP3D_Vector3* outVertex) {
    const TriangleMesh* tm = reinterpret_cast<const TriangleMesh*>(triangleMesh);
    if (tm && outVertex) {
        const reactphysics3d::Vector3& vertex = tm->getVertex(vertexIndex);
        outVertex->x = vertex.x;
        outVertex->y = vertex.y;
        outVertex->z = vertex.z;
    }
}

EMSCRIPTEN_KEEPALIVE
void rp3d_triangle_mesh_get_triangle_vertices_indices(
    const RP3D_TriangleMesh* triangleMesh,
    uint32_t triangleIndex,
    uint32_t *indices) {
    const TriangleMesh* tm = reinterpret_cast<const TriangleMesh*>(triangleMesh);
    tm->getTriangleVerticesIndices(triangleIndex, indices[0], indices[1], indices[2]);
}

// ==================== ConvexMesh ====================

EMSCRIPTEN_KEEPALIVE
RP3D_ConvexMesh* rp3d_physics_common_create_convex_mesh_from_triangles(
    RP3D_PhysicsCommon* common,
    RP3D_TriangleVertexArray* triangleVertexArray
) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    TriangleVertexArray* tva = reinterpret_cast<TriangleVertexArray*>(triangleVertexArray);

    // Input validation
    if (!tva || !tva->getVerticesStart() || tva->getNbVertices() < 3) {
        std::cout << "ConvexMesh creation failed: Invalid triangle vertex array data" << std::endl;
        return nullptr;
    }

    // Check vertex stride is valid for 3D positions
    if (tva->getVerticesStride() < 12) { // At least 3 floats * 4 bytes
        std::cout << "ConvexMesh creation failed: Invalid vertex stride" << std::endl;
        return nullptr;
    }

    // Extract unique vertices from triangle data to avoid duplicates
    const float* verticesData = static_cast<const float*>(tva->getVerticesStart());
    const uint32_t* indicesData = static_cast<const uint32_t*>(tva->getIndicesStart());
    uint32_t nbVertices = tva->getNbVertices();
    uint32_t nbTriangles = tva->getNbTriangles();
    uint32_t vertexStride = tva->getVerticesStride() / 4; // Convert bytes to float count

    // For simplicity and safety, create a VertexArray with the original vertex data
    // but limit the number of vertices to prevent crashes with degenerate data
    uint32_t maxVertices = std::min(nbVertices, 1000u); // Safety limit
    if (maxVertices < 4) {
        std::cout << "ConvexMesh creation failed: Not enough vertices (minimum 4 required)" << std::endl;
        return nullptr;
    }

    try {

        VertexArray vertexArray(
            verticesData,
            tva->getVerticesStride(),
            maxVertices,
            VertexArray::DataType::VERTEX_FLOAT_TYPE
        );

        std::vector<Message> messages;
        ConvexMesh* convexMesh = pc->createConvexMesh(vertexArray, messages);

        // Output any error messages
        if (!messages.empty()) {
            for(const auto & message : messages) {
                std::cout << "ConvexMesh creation warning: " << message.text << std::endl;
            }
        }

        if (!convexMesh) {
            std::cout << "ConvexMesh creation failed: QuickHull algorithm failed" << std::endl;
            return nullptr;
        }

        return reinterpret_cast<RP3D_ConvexMesh*>(convexMesh);
    } catch (const std::exception& e) {
        std::cout << "ConvexMesh creation failed with exception: " << e.what() << std::endl;
        return nullptr;
    } catch (...) {
        std::cout << "ConvexMesh creation failed with unknown exception" << std::endl;
        return nullptr;
    }
}

EMSCRIPTEN_KEEPALIVE
RP3D_ConvexMesh* rp3d_physics_common_create_convex_mesh_from_polygons(
    RP3D_PhysicsCommon* common,
    RP3D_PolygonVertexArray* polygonVertexArray
) {
    std::cout << "start" << std::endl;
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    PolygonVertexArray* pva = reinterpret_cast<PolygonVertexArray*>(polygonVertexArray);

    if (!pva) {
        std::cout << "ConvexMesh creation from polygons failed: null polygon vertex array" << std::endl;
        return nullptr;
    }

    std::vector<Message> messages;
    ConvexMesh* convexMesh = pc->createConvexMesh(*pva, messages);

    // Output any error messages
    if (!messages.empty()) {
        for(const auto & message : messages) {
            std::cout << "ConvexMesh creation from polygons warning: " << message.text << std::endl;
        }
    } else {
        std::cout << "No messages" << std::endl;
    }

    if (!convexMesh) {
        std::cout << "ConvexMesh creation from polygons failed: algorithm failed" << std::endl;
        return nullptr;
    }

    return reinterpret_cast<RP3D_ConvexMesh*>(convexMesh);
}

EMSCRIPTEN_KEEPALIVE
RP3D_ConvexMesh* rp3d_physics_common_create_convex_mesh_from_vertices(
    RP3D_PhysicsCommon* common,
    RP3D_VertexArray* vertexArray
) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    VertexArray* va = reinterpret_cast<VertexArray*>(vertexArray);

    if (!va) {
        std::cout << "ConvexMesh creation from vertices failed: null vertex array" << std::endl;
        return nullptr;
    }

    if (va->getNbVertices() < 4) {
        std::cout << "ConvexMesh creation from vertices failed: minimum 4 vertices required" << std::endl;
        return nullptr;
    }

    try {
        std::vector<Message> messages;
        ConvexMesh* convexMesh = pc->createConvexMesh(*va, messages);

        // Output any error messages
        if (!messages.empty()) {
            for(const auto & message : messages) {
                std::cout << "ConvexMesh creation from vertices warning: " << message.text << std::endl;
            }
        }

        if (!convexMesh) {
            std::cout << "ConvexMesh creation from vertices failed: QuickHull algorithm failed" << std::endl;
            return nullptr;
        }

        return reinterpret_cast<RP3D_ConvexMesh*>(convexMesh);
    } catch (const std::exception& e) {
        std::cout << "ConvexMesh creation from vertices failed with exception: " << e.what() << std::endl;
        return nullptr;
    } catch (...) {
        std::cout << "ConvexMesh creation from vertices failed with unknown exception" << std::endl;
        return nullptr;
    }
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_convex_mesh(RP3D_PhysicsCommon* common, RP3D_ConvexMesh* convexMesh) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    ConvexMesh* cm = reinterpret_cast<ConvexMesh*>(convexMesh);
    pc->destroyConvexMesh(cm);
}

// ==================== ConvexMeshShape ====================

EMSCRIPTEN_KEEPALIVE
RP3D_ConvexMeshShape* rp3d_physics_common_create_convex_mesh_shape(
    RP3D_PhysicsCommon* common,
    RP3D_ConvexMesh* convexMesh,
    const RP3D_Vector3* scaling
) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    ConvexMesh* cm = reinterpret_cast<ConvexMesh*>(convexMesh);
    Vector3 scaleVec = to_rp3d_vector3(scaling);

    ConvexMeshShape* convexMeshShape = pc->createConvexMeshShape(cm, scaleVec);
    return reinterpret_cast<RP3D_ConvexMeshShape*>(convexMeshShape);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_convex_mesh_shape(RP3D_PhysicsCommon* common, RP3D_ConvexMeshShape* convexMeshShape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    ConvexMeshShape* cms = reinterpret_cast<ConvexMeshShape*>(convexMeshShape);
    pc->destroyConvexMeshShape(cms);
}

// ==================== ConcaveMeshShape ====================

EMSCRIPTEN_KEEPALIVE
RP3D_ConcaveMeshShape* rp3d_physics_common_create_concave_mesh_shape(
    RP3D_PhysicsCommon* common,
    RP3D_TriangleMesh* triangleMesh,
    const RP3D_Vector3* scaling
) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    TriangleMesh* tm = reinterpret_cast<TriangleMesh*>(triangleMesh);
    Vector3 scaleVec = to_rp3d_vector3(scaling);

    ConcaveMeshShape* concaveMeshShape = pc->createConcaveMeshShape(tm, scaleVec);
    return reinterpret_cast<RP3D_ConcaveMeshShape*>(concaveMeshShape);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_physics_common_destroy_concave_mesh_shape(RP3D_PhysicsCommon* common, RP3D_ConcaveMeshShape* concaveMeshShape) {
    PhysicsCommon* pc = reinterpret_cast<PhysicsCommon*>(common);
    ConcaveMeshShape* cms = reinterpret_cast<ConcaveMeshShape*>(concaveMeshShape);
    pc->destroyConcaveMeshShape(cms);
}

EMSCRIPTEN_KEEPALIVE
void rp3d_collider_get_local_transform(const RP3D_Collider* collider, RP3D_Transform* out) {
    from_rp3d_transform(reinterpret_cast<const Collider*>(collider)->getLocalToBodyTransform(), out);
}
EMSCRIPTEN_KEEPALIVE
void rp3d_collider_set_local_transform(RP3D_Collider* collider, const RP3D_Transform* value) {
    reinterpret_cast<Collider*>(collider)->setLocalToBodyTransform(to_rp3d_transform(value));
}
