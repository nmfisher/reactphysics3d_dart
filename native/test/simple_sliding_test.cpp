/*
 * Simple Character Sliding Test
 *
 * A more direct test of sliding behavior with a head-on approach to wall.
 */

#include "../reactphysics3d/include/CharacterController.hpp"
#include <iostream>

using namespace reactphysics3d;

int main() {
    std::cout << "=== Simple Sliding Test ===" << std::endl;

    // Create physics manager
    PhysicsComponentManager physicsManager;
    if (!physicsManager.initialize(Vector3(0, -9.81f, 0))) {
        std::cerr << "Failed to initialize physics manager!" << std::endl;
        return 1;
    }
    std::cout << "✓ Physics manager initialized" << std::endl;

    // Create ground
    PhysicsObjectConfig groundConfig;
    groundConfig.position = Vector3(0, -1, 0);
    groundConfig.bodyType = BodyType::STATIC;
    uint32_t groundId = physicsManager.createBox(groundConfig, Vector3(20, 2, 20));
    if (groundId == 0) {
        std::cerr << "Failed to create ground!" << std::endl;
        return 1;
    }
    std::cout << "✓ Ground created" << std::endl;

    // Create wall directly in character's path
    PhysicsObjectConfig wallConfig;
    wallConfig.position = Vector3(2, 1, 0);  // Wall at X=2
    wallConfig.bodyType = BodyType::STATIC;
    uint32_t wallId = physicsManager.createBox(wallConfig, Vector3(1, 3, 10));  // Wide wall
    if (wallId == 0) {
        std::cerr << "Failed to create wall!" << std::endl;
        return 1;
    }
    std::cout << "✓ Wall created at X=2" << std::endl;

    // Create character
    CharacterController character(physicsManager);
    CharacterConfig config;
    config.height = 1.8f;
    config.radius = 0.3f;
    config.maxSpeed = 3.0f;  // Slower speed for better control

    Vector3 startPosition(0, 1, 0);  // Start at origin, facing wall
    if (!character.createCharacter(config, startPosition)) {
        std::cerr << "Failed to create character!" << std::endl;
        return 1;
    }
    std::cout << "✓ Character created at (0, 1, 0)" << std::endl;

    const float timeStep = 1.0f / 60.0f;

    std::cout << "\n=== Testing Direct Movement ===" << std::endl;

    // Test 1: Direct movement toward wall (should be blocked)
    std::cout << "Test 1: Moving directly toward wall..." << std::endl;
    Vector3 initialPos = character.getPosition();

    for (int frame = 0; frame < 30; ++frame) {
        Vector3 moveDirection(1, 0, 0);  // Move directly toward wall
        character.move(moveDirection, timeStep);
        physicsManager.update(timeStep);
        character.update(timeStep);

        Vector3 currentPos = character.getPosition();
        std::cout << "Frame " << frame << ": Position (" << currentPos.x << ", "
                  << currentPos.y << ", " << currentPos.z << ") ";
        if (character.hasCollision()) {
            std::cout << "[COLLISION]";
        }
        std::cout << std::endl;

        if (character.hasCollision()) {
            std::cout << "✓ Collision detected at frame " << frame << std::endl;
            std::cout << "  Collision normal: (" << character.getCollisionNormal().x
                      << ", " << character.getCollisionNormal().y
                      << ", " << character.getCollisionNormal().z << ")" << std::endl;
            break;
        }
    }

    Vector3 afterDirectMove = character.getPosition();
    std::cout << "Position after direct movement: (" << afterDirectMove.x << ", "
              << afterDirectMove.y << ", " << afterDirectMove.z << ")" << std::endl;

    // Test 2: Diagonal movement (should slide)
    std::cout << "\nTest 2: Moving diagonally toward wall (should slide)..." << std::endl;

    for (int frame = 0; frame < 60; ++frame) {
        Vector3 moveDirection(0.7f, 0, 0.7f);  // Diagonal: toward wall + right
        moveDirection.normalize();
        character.move(moveDirection, timeStep);
        physicsManager.update(timeStep);
        character.update(timeStep);

        Vector3 currentPos = character.getPosition();

        if (frame % 15 == 0) {
            std::cout << "Frame " << frame << ": Position (" << currentPos.x << ", "
                      << currentPos.y << ", " << currentPos.z << ") ";
            if (character.hasCollision()) {
                std::cout << "[COLLISION]";
            }
            std::cout << std::endl;
        }
    }

    Vector3 finalPos = character.getPosition();
    std::cout << "Final position: (" << finalPos.x << ", " << finalPos.y << ", " << finalPos.z << ")" << std::endl;

    // Analyze results
    std::cout << "\n=== Analysis ===" << std::endl;

    float xMovement = finalPos.x - afterDirectMove.x;
    float zMovement = finalPos.z - afterDirectMove.z;

    std::cout << "X movement (toward wall): " << xMovement << std::endl;
    std::cout << "Z movement (along wall): " << zMovement << std::endl;

    if (abs(xMovement) < 0.1f && abs(zMovement) > 0.5f) {
        std::cout << "✓ SLIDING BEHAVIOR CONFIRMED" << std::endl;
        std::cout << "  - Movement toward wall blocked" << std::endl;
        std::cout << "  - Movement along wall continued" << std::endl;
    } else if (abs(xMovement) < 0.1f && abs(zMovement) < 0.1f) {
        std::cout << "✗ Movement completely blocked" << std::endl;
    } else {
        std::cout << "? Unclear behavior" << std::endl;
    }

    // Cleanup
    character.destroyCharacter();
    physicsManager.removeComponent(wallId);
    physicsManager.removeComponent(groundId);
    physicsManager.shutdown();

    std::cout << "\n=== Test Complete ===" << std::endl;
    return 0;
}