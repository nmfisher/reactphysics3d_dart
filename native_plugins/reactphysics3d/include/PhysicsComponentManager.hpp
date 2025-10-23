/*
 * PhysicsComponentManager
 *
 * A high-level C++ manager for ReactPhysics3D that simplifies common physics operations.
 * Provides easy-to-use methods for creating physics objects with collision detection
 * and gravity functionality. Designed to work with the existing C API wrapper.
 */


#pragma once

#include <cmath>
#include <vector>
#include <memory>
#include <string>
#include <filesystem>
#include <mutex>


#include <reactphysics3d/reactphysics3d.h>
#include <vector>
#include <unordered_map>
#include <memory>

using namespace reactphysics3d;

// Custom RaycastCallback for simple raycast queries
class SimpleRaycastCallback : public RaycastCallback {
public:
    RaycastInfo* hitInfo;
    bool hasHit;

    SimpleRaycastCallback() : hitInfo(nullptr), hasHit(false) {}

    virtual decimal notifyRaycastHit(const RaycastInfo& info) override {
        // Copy the relevant data manually since RaycastInfo has deleted copy operations
        if (hitInfo) {
            hitInfo->worldPoint = info.worldPoint;
            hitInfo->worldNormal = info.worldNormal;
            hitInfo->hitFraction = info.hitFraction;
            hitInfo->triangleIndex = info.triangleIndex;
            hitInfo->body = info.body;
            hitInfo->collider = info.collider;
        }
        hasHit = true;
        return 0.0f; // Stop the raycast at the first hit
    }
};

// Physics component data structure
struct PhysicsComponent {
    uint32_t id;
    RigidBody* rigidBody;
    std::vector<Collider*> colliders;
    mutable Transform transform;
    bool isActive;

    PhysicsComponent() : id(0), rigidBody(nullptr), isActive(true) {}
};

// Configuration for creating physics objects
struct PhysicsObjectConfig {
    Vector3 position;
    Quaternion orientation;
    Vector3 velocity;
    float mass;
    bool enableGravity;
    BodyType bodyType;
    float bounciness;
    float friction;

    PhysicsObjectConfig()
        : position(0, 0, 0)
        , orientation(Quaternion::identity())
        , velocity(0, 0, 0)
        , mass(1.0f)
        , enableGravity(true)
        , bodyType(BodyType::DYNAMIC)
        , bounciness(0.2f)
        , friction(0.3f) {}
};

class PhysicsComponentManager {
public:
    PhysicsComponentManager();
    ~PhysicsComponentManager();

    // Initialization and cleanup
    bool initialize(const Vector3& gravity = Vector3(0, -9.81f, 0));
    void shutdown();
    void update(float deltaTime);

    // World management
    void setGravity(const Vector3& gravity);
    Vector3 getGravity() const;
    void setGravityEnabled(bool enabled);
    bool isGravityEnabled() const;

    // Physics object creation methods
    uint32_t createSphere(const PhysicsObjectConfig& config, float radius);
    uint32_t createBox(const PhysicsObjectConfig& config, const Vector3& halfExtents);
    uint32_t createCapsule(const PhysicsObjectConfig& config, float radius, float height);

    // Component management
    bool removeComponent(uint32_t componentId);
    PhysicsComponent* getComponent(uint32_t componentId);
    bool setComponentActive(uint32_t componentId, bool active);

    // Transform and physics property accessors
    bool setComponentTransform(uint32_t componentId, const Transform& transform);
    bool getComponentTransform(uint32_t componentId, Transform& outTransform) const;
    bool setComponentPosition(uint32_t componentId, const Vector3& position);
    bool getComponentPosition(uint32_t componentId, Vector3& outPosition) const;

    bool setComponentVelocity(uint32_t componentId, const Vector3& velocity);
    bool getComponentVelocity(uint32_t componentId, Vector3& outVelocity) const;
    bool setComponentMass(uint32_t componentId, float mass);
    float getComponentMass(uint32_t componentId) const;

    bool setComponentGravityEnabled(uint32_t componentId, bool enabled);
    bool isComponentGravityEnabled(uint32_t componentId) const;

    // Force application
    bool applyForce(uint32_t componentId, const Vector3& force);
    bool applyForceAtPosition(uint32_t componentId, const Vector3& force, const Vector3& position);
    bool applyImpulse(uint32_t componentId, const Vector3& impulse);

    // Collision detection queries
    bool raycast(const Vector3& start, const Vector3& end, RaycastInfo& hitInfo) const;
    std::vector<uint32_t> getComponentsInSphere(const Vector3& center, float radius) const;

    // Utility methods
    uint32_t getComponentCount() const;
    std::vector<uint32_t> getAllComponentIds() const;
    void clearAllComponents();

    // Access to underlying physics world (for advanced usage)
    PhysicsWorld* getPhysicsWorld() const { return m_physicsWorld; }
    PhysicsCommon* getPhysicsCommon() const { return m_physicsCommon; }

private:
    PhysicsCommon* m_physicsCommon;
    PhysicsWorld* m_physicsWorld;
    std::unordered_map<uint32_t, std::unique_ptr<PhysicsComponent>> m_components;
    uint32_t m_nextComponentId;
    bool m_initialized;

    // Internal helper methods
    uint32_t generateComponentId();
    CollisionShape* createCollisionShape(const std::string& shapeType, const std::vector<float>& params);
    PhysicsComponent* createComponentInternal(const PhysicsObjectConfig& config);
    void updateMassProperties(PhysicsComponent* component);

    // Shape creation helpers
    SphereShape* createSphereShape(float radius);
    BoxShape* createBoxShape(const Vector3& halfExtents);
    CapsuleShape* createCapsuleShape(float radius, float height);
};