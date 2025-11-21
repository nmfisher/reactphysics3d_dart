
import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart' as ffi;
import '../bindings/src/bindings.dart';

/// Interface for physics simulation world
abstract class PhysicsWorld
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_PhysicsWorld>> {
  /// Update the physics simulation
  void update(double timeStep);

  /// Set gravity vector
  void setGravity(Vector3 gravity);

  /// Get gravity vector
  Vector3 getGravity();

  /// Create a rigid body
  RigidBody createRigidBody({Transform? transform});

  /// Destroy a rigid body
  void destroyRigidBody(RigidBody body);

  /// Enable/disable gravity for this world
  void setIsGravityEnabled(bool isEnabled);

  /// Enable/disable the sleeping technique for inactive bodies
  void enableSleeping(bool isSleepingEnabled);

  /// Set the sleep linear velocity threshold
  void setSleepLinearVelocity(double sleepLinearVelocity);

  /// Set the sleep angular velocity threshold
  void setSleepAngularVelocity(double sleepAngularVelocity);

  /// Set the time a body must stay still before sleeping
  void setTimeBeforeSleep(double timeBeforeSleep);

  /// Get the number of rigid bodies in the physics world
  int getNbRigidBodies();

  /// Get a rigid body by index from the physics world
  RigidBody getRigidBody(int index);

  /// Enable/disable debug rendering
  void setIsDebugRenderingEnabled(bool isEnabled);

  /// Get whether debug rendering is enabled
  bool getIsDebugRenderingEnabled();

  /// Get the debug renderer
  DebugRenderer getDebugRenderer();

  /// Raycast from point1 to point2 and return hit information if hit
  /// Returns null if no hit
  RaycastInfo? raycast(Ray ray);
}
