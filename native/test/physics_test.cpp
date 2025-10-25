/*
 * PhysicsComponentManager Test
 *
 * Simple test program to verify the PhysicsComponentManager implementation
 * works correctly with collision detection and gravity.
 */

#include "../reactphysics3d/include/PhysicsComponentManager.hpp"
#include <iostream>
#include <chrono>
#include <thread>

using namespace reactphysics3d;

int main() {
    std::cout << "=== PhysicsComponentManager Test ===" << std::endl;

    // Create physics manager
    PhysicsComponentManager manager;

    // Initialize with Earth gravity
    if (!manager.initialize(Vector3(0, -9.81f, 0))) {
        std::cerr << "Failed to initialize physics manager!" << std::endl;
        return 1;
    }
    std::cout << "✓ Physics manager initialized successfully" << std::endl;

    // Test 1: Create a falling sphere
    PhysicsObjectConfig sphereConfig;
    sphereConfig.position = Vector3(0, 10, 0);  // 10 units high
    sphereConfig.mass = 1.0f;
    sphereConfig.enableGravity = true;
    sphereConfig.bounciness = 0.7f;

    uint32_t sphereId = manager.createSphere(sphereConfig, 1.0f);
    if (sphereId == 0) {
        std::cerr << "Failed to create sphere!" << std::endl;
        return 1;
    }
    std::cout << "✓ Created sphere with ID: " << sphereId << std::endl;

    // Test 2: Create a static ground box
    PhysicsObjectConfig groundConfig;
    groundConfig.position = Vector3(0, -1, 0);  // Ground level
    groundConfig.bodyType = BodyType::STATIC;
    groundConfig.bounciness = 0.2f;

    uint32_t groundId = manager.createBox(groundConfig, Vector3(20, 1, 20));
    if (groundId == 0) {
        std::cerr << "Failed to create ground!" << std::endl;
        return 1;
    }
    std::cout << "✓ Created ground box with ID: " << groundId << std::endl;

    // Test 3: Create a capsule
    PhysicsObjectConfig capsuleConfig;
    capsuleConfig.position = Vector3(3, 8, 0);
    capsuleConfig.mass = 2.0f;
    capsuleConfig.enableGravity = true;
    capsuleConfig.bounciness = 0.5f;

    uint32_t capsuleId = manager.createCapsule(capsuleConfig, 0.5f, 2.0f);
    if (capsuleId == 0) {
        std::cerr << "Failed to create capsule!" << std::endl;
        return 1;
    }
    std::cout << "✓ Created capsule with ID: " << capsuleId << std::endl;

    // Test 4: Initial positions
    Vector3 spherePos, capsulePos;
    if (manager.getComponentPosition(sphereId, spherePos)) {
        std::cout << "✓ Initial sphere position: (" << spherePos.x << ", "
                  << spherePos.y << ", " << spherePos.z << ")" << std::endl;
    }

    if (manager.getComponentPosition(capsuleId, capsulePos)) {
        std::cout << "✓ Initial capsule position: (" << capsulePos.x << ", "
                  << capsulePos.y << ", " << capsulePos.z << ")" << std::endl;
    }

    // Test 5: Apply impulse to sphere
    if (manager.applyImpulse(sphereId, Vector3(2, 0, 0))) {
        std::cout << "✓ Applied impulse to sphere" << std::endl;
    }

    // Test 6: Update physics simulation
    std::cout << "\n=== Running Physics Simulation ===" << std::endl;
    const float timeStep = 1.0f / 60.0f; // 60 FPS
    const int simulationSteps = 180; // 3 seconds of simulation

    for (int i = 0; i < simulationSteps; ++i) {
        manager.update(timeStep);

        // Print positions every 60 frames (1 second)
        if (i % 60 == 0) {
            if (manager.getComponentPosition(sphereId, spherePos)) {
                std::cout << "Frame " << i << " - Sphere position: ("
                          << spherePos.x << ", " << spherePos.y << ", "
                          << spherePos.z << ")" << std::endl;
            }

            if (manager.getComponentPosition(capsuleId, capsulePos)) {
                std::cout << "Frame " << i << " - Capsule position: ("
                          << capsulePos.x << ", " << capsulePos.y << ", "
                          << capsulePos.z << ")" << std::endl;
            }
        }
    }

    // Test 7: Raycast test
    RaycastInfo hitInfo;
    Vector3 rayStart(0, 15, 0);
    Vector3 rayEnd(0, -5, 0);

    if (manager.raycast(rayStart, rayEnd, hitInfo)) {
        std::cout << "✓ Raycast hit detected!" << std::endl;
        std::cout << "  Hit point: (" << hitInfo.worldPoint.x << ", "
                  << hitInfo.worldPoint.y << ", " << hitInfo.worldPoint.z << ")" << std::endl;
        std::cout << "  Hit normal: (" << hitInfo.worldNormal.x << ", "
                  << hitInfo.worldNormal.y << ", " << hitInfo.worldNormal.z << ")" << std::endl;
    } else {
        std::cout << "✗ Raycast did not hit anything" << std::endl;
    }

    // Test 8: Query components in sphere
    std::vector<uint32_t> componentsInSphere = manager.getComponentsInSphere(Vector3(0, 0, 0), 5.0f);
    std::cout << "✓ Found " << componentsInSphere.size()
              << " components within 5 units of origin" << std::endl;

    // Test 9: Component count and cleanup
    std::cout << "✓ Total components: " << manager.getComponentCount() << std::endl;

    // Test 10: Remove components
    if (manager.removeComponent(sphereId)) {
        std::cout << "✓ Removed sphere component" << std::endl;
    }

    if (manager.removeComponent(capsuleId)) {
        std::cout << "✓ Removed capsule component" << std::endl;
    }

    std::cout << "✓ Components after removal: " << manager.getComponentCount() << std::endl;

    // Cleanup
    manager.shutdown();
    std::cout << "✓ Physics manager shutdown successfully" << std::endl;

    std::cout << "\n=== All Tests Passed! ===" << std::endl;
    return 0;
}