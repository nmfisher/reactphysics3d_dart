import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';
import '../bindings/src/bindings.dart';
import '../interfaces/collision_callback.dart';
import '../interfaces/physics_world.dart';
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
/// listener.attachTo(world);
///
/// // Update can be called from any thread (including background threads)
/// world.update(1/60);  // Callbacks will be processed on Dart's event loop
///
/// // When done
/// listener.detach();
/// ```
class SendPortEventListener {
  final CollisionCallback _callback;
  late final ReceivePort _receivePort;
  late final SendPort _sendPort;
  late final int _listenerId;
  bool _isActive = false;
  PhysicsWorld? _attachedWorld;

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
    _listenerId = rp3d_create_sendport_event_listener(_sendPort.nativePort);
  }

  /// Attach this listener to a physics world for automatic callbacks during update()
  void attachTo(PhysicsWorld world) {
    if (_isActive) return;

    _attachedWorld = world;

    // Set the listener on the world
    rp3d_world_set_sendport_listener(world.handle.cast(), _listenerId);
    _isActive = true;
  }

  /// Detach this listener from the physics world
  void detach() {
    if (!_isActive) return;

    rp3d_destroy_sendport_event_listener(_listenerId);
    _isActive = false;
    _attachedWorld = null;
  }

  /// Check if this listener is currently active
  bool get isActive => _isActive;

  /// Get the number of messages received
  int messageCount = 0;

  /// Handle incoming message from native code
  void _handleMessage(dynamic message) {
    messageCount++;

    // The message from C++ will be a list of bytes (the serialized contact data)
    // For now, we'll poll for the message since the actual SendPort.send()
    // from C++ requires Dart VM integration

    try {
      // Poll for messages from the listener
      final msgSize = rp3d_get_listener_message(
        _listenerId,
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
    final reader = _MessageReader(data, size);

    // Read message type
    final messageType = reader.readUint32();

    if (messageType == 0) {
      // Contact data
      _processContactData(reader);
    } else if (messageType == 1) {
      // Overlap data
      _processOverlapData(reader);
    }
  }

  /// Process contact data from the message
  void _processContactData(_MessageReader reader) {
    final nbPairs = reader.readUint32();
    final contactPairs = <ContactPair>[];

    for (int i = 0; i < nbPairs; i++) {
      // Read body/collider addresses
      final body1Addr = reader.readUint64();
      final body2Addr = reader.readUint64();
      final collider1Addr = reader.readUint64();
      final collider2Addr = reader.readUint64();

      // Read event type
      final eventTypeInt = reader.readInt32();
      final ContactEventType eventType;
      if (eventTypeInt == 0) {
        eventType = ContactEventType.contactStart;
      } else if (eventTypeInt == 1) {
        eventType = ContactEventType.contactStay;
      } else {
        eventType = ContactEventType.contactExit;
      }

      // Read contact points
      final nbPoints = reader.readUint32();
      final contactPoints = <ContactPoint>[];

      for (int j = 0; j < nbPoints; j++) {
        final penetrationDepth = reader.readFloat();
        final normalX = reader.readFloat();
        final normalY = reader.readFloat();
        final normalZ = reader.readFloat();
        final point1X = reader.readFloat();
        final point1Y = reader.readFloat();
        final point1Z = reader.readFloat();
        final point2X = reader.readFloat();
        final point2Y = reader.readFloat();
        final point2Z = reader.readFloat();

        contactPoints.add(ContactPoint(
          penetrationDepth: penetrationDepth.toDouble(),
          worldNormal: Vector3(normalX.toDouble(), normalY.toDouble(), normalZ.toDouble()),
          localPointOnCollider1: Vector3(point1X.toDouble(), point1Y.toDouble(), point1Z.toDouble()),
          localPointOnCollider2: Vector3(point2X.toDouble(), point2Y.toDouble(), point2Z.toDouble()),
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
  void _processOverlapData(_MessageReader reader) {
    final nbPairs = reader.readUint32();

    // For now, overlaps are reported as contact pairs with no points
    // In a full implementation, you might want a separate callback for overlaps
    print('Received $nbPairs overlap events');

    for (int i = 0; i < nbPairs; i++) {
      final body1Addr = reader.readUint64();
      final body2Addr = reader.readUint64();
      final eventTypeInt = reader.readInt32();

      // Skip points (overlaps have none)
      reader.readUint32();

      print('  Overlap between bodies at $body1Addr and $body2Addr: '
            '${eventTypeInt == 0 ? "Start" : eventTypeInt == 1 ? "Stay" : "Exit"}');
    }
  }

  /// Check for pending messages and process them
  ///
  /// This can be called periodically to poll for messages if needed.
  /// Messages are also processed automatically when sent via SendPort.
  void poll() {
    while (rp3d_has_pending_message() != 0) {
      _handleMessage(null);
    }
  }

  /// Get the number of messages processed by the native listener
  int get nativeMessageCount {
    return rp3d_get_listener_message_count(_listenerId);
  }

  void dispose() {
    detach();
    _receivePort.close();
    calloc.free(_messageBuffer);
  }
}

/// Helper class for reading binary messages from native code
class _MessageReader {
  final ffi.Pointer<ffi.Uint8> _data;
  int _offset;

  _MessageReader(this._data, int size) : _offset = 0;

  int readUint32() {
    final value = _data.elementAt(_offset).cast<ffi.Uint32>().value;
    _offset += 4;
    return value;
  }

  int readInt32() {
    final value = _data.elementAt(_offset).cast<ffi.Int32>().value;
    _offset += 4;
    return value;
  }

  int readUint64() {
    final value = _data.elementAt(_offset).cast<ffi.Uint64>().value;
    _offset += 8;
    return value;
  }

  double readFloat() {
    final value = _data.elementAt(_offset).cast<ffi.Float>().value;
    _offset += 4;
    return value.toDouble();
  }

  bool get hasMore => true; // We don't track the original size
}

/// Helper function to create a buffer for testing SendPort communication
///
/// This can be used to test the SendPort integration without needing
/// actual collisions to occur.
ffi.Pointer<ffi.Uint8> createTestMessageBuffer() {
  // Create a simple test message with one contact pair
  const size = 4 + // message type
      4 + // nb pairs
      8 + 8 + 8 + 8 + // pointers
      4 + // event type
      4 + // nb points
      1 * 4 + 3 * 4 + 3 * 4 + 3 * 4; // one point

  final buffer = calloc.allocate<ffi.Uint8>(size);
  final writer = _MessageWriter(buffer);

  writer.writeUint32(0); // Message type: contact data
  writer.writeUint32(1); // 1 pair

  // Write a dummy pair
  writer.writeUint64(0x1000); // body1
  writer.writeUint64(0x2000); // body2
  writer.writeUint64(0x3000); // collider1
  writer.writeUint64(0x4000); // collider2
  writer.writeInt32(0); // event type: start
  writer.writeUint32(1); // 1 point

  // Write a dummy point
  writer.writeFloat(1.0); // penetration depth
  writer.writeFloat(0.0); writer.writeFloat(1.0); writer.writeFloat(0.0); // normal
  writer.writeFloat(0.0); writer.writeFloat(0.0); writer.writeFloat(0.0); // point1
  writer.writeFloat(0.0); writer.writeFloat(0.0); writer.writeFloat(0.0); // point2

  return buffer;
}

/// Helper class for writing binary messages to native buffers
class _MessageWriter {
  final ffi.Pointer<ffi.Uint8> _data;
  int _offset;

  _MessageWriter(this._data) : _offset = 0;

  void writeUint32(int value) {
    _data.elementAt(_offset).cast<ffi.Uint32>().value = value;
    _offset += 4;
  }

  void writeInt32(int value) {
    _data.elementAt(_offset).cast<ffi.Int32>().value = value;
    _offset += 4;
  }

  void writeUint64(int value) {
    _data.elementAt(_offset).cast<ffi.Uint64>().value = value;
    _offset += 8;
  }

  void writeFloat(double value) {
    _data.elementAt(_offset).cast<ffi.Float>().value = value;
    _offset += 4;
  }

  int get offset => _offset;
}
