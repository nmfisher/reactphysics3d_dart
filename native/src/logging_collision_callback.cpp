/*
 * Simple Collision Callback Implementation
 *
 * This file implements a minimal CollisionCallback subclass that logs collision events
 * for debugging and demonstration purposes. This is a simplified version that focuses
 * on the core functionality without complex collision testing.
 */

#include "c_api/rp3d_c_api.h"
#include <reactphysics3d/reactphysics3d.h>
#include <reactphysics3d/collision/CollisionCallback.h>
#include <reactphysics3d/collision/OverlapCallback.h>
#include <iostream>
#include <iomanip>
#include <unordered_map>

using namespace reactphysics3d;

// ==================== Simple Logging Callback ====================

/**
 * Simple implementation of CollisionCallback that logs collision events
 */
class SimpleLoggingCallback : public reactphysics3d::CollisionCallback
{
private:
    std::string logPrefix;
    uint32_t totalCallbacks;

public:
    bool hasContact;

    /**
     * Constructor
     */
    SimpleLoggingCallback(const std::string &prefix = "CollisionCallback")
        : logPrefix(prefix), totalCallbacks(0), hasContact(false) {}

    /**
     * Called when contacts occur during collision testing
     */
    virtual void onContact(const CallbackData &callbackData) override
    {
        totalCallbacks++;
        uint32_t contactPairs = callbackData.getNbContactPairs();

        std::cout << logPrefix << ": onContact called #" << totalCallbacks
                  << " with " << contactPairs << " contact pair(s)" << std::endl;

        if (contactPairs > 0)
        {
            std::cout << logPrefix << ": Collision detected!" << std::endl;
            hasContact = true;
        }
    }
};

// ==================== C API Functions ====================

/**
 * Create a simple logging collision callback
 */
extern "C" EMSCRIPTEN_KEEPALIVE TCollisionCallback *rp3d_create_logging_collision_callback(const char *prefix, uint8_t logContactPoints, uint8_t verbose)
{
    std::string logPrefix = prefix ? prefix : "CollisionCallback";
    SimpleLoggingCallback *callback = new SimpleLoggingCallback(logPrefix);

    std::cout << "Created logging callback with prefix: " << logPrefix << std::endl;

    return reinterpret_cast<TCollisionCallback *>(callback);
}

/**
 * Create a contact counter callback (alias to logging callback for now)
 */
extern "C" EMSCRIPTEN_KEEPALIVE TCollisionCallback *rp3d_create_contact_counter_callback()
{
    SimpleLoggingCallback *callback = new SimpleLoggingCallback("CounterCallback");

    std::cout << "Created counter callback" << std::endl;

    return reinterpret_cast<TCollisionCallback *>(callback);
}

/**
 * Get the hasContact flag from a logging callback
 */
extern "C" EMSCRIPTEN_KEEPALIVE
    uint8_t
    rp3d_get_logging_callback_has_contact(TCollisionCallback *callback)
{
    if (!callback)
    {
        std::cout << "Warning: null callback provided for has_contact query" << std::endl;
        return 0;
    }

    try
    {
        SimpleLoggingCallback *loggingCallback = reinterpret_cast<SimpleLoggingCallback *>(callback);
        return loggingCallback->hasContact ? 1 : 0;
    }
    catch (...)
    {
        std::cout << "Error getting callback has_contact" << std::endl;
        return 0;
    }
}

/**
 * Get statistics from a logging callback
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_get_logging_callback_stats(TCollisionCallback *callback, uint32_t *callbackCount,
                                                                     uint32_t *totalContactPairs, uint32_t *totalContactPoints)
{
    if (!callback)
    {
        if (callbackCount)
            *callbackCount = 0;
        if (totalContactPairs)
            *totalContactPairs = 0;
        if (totalContactPoints)
            *totalContactPoints = 0;
        return;
    }

    // Note: Simple implementation doesn't track detailed stats
    if (callbackCount)
        *callbackCount = 1;
    if (totalContactPairs)
        *totalContactPairs = 0;
    if (totalContactPoints)
        *totalContactPoints = 0;
}

/**
 * Get statistics from a counter callback
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_get_counter_callback_stats(TCollisionCallback *callback, uint32_t *callbackCount,
                                                                     uint32_t *totalContactPairs, uint32_t *totalContactPoints)
{
    if (!callback)
    {
        if (callbackCount)
            *callbackCount = 0;
        if (totalContactPairs)
            *totalContactPairs = 0;
        if (totalContactPoints)
            *totalContactPoints = 0;
        return;
    }

    // Note: Simple implementation doesn't track detailed stats
    if (callbackCount)
        *callbackCount = 1;
    if (totalContactPairs)
        *totalContactPairs = 0;
    if (totalContactPoints)
        *totalContactPoints = 0;
}

/**
 * Reset callback statistics
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_reset_callback_stats(TCollisionCallback *callback)
{
    if (!callback)
    {
        std::cout << "Warning: null callback provided for reset stats" << std::endl;
        return;
    }

    SimpleLoggingCallback *loggingCallback = reinterpret_cast<SimpleLoggingCallback *>(callback);
    loggingCallback->hasContact = false;
    std::cout << "Reset stats for callback" << std::endl;
}

/**
 * Test collision between two bodies using a callback (New Direct API)
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_collision_bodies_direct(RP3D_PhysicsWorld *world, RP3D_Body *body1, RP3D_Body *body2, TCollisionCallback *callback)
{
    if (!world)
    {
        std::cout << "Error: null world provided to test_collision_bodies_direct" << std::endl;
        return;
    }

    if (!body1 || !body2)
    {
        std::cout << "Error: null bodies provided to test_collision_bodies_direct" << std::endl;
        return;
    }

    if (!callback)
    {
        std::cout << "Error: null callback provided to test_collision_bodies_direct" << std::endl;
        return;
    }

    std::cout << "Testing collision between two bodies using direct callback" << std::endl;

    // Cast opaque pointers back to ReactPhysics3D objects
    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::Body *rp3dBody1 = reinterpret_cast<reactphysics3d::Body *>(body1);
    reactphysics3d::Body *rp3dBody2 = reinterpret_cast<reactphysics3d::Body *>(body2);
    reactphysics3d::CollisionCallback *rp3dCallback = reinterpret_cast<reactphysics3d::CollisionCallback *>(callback);

    // Get body positions for logging
    reactphysics3d::Transform transform1 = rp3dBody1->getTransform();
    reactphysics3d::Transform transform2 = rp3dBody2->getTransform();
    reactphysics3d::Vector3 position1 = transform1.getPosition();
    reactphysics3d::Vector3 position2 = transform2.getPosition();

    std::cout << "Body 1 position: (" << position1.x << ", " << position1.y << ", " << position1.z << ")" << std::endl;
    std::cout << "Body 2 position: (" << position2.x << ", " << position2.y << ", " << position2.z << ")" << std::endl;
    std::cout << "Direct callback provided: " << (callback != nullptr) << std::endl;

    // Use the ReactPhysics3D API to test collision
    std::cout << "Calling ReactPhysics3D PhysicsWorld::testCollision..." << std::endl;
    rp3dWorld->testCollision(rp3dBody1, rp3dBody2, *rp3dCallback);

    std::cout << "Collision testing completed with direct callback" << std::endl;
}

/**
 * Destroy a callback
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_destroy_collision_callback(TCollisionCallback *callback)
{
    if (!callback)
    {
        std::cout << "Warning: Attempted to destroy null callback" << std::endl;
        return;
    }

    SimpleLoggingCallback *loggingCallback = reinterpret_cast<SimpleLoggingCallback *>(callback);
    delete loggingCallback;
    std::cout << "Destroyed callback" << std::endl;
}

// ==================== OverlapCallback Implementation ====================

/**
 * Simple implementation of OverlapCallback for trigger overlap testing
 */
class SimpleOverlapCallback : public reactphysics3d::OverlapCallback
{
private:
    uint32_t totalOverlaps;

public:
    SimpleOverlapCallback() : totalOverlaps(0) {}

    virtual void onOverlap(CallbackData &callbackData) override
    {
        totalOverlaps++;
        uint32_t overlapPairs = callbackData.getNbOverlappingPairs();

        std::cout << "OverlapCallback: onOverlap called #" << totalOverlaps
                  << " with " << overlapPairs << " overlap pair(s)" << std::endl;

        for (uint32_t i = 0; i < overlapPairs; i++)
        {
            OverlapPair overlapPair = callbackData.getOverlappingPair(i);

            const Collider *collider1 = overlapPair.getCollider1();
            const Collider *collider2 = overlapPair.getCollider2();
            const Body *body1 = overlapPair.getBody1();
            const Body *body2 = overlapPair.getBody2();

            OverlapPair::EventType eventType = overlapPair.getEventType();
            const char *eventTypeStr = "";
            switch (eventType)
            {
            case OverlapPair::EventType::OverlapStart:
                eventTypeStr = "OverlapStart";
                break;
            case OverlapPair::EventType::OverlapStay:
                eventTypeStr = "OverlapStay";
                break;
            case OverlapPair::EventType::OverlapExit:
                eventTypeStr = "OverlapExit";
                break;
            }

            std::cout << "  OverlapPair " << i << ": " << eventTypeStr
                      << " between Collider " << collider1 << " and Collider " << collider2
                      << " (Body " << body1 << " and Body " << body2 << ")" << std::endl;
        }
    }
};

// ==================== Collision Testing Functions ====================

/**
 * Test collision for all bodies in the world
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_collision_world(RP3D_PhysicsWorld *world, TCollisionCallback *callback)
{
    if (!world)
    {
        std::cout << "Error: null world provided to test_collision_world" << std::endl;
        return;
    }

    if (!callback)
    {
        std::cout << "Error: null callback provided to test_collision_world" << std::endl;
        return;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::CollisionCallback *rp3dCallback = reinterpret_cast<reactphysics3d::CollisionCallback *>(callback);

    std::cout << "Testing collision for all bodies in world" << std::endl;
    rp3dWorld->testCollision(*rp3dCallback);
    std::cout << "World collision testing completed" << std::endl;
}

/**
 * Test collision for a specific body against all other bodies
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_collision_body(RP3D_PhysicsWorld *world, RP3D_Body *body, TCollisionCallback *callback)
{
    if (!world)
    {
        std::cout << "Error: null world provided to test_collision_body" << std::endl;
        return;
    }

    if (!body)
    {
        std::cout << "Error: null body provided to test_collision_body" << std::endl;
        return;
    }

    if (!callback)
    {
        std::cout << "Error: null callback provided to test_collision_body" << std::endl;
        return;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);
    reactphysics3d::Body *rp3dBody = reinterpret_cast<reactphysics3d::Body *>(body);
    reactphysics3d::CollisionCallback *rp3dCallback = reinterpret_cast<reactphysics3d::CollisionCallback *>(callback);

    std::cout << "Testing collision for body " << body << " against all other bodies" << std::endl;
    rp3dWorld->testCollision(rp3dBody, *rp3dCallback);
    std::cout << "Body collision testing completed" << std::endl;
}

/**
 * Test overlap for all trigger colliders in the world
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_test_overlap_world(RP3D_PhysicsWorld *world, TCollisionCallback *callback)
{
    if (!world)
    {
        std::cout << "Error: null world provided to test_overlap_world" << std::endl;
        return;
    }

    if (!callback)
    {
        std::cout << "Error: null callback provided to test_overlap_world" << std::endl;
        return;
    }

    reactphysics3d::PhysicsWorld *rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld *>(world);

    // Create a temporary overlap callback
    SimpleOverlapCallback overlapCallback;

    std::cout << "Testing overlap/triggers for all bodies in world" << std::endl;
    rp3dWorld->testOverlap(overlapCallback);
    std::cout << "World overlap testing completed" << std::endl;
}

// Note: EventListener functionality is provided by dart_sendport_listener.cpp.
// The CollisionCallback class (used for testCollision/testOverlap) is
// different from EventListener (used for automatic callbacks during update).

// ==================== Event Listener Stubs ====================

// These are simple stub functions for backward compatibility.
// For actual EventListener functionality, use the SendPort event listener
// functions from dart_sendport_listener.cpp.

/**
 * Stub for setting an event listener.
 * This is a no-op for backward compatibility.
 * Use rp3d_world_set_sendport_listener for actual event listener functionality.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_world_set_event_listener(
    RP3D_PhysicsWorld *world,
    TCollisionCallback *eventListener)
{
    if (!world)
    {
        std::cout << "Error: null world provided to set_event_listener" << std::endl;
        return;
    }

    // This is a stub - the actual event listener functionality is provided
    // by dart_sendport_listener.cpp
    std::cout << "set_event_listener called (stub - use sendport_listener for actual functionality)" << std::endl;
}

/**
 * Stub for removing an event listener.
 * This is a no-op for backward compatibility.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_world_remove_event_listener(RP3D_PhysicsWorld *world)
{
    if (!world)
    {
        std::cout << "Error: null world provided to remove_event_listener" << std::endl;
        return;
    }

    // This is a stub - the actual event listener functionality is provided
    // by dart_sendport_listener.cpp
    std::cout << "remove_event_listener called (stub)" << std::endl;
}