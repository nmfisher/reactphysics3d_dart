/// Base interface for all ReactPhysics3D types that expose a native handle
///
/// This interface provides a unified way to access the underlying native
/// handle for any ReactPhysics3D object, enabling consistent FFI operations
/// across all physics object types.
abstract class BaseRP3DType<T> {
  /// The native handle to the underlying ReactPhysics3D object
  ///
  /// The type T represents the specific native pointer type for each
  /// implementation (e.g., `Pointer<RP3D_PhysicsWorld>`, `Pointer<RP3D_RigidBody>`, etc.)
  T get handle;
}