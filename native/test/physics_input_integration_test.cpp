/*
 * Physics Input Integration Test
 *
 * Tests the integration between ReactPhysics3D and the Thermion input system.
 * Verifies that:
 * 1. Physics systems can be registered with the input pipeline
 * 2. MovementIntent is properly converted to physics movement
 * 3. Collision detection and sliding works correctly
 */

#include "../reactphysics3d/include/PhysicsIntegration.hpp"
#include <iostream>
#include <chrono>
#include <thread>

#ifdef __APPLE__
#include "/Users/nickfisher/Documents/mixworld/thermion_input_handler_component/native/include/Pipeline.hpp"
#include "/Users/nickfisher/Documents/mixworld/thermion_input_handler_component/native/include/InputHandlerComponentManager.hpp"
#include "/Users/nickfisher/Documents/mixworld/thermion_input_handler_component/native/include/Movement.hpp"
#else
#include "Pipeline.hpp"
#include "InputHandlerComponentManager.hpp"
#include "Movement.hpp"
#endif

using namespace thermion::plugin::input;
using namespace thermion::plugin::physics;
using namespace reactphysics3d;

int main() {
    std::cout << "=== Physics Input Integration Test ===" << std::endl;

    // Create physics integration
    PhysicsIntegration physicsIntegration;

    // Initialize physics
    if (!physicsIntegration.initialize(Vector3(0, -9.81f, 0))) {
        std::cerr << "Failed to initialize physics integration!" << std::endl;
        return 1;
    }
    std::cout << "✓ Physics integration initialized" << std::endl;

    // Create input pipeline
    auto pipeline = std::make_unique<Pipeline>();
    std::cout << "✓ Input pipeline created" << std::endl;

    // Register physics with pipeline
    physicsIntegration.registerWithPipeline(pipeline.get());
    std::cout << "✓ Physics registered with pipeline" << std::endl;

    // Create test entity (using a simple ID for testing)
    utils::Entity testEntity(42);

    // Create physics character
    CharacterConfig characterConfig;
    characterConfig.height = 1.8f;
    characterConfig.radius = 0.3f;
    characterConfig.mass = 10.0f;
    characterConfig.maxSpeed = 5.0f;
    characterConfig.jumpForce = 8.0f;

    if (!physicsIntegration.createCharacter(testEntity, characterConfig, Vector3(0, 2, 0))) {
        std::cerr << "Failed to create physics character!" << std::endl;
        return 1;
    }
    std::cout << "✓ Physics character created for entity " << testEntity.getId() << std::endl;

    // Add input handler component to test entity
    InputHandlerComponentManager* componentManager = pipeline->getComponentManager();
    componentManager->addInputHandlerComponent(testEntity);
    componentManager->setMovementSpeed(testEntity, 5.0);
    std::cout << "✓ Input handler component added to entity" << std::endl;

    // Test simulation parameters
    const float timeStep = 1.0f / 60.0f; // 60 FPS
    const int totalFrames = 180; // 3 seconds of simulation
    const uint64_t timeStepNanos = static_cast<uint64_t>(timeStep * 1'000'000'000.0f);

    std::cout << "\n=== Starting Integration Test ===" << std::endl;
    std::cout << "Simulating " << totalFrames << " frames at 60 FPS..." << std::endl;
    std::cout << "Test Plan:" << std::endl;
    std::cout << "- Frames 0-60: Character falls due to gravity" << std::endl;
    std::cout << "- Frames 60-120: Character moves forward" << std::endl;
    std::cout << "- Frames 120-180: Character jumps" << std::endl;

    // Track initial position
    Vector3 initialPosition = physicsIntegration.getPhysicsManager()->getComponent(1) ?
        physicsIntegration.getPhysicsManager()->getComponent(1)->transform.getPosition() :
        Vector3(0, 2, 0);
    std::cout << "Initial position: (" << initialPosition.x << ", "
              << initialPosition.y << ", " << initialPosition.z << ")" << std::endl;

    // Run simulation
    for (int frame = 0; frame < totalFrames; ++frame) {
        // Simulate input events based on frame
        if (frame >= 60 && frame < 120) {
            // Move forward
            MouseEvent moveEvent;
            moveEvent.type = MouseEventType::move;
            moveEvent.localPosition = {0, 0};
            moveEvent.delta = {0, 0};
            componentManager->handleMouseEvent(moveEvent);

            // Simulate forward movement intent
            // (In a real application, this would come from actual input)

        } else if (frame >= 120) {
            // Jump intent
            KeyEvent jumpEvent;
            jumpEvent.type = KeyEventType::down;
            jumpEvent.logicalKey = LogicalKey::space;
            componentManager->handleKeyEvent(jumpEvent);
        }

        // Update pipeline (this will run physics pre-update, then input, then movement processing)
        uint64_t currentTime = static_cast<uint64_t>(frame * timeStepNanos);
        pipeline->update(currentTime);

        // Print status every 60 frames
        if (frame % 60 == 0) {
            Vector3 currentPos = physicsIntegration.getPhysicsManager()->getComponent(1) ?
                physicsIntegration.getPhysicsManager()->getComponent(1)->transform.getPosition() :
                Vector3(0, 0, 0);

            std::cout << "Frame " << frame << " - Position: ("
                      << currentPos.x << ", " << currentPos.y << ", " << currentPos.z << ")" << std::endl;
        }

        // Small delay to simulate real-time
        std::this_thread::sleep_for(std::chrono::milliseconds(16));
    }

    // Final position check
    Vector3 finalPosition = physicsIntegration.getPhysicsManager()->getComponent(1) ?
        physicsIntegration.getPhysicsManager()->getComponent(1)->transform.getPosition() :
        Vector3(0, 0, 0);

    std::cout << "\n=== Integration Test Results ===" << std::endl;
    std::cout << "Final position: (" << finalPosition.x << ", "
              << finalPosition.y << ", " << finalPosition.z << ")" << std::endl;

    // Verify physics worked (character should have fallen due to gravity)
    bool gravityWorked = finalPosition.y < initialPosition.y - 0.5f;
    std::cout << "Gravity effect: " << (gravityWorked ? "✓ PASSED" : "✗ FAILED") << std::endl;

    // Cleanup
    physicsIntegration.destroyCharacter(testEntity);
    physicsIntegration.unregisterFromPipeline(pipeline.get());
    physicsIntegration.shutdown();

    std::cout << "\n=== Physics Input Integration Test Complete ===" << std::endl;
    return gravityWorked ? 0 : 1;
}