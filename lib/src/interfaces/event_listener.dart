import '../bindings/src/bindings.dart';

/// Interface for event listeners that receive automatic collision callbacks during world.update().
///
/// Implementations must provide a native EventListener pointer to pass to ReactPhysics3D.
/// The primary implementation is [SendPortEventListener] for thread-safe callbacks.
abstract interface class EventListener {
  /// The native EventListener pointer for passing to rp3d_world_set_event_listener()
  Pointer<RP3D_EventListener> get pointer;
}
