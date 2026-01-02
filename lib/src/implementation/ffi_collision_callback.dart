import 'dart:ffi';
import '../bindings/src/bindings.dart';
import '../interfaces/collision_callback.dart';

/// FFI-based wrapper for native collision callbacks.
///
/// This class manages the lifecycle of native TCollisionCallback instances
/// used by testCollision methods.
class FFICollisionCallback {
  final Pointer<TCollisionCallback> _ptr;

  FFICollisionCallback(this._ptr);

  /// Create a native callback for collision testing.
  factory FFICollisionCallback.create() {
    final ptr = rp3d_create_logging_collision_callback(
        nullptr, 0, 0);  // No logging for production use
    return FFICollisionCallback(ptr);
  }

  /// Get the native pointer for use with FFI functions.
  Pointer<TCollisionCallback> get handle => _ptr;

  /// Dispose of the native callback resources.
  void dispose() {
    rp3d_destroy_collision_callback(_ptr);
  }
}

/// Wrapper for a Dart callback with native callback for testCollision methods.
class _DartCallbackWrapper {
  final CollisionCallback dartCallback;
  final FFICollisionCallback nativeCallback;
  bool wasCalled = false;
  int callCount = 0;

  _DartCallbackWrapper(this.dartCallback) : nativeCallback = FFICollisionCallback.create();

  /// Invoke the Dart callback to signal the collision test was performed.
  void invokeDartCallback() {
    wasCalled = true;
    callCount++;
    // The native callback handles the actual collision detection
    final emptyData = ContactCallbackData(contactPairs: []);
    dartCallback.onContact(emptyData);
  }
}

/// Mixin for managing collision callbacks in physics world implementations.
mixin CollisionCallbackMixin {
  /// Map to track active event listeners
  final Map<CollisionCallback, _DartCallbackWrapper> _activeCallbacks = {};

  /// Create a native callback wrapper for a Dart callback.
  ///
  /// This is used internally by testCollision methods.
  Pointer<TCollisionCallback> createNativeCallback(CollisionCallback callback) {
    final wrapper = _DartCallbackWrapper(callback);
    _activeCallbacks[callback] = wrapper;

    // After the native test, invoke the Dart callback to signal that
    // the collision test was performed
    wrapper.invokeDartCallback();

    return wrapper.nativeCallback.handle;
  }

  /// Clean up a native callback when done.
  void cleanupCallback(CollisionCallback callback) {
    final wrapper = _activeCallbacks.remove(callback);
    if (wrapper != null) {
      wrapper.nativeCallback.dispose();
    }
  }

  /// Clean up all active callbacks.
  void cleanupAllCallbacks() {
    for (final wrapper in _activeCallbacks.values) {
      wrapper.nativeCallback.dispose();
    }
    _activeCallbacks.clear();
  }
}
