/*
 * Character Sliding Test
 *
 * Tests wall sliding behavior where characters approaching walls at angles
 * should slide along the wall surface rather than stopping completely.
 */

#include "../reactphysics3d/include/CharacterController.hpp"
#include <iostream>
#include <chrono>
#include <thread>

using namespace reactphysics3d;

int main() {
    std::cout << "=== Character Sliding Test ===" << std::endl;
    std::cout << "Testing sliding behavior when character approaches wall at angle..." << std::endl;

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

    // Create static wall object
    PhysicsObjectConfig wallConfig;
    wallConfig.position = Vector3(3, 2, 0);
    wallConfig.bodyType = BodyType::STATIC;
    wallConfig.bounciness = 0.0f;
    wallConfig.friction = 0.8f;
    wallConfig.mass = 0.0f;
    wallConfig.enableGravity = false;

    uint32_t wallId = physicsManager.createBox(wallConfig, Vector3(4, 4, 4));
    if (wallId == 0) {
        std::cerr << "Failed to create wall!" << std::endl;
        return 1;
    }
    std::cout << "✓ Static wall created at position (3, 2, 0)" << std::endl;

    // Create character controller
    CharacterController character(physicsManager);

    // Character configuration
    CharacterConfig config;
    config.height = 1.8f;
    config.radius = 0.3f;
    config.mass = 10.0f;
    config.maxSpeed = 5.0f;
    config.jumpForce = 8.0f;
    config.slopeLimit = 45.0f;

    // Create character at an angle from wall (diagonal approach)
    Vector3 startPosition(-5, 1, -2); // Start left and back from wall
    if (!character.createCharacter(config, startPosition)) {
        std::cerr << "Failed to create character!" << std::endl;
        return 1;
    }
    std::cout << "✓ Character created at diagonal approach position (" << startPosition.x << ", "
              << startPosition.y << ", " << startPosition.z << ")" << std::endl;

    // Test parameters
    const float timeStep = 1.0f / 60.0f; // 60 FPS
    const int totalFrames = 300; // 5 seconds of simulation
    const int startMoveFrame = 60; // Start moving after 1 second

    std::cout << "\n=== Starting Sliding Test ===" << std::endl;
    std::cout << "Test Plan:" << std::endl;
    std::cout << "- Frames 0-60: Character stands still" << std::endl;
    std::cout << "- Frame 60+: Character moves diagonally toward wall (forward + right)" << std::endl;
    std::cout << "- Expected: Character should slide along wall (Z movement continues, X stops)" << std::endl;
    std::cout << std::endl;

    // Tracking variables
    Vector3 initialPosition = character.getPosition();
    Vector3 wallPos = Vector3(3, 2, 0);
    bool collisionDetected = false;
    int collisionFrame = -1;
    Vector3 preCollisionPosition(0, 0, 0);
    Vector3 postCollisionPosition(0, 0, 0);

    // Movement tracking for sliding analysis
    std::vector<Vector3> positions;
    std::vector<bool> collisionStates;
    std::vector<Vector3> velocities;

    std::cout << "Initial State:" << std::endl;
    std::cout << "Character Position: (" << initialPosition.x << ", "
              << initialPosition.y << ", " << initialPosition.z << ")" << std::endl;
    std::cout << "Wall Position: (" << wallPos.x << ", " << wallPos.y << ", " << wallPos.z << ")" << std::endl;
    std::cout << "Distance to wall: " << (wallPos - initialPosition).length() << " units" << std::endl;
    std::cout << std::endl;

    // Run simulation
    for (int frame = 0; frame < totalFrames; ++frame) {
        // Start diagonal movement toward wall
        if (frame >= startMoveFrame) {
            // Move diagonally: forward (positive X) and right (positive Z)
            // This approach should hit the wall at an angle and slide along it
            Vector3 moveDirection(0.7f, 0, 0.7f); // Diagonal direction
            moveDirection.normalize();
            character.move(moveDirection, timeStep);
        }

        // Update physics and character
        physicsManager.update(timeStep);
        character.update(timeStep);

        // Get current state
        Vector3 currentPos = character.getPosition();
        Vector3 currentVel = character.getVelocity();
        CharacterState state = character.getState();
        bool hasCollision = character.hasCollision();
        Vector3 collisionNormal = character.getCollisionNormal();

        // Store data for analysis
        positions.push_back(currentPos);
        collisionStates.push_back(hasCollision);
        velocities.push_back(currentVel);

        // Detect collision onset
        if (!collisionDetected && hasCollision && frame > startMoveFrame + 10) {
            collisionDetected = true;
            collisionFrame = frame;
            preCollisionPosition = positions.size() > 1 ? positions[positions.size() - 2] : currentPos;
            postCollisionPosition = currentPos;

            std::cout << "\n=== COLLISION DETECTED (Frame " << frame << ") ===" << std::endl;
            std::cout << "Position at collision: (" << currentPos.x << ", "
                      << currentPos.y << ", " << currentPos.z << ")" << std::endl;
            std::cout << "Collision normal: (" << collisionNormal.x << ", "
                      << collisionNormal.y << ", " << collisionNormal.z << ")" << std::endl;
            std::cout << "Velocity: (" << currentVel.x << ", " << currentVel.y << ", " << currentVel.z << ")" << std::endl;
        }

        // Print status at key intervals
        if (frame == startMoveFrame - 1) { // Just before movement
            std::cout << "Pre-movement state (Frame " << frame << "):" << std::endl;
            std::cout << "  Position: (" << currentPos.x << ", " << currentPos.y << ", " << currentPos.z << ")" << std::endl;
            std::cout << "  Distance to wall: " << (wallPos - currentPos).length() << " units" << std::endl;
        } else if (frame == startMoveFrame + 60) { // After initial movement
            std::cout << "During movement (Frame " << frame << "):" << std::endl;
            std::cout << "  Position: (" << currentPos.x << ", " << currentPos.y << ", " << currentPos.z << ")" << std::endl;
            std::cout << "  Velocity: (" << currentVel.x << ", " << currentVel.y << ", " << currentVel.z << ")" << std::endl;
            std::cout << "  Distance to wall: " << (wallPos - currentPos).length() << " units" << std::endl;
            std::cout << "  Has collision: " << (hasCollision ? "YES" : "NO") << std::endl;
        }

        // Print every 60 frames for general progress
        if (frame % 60 == 0 && frame > 0) {
            std::cout << "Frame " << frame << " - Position: ("
                      << currentPos.x << ", " << currentPos.y << ", " << currentPos.z
                      << ") Velocity: (" << currentVel.x << ", " << currentVel.y << ", " << currentVel.z << ") ";

            switch (state) {
                case CharacterState::GROUNDED: std::cout << "[GROUNDED]"; break;
                case CharacterState::JUMPING: std::cout << "[JUMPING]"; break;
                case CharacterState::FALLING: std::cout << "[FALLING]"; break;
            }

            if (hasCollision) {
                std::cout << " [COLLISION]";
            }

            std::cout << std::endl;
        }
    }

    // Analyze sliding behavior
    Vector3 finalPosition = character.getPosition();
    std::cout << "\n=== SLIDING ANALYSIS ===" << std::endl;

    if (collisionDetected) {
        std::cout << "✓ Collision detected at frame " << collisionFrame << std::endl;

        // Analyze movement before and after collision
        Vector3 preCollisionMovement = postCollisionPosition - preCollisionPosition;
        Vector3 postCollisionMovement = finalPosition - postCollisionPosition;

        std::cout << "Pre-collision movement: (" << preCollisionMovement.x << ", "
                  << preCollisionMovement.y << ", " << preCollisionMovement.z << ")" << std::endl;
        std::cout << "Post-collision movement: (" << postCollisionMovement.x << ", "
                  << postCollisionMovement.y << ", " << postCollisionMovement.z << ")" << std::endl;

        // Check for sliding behavior
        bool xMovementStopped = abs(postCollisionMovement.x) < 0.1f;
        bool zMovementContinues = abs(postCollisionMovement.z) > 0.5f;
        bool slidingBehavior = xMovementStopped && zMovementContinues;

        if (slidingBehavior) {
            std::cout << "✓ SLIDING BEHAVIOR CONFIRMED" << std::endl;
            std::cout << "  - X movement (toward wall) stopped: " << xMovementStopped << std::endl;
            std::cout << "  - Z movement (along wall) continued: " << zMovementContinues << std::endl;
        } else {
            std::cout << "✗ Sliding behavior not detected" << std::endl;
            std::cout << "  - X movement stopped: " << xMovementStopped << std::endl;
            std::cout << "  - Z movement continued: " << zMovementContinues << std::endl;
        }

        // Calculate final distance to wall
        float finalDistanceToWall = (wallPos - finalPosition).length();
        std::cout << "Final distance to wall: " << finalDistanceToWall << " units" << std::endl;

    } else {
        std::cout << "✗ No collision detected (character may have missed wall)" << std::endl;
    }

    // Test collision state tracking
    bool collisionStateConsistent = true;
    for (int i = 1; i < collisionStates.size(); ++i) {
        // Check if collision state changes persistently (not flickering)
        if (collisionStates[i] != collisionStates[i-1]) {
            // Count how many frames this state persists
            bool currentState = collisionStates[i];
            int persistCount = 1;
            for (int j = i + 1; j < collisionStates.size() && j < i + 10; ++j) {
                if (collisionStates[j] == currentState) {
                    persistCount++;
                } else {
                    break;
                }
            }
            if (persistCount < 3) {
                collisionStateConsistent = false;
                break;
            }
        }
    }

    if (collisionStateConsistent) {
        std::cout << "✓ Collision state tracking is consistent" << std::endl;
    } else {
        std::cout << "⚠ Warning: Collision state may be flickering" << std::endl;
    }

    // Cleanup
    character.destroyCharacter();
    physicsManager.removeComponent(wallId);
    physicsManager.removeComponent(groundId);
    physicsManager.shutdown();

    std::cout << "\n=== Character Sliding Test Complete ===" << std::endl;
    return 0;
}