/*
 * Synchronous Collision Callback Implementation
 *
 * This file implements synchronous collision testing that returns data directly
 * to the caller, rather than using async callbacks.
 */

#include "c_api/rp3d_c_api.h"
#include <reactphysics3d/reactphysics3d.h>
#include <reactphysics3d/collision/CollisionCallback.h>
#include <reactphysics3d/collision/OverlapCallback.h>
#include <cstring>

using namespace reactphysics3d;

// ==================== Sync Callback Implementations ====================

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

// ==================== Synchronous C API Functions ====================

/**
 * Test collision between two bodies (synchronous).
 */
extern "C" EMSCRIPTEN_KEEPALIVE RP3D_CollisionCallbackData* rp3d_test_collision_two_bodies_sync(
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
extern "C" EMSCRIPTEN_KEEPALIVE RP3D_CollisionCallbackData* rp3d_test_collision_body_sync(
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
extern "C" EMSCRIPTEN_KEEPALIVE RP3D_CollisionCallbackData* rp3d_test_collision_world_sync(
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
extern "C" EMSCRIPTEN_KEEPALIVE RP3D_OverlapCallbackData* rp3d_test_overlap_world_sync(
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
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_free_collision_callback_data(RP3D_CollisionCallbackData* data)
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
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_free_overlap_callback_data(RP3D_OverlapCallbackData* data)
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
