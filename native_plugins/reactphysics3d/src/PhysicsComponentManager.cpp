/*
 * PhysicsComponentManager Implementation
 *
 * Provides a high-level interface for managing physics components with
 * collision detection and gravity in ReactPhysics3D.
 */

#include "PhysicsComponentManager.hpp"
#include <algorithm>
#include <cmath>

PhysicsComponentManager::PhysicsComponentManager()
    : m_physicsCommon(nullptr)
    , m_physicsWorld(nullptr)
    , m_nextComponentId(1)
    , m_initialized(false) {
}

PhysicsComponentManager::~PhysicsComponentManager() {
    shutdown();
}

bool PhysicsComponentManager::initialize(const Vector3& gravity) {
    if (m_initialized) {
        return true; // Already initialized
    }

    try {
        // Create the physics common instance
        m_physicsCommon = new PhysicsCommon();

        // Create physics world with specified gravity
        PhysicsWorld::WorldSettings settings;
        settings.gravity = gravity;
        m_physicsWorld = m_physicsCommon->createPhysicsWorld(settings);

        m_initialized = true;
        return true;
    }
    catch (...) {
        return false;
    }
}

void PhysicsComponentManager::shutdown() {
    if (!m_initialized) {
        return;
    }

    // Clear all components first
    clearAllComponents();

    // Destroy physics world
    if (m_physicsWorld && m_physicsCommon) {
        m_physicsCommon->destroyPhysicsWorld(m_physicsWorld);
        m_physicsWorld = nullptr;
    }

    // Destroy physics common
    if (m_physicsCommon) {
        delete m_physicsCommon;
        m_physicsCommon = nullptr;
    }

    m_initialized = false;
}

void PhysicsComponentManager::update(float deltaTime) {
    if (!m_initialized || !m_physicsWorld) {
        return;
    }

    // Update physics simulation
    m_physicsWorld->update(deltaTime);
}

void PhysicsComponentManager::setGravity(const Vector3& gravity) {
    if (m_physicsWorld) {
        m_physicsWorld->setGravity(gravity);
    }
}

Vector3 PhysicsComponentManager::getGravity() const {
    if (m_physicsWorld) {
        return m_physicsWorld->getGravity();
    }
    return Vector3(0, 0, 0);
}

void PhysicsComponentManager::setGravityEnabled(bool enabled) {
    if (m_physicsWorld) {
        m_physicsWorld->setIsGravityEnabled(enabled);
    }
}

bool PhysicsComponentManager::isGravityEnabled() const {
    if (m_physicsWorld) {
        return m_physicsWorld->isGravityEnabled();
    }
    return false;
}

uint32_t PhysicsComponentManager::createSphere(const PhysicsObjectConfig& config, float radius) {
    if (!m_initialized) {
        return 0;
    }

    // Create the base component
    PhysicsComponent* component = createComponentInternal(config);
    if (!component) {
        return 0;
    }

    // Create sphere shape
    SphereShape* sphereShape = createSphereShape(radius);
    if (!sphereShape) {
        m_components.erase(component->id);
        return 0;
    }

    // Add collider to the rigid body
    Transform colliderTransform = Transform::identity();
    Collider* collider = component->rigidBody->addCollider(sphereShape, colliderTransform);
    if (!collider) {
        m_components.erase(component->id);
        return 0;
    }

    // Set material properties
    Material& material = collider->getMaterial();
    material.setBounciness(config.bounciness);
    material.setFrictionCoefficient(config.friction);

    // Store collider reference
    component->colliders.push_back(collider);

    // Update mass properties
    updateMassProperties(component);

    return component->id;
}

uint32_t PhysicsComponentManager::createBox(const PhysicsObjectConfig& config, const Vector3& halfExtents) {
    if (!m_initialized) {
        return 0;
    }

    // Create the base component
    PhysicsComponent* component = createComponentInternal(config);
    if (!component) {
        return 0;
    }

    // Create box shape
    BoxShape* boxShape = createBoxShape(halfExtents);
    if (!boxShape) {
        m_components.erase(component->id);
        return 0;
    }

    // Add collider to the rigid body
    Transform colliderTransform = Transform::identity();
    Collider* collider = component->rigidBody->addCollider(boxShape, colliderTransform);
    if (!collider) {
        m_components.erase(component->id);
        return 0;
    }

    // Set material properties
    Material& material = collider->getMaterial();
    material.setBounciness(config.bounciness);
    material.setFrictionCoefficient(config.friction);

    // Store collider reference
    component->colliders.push_back(collider);

    // Update mass properties
    updateMassProperties(component);

    return component->id;
}

uint32_t PhysicsComponentManager::createCapsule(const PhysicsObjectConfig& config, float radius, float height) {
    if (!m_initialized) {
        return 0;
    }

    // Create the base component
    PhysicsComponent* component = createComponentInternal(config);
    if (!component) {
        return 0;
    }

    // Create capsule shape
    CapsuleShape* capsuleShape = createCapsuleShape(radius, height);
    if (!capsuleShape) {
        m_components.erase(component->id);
        return 0;
    }

    // Add collider to the rigid body
    Transform colliderTransform = Transform::identity();
    Collider* collider = component->rigidBody->addCollider(capsuleShape, colliderTransform);
    if (!collider) {
        m_components.erase(component->id);
        return 0;
    }

    // Set material properties
    Material& material = collider->getMaterial();
    material.setBounciness(config.bounciness);
    material.setFrictionCoefficient(config.friction);

    // Store collider reference
    component->colliders.push_back(collider);

    // Update mass properties
    updateMassProperties(component);

    return component->id;
}

bool PhysicsComponentManager::removeComponent(uint32_t componentId) {
    auto it = m_components.find(componentId);
    if (it == m_components.end()) {
        return false;
    }

    PhysicsComponent* component = it->second.get();
    if (component && component->rigidBody && m_physicsWorld) {
        m_physicsWorld->destroyRigidBody(component->rigidBody);
    }

    m_components.erase(it);
    return true;
}

PhysicsComponent* PhysicsComponentManager::getComponent(uint32_t componentId) {
    auto it = m_components.find(componentId);
    return (it != m_components.end()) ? it->second.get() : nullptr;
}

bool PhysicsComponentManager::setComponentActive(uint32_t componentId, bool active) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    component->isActive = active;
    component->rigidBody->setIsActive(active);
    return true;
}

bool PhysicsComponentManager::setComponentTransform(uint32_t componentId, const Transform& transform) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    component->transform = transform;
    component->rigidBody->setTransform(transform);
    return true;
}

bool PhysicsComponentManager::getComponentTransform(uint32_t componentId, Transform& outTransform) const {
    const PhysicsComponent* component = const_cast<PhysicsComponentManager*>(this)->getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    outTransform = component->rigidBody->getTransform();
    component->transform = outTransform; // Cache the transform
    return true;
}

bool PhysicsComponentManager::setComponentPosition(uint32_t componentId, const Vector3& position) {
    Transform transform;
    if (!getComponentTransform(componentId, transform)) {
        return false;
    }

    transform.setPosition(position);
    return setComponentTransform(componentId, transform);
}

bool PhysicsComponentManager::getComponentPosition(uint32_t componentId, Vector3& outPosition) const {
    Transform transform;
    if (!getComponentTransform(componentId, transform)) {
        return false;
    }

    outPosition = transform.getPosition();
    return true;
}

bool PhysicsComponentManager::setComponentVelocity(uint32_t componentId, const Vector3& velocity) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    component->rigidBody->setLinearVelocity(velocity);
    return true;
}

bool PhysicsComponentManager::getComponentVelocity(uint32_t componentId, Vector3& outVelocity) const {
    const PhysicsComponent* component = const_cast<PhysicsComponentManager*>(this)->getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    outVelocity = component->rigidBody->getLinearVelocity();
    return true;
}

bool PhysicsComponentManager::setComponentMass(uint32_t componentId, float mass) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    component->rigidBody->setMass(mass);
    return true;
}

float PhysicsComponentManager::getComponentMass(uint32_t componentId) const {
    const PhysicsComponent* component = const_cast<PhysicsComponentManager*>(this)->getComponent(componentId);
    if (!component || !component->rigidBody) {
        return 0.0f;
    }

    return component->rigidBody->getMass();
}

bool PhysicsComponentManager::setComponentGravityEnabled(uint32_t componentId, bool enabled) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    component->rigidBody->enableGravity(enabled);
    return true;
}

bool PhysicsComponentManager::isComponentGravityEnabled(uint32_t componentId) const {
    const PhysicsComponent* component = const_cast<PhysicsComponentManager*>(this)->getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    // Note: ReactPhysics3D doesn't have a direct getter for gravity enabled state
    // We'll assume it's enabled for dynamic bodies unless explicitly disabled
    return component->rigidBody->getType() == BodyType::DYNAMIC;
}

bool PhysicsComponentManager::applyForce(uint32_t componentId, const Vector3& force) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    component->rigidBody->applyWorldForceAtCenterOfMass(force);
    return true;
}

bool PhysicsComponentManager::applyForceAtPosition(uint32_t componentId, const Vector3& force, const Vector3& position) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    component->rigidBody->applyWorldForceAtWorldPosition(force, position);
    return true;
}

bool PhysicsComponentManager::applyImpulse(uint32_t componentId, const Vector3& impulse) {
    PhysicsComponent* component = getComponent(componentId);
    if (!component || !component->rigidBody) {
        return false;
    }

    // Convert impulse to force (impulse = force * dt, so force = impulse / dt)
    // For simplicity, we'll apply it as a force over a small time step
    const float smallDt = 1.0f / 60.0f;
    Vector3 force = impulse * (1.0f / smallDt);
    component->rigidBody->applyWorldForceAtCenterOfMass(force);
    return true;
}

bool PhysicsComponentManager::raycast(const Vector3& start, const Vector3& end, RaycastInfo& hitInfo) const {
    if (!m_initialized || !m_physicsWorld) {
        return false;
    }

    Ray ray(start, end);
    SimpleRaycastCallback callback;
    callback.hitInfo = &hitInfo;

    m_physicsWorld->raycast(ray, &callback);

    return callback.hasHit;
}

std::vector<uint32_t> PhysicsComponentManager::getComponentsInSphere(const Vector3& center, float radius) const {
    std::vector<uint32_t> result;

    for (const auto& pair : m_components) {
        uint32_t id = pair.first;
        const PhysicsComponent* component = pair.second.get();

        if (!component || !component->rigidBody) {
            continue;
        }

        Vector3 position = component->rigidBody->getTransform().getPosition();
        float distance = (position - center).length();

        if (distance <= radius) {
            result.push_back(id);
        }
    }

    return result;
}

uint32_t PhysicsComponentManager::getComponentCount() const {
    return static_cast<uint32_t>(m_components.size());
}

std::vector<uint32_t> PhysicsComponentManager::getAllComponentIds() const {
    std::vector<uint32_t> ids;
    ids.reserve(m_components.size());

    for (const auto& pair : m_components) {
        ids.push_back(pair.first);
    }

    return ids;
}

void PhysicsComponentManager::clearAllComponents() {
    // Destroy all rigid bodies
    for (auto& pair : m_components) {
        PhysicsComponent* component = pair.second.get();
        if (component && component->rigidBody && m_physicsWorld) {
            m_physicsWorld->destroyRigidBody(component->rigidBody);
        }
    }

    m_components.clear();
}

// Private helper methods

uint32_t PhysicsComponentManager::generateComponentId() {
    return m_nextComponentId++;
}

PhysicsComponent* PhysicsComponentManager::createComponentInternal(const PhysicsObjectConfig& config) {
    if (!m_physicsWorld) {
        return nullptr;
    }

    // Create new component
    auto component = std::make_unique<PhysicsComponent>();
    component->id = generateComponentId();
    component->transform.setPosition(config.position);
    component->transform.setOrientation(config.orientation);
    component->isActive = true;

    // Create rigid body
    component->rigidBody = m_physicsWorld->createRigidBody(component->transform);
    if (!component->rigidBody) {
        return nullptr;
    }

    // Configure rigid body
    component->rigidBody->setType(config.bodyType);
    component->rigidBody->setMass(config.mass);
    component->rigidBody->enableGravity(config.enableGravity);
    component->rigidBody->setLinearVelocity(config.velocity);

    PhysicsComponent* rawPtr = component.get();
    m_components[component->id] = std::move(component);

    return rawPtr;
}

void PhysicsComponentManager::updateMassProperties(PhysicsComponent* component) {
    if (!component || !component->rigidBody) {
        return;
    }

    // Update mass properties based on colliders
    component->rigidBody->updateMassPropertiesFromColliders();
}

SphereShape* PhysicsComponentManager::createSphereShape(float radius) {
    if (!m_physicsCommon) {
        return nullptr;
    }
    return m_physicsCommon->createSphereShape(radius);
}

BoxShape* PhysicsComponentManager::createBoxShape(const Vector3& halfExtents) {
    if (!m_physicsCommon) {
        return nullptr;
    }
    return m_physicsCommon->createBoxShape(halfExtents);
}

CapsuleShape* PhysicsComponentManager::createCapsuleShape(float radius, float height) {
    if (!m_physicsCommon) {
        return nullptr;
    }
    return m_physicsCommon->createCapsuleShape(radius, height);
}