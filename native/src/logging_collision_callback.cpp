/*
 * Collision Callback Implementation
 *
 * This file implements a minimal CollisionCallback subclass for use with
 * testCollision methods. The native ReactPhysics3D testCollision API requires
 * a C++ CollisionCallback object, so we provide this minimal implementation.
 */

#include "c_api/rp3d_c_api.h"
#include <reactphysics3d/reactphysics3d.h>
#include <reactphysics3d/collision/CollisionCallback.h>
#include <reactphysics3d/collision/OverlapCallback.h>
#include <iostream>

using namespace reactphysics3d;

// ==================== Minimal Callback Implementations ====================

/**
 * Minimal implementation of CollisionCallback for testCollision methods.
 */
class MinimalCollisionCallback : public reactphysics3d::CollisionCallback
{
public:
    MinimalCollisionCallback() = default;

    virtual void onContact(const CallbackData &callbackData) override
    {
        // Minimal implementation - the actual collision detection is done
        // by ReactPhysics3D, and the Dart side is notified separately
        (void)callbackData;  // Suppress unused warning
    }
};

/**
 * Minimal implementation of OverlapCallback for testOverlap methods.
 */
class MinimalOverlapCallback : public reactphysics3d::OverlapCallback
{
public:
    MinimalOverlapCallback() = default;

    virtual void onOverlap(CallbackData &callbackData) override
    {
        // Log overlap events for debugging
        uint32_t overlapPairs = callbackData.getNbOverlappingPairs();
        if (overlapPairs > 0)
        {
            std::cout << "OverlapCallback: " << overlapPairs << " overlap pair(s)" << std::endl;
        }
    }
};

// ==================== C API Functions ====================

/**
 * Create a minimal collision callback.
 * The prefix, logContactPoints, and verbose parameters are accepted for
 * compatibility but currently ignored.
 */
extern "C" EMSCRIPTEN_KEEPALIVE TCollisionCallback *rp3d_create_logging_collision_callback(
    const char *prefix,
    uint8_t logContactPoints,
    uint8_t verbose)
{
    (void)prefix;
    (void)logContactPoints;
    (void)verbose;
    MinimalCollisionCallback *callback = new MinimalCollisionCallback();
    return reinterpret_cast<TCollisionCallback *>(callback);
}

/**
 * Destroy a collision callback.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_destroy_collision_callback(TCollisionCallback *callback)
{
    if (!callback)
    {
        return;
    }
    MinimalCollisionCallback *cb = reinterpret_cast<MinimalCollisionCallback *>(callback);
    delete cb;
}

// ==================== Collision Testing Functions ====================

/**
 * Test collision between two bodies.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_collision_bodies_direct(
    RP3D_PhysicsWorld *world,
    RP3D_Body *body1,
    RP3D_Body *body2,
    TCollisionCallback *callback)
{
    if (!world || !body1 || !body2 || !callback)
    {
        return;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::Body *rp3dBody1 = reinterpret_cast<reactphysics3d::Body *>(body1);
    reactphysics3d::Body *rp3dBody2 = reinterpret_cast<reactphysics3d::Body *>(body2);
    reactphysics3d::CollisionCallback *rp3dCallback = reinterpret_cast<reactphysics3d::CollisionCallback *>(callback);

    rp3dWorld->testCollision(rp3dBody1, rp3dBody2, *rp3dCallback);
}

/**
 * Test collision for all bodies in the world.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_collision_world(
    RP3D_PhysicsWorld *world,
    TCollisionCallback *callback)
{
    if (!world || !callback)
    {
        return;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::CollisionCallback *rp3dCallback = reinterpret_cast<reactphysics3d::CollisionCallback *>(callback);

    rp3dWorld->testCollision(*rp3dCallback);
}

/**
 * Test collision for a specific body against all other bodies.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_collision_body(
    RP3D_PhysicsWorld *world,
    RP3D_Body *body,
    TCollisionCallback *callback)
{
    if (!world || !body || !callback)
    {
        return;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::Body *rp3dBody = reinterpret_cast<reactphysics3d::Body *>(body);
    reactphysics3d::CollisionCallback *rp3dCallback = reinterpret_cast<reactphysics3d::CollisionCallback *>(callback);

    rp3dWorld->testCollision(rp3dBody, *rp3dCallback);
}

/**
 * Test overlap for all trigger colliders in the world.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_overlap_world(
    RP3D_PhysicsWorld *world,
    TCollisionCallback *callback)
{
    if (!world || !callback)
    {
        return;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);

    // Note: testOverlap uses OverlapCallback, not CollisionCallback
    // We create a temporary overlap callback here
    MinimalOverlapCallback overlapCallback;
    rp3dWorld->testOverlap(overlapCallback);
}
