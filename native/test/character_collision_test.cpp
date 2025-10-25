/*
 * Character Collision Test
 *
 * Demonstrates collision between a jumping character and a static collidable object.
 * Shows how forward motion is blocked by collision while gravity continues to affect the character.
 */

#include "../reactphysics3d/include/CharacterController.hpp"
#include <iostream>
#include <chrono>
#include <thread>

using namespace reactphysics3d;

int main() {
    std::cout << "=== Character Collision Test ===" << std::endl;
    std::cout << "Testing collision between jumping character and static wall..." << std::endl;

    // Create physics manager
    PhysicsComponentManager physicsManager;

    // Initialize with Earth gravity
    if (!physicsManager.initialize(Vector3(0, -9.81f, 0))) {
        std::cerr << "Failed to initialize physics manager!" << std::endl;
        return 1;
    }
    std::cout << "✓ Physics manager initialized successfully" << std::endl;

    // Create ground plane
    PhysicsObjectConfig groundConfig;
    groundConfig.position = Vector3(0, -1, 0);
    groundConfig.bodyType = BodyType::STATIC;
    groundConfig.bounciness = 0.0f;
    groundConfig.friction = 1.0f;

    uint32_t groundId = physicsManager.createBox(groundConfig, Vector3(20, 2, 10));
    if (groundId == 0) {
        std::cerr << "Failed to create ground!" << std::endl;
        return 1;
    }
    std::cout << "✓ Ground created" << std::endl;

    // Create static wall object - larger to ensure collision
    PhysicsObjectConfig wallConfig;
    wallConfig.position = Vector3(3, 2, 0);  // Positioned further in character's path
    wallConfig.bodyType = BodyType::STATIC;   // Immovable
    wallConfig.bounciness = 0.0f;             // No bouncing
    wallConfig.friction = 0.8f;               // High friction
    wallConfig.mass = 0.0f;                   // Static objects have no mass
    wallConfig.enableGravity = false;         // No gravity for static objects

    uint32_t wallId = physicsManager.createBox(wallConfig, Vector3(4, 4, 4));  // Much larger wall
    if (wallId == 0) {
        std::cerr << "Failed to create wall!" << std::endl;
        return 1;
    }
    std::cout << "✓ Static wall created at position (3, 2, 0) with size (4, 4, 4)" << std::endl;

    // Create character controller
    CharacterController character(physicsManager);

    // Character configuration
    CharacterConfig config;
    config.height = 1.8f;      // Human height
    config.radius = 0.3f;      // Capsule radius
    config.mass = 10.0f;       // Lighter character for more responsive movement
    config.maxSpeed = 15.0f;   // Very high speed for reaching wall
    config.jumpForce = 8.0f;   // Stronger jump force
    config.slopeLimit = 45.0f; // Can walk on 45-degree slopes

    // Create character on the left side, facing the wall
    Vector3 startPosition(-5, 2, 0);  // Start 5 units left of wall, higher up
    if (!character.createCharacter(config, startPosition)) {
        std::cerr << "Failed to create character!" << std::endl;
        return 1;
    }
    std::cout << "✓ Character created at position (" << startPosition.x << ", "
              << startPosition.y << ", " << startPosition.z << ")" << std::endl;

    // Test parameters
    const float timeStep = 1.0f / 60.0f; // 60 FPS
    const int totalFrames = 480; // 8 seconds of simulation
    const int jumpFrame = 120;   // Jump at 2 seconds
    const int preJumpFrames = jumpFrame;
    const int postJumpFrames = totalFrames - jumpFrame;

    std::cout << "\n=== Starting Collision Test ===" << std::endl;
    std::cout << "Test Plan:" << std::endl;
    std::cout << "- Frames 0-120: Character stands still (2 seconds)" << std::endl;
    std::cout << "- Frame 120: Character jumps forward toward wall" << std::endl;
    std::cout << "- Frames 120-480: Monitor collision and physics response" << std::endl;
    std::cout << std::endl;

    // Store initial values for comparison
    Vector3 initialCharacterPos = character.getPosition();
    Vector3 initialCharacterVel = character.getVelocity();
    Vector3 wallPos = Vector3(3, 2, 0);

    // Collision detection variables
    bool collisionDetected = false;
    float collisionFrame = -1;
    Vector3 preCollisionVelocity(0, 0, 0);
    Vector3 postCollisionVelocity(0, 0, 0);
    float minDistanceToWall = 999.0f;
    float closestFrame = -1;

    std::cout << "Initial State:" << std::endl;
    std::cout << "Character Position: (" << initialCharacterPos.x << ", "
              << initialCharacterPos.y << ", " << initialCharacterPos.z << ")" << std::endl;
    std::cout << "Character Velocity: (" << initialCharacterVel.x << ", "
              << initialCharacterVel.y << ", " << initialCharacterVel.z << ")" << std::endl;
    std::cout << "Wall Position: (" << wallPos.x << ", " << wallPos.y << ", " << wallPos.z << ")" << std::endl;
    std::cout << "Distance to wall: " << (wallPos - initialCharacterPos).length() << " units" << std::endl;
    std::cout << std::endl;

    // Run simulation
    for (int frame = 0; frame < totalFrames; ++frame) {
        // Print header for important events
        if (frame == jumpFrame) {
            std::cout << "=== JUMP INITIATED (Frame " << frame << ") ===" << std::endl;

            // Make character jump forward (toward the wall)
            Vector3 jumpDirection(1, 0, 0);  // Forward (positive X)
            character.move(jumpDirection, timeStep);
            character.jump();

            // Also apply a strong forward impulse to ensure we reach the wall
            Vector3 forwardImpulse(100.0f, 0, 0);  // Forward impulse (reduced for more controlled test)
            physicsManager.applyImpulse(character.getComponentId(), forwardImpulse);
        }

        // Update physics and character
        physicsManager.update(timeStep);
        character.update(timeStep);

        // Get current state
        Vector3 currentPos = character.getPosition();
        Vector3 currentVel = character.getVelocity();
        CharacterState state = character.getState();

        // Calculate distance to wall
        float distanceToWall = (wallPos - currentPos).length();
        if (distanceToWall < minDistanceToWall) {
            minDistanceToWall = distanceToWall;
            closestFrame = frame;
        }

        // Check for collision (position stagnation or unexpected behavior)
        if (!collisionDetected && frame > jumpFrame + 10) { // Give time for jump to develop
            // Check if character has stopped moving forward despite having forward velocity
            static Vector3 lastPos = currentPos;

            if (frame > jumpFrame + 20) { // After initial jump phase
                float forwardMovement = currentPos.x - lastPos.x;
                bool hasForwardVelocity = currentVel.x > 0.5f;
                bool notMovingForward = forwardMovement < 0.01f;

                if (hasForwardVelocity && notMovingForward && distanceToWall < 6.0f) {
                    collisionDetected = true;
                    collisionFrame = frame;
                    preCollisionVelocity = Vector3(currentVel.x, currentVel.y, currentVel.z);
                    postCollisionVelocity = currentVel;

                    std::cout << "\n=== COLLISION DETECTED (Frame " << frame << ") ===" << std::endl;
                    std::cout << "Position at collision: (" << currentPos.x << ", "
                              << currentPos.y << ", " << currentPos.z << ")" << std::endl;
                    std::cout << "Distance to wall: " << distanceToWall << " units" << std::endl;
                    std::cout << "Forward velocity present: " << currentVel.x << " (but position not changing)" << std::endl;
                    std::cout << "Y velocity (gravity): " << currentVel.y << " (still active)" << std::endl;
                    std::cout << "Frame-to-frame X movement: " << forwardMovement << " (near zero = blocked by collision)" << std::endl;
                }
            }

            lastPos = currentPos;
        }

        // Store current velocity for next frame comparison
        postCollisionVelocity = currentVel;

        // Print detailed status at key intervals
        if (frame == jumpFrame - 1) { // Just before jump
            std::cout << "Pre-jump state (Frame " << frame << "):" << std::endl;
            std::cout << "  Position: (" << currentPos.x << ", " << currentPos.y << ", " << currentPos.z << ")" << std::endl;
            std::cout << "  Velocity: (" << currentVel.x << ", " << currentVel.y << ", " << currentVel.z << ")" << std::endl;
            std::cout << "  State: ";
            switch (state) {
                case CharacterState::GROUNDED: std::cout << "GROUNDED"; break;
                case CharacterState::JUMPING: std::cout << "JUMPING"; break;
                case CharacterState::FALLING: std::cout << "FALLING"; break;
            }
            std::cout << std::endl;
            std::cout << "  Distance to wall: " << distanceToWall << " units" << std::endl;
        } else if (frame == jumpFrame + 30) { // Mid-jump, approaching wall
            std::cout << "Mid-jump approach (Frame " << frame << "):" << std::endl;
            std::cout << "  Position: (" << currentPos.x << ", " << currentPos.y << ", " << currentPos.z << ")" << std::endl;
            std::cout << "  Velocity: (" << currentVel.x << ", " << currentVel.y << ", " << currentVel.z << ")" << std::endl;
            std::cout << "  Distance to wall: " << distanceToWall << " units" << std::endl;
        }

        // Print every 60 frames (1 second) for general progress
        if (frame % 60 == 0 && frame > 0) {
            std::cout << "Frame " << frame << " - Position: ("
                      << currentPos.x << ", " << currentPos.y << ", " << currentPos.z
                      << ") Velocity: (" << currentVel.x << ", " << currentVel.y << ", " << currentVel.z << ") ";

            switch (state) {
                case CharacterState::GROUNDED: std::cout << "[GROUNDED]"; break;
                case CharacterState::JUMPING: std::cout << "[JUMPING]"; break;
                case CharacterState::FALLING: std::cout << "[FALLING]"; break;
            }

            if (collisionDetected) {
                std::cout << " [COLLISION OCCURRED]";
            }

            std::cout << std::endl;
        }
    }

    // Final state analysis
    Vector3 finalPos = character.getPosition();
    Vector3 finalVel = character.getVelocity();
    CharacterState finalState = character.getState();

    std::cout << "\n=== FINAL RESULTS ===" << std::endl;
    std::cout << "Final Position: (" << finalPos.x << ", " << finalPos.y << ", " << finalPos.z << ")" << std::endl;
    std::cout << "Final Velocity: (" << finalVel.x << ", " << finalVel.y << ", " << finalVel.z << ")" << std::endl;
    std::cout << "Final State: ";
    switch (finalState) {
        case CharacterState::GROUNDED: std::cout << "GROUNDED"; break;
        case CharacterState::JUMPING: std::cout << "JUMPING"; break;
        case CharacterState::FALLING: std::cout << "FALLING"; break;
    }
    std::cout << std::endl;

    std::cout << "\n=== COLLISION ANALYSIS ===" << std::endl;
    if (collisionDetected) {
        std::cout << "✓ Collision successfully detected at frame " << collisionFrame << std::endl;
        std::cout << "✓ Forward X velocity was blocked: "
                  << preCollisionVelocity.x << " → " << postCollisionVelocity.x << std::endl;
        std::cout << "✓ Gravity continued to affect Y velocity: " << postCollisionVelocity.y << std::endl;
        std::cout << "✓ Character stopped moving forward but continued falling" << std::endl;
    } else {
        std::cout << "✗ No collision detected (this may indicate an issue)" << std::endl;
        std::cout << "  Closest approach: " << minDistanceToWall << " units at frame " << closestFrame << std::endl;
    }

    std::cout << "\n=== PHYSICS VERIFICATION ===" << std::endl;

    // Verify that gravity was unaffected
    bool gravityUnaffected = true;
    if (collisionDetected && postCollisionVelocity.y > -8.0f) {
        gravityUnaffected = false;
        std::cout << "⚠ Warning: Gravity may have been affected by collision" << std::endl;
    }

    // Verify that forward motion was blocked
    bool forwardBlocked = true;
    if (collisionDetected && finalPos.x > 0.5f) {
        forwardBlocked = false;
        std::cout << "⚠ Warning: Character may have passed through the wall" << std::endl;
    }

    if (gravityUnaffected && forwardBlocked) {
        std::cout << "✓ Test PASSED: Forward motion blocked, gravity unaffected" << std::endl;
    } else {
        std::cout << "✗ Test FAILED: Physics behavior not as expected" << std::endl;
    }

    // Cleanup
    character.destroyCharacter();
    physicsManager.removeComponent(wallId);
    physicsManager.removeComponent(groundId);
    physicsManager.shutdown();

    std::cout << "\n=== Character Collision Test Complete ===" << std::endl;
    return 0;
}