import 'dart:typed_data';
import '../bindings/src/bindings.dart';
import '../interfaces/collision_callback.dart';
import '../interfaces/event_listener.dart';
import 'ffi_physics_world.dart';
import 'event_port.dart';
import 'package:vector_math/vector_math_64.dart';

/// Receives contacts and trigger overlaps asynchronously after [PhysicsWorld.update].
///
/// Attach to one world at a time. The native queue belongs to this listener;
/// [poll] drains it synchronously when immediate delivery is needed. Trigger
/// pairs have no contact points. Disposal detaches the listener and drops queued
/// events. World/body/collider destruction also discards pending events.
///
/// The transport is thread-safe. Physics operations on a world must still be
/// serialized; do not update or destroy the same world concurrently.
class SendPortEventListener implements EventListener {
  final CollisionCallback _callback;
  late final EventPort _port;
  late final Pointer<RP3D_EventListener> _pointer;
  FFIPhysicsWorld? _world;
  bool _disposed = false;
  bool _polling = false;
  int _generation = 0;

  SendPortEventListener(this._callback) {
    _port = EventPort(poll);
    try {
      _pointer = rp3d_create_sendport_event_listener(_port.id.toBigInt);
      if (_pointer == nullptr)
        throw StateError('Failed to create event listener');
    } catch (_) {
      _port.close();
      rethrow;
    }
  }

  @override
  Pointer<RP3D_EventListener> get pointer {
    if (_disposed) throw StateError('Event listener has been disposed');
    return _pointer;
  }

  void checkCanAttach(FFIPhysicsWorld world) {
    pointer;
    if (_world != null && !identical(_world, world)) {
      throw StateError('An event listener can only belong to one world');
    }
  }

  void attachToWorld(FFIPhysicsWorld world) {
    _world = world;
  }

  void detachFromWorld(FFIPhysicsWorld world) {
    if (identical(_world, world)) {
      discardPendingEvents();
      _world = null;
    }
  }

  void discardPendingEvents() {
    _generation++;
    if (!_disposed) rp3d_listener_clear_messages(_pointer);
  }

  /// Deliver queued events now. Also called automatically by Dart notifications.
  void poll() {
    if (_disposed || _polling) return;
    _polling = true;
    final stack = saveNativeStack();
    try {
      // Snapshot packets before calling user code, which can mutate the world.
      final packets = <Uint8List>[];
      while (true) {
        final size = rp3d_listener_message_size(_pointer);
        if (size == 0) break;
        final bytes = makeUint8List(size);
        try {
          final read = rp3d_listener_read_message(
            _pointer,
            bytes.address,
            size,
          );
          if (read == 0) throw StateError('Failed to drain event queue');
          packets.add(Uint8List.fromList(bytes));
        } finally {
          bytes.free();
        }
      }
      final generation = _generation;
      final world = _world;
      if (world == null) return;
      for (final packet in packets) {
        if (_disposed ||
            generation != _generation ||
            !identical(world, _world) ||
            world.lifetime.isDisposed)
          break;
        final data = _decode(packet, world);
        if (data.contactPairs.isNotEmpty) _callback.onContact(data);
      }
    } finally {
      _polling = false;
      restoreNativeStack(stack);
    }
  }

  ContactCallbackData _decode(Uint8List bytes, FFIPhysicsWorld world) {
    final reader = _EventReader(ByteData.sublistView(bytes));
    final type = reader.uint32();
    if (type != 0 && type != 1)
      throw FormatException('Unknown physics event type: $type');
    final count = reader.uint32();
    final pairs = <ContactPair>[];
    for (var i = 0; i < count; i++) {
      final body1 = reader.uint64();
      final body2 = reader.uint64();
      final collider1 = reader.uint64();
      final collider2 = reader.uint64();
      final event = reader.uint32();
      if (event > 2) throw const FormatException('Invalid physics event');
      final pointCount = reader.uint32();
      final points = <ContactPoint>[];
      for (var j = 0; j < pointCount; j++) {
        points.add(
          ContactPoint(
            penetrationDepth: reader.float32(),
            worldNormal: reader.vector(),
            localPointOnCollider1: reader.vector(),
            localPointOnCollider2: reader.vector(),
          ),
        );
      }
      // Earlier callbacks may have destroyed objects referenced by later packets.
      final b1 = world.bodies[body1];
      final b2 = world.bodies[body2];
      final c1 = world.colliders[collider1];
      final c2 = world.colliders[collider2];
      if (b1 == null || b2 == null || c1 == null || c2 == null) continue;
      pairs.add(
        ContactPair(
          body1: b1,
          body2: b2,
          collider1: c1,
          collider2: c2,
          eventType: ContactEventType.values[event],
          contactPoints: points,
        ),
      );
    }
    return ContactCallbackData(contactPairs: pairs);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _world?.setEventListener(null);
    _disposed = true;
    _port.close();
    rp3d_destroy_event_listener(_pointer);
  }
}

class _EventReader {
  final ByteData data;
  int offset = 0;
  _EventReader(this.data);
  int uint32() {
    final v = data.getUint32(offset, Endian.little);
    offset += 4;
    return v;
  }

  int uint64() {
    final low = uint32();
    final high = uint32();
    return low + high * 0x100000000;
  }

  double float32() {
    final v = data.getFloat32(offset, Endian.little);
    offset += 4;
    return v;
  }

  Vector3 vector() => Vector3(float32(), float32(), float32());
}
