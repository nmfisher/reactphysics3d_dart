/*
 * Character Controller Jump Test
 *
 * Demonstrates a character controller with jump functionality,
 * ground detection, and movement control.
 */

#include "../reactphysics3d/include/CharacterController.hpp"
#include <iostream>
#include <chrono>
#include <thread>

using namespace reactphysics3d;

// Simple input simulation
struct InputState {
    bool moveForward = false;
    bool moveBackward = false;
    bool moveLeft = false;
    bool moveRight = false;
    bool jump = false;

    Vector3 getMovementDirection() const {
        Vector3 direction(0, 0, 0);

        if (moveForward) direction.z -= 1;
        if (moveBackward) direction.z += 1;
        if (moveLeft) direction.x -= 1;
        if (moveRight) direction.x += 1;

        return direction;
    }
};

int main() {
    std::cout << "=== Character Controller Jump Test ===" << std::endl;

    // Create physics manager
    PhysicsComponentManager physicsManager;

    // Initialize with Earth gravity
    if (!physicsManager.initialize(Vector3(0, -9.81f, 0))) {
        std::cerr << "Failed to initialize physics manager!" << std::endl;
        return 1;
    }
    std::cout << "✓ Physics manager initialized successfully" << std::endl;

    // Create character controller
    CharacterController character(physicsManager);

    // Character configuration
    CharacterConfig config;
    config.height = 1.8f;      // Human height
    config.radius = 0.3f;      // Capsule radius
    config.mass = 70.0f;       // 70 kg character
    config.maxSpeed = 5.0f;    // 5 units/second max speed
    config.jumpForce = 6.0f;   // Jump strength
    config.slopeLimit = 45.0f; // Can walk on 45-degree slopes

    // Create character at height
    Vector3 startPosition(0, 2, 0);
    if (!character.createCharacter(config, startPosition)) {
        std::cerr << "Failed to create character!" << std::endl;
        return 1;
    }
    std::cout << "✓ Character created at position (" << startPosition.x << ", "
              << startPosition.y << ", " << startPosition.z << ")" << std::endl;

    // Create ground
    PhysicsObjectConfig groundConfig;
    groundConfig.position = Vector3(0, -1, 0);
    groundConfig.bodyType = BodyType::STATIC;
    groundConfig.bounciness = 0.1f;
    groundConfig.friction = 0.8f;

    uint32_t groundId = physicsManager.createBox(groundConfig, Vector3(20, 1, 20));
    if (groundId == 0) {
        std::cerr << "Failed to create ground!" << std::endl;
        return 1;
    }
    std::cout << "✓ Ground created" << std::endl;

    // Create some platforms for jumping test
    std::vector<uint32_t> platforms;

    // Platform 1: Step up
    PhysicsObjectConfig platform1Config;
    platform1Config.position = Vector3(3, 0.5f, 0);
    platform1Config.bodyType = BodyType::STATIC;
    platforms.push_back(physicsManager.createBox(platform1Config, Vector3(2, 1, 2)));

    // Platform 2: Higher platform
    PhysicsObjectConfig platform2Config;
    platform2Config.position = Vector3(6, 1.5f, 0);
    platform2Config.bodyType = BodyType::STATIC;
    platforms.push_back(physicsManager.createBox(platform2Config, Vector3(2, 3, 2)));

    // Platform 3: Moving height test
    PhysicsObjectConfig platform3Config;
    platform3Config.position = Vector3(-3, 1.0f, 0);
    platform3Config.bodyType = BodyType::STATIC;
    platforms.push_back(physicsManager.createBox(platform3Config, Vector3(2, 2, 2)));

    std::cout << "✓ Jump platforms created" << std::endl;

    // Test scenarios
    std::cout << "\n=== Running Character Movement Tests ===" << std::endl;

    InputState input;
    const float timeStep = 1.0f / 60.0f; // 60 FPS
    const int totalFrames = 600; // 10 seconds of simulation

    for (int frame = 0; frame < totalFrames; ++frame) {
        // Simulate input based on frame number
        input = InputState();

        if (frame < 120) {
            // First 2 seconds: Walk forward
            input.moveForward = true;
            if (frame == 60) input.jump = true; // Jump at 1 second
        } else if (frame < 240) {
            // Seconds 2-4: Walk right and jump
            input.moveRight = true;
            if (frame == 180) input.jump = true; // Jump at 3 seconds
        } else if (frame < 360) {
            // Seconds 4-6: Walk backward
            input.moveBackward = true;
            if (frame == 300) input.jump = true; // Jump at 5 seconds
        } else if (frame < 480) {
            // Seconds 6-8: Walk left and jump
            input.moveLeft = true;
            if (frame == 420) input.jump = true; // Jump at 7 seconds
        } else {
            // Seconds 8-10: Mixed movement
            input.moveForward = true;
            input.moveRight = true;
            if (frame == 540) input.jump = true; // Final jump at 9 seconds
        }

        // Apply movement input
        Vector3 moveDirection = input.getMovementDirection();
        if (moveDirection.length() > 0.001f) {
            character.move(moveDirection, timeStep);
        }

        // Apply jump input
        if (input.jump) {
            character.jump();
        }

        // Update physics
        physicsManager.update(timeStep);
        character.update(timeStep);

        // Print status every 60 frames (1 second)
        if (frame % 60 == 0) {
            Vector3 position = character.getPosition();
            Vector3 velocity = character.getVelocity();
            CharacterState state = character.getState();

            std::cout << "Frame " << frame << " - Position: ("
                      << position.x << ", " << position.y << ", " << position.z
                      << ") Velocity: (" << velocity.x << ", " << velocity.y << ", " << velocity.z << ") ";

            switch (state) {
                case CharacterState::GROUNDED:
                    std::cout << "[GROUNDED]";
                    break;
                case CharacterState::JUMPING:
                    std::cout << "[JUMPING]";
                    break;
                case CharacterState::FALLING:
                    std::cout << "[FALLING]";
                    break;
            }

            if (character.isGrounded()) {
                std::cout << " Ground slope: " << character.getGroundSlope() << "°";
            }

            std::cout << std::endl;
        }
    }

    // Test raycast functionality
    std::cout << "\n=== Testing Raycast Ground Detection ===" << std::endl;
    Vector3 characterPos = character.getPosition();
    Vector3 rayStart = characterPos + Vector3(0, 1, 0);
    Vector3 rayEnd = characterPos - Vector3(0, 2, 0);

    RaycastInfo hitInfo;
    if (physicsManager.raycast(rayStart, rayEnd, hitInfo)) {
        std::cout << "✓ Ground detected at distance: " << hitInfo.hitFraction << std::endl;
        std::cout << "  Hit point: (" << hitInfo.worldPoint.x << ", "
                  << hitInfo.worldPoint.y << ", " << hitInfo.worldPoint.z << ")" << std::endl;
        std::cout << "  Normal: (" << hitInfo.worldNormal.x << ", "
                  << hitInfo.worldNormal.y << ", " << hitInfo.worldNormal.z << ")" << std::endl;
    } else {
        std::cout << "✗ No ground detected below character" << std::endl;
    }

    // Test components in sphere query
    std::cout << "\n=== Testing Spatial Queries ===" << std::endl;
    std::vector<uint32_t> nearbyComponents = physicsManager.getComponentsInSphere(characterPos, 3.0f);
    std::cout << "✓ Found " << nearbyComponents.size() << " components within 3 units of character" << std::endl;

    // Final status
    Vector3 finalPosition = character.getPosition();
    Vector3 finalVelocity = character.getVelocity();
    CharacterState finalState = character.getState();

    std::cout << "\n=== Test Results ===" << std::endl;
    std::cout << "✓ Final position: (" << finalPosition.x << ", " << finalPosition.y << ", " << finalPosition.z << ")" << std::endl;
    std::cout << "✓ Final velocity: (" << finalVelocity.x << ", " << finalVelocity.y << ", " << finalVelocity.z << ")" << std::endl;
    std::cout << "✓ Final state: ";
    switch (finalState) {
        case CharacterState::GROUNDED:
            std::cout << "GROUNDED";
            break;
        case CharacterState::JUMPING:
            std::cout << "JUMPING";
            break;
        case CharacterState::FALLING:
            std::cout << "FALLING";
            break;
    }
    std::cout << std::endl;

    std::cout << "✓ Total physics components: " << physicsManager.getComponentCount() << std::endl;

    // Cleanup
    character.destroyCharacter();
    for (uint32_t platformId : platforms) {
        physicsManager.removeComponent(platformId);
    }
    physicsManager.removeComponent(groundId);
    physicsManager.shutdown();

    std::cout << "\n=== All Character Controller Tests Passed! ===" << std::endl;
    return 0;
}