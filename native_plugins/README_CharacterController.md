# Character Controller Jump System

This document explains how to use the CharacterController class for implementing character movement and jumping in your ReactPhysics3D-based games.

## Overview

The `CharacterController` is a high-level wrapper around ReactPhysics3D that provides:
- **Character Movement**: Smooth horizontal movement with configurable speed
- **Jump System**: Realistic jumping with gravity and ground detection
- **Collision Detection**: Automatic ground detection and slope limiting
- **State Management**: Tracks whether character is grounded, jumping, or falling

## Quick Start

```cpp
#include "CharacterController.hpp"

// Initialize physics system
PhysicsComponentManager physicsManager;
physicsManager.initialize(Vector3(0, -9.81f, 0));

// Create character controller
CharacterController character(physicsManager);

// Configure character
CharacterConfig config;
config.height = 1.8f;      // Character height
config.radius = 0.3f;      // Capsule radius
config.mass = 70.0f;       // Character mass
config.maxSpeed = 5.0f;    // Maximum movement speed
config.jumpForce = 8.0f;   // Jump strength

// Create character in the world
character.createCharacter(config, Vector3(0, 2, 0));
```

## Basic Usage

### Movement Control

```cpp
// Update loop (call every frame)
float deltaTime = 1.0f / 60.0f;

// Handle input
Vector3 moveDirection(0, 0, 0);
if (input.forward) moveDirection.z -= 1;
if (input.backward) moveDirection.z += 1;
if (input.left) moveDirection.x -= 1;
if (input.right) moveDirection.x += 1;

// Apply movement
character.move(moveDirection, deltaTime);

// Jump when button pressed
if (input.jumpButtonPressed) {
    character.jump();
}

// Update physics and character
physicsManager.update(deltaTime);
character.update(deltaTime);
```

### State Queries

```cpp
// Check character state
if (character.isGrounded()) {
    // Character is on the ground
    std::cout << "Ground slope: " << character.getGroundSlope() << "°" << std::endl;
}

if (character.isJumping()) {
    // Character is currently jumping upward
}

if (character.isFalling()) {
    // Character is falling down
}

// Get current position and velocity
Vector3 position = character.getPosition();
Vector3 velocity = character.getVelocity();
```

## Configuration Options

The `CharacterConfig` struct allows you to customize the character:

```cpp
struct CharacterConfig {
    float height;           // Total character height (default: 1.8f)
    float radius;           // Capsule radius (default: 0.3f)
    float mass;             // Character mass in kg (default: 70.0f)
    float maxSpeed;         // Max horizontal speed (default: 5.0f)
    float jumpForce;        // Jump upward force (default: 8.0f)
    float gravity;          // Gravity multiplier (default: 1.0f)
    float groundCheckDistance; // Distance to check for ground (default: 0.1f)
    float slopeLimit;       // Maximum walkable slope in degrees (default: 45.0f)
    float stepHeight;       // Maximum step height (default: 0.3f)
};
```

## Character States

The controller maintains three character states:

- **GROUNDED**: Character is on the ground and can jump
- **JUMPING**: Character is moving upward after jumping
- **FALLING**: Character is falling down (either after jump apex or from walking off edge)

## Implementation Details

### Collision Shape

The character uses a **capsule shape** which is ideal for human characters:
- Smooth edges prevent getting caught on obstacles
- Realistic collision response
- Good balance between performance and accuracy

### Ground Detection

Ground detection uses **raycasting**:
- Casts ray downward from character center
- Detects ground contact and calculates surface normal
- Determines if slope is walkable (within slope limit)
- Prevents jumping when not grounded

### Movement System

Movement is handled through:
- **Velocity-based control** for smooth, responsive movement
- **Acceleration system** for gradual speed changes
- **Gravity application** when not grounded
- **Impulse application** for jumping

### Physics Integration

The character controller integrates with ReactPhysics3D through:
- **Dynamic body** for proper physics simulation
- **Force/impulse application** for movement and jumping
- **Collision detection** through the physics engine
- **Spatial queries** for ground detection

## Advanced Usage

### Custom Ground Detection

```cpp
// You can manually check ground conditions
Vector3 characterPos = character.getPosition();
Vector3 rayStart = characterPos + Vector3(0, 1, 0);
Vector3 rayEnd = characterPos - Vector3(0, 2, 0);

RaycastInfo hitInfo;
if (physicsManager.raycast(rayStart, rayEnd, hitInfo)) {
    // Ground detected
    float distance = hitInfo.hitFraction;
    Vector3 normal = hitInfo.worldNormal;
}
```

### Direct Velocity Control

```cpp
// Set velocity directly (bypasses smooth movement)
character.setVelocity(Vector3(5.0f, 0.0f, 3.0f));

// Get current velocity
Vector3 velocity = character.getVelocity();
```

### Runtime Configuration Changes

```cpp
// Change character properties at runtime
CharacterConfig newConfig = character.getConfig();
newConfig.maxSpeed = 8.0f;  // Increase speed
newConfig.jumpForce = 10.0f; // Higher jumps
character.setConfig(newConfig);

// Change mass
character.setMass(80.0f);
```

## Example Integration

See `character_jump_test.cpp` for a complete example showing:
- Character creation and configuration
- Movement control with simulated input
- Jump mechanics
- Ground detection and state management
- Platform navigation

## Performance Considerations

- The controller performs one raycast per frame for ground detection
- Character movement is handled through velocity, not forces (more responsive)
- Collision detection is handled by ReactPhysics3D's efficient systems
- Memory usage is minimal (single physics component per character)

## Limitations

- Currently supports single character per controller instance
- No animation integration (you'll need to handle that separately)
- No stair climbing automation (characters need to jump up steps)
- No sliding or friction system beyond basic physics

## Future Enhancements

Potential improvements you could add:
- **Stair climbing**: Automatic step-up for small obstacles
- **Ledge grabbing**: Detect and hang onto edges
- **Wall jumping**: Jump off walls when appropriate
- **Swimming**: Different physics behavior in water
- **Crouching**: Dynamic height changes
- **Sprinting**: Speed multiplier for running