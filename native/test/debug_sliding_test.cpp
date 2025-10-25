/*
 * Debug Sliding Test
 *
 * Test with detailed debugging to understand collision detection behavior.
 */

#include "../reactphysics3d/include/CharacterController.hpp"
#include <iostream>

using namespace reactphysics3d;

int main() {
    std::cout << "=== Debug Sliding Test ===" << std::endl;

    // Create physics manager
    PhysicsComponentManager physicsManager;
    if (!physicsManager.initialize(Vector3(0, 0, 0))) {  // No gravity for simpler test
        std::cerr << "Failed to initialize physics manager!" << std::endl;
        return 1;
    }
    std::cout << "✓ Physics manager initialized (no gravity)" << std::endl;

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

    // Create wall directly in front of character
    PhysicsObjectConfig wallConfig;
    wallConfig.position = Vector3(1.5, 1, 0);  // Closer wall at X=1.5
    wallConfig.bodyType = BodyType::STATIC;
    uint32_t wallId = physicsManager.createBox(wallConfig, Vector3(0.5, 3, 10));  // Thinner wall
    if (wallId == 0) {
        std::cerr << "Failed to create wall!" << std::endl;
        return 1;
    }
    std::cout << "✓ Wall created at X=1.5" << std::endl;

    // Create character
    CharacterController character(physicsManager);
    CharacterConfig config;
    config.height = 1.8f;
    config.radius = 0.3f;
    config.maxSpeed = 2.0f;

    Vector3 startPosition(0, 1, 0);  // Start at origin
    if (!character.createCharacter(config, startPosition)) {
        std::cerr << "Failed to create character!" << std::endl;
        return 1;
    }
    std::cout << "✓ Character created at (0, 1, 0)" << std::endl;

    const float timeStep = 1.0f / 60.0f;

    std::cout << "\n=== Testing Raycast Collision Detection ===" << std::endl;

    // Test direct raycast to understand collision detection
    Vector3 currentPos = character.getPosition();
    Vector3 targetPos = Vector3(2.0, 1.0, 0.0);  // Point beyond wall

    std::cout << "Testing raycast from (" << currentPos.x << ", " << currentPos.y << ", " << currentPos.z
              << ") to (" << targetPos.x << ", " << targetPos.y << ", " << targetPos.z << ")" << std::endl;

    RaycastInfo hitInfo;
    bool hasHit = physicsManager.raycast(currentPos, targetPos, hitInfo);

    if (hasHit) {
        std::cout << "✓ Raycast hit detected!" << std::endl;
        std::cout << "  Hit point: (" << hitInfo.worldPoint.x << ", " << hitInfo.worldPoint.y
                  << ", " << hitInfo.worldPoint.z << ")" << std::endl;
        std::cout << "  Normal: (" << hitInfo.worldNormal.x << ", " << hitInfo.worldNormal.y
                  << ", " << hitInfo.worldNormal.z << ")" << std::endl;
        std::cout << "  Distance: " << (hitInfo.worldPoint - currentPos).length() << std::endl;
    } else {
        std::cout << "✗ No raycast hit detected" << std::endl;
    }

    std::cout << "\n=== Testing Character Movement ===" << std::endl;

    // Test character movement with collision detection
    for (int frame = 0; frame < 120; ++frame) {
        Vector3 currentPos = character.getPosition();
        Vector3 desiredMovement = Vector3(0.05f, 0, 0);  // Small steps toward wall
        Vector3 desiredPos = currentPos + desiredMovement;

        // Test collision detection for this movement
        RaycastInfo moveHitInfo;
        bool hasMoveHit = physicsManager.raycast(currentPos, desiredPos, moveHitInfo);

        std::cout << "Frame " << frame << ": Current pos (" << currentPos.x << ", "
                  << currentPos.y << ", " << currentPos.z << ") ";

        if (hasMoveHit) {
            std::cout << "[RAYCAST HIT] ";
            std::cout << "Hit at (" << moveHitInfo.worldPoint.x << ", ";
            std::cout << moveHitInfo.worldPoint.y << ", " << moveHitInfo.worldPoint.z << ") ";
            std::cout << "Normal (" << moveHitInfo.worldNormal.x << ", ";
            std::cout << moveHitInfo.worldNormal.y << ", " << moveHitInfo.worldNormal.z << ") ";
        } else {
            std::cout << "[NO HIT] ";
        }

        // Try movement
        Vector3 moveDirection(1, 0, 0);  // Move toward wall
        character.move(moveDirection, timeStep);
        physicsManager.update(timeStep);
        character.update(timeStep);

        Vector3 newPos = character.getPosition();
        std::cout << "New pos (" << newPos.x << ", " << newPos.y << ", " << newPos.z << ")";

        if (character.hasCollision()) {
            std::cout << " [CHAR COLLISION]";
            std::cout << " Normal (" << character.getCollisionNormal().x << ", ";
            std::cout << character.getCollisionNormal().y << ", ";
            std::cout << character.getCollisionNormal().z << ")";
        }

        std::cout << std::endl;

        // Stop if we've moved enough or hit the wall
        if (newPos.x >= 1.2f) {
            std::cout << "Stopping test - close to wall position" << std::endl;
            break;
        }
    }

    // Cleanup
    character.destroyCharacter();
    physicsManager.removeComponent(wallId);
    physicsManager.removeComponent(groundId);
    physicsManager.shutdown();

    std::cout << "\n=== Debug Test Complete ===" << std::endl;
    return 0;
}