/*
 * CharacterController Implementation
 *
 * Implements character movement, jumping, and collision detection
 * using ReactPhysics3D's physics system.
 */

#include "CharacterController.hpp"
#include <cmath>
#include <algorithm>

CharacterController::CharacterController(PhysicsComponentManager& physicsManager)
    : m_physicsManager(physicsManager)
    , m_componentId(0)
    , m_state(CharacterState::FALLING)
    , m_groundNormal(0, 1, 0)
    , m_groundSlope(0.0f)
    , m_wasGroundedLastFrame(false)
    , m_velocity(0, 0, 0)
    , m_horizontalVelocity(0, 0, 0)
    , m_verticalVelocity(0.0f) {
}

CharacterController::~CharacterController() {
    destroyCharacter();
}

bool CharacterController::createCharacter(const CharacterConfig& config, const Vector3& position) {
    m_config = config;

    // Create physics object configuration
    PhysicsObjectConfig physicsConfig;
    physicsConfig.position = position;
    physicsConfig.mass = config.mass;
    physicsConfig.bodyType = BodyType::DYNAMIC; // Use DYNAMIC for proper gravity response
    physicsConfig.enableGravity = true;
    physicsConfig.bounciness = 0.0f; // No bouncing for character
    physicsConfig.friction = 0.5f;

    // Create capsule shape (capsules are ideal for characters)
    float capsuleHeight = config.height - 2.0f * config.radius;
    if (capsuleHeight < 0.1f) capsuleHeight = 0.1f; // Ensure minimum height

    m_componentId = m_physicsManager.createCapsule(physicsConfig, config.radius, capsuleHeight);

    if (m_componentId == 0) {
        return false;
    }

    // Initialize state
    m_state = CharacterState::FALLING;
    m_velocity = Vector3(0, 0, 0);
    m_horizontalVelocity = Vector3(0, 0, 0);
    m_verticalVelocity = 0.0f;
    m_wasGroundedLastFrame = false;

    return true;
}

void CharacterController::destroyCharacter() {
    if (m_componentId != 0) {
        m_physicsManager.removeComponent(m_componentId);
        m_componentId = 0;
    }
}

void CharacterController::move(const Vector3& direction, float deltaTime) {
    if (m_componentId == 0) return;

    // Normalize and scale direction
    Vector3 normalizedDir = direction;
    float length = normalizedDir.length();
    if (length > 0.001f) {
        normalizedDir = normalizedDir * (1.0f / length);
    }

    // Apply horizontal movement
    applyHorizontalMovement(normalizedDir, deltaTime);
}

void CharacterController::jump() {
    if (m_componentId == 0) return;

    // Only jump if grounded
    if (m_state == CharacterState::GROUNDED) {
        applyJumpForce();
        m_state = CharacterState::JUMPING;
        m_verticalVelocity = m_config.jumpForce;
    }
}

void CharacterController::setVelocity(const Vector3& velocity) {
    if (m_componentId == 0) return;

    m_velocity = velocity;
    m_horizontalVelocity = Vector3(velocity.x, 0, velocity.z);
    m_verticalVelocity = velocity.y;

    m_physicsManager.setComponentVelocity(m_componentId, velocity);
}

Vector3 CharacterController::getVelocity() const {
    if (m_componentId == 0) return Vector3(0, 0, 0);

    Vector3 physicsVelocity;
    if (m_physicsManager.getComponentVelocity(m_componentId, physicsVelocity)) {
        return physicsVelocity;
    }
    return m_velocity;
}

void CharacterController::setPosition(const Vector3& position) {
    if (m_componentId == 0) return;

    m_physicsManager.setComponentPosition(m_componentId, position);
}

Vector3 CharacterController::getPosition() const {
    if (m_componentId == 0) return Vector3(0, 0, 0);

    Vector3 position;
    if (m_physicsManager.getComponentPosition(m_componentId, position)) {
        return position;
    }
    return Vector3(0, 0, 0);
}

void CharacterController::setMass(float mass) {
    if (m_componentId == 0) return;

    m_config.mass = mass;
    m_physicsManager.setComponentMass(m_componentId, mass);
}

void CharacterController::setConfig(const CharacterConfig& config) {
    m_config = config;

    // Update physics object if it exists
    if (m_componentId != 0) {
        setMass(config.mass);
    }
}

void CharacterController::update(float deltaTime) {
    if (m_componentId == 0) return;

    // Update ground detection
    updateGroundDetection();

    // Apply gravity if not grounded
    if (m_state != CharacterState::GROUNDED) {
        applyGravity(deltaTime);
    }

    // Apply movement
    applyMovement(deltaTime);

    // Update character state
    updateState();

    // Store ground state for next frame
    m_wasGroundedLastFrame = (m_state == CharacterState::GROUNDED);
}

PhysicsComponent* CharacterController::getPhysicsComponent() {
    if (m_componentId == 0) return nullptr;
    return m_physicsManager.getComponent(m_componentId);
}

void CharacterController::updateGroundDetection() {
    // Cast ray downward from character center
    Vector3 characterPos = getPosition();
    Vector3 rayStart = characterPos + Vector3(0, m_config.radius, 0);
    Vector3 rayEnd = characterPos - Vector3(0, m_config.groundCheckDistance + m_config.radius, 0);

    RaycastInfo hitInfo;
    bool hasHit = m_physicsManager.raycast(rayStart, rayEnd, hitInfo);

    if (hasHit) {
        m_groundNormal = hitInfo.worldNormal;

        // Calculate slope angle
        Vector3 upVector(0, 1, 0);
        float dotProduct = m_groundNormal.dot(upVector);
        m_groundSlope = std::acos(std::clamp(dotProduct, -1.0f, 1.0f)) * (180.0f / M_PI);
    } else {
        m_groundNormal = Vector3(0, 1, 0);
        m_groundSlope = 0.0f;
    }
}

void CharacterController::applyGravity(float deltaTime) {
    // Apply gravity to vertical velocity
    Vector3 currentGravity = m_physicsManager.getGravity();
    m_verticalVelocity += currentGravity.y * m_config.gravity * deltaTime;

    // Update velocity
    m_velocity = Vector3(m_horizontalVelocity.x, m_verticalVelocity, m_horizontalVelocity.z);
}

void CharacterController::applyMovement(float deltaTime) {
    if (m_componentId == 0) return;

    // Apply velocity to physics body
    m_physicsManager.setComponentVelocity(m_componentId, m_velocity);
}

void CharacterController::updateState() {
    bool isGrounded = checkGroundCollision();

    if (isGrounded) {
        if (m_state == CharacterState::FALLING && m_verticalVelocity < -0.1f) {
            // Just landed
            m_state = CharacterState::GROUNDED;
            m_verticalVelocity = 0.0f;

            // Stop horizontal velocity when landing softly
            if (m_horizontalVelocity.length() < 0.1f) {
                m_horizontalVelocity = Vector3(0, 0, 0);
            }
        } else if (m_state == CharacterState::JUMPING && m_verticalVelocity <= 0.0f) {
            // Jump apex reached, now falling
            m_state = CharacterState::FALLING;
        } else if (m_state == CharacterState::GROUNDED) {
            // Ensure no vertical velocity when grounded
            m_verticalVelocity = 0.0f;
        }
    } else {
        // Not grounded - either jumping or falling
        if (m_verticalVelocity > 0.1f) {
            m_state = CharacterState::JUMPING;
        } else {
            m_state = CharacterState::FALLING;
        }
    }

    // Update combined velocity
    m_velocity = Vector3(m_horizontalVelocity.x, m_verticalVelocity, m_horizontalVelocity.z);
}

bool CharacterController::checkGroundCollision() {
    // Check if we're close enough to ground and slope is walkable
    Vector3 characterPos = getPosition();
    Vector3 rayStart = characterPos + Vector3(0, m_config.radius, 0);
    Vector3 rayEnd = characterPos - Vector3(0, m_config.groundCheckDistance + m_config.radius, 0);

    RaycastInfo hitInfo;
    bool hasHit = m_physicsManager.raycast(rayStart, rayEnd, hitInfo);

    if (hasHit) {
        // Check if the hit distance is within ground check range
        float hitDistance = (hitInfo.worldPoint - rayStart).length();
        if (hitDistance <= m_config.groundCheckDistance + m_config.radius) {
            // Check if slope is walkable
            return isSlopeWalkable(m_groundSlope);
        }
    }

    return false;
}

bool CharacterController::isSlopeWalkable(float slopeAngle) const {
    return slopeAngle <= m_config.slopeLimit;
}

void CharacterController::applyJumpForce() {
    // Apply upward impulse for jump
    Vector3 jumpImpulse(0, m_config.jumpForce, 0);
    m_physicsManager.applyImpulse(m_componentId, jumpImpulse);
}

void CharacterController::applyHorizontalMovement(const Vector3& direction, float deltaTime) {
    // Calculate desired velocity
    Vector3 desiredVelocity = direction * m_config.maxSpeed;

    // Smooth velocity change (simple acceleration)
    float acceleration = 15.0f; // Adjust for desired responsiveness
    m_horizontalVelocity = m_horizontalVelocity + (desiredVelocity - m_horizontalVelocity) * acceleration * deltaTime;

    // Update combined velocity
    m_velocity = Vector3(m_horizontalVelocity.x, m_verticalVelocity, m_horizontalVelocity.z);
}