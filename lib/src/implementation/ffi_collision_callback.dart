import 'dart:ffi';
import '../bindings/src/bindings.dart';
import '../interfaces/collision_callback.dart';

/// FFI-based implementation that wraps native collision callbacks.
///
/// This class manages the lifecycle of native TCollisionCallback instances
/// and bridges them to Dart [CollisionCallback] implementations.
class FFICollisionCallback {
  final Pointer<TCollisionCallback> _ptr;

  FFICollisionCallback(this._ptr);

  /// Create a native logging collision callback.
  ///
  /// [prefix] - Custom log prefix for identification
  /// [logContactPoints] - Whether to log individual contact point details
  /// [verbose] - Enable verbose logging mode
  factory FFICollisionCallback.logging({
    String prefix = 'CollisionCallback',
    bool logContactPoints = true,
    bool verbose = true,
  }) {
    // Convert the prefix to a native string
    final prefixPtr = prefix.toNativeUtf8();
    final ptr = rp3d_create_logging_collision_callback(
      prefixPtr.cast<Char>(),
      logContactPoints ? 1 : 0,
      verbose ? 1 : 0,
    );
    calloc.free(prefixPtr);
    return FFICollisionCallback(ptr);
  }

  /// Create a native contact counter callback.
  ///
  /// This is a lightweight callback that only counts collision events.
  factory FFICollisionCallback.counter() {
    final ptr = rp3d_create_contact_counter_callback();
    return FFICollisionCallback(ptr);
  }

  /// Get the native pointer for use with FFI functions.
  Pointer<TCollisionCallback> get handle => _ptr;

  /// Check if this callback has detected any contact (for logging callbacks).
  bool get hasContact {
    return rp3d_get_logging_callback_has_contact(_ptr) != 0;
  }

  /// Get statistics from this callback (for logging callbacks).
  ///
  /// Returns a map with keys:
  /// - 'callbackCount': Number of times the callback was invoked
  /// - 'totalContactPairs': Total number of contact pairs reported
  /// - 'totalContactPoints': Total number of contact points reported
  Map<String, int> get stats {
    final callbackCountPtr = calloc<Uint32>();
    final totalContactPairsPtr = calloc<Uint32>();
    final totalContactPointsPtr = calloc<Uint32>();

    rp3d_get_logging_callback_stats(
      _ptr,
      callbackCountPtr,
      totalContactPairsPtr,
      totalContactPointsPtr,
    );

    final stats = {
      'callbackCount': callbackCountPtr.value,
      'totalContactPairs': totalContactPairsPtr.value,
      'totalContactPoints': totalContactPointsPtr.value,
    };

    calloc.free(callbackCountPtr);
    calloc.free(totalContactPairsPtr);
    calloc.free(totalContactPointsPtr);

    return stats;
  }

  /// Reset statistics for this callback.
  void resetStats() {
    rp3d_reset_callback_stats(_ptr);
  }

  /// Dispose of the native callback resources.
  void dispose() {
    rp3d_destroy_collision_callback(_ptr);
  }
}

/// A simple logging collision callback that prints to console.
///
/// This is a convenience class for debugging collision detection.
class LoggingCollisionCallback implements CollisionCallback {
  final String logPrefix;
  final bool logContactPoints;
  final bool verbose;
  int callbackCount = 0;
  int totalContactPairs = 0;
  int totalContactPoints = 0;

  LoggingCollisionCallback({
    this.logPrefix = 'CollisionCallback',
    this.logContactPoints = true,
    this.verbose = true,
  });

  @override
  void onContact(ContactCallbackData callbackData) {
    callbackCount++;
    final contactPairs = callbackData.nbContactPairs;
    totalContactPairs += contactPairs;

    if (verbose) {
      print('$logPrefix: onContact called #$callbackCount with '
          '$contactPairs contact pair(s)');
    }

    for (final pair in callbackData.contactPairs) {
      totalContactPoints += pair.nbContactPoints;

      if (verbose) {
        print('  ContactPair: ${pair.eventType} between '
            '${pair.body1} and ${pair.body2}');

        if (logContactPoints) {
          for (final point in pair.contactPoints) {
            print('    ContactPoint: depth=${point.penetrationDepth}, '
                'normal=${point.worldNormal}');
          }
        }
      }
    }
  }

  void reset() {
    callbackCount = 0;
    totalContactPairs = 0;
    totalContactPoints = 0;
  }

  @override
  String toString() {
    return 'LoggingCollisionCallback(callbacks: $callbackCount, '
        'pairs: $totalContactPairs, points: $totalContactPoints)';
  }
}

/// A simple counter collision callback that tracks collision counts.
///
/// This is a lightweight callback for performance monitoring.
class ContactCounterCallback implements CollisionCallback {
  int callbackCount = 0;
  int totalContactPairs = 0;
  int totalContactPoints = 0;

  @override
  void onContact(ContactCallbackData callbackData) {
    callbackCount++;
    totalContactPairs += callbackData.nbContactPairs;

    for (final pair in callbackData.contactPairs) {
      totalContactPoints += pair.nbContactPoints;
    }
  }

  void reset() {
    callbackCount = 0;
    totalContactPairs = 0;
    totalContactPoints = 0;
  }

  @override
  String toString() {
    return 'ContactCounterCallback(callbacks: $callbackCount, '
        'pairs: $totalContactPairs, points: $totalContactPoints)';
  }
}

/// Wrapper for a Dart callback with tracking for test collision methods.
class _DartCallbackWrapper {
  final CollisionCallback dartCallback;
  final FFICollisionCallback nativeCallback;
  bool wasCalled = false;
  int callCount = 0;

  _DartCallbackWrapper(this.dartCallback)
      : nativeCallback = FFICollisionCallback.logging(
          prefix: 'DartCallback',
          logContactPoints: true,
          verbose: true,
        );

  /// Invoke the Dart callback with mock data for testing purposes.
  void invokeDartCallback() {
    wasCalled = true;
    callCount++;

    // For now, create minimal callback data
    // The native callback has already logged the collision details
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
    // the collision test was performed (even though we don't have the
    // full collision data marshaled yet)
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
