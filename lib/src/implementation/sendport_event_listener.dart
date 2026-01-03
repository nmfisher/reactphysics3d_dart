import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'package:vector_math/vector_math_64.dart';
import '../bindings/src/bindings.dart';
import '../interfaces/collision_callback.dart';
import '../interfaces/event_listener.dart';
import 'ffi_rigid_body.dart';
import 'ffi_collider.dart';

/// A thread-safe event listener that uses ReceivePort/SendPort for callbacks
///
/// This implementation is safe for multi-threaded scenarios because:
/// 1. C++ can post messages to Dart's SendPort from any thread
/// 2. Dart processes messages on its main event loop
/// 3. No isolate-local restrictions with `isolateLocal` callbacks
///
/// ## Architecture
///
/// ```
/// C++ Thread Pool          Dart Isolate
///     │                         │
///     ├─► SendPort ─────────────▶ ReceivePort
///     │                         │
///     │   (any thread)           │  (main event loop)
///     │                         │
///     ▼                         ▼
/// Collision              ContactCallbackData
/// Detection              .onContact()
/// ```
///
/// ## Usage
///
/// ```dart
/// final listener = SendPortEventListener(MyCallback());
/// world.setEventListener(listener);
///
/// // Update can be called from any thread (including background threads)
/// world.update(1/60);  // Callbacks will be processed on Dart's event loop
///
/// // When done
/// world.setEventListener(null);
/// listener.dispose();
/// ```
class SendPortEventListener implements EventListener {
  final CollisionCallback _callback;
  late final ReceivePort _receivePort;
  late final SendPort _sendPort;
  late final ffi.Pointer<RP3D_EventListener> _listenerPtr;
  bool _isDisposed = false;

  // Buffer for reading messages from native
  final ffi.Pointer<ffi.Uint8> _messageBuffer;
  static const int _maxMessageSize = 65536; // 64KB buffer

  SendPortEventListener(this._callback)
      : _messageBuffer = calloc.allocate<ffi.Uint8>(_maxMessageSize) {
    // Create a ReceivePort to receive messages from native code
    _receivePort = ReceivePort();
    _sendPort = _receivePort.sendPort;

    // Listen for messages from native code
    _receivePort.listen(_handleMessage);

    // Create the native event listener with the SendPort ID
    _listenerPtr = rp3d_create_sendport_event_listener(_sendPort.nativePort);
  }

  /// Get the native EventListener pointer for passing to rp3d_world_set_event_listener()
  ffi.Pointer<RP3D_EventListener> get pointer => _listenerPtr;

  /// Handle incoming message from native code
  void _handleMessage(dynamic message) {
    if (_isDisposed) return;

    // Poll for messages from the global buffer
    try {
      final msgSize = rp3d_get_listener_message(
        _messageBuffer,
        _maxMessageSize,
      );

      if (msgSize > 0) {
        _processMessage(_messageBuffer, msgSize);
      }
    } catch (e) {
      print('Error processing collision message: $e');
    }
  }

  /// Process a binary message from native code
  void _processMessage(ffi.Pointer<ffi.Uint8> data, int size) {
    final bytes = data.asTypedList(size);
    final byteData = ByteData.view(bytes.buffer);

    // Read message type
    int offset = 0;
    final messageType = byteData.getUint32(offset, Endian.little);
    offset += 4;

    if (messageType == 0) {
      // Contact data
      _processContactData(byteData, offset);
    } else if (messageType == 1) {
      // Overlap data
      _processOverlapData(byteData, offset);
    }
  }

  /// Process contact data from the message
  void _processContactData(ByteData byteData, int initialOffset) {
    int offset = initialOffset;
    final nbPairs = byteData.getUint32(offset, Endian.little);
    offset += 4;
    final contactPairs = <ContactPair>[];

    for (int i = 0; i < nbPairs; i++) {
      // Read body/collider addresses
      final body1Addr = byteData.getUint64(offset, Endian.little);
      offset += 8;
      final body2Addr = byteData.getUint64(offset, Endian.little);
      offset += 8;
      final collider1Addr = byteData.getUint64(offset, Endian.little);
      offset += 8;
      final collider2Addr = byteData.getUint64(offset, Endian.little);
      offset += 8;

      // Read event type
      final eventTypeInt = byteData.getInt32(offset, Endian.little);
      offset += 4;
      final ContactEventType eventType;
      if (eventTypeInt == 0) {
        eventType = ContactEventType.contactStart;
      } else if (eventTypeInt == 1) {
        eventType = ContactEventType.contactStay;
      } else {
        eventType = ContactEventType.contactExit;
      }

      // Read contact points
      final nbPoints = byteData.getUint32(offset, Endian.little);
      offset += 4;
      final contactPoints = <ContactPoint>[];

      for (int j = 0; j < nbPoints; j++) {
        final penetrationDepth = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final normalX = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final normalY = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final normalZ = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final point1X = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final point1Y = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final point1Z = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final point2X = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final point2Y = byteData.getFloat32(offset, Endian.little);
        offset += 4;
        final point2Z = byteData.getFloat32(offset, Endian.little);
        offset += 4;

        contactPoints.add(ContactPoint(
          penetrationDepth: penetrationDepth,
          worldNormal: Vector3(normalX, normalY, normalZ),
          localPointOnCollider1: Vector3(point1X, point1Y, point1Z),
          localPointOnCollider2: Vector3(point2X, point2Y, point2Z),
        ));
      }

      // Create wrappers for bodies and colliders
      final body1Ptr = ffi.Pointer<RP3D_RigidBody>.fromAddress(body1Addr);
      final body2Ptr = ffi.Pointer<RP3D_RigidBody>.fromAddress(body2Addr);
      final collider1Ptr = ffi.Pointer<RP3D_Collider>.fromAddress(collider1Addr);
      final collider2Ptr = ffi.Pointer<RP3D_Collider>.fromAddress(collider2Addr);

      contactPairs.add(ContactPair(
        contactPoints: contactPoints,
        body1: FFIRigidBody(body1Ptr),
        body2: FFIRigidBody(body2Ptr),
        collider1: FFICollider(collider1Ptr),
        collider2: FFICollider(collider2Ptr),
        eventType: eventType,
      ));
    }

    // Call the Dart callback with the marshaled data
    final callbackData = ContactCallbackData(contactPairs: contactPairs);
    _callback.onContact(callbackData);
  }

  /// Process overlap data from the message
  void _processOverlapData(ByteData byteData, int initialOffset) {
    int offset = initialOffset;
    final nbPairs = byteData.getUint32(offset, Endian.little);
    offset += 4;

    // For now, overlaps are reported as contact pairs with no points
    // In a full implementation, you might want a separate callback for overlaps
    print('Received $nbPairs overlap events');

    for (int i = 0; i < nbPairs; i++) {
      final body1Addr = byteData.getUint64(offset, Endian.little);
      offset += 8;
      final body2Addr = byteData.getUint64(offset, Endian.little);
      offset += 8;
      final eventTypeInt = byteData.getInt32(offset, Endian.little);
      offset += 4;

      // Skip points (overlaps have none)
      offset += 4;

      print('  Overlap between bodies at $body1Addr and $body2Addr: '
            '${eventTypeInt == 0 ? "Start" : eventTypeInt == 1 ? "Stay" : "Exit"}');
    }
  }

  /// Check for pending messages and process them
  ///
  /// This can be called periodically to poll for messages if needed.
  void poll() {
    if (_isDisposed) return;
    while (rp3d_has_pending_message() != 0) {
      _handleMessage(null);
    }
  }

  /// Clean up resources
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    _receivePort.close();
    rp3d_destroy_event_listener(_listenerPtr);
    calloc.free(_messageBuffer);
  }
}
