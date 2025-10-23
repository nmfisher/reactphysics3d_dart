/*
 * CharacterController
 *
 * A high-level character controller built on top of ReactPhysics3D.
 * Provides jump system, movement control, and collision detection for game characters.
 */

#pragma once

#include "PhysicsComponentManager.hpp"
#include <reactphysics3d/reactphysics3d.h>
#include <memory>

using namespace reactphysics3d;

// Character movement state
enum class CharacterState {
    GROUNDED,
    JUMPING,
    FALLING
};

// Character configuration
struct CharacterConfig {
    float height;           // Total character height
    float radius;           // Capsule radius
    float mass;             // Character mass
    float maxSpeed;         // Maximum horizontal speed
    float jumpForce;        // Jump upward force/impulse
    float gravity;          // Gravity multiplier
    float groundCheckDistance; // Distance to check for ground
    float slopeLimit;       // Maximum walkable slope angle (degrees)
    float stepHeight;       // Maximum step height

    CharacterConfig()
        : height(1.8f)
        , radius(0.3f)
        , mass(70.0f)
        , maxSpeed(5.0f)
        , jumpForce(8.0f)
        , gravity(1.0f)
        , groundCheckDistance(0.1f)
        , slopeLimit(45.0f)
        , stepHeight(0.3f) {}
};

// Character controller class
class CharacterController {
public:
    CharacterController(PhysicsComponentManager& physicsManager);
    ~CharacterController();

    // Character creation and destruction
    bool createCharacter(const CharacterConfig& config, const Vector3& position);
    void destroyCharacter();

    // Movement control
    void move(const Vector3& direction, float deltaTime);
    void jump();
    void setVelocity(const Vector3& velocity);
    Vector3 getVelocity() const;

    // Position control
    void setPosition(const Vector3& position);
    Vector3 getPosition() const;

    // State queries
    CharacterState getState() const { return m_state; }
    bool isGrounded() const { return m_state == CharacterState::GROUNDED; }
    bool isJumping() const { return m_state == CharacterState::JUMPING; }
    bool isFalling() const { return m_state == CharacterState::FALLING; }

    // Physics properties
    float getMass() const { return m_config.mass; }
    void setMass(float mass);

    // Ground information
    Vector3 getGroundNormal() const { return m_groundNormal; }
    float getGroundSlope() const { return m_groundSlope; }

    // Configuration
    const CharacterConfig& getConfig() const { return m_config; }
    void setConfig(const CharacterConfig& config);

    // Update (call this every frame)
    void update(float deltaTime);

    // Access to underlying physics component
    uint32_t getComponentId() const { return m_componentId; }
    PhysicsComponent* getPhysicsComponent();

private:
    PhysicsComponentManager& m_physicsManager;
    CharacterConfig m_config;
    uint32_t m_componentId;
    CharacterState m_state;

    // Ground detection
    Vector3 m_groundNormal;
    float m_groundSlope;
    bool m_wasGroundedLastFrame;

    // Movement
    Vector3 m_velocity;
    Vector3 m_horizontalVelocity;
    float m_verticalVelocity;

    // Internal methods
    void updateGroundDetection();
    void applyGravity(float deltaTime);
    void applyMovement(float deltaTime);
    void updateState();
    bool checkGroundCollision();
    bool isSlopeWalkable(float slopeAngle) const;

    // Force application helpers
    void applyJumpForce();
    void applyHorizontalMovement(const Vector3& direction, float deltaTime);
};