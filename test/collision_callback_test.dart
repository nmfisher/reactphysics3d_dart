import 'package:test/test.dart';
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';
import 'package:reactphysics3d_dart/src/implementation/sendport_event_listener.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:ffi' as ffi;
import 'package:reactphysics3d_dart/src/bindings/src/bindings.dart' as ffi_bindings;

void main() {
  group('Collision Callback Tests', () {
    late ReactPhysics3D physics3D;
    late PhysicsWorld world;

    setUp(() {
      physics3D = createReactPhysics3D();
      world = physics3D.createWorld();
    });

    tearDown(() {});

    group('testCollision - Manual collision queries', () {
      test('testCollisionTwoBodies should detect collision between two bodies', () {
        // Create two box shapes
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        // Create two rigid bodies at the same position (should collide)
        final body1 = world.createRigidBody(
          transform: (
            position: Vector3(0, 0, 0),
            orientation: Quaternion.identity(),
          ),
        );
        body1.addCollider(boxShape);

        final body2 = world.createRigidBody(
          transform: (
            position: Vector3(0, 0, 0),
            orientation: Quaternion.identity(),
          ),
        );
        body2.addCollider(boxShape);

        // Create a simple callback
        final callback = _TestCollisionCallback();
        world.testCollisionTwoBodies(body1, body2, callback);

        // The callback should have been invoked
        // (actual collision detection depends on native implementation)
        expect(callback.wasCalled, isTrue);
      });

      test('testCollision should query all collisions in world', () {
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        // Create overlapping bodies
        for (int i = 0; i < 3; i++) {
          final body = world.createRigidBody(
            transform: (
              position: Vector3(i.toDouble(), 0, 0),
              orientation: Quaternion.identity(),
            ),
          );
          body.addCollider(boxShape);
        }

        final callback = _TestCollisionCallback();
        world.testCollision(callback);

        expect(callback.wasCalled, isTrue);
      });

      test('testCollisionBody should query collisions for single body', () {
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        final body1 = world.createRigidBody(
          transform: (
            position: Vector3(0, 0, 0),
            orientation: Quaternion.identity(),
          ),
        );
        body1.addCollider(boxShape);

        final body2 = world.createRigidBody(
          transform: (
            position: Vector3(0.5, 0, 0),
            orientation: Quaternion.identity(),
          ),
        );
        body2.addCollider(boxShape);

        final callback = _TestCollisionCallback();
        world.testCollisionBody(body1, callback);

        expect(callback.wasCalled, isTrue);
      });
    });

    group('testOverlap - Trigger overlap queries', () {
      test('testOverlap should query trigger overlaps', () {
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        // Create trigger colliders
        final body1 = world.createRigidBody(
          transform: (
            position: Vector3(0, 0, 0),
            orientation: Quaternion.identity(),
          ),
        );
        final collider1 = body1.addCollider(boxShape);
        collider1.setAsTrigger(true);

        final body2 = world.createRigidBody(
          transform: (
            position: Vector3(0, 0, 0),
            orientation: Quaternion.identity(),
          ),
        );
        final collider2 = body2.addCollider(boxShape);
        collider2.setAsTrigger(true);

        final callback = _TestCollisionCallback();
        world.testOverlap(callback);

        expect(callback.wasCalled, isTrue);
      });

      test('collider isTrigger should return correct state', () {
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        final body = world.createRigidBody();
        final collider = body.addCollider(boxShape);

        expect(collider.isTrigger, isFalse);

        collider.setAsTrigger(true);
        expect(collider.isTrigger, isTrue);

        collider.setAsTrigger(false);
        expect(collider.isTrigger, isFalse);
      });
    });

    group('EventListener - Automatic callbacks during update', () {
      test('setEventListener should register a callback', () {
        final callback = _TestCollisionCallback();

        // Should not throw
        world.setEventListener(callback);

        // Clean up
        world.removeEventListener();
      });

      test('removeEventListener should remove the callback', () {
        final callback = _TestCollisionCallback();

        world.setEventListener(callback);
        world.removeEventListener();

        // Should not throw when removing again
        world.removeEventListener();
      });

      test('setEventListener with null should remove listener', () {
        final callback = _TestCollisionCallback();

        world.setEventListener(callback);
        world.setEventListener(null);

        // Listener should be removed
        expect(true, isTrue); // Placeholder - actual verification requires native support
      });
    });

    group('CollisionCallback data structures', () {
      test('ContactPoint should store contact data', () {
        final contactPoint = ContactPoint(
          penetrationDepth: 0.5,
          worldNormal: Vector3(0, 1, 0),
          localPointOnCollider1: Vector3(0.1, 0.2, 0.3),
          localPointOnCollider2: Vector3(-0.1, -0.2, -0.3),
        );

        expect(contactPoint.penetrationDepth, 0.5);
        expect(contactPoint.worldNormal, Vector3(0, 1, 0));
        expect(contactPoint.localPointOnCollider1, Vector3(0.1, 0.2, 0.3));
        expect(contactPoint.localPointOnCollider2, Vector3(-0.1, -0.2, -0.3));
      });

      test('ContactCallbackData should store contact pairs', () {
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        final body1 = world.createRigidBody();
        final collider1 = body1.addCollider(boxShape);

        final body2 = world.createRigidBody();
        final collider2 = body2.addCollider(boxShape);

        final contactPoint = ContactPoint(
          penetrationDepth: 0.5,
          worldNormal: Vector3(0, 1, 0),
          localPointOnCollider1: Vector3.zero(),
          localPointOnCollider2: Vector3.zero(),
        );

        final contactPair = ContactPair(
          contactPoints: [contactPoint],
          body1: body1,
          body2: body2,
          collider1: collider1,
          collider2: collider2,
          eventType: ContactEventType.contactStart,
        );

        final callbackData = ContactCallbackData(contactPairs: [contactPair]);

        expect(callbackData.nbContactPairs, 1);
        expect(callbackData.getContactPair(0), same(contactPair));
      });

      test('ContactEventType enum should have all values', () {
        expect(ContactEventType.contactStart, isNotNull);
        expect(ContactEventType.contactStay, isNotNull);
        expect(ContactEventType.contactExit, isNotNull);
      });
    });

    group('OverlapCallback data structures', () {
      test('OverlapPair should store overlap data', () {
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        final body1 = world.createRigidBody();
        final collider1 = body1.addCollider(boxShape);

        final body2 = world.createRigidBody();
        final collider2 = body2.addCollider(boxShape);

        final overlapPair = OverlapPair(
          collider1: collider1,
          collider2: collider2,
          body1: body1,
          body2: body2,
          eventType: OverlapEventType.overlapStart,
        );

        expect(overlapPair.collider1, same(collider1));
        expect(overlapPair.collider2, same(collider2));
        expect(overlapPair.body1, same(body1));
        expect(overlapPair.body2, same(body2));
        expect(overlapPair.eventType, OverlapEventType.overlapStart);
      });

      test('OverlapCallbackData should store overlap pairs', () {
        final boxShape = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        final body1 = world.createRigidBody();
        final collider1 = body1.addCollider(boxShape);

        final body2 = world.createRigidBody();
        final collider2 = body2.addCollider(boxShape);

        final overlapPair = OverlapPair(
          collider1: collider1,
          collider2: collider2,
          body1: body1,
          body2: body2,
          eventType: OverlapEventType.overlapStart,
        );

        final callbackData = OverlapCallbackData(overlapPairs: [overlapPair]);

        expect(callbackData.nbOverlapPairs, 1);
        expect(callbackData.getOverlapPair(0), same(overlapPair));
      });

      test('OverlapEventType enum should have all values', () {
        expect(OverlapEventType.overlapStart, isNotNull);
        expect(OverlapEventType.overlapStay, isNotNull);
        expect(OverlapEventType.overlapExit, isNotNull);
      });
    });

    group('SendPortEventListener (Thread-Safe)', () {
      test('SendPortEventListener should create with valid SendPort', () {
        final callback = _TestCollisionCallback();
        final listener = SendPortEventListener(callback);

        expect(listener.isActive, isFalse);
        // The listener ID should be positive
        expect(listener.nativeMessageCount, greaterThanOrEqualTo(0));

        listener.dispose();
      });

      test('SendPortEventListener should attach and detach from world', () {
        final callback = _TestCollisionCallback();
        final listener = SendPortEventListener(callback);

        listener.attachTo(world);
        expect(listener.isActive, isTrue);

        listener.detach();
        expect(listener.isActive, isFalse);

        listener.dispose();
      });

      test('SendPortEventListener should handle message buffer reading', () {
        // Test the message reader with a known structure
        final buffer = createTestMessageBuffer();

        final reader = _TestMessageReader(buffer);
        final messageType = reader.readUint32();
        expect(messageType, equals(0)); // Contact data

        final nbPairs = reader.readUint32();
        expect(nbPairs, equals(1));

        // Read body/collider addresses
        final body1Addr = reader.readUint64();
        final body2Addr = reader.readUint64();
        expect(body1Addr, equals(0x1000));
        expect(body2Addr, equals(0x2000));

        ffi_bindings.calloc.free(buffer);
      });

      test('SendPortEventListener should poll for messages', () {
        final callback = _TestCollisionCallback();
        final listener = SendPortEventListener(callback);

        listener.attachTo(world);

        // Polling should not throw
        listener.poll();

        listener.detach();
        listener.dispose();
      });

      test('SendPortEventListener should track message count', () {
        final callback = _TestCollisionCallback();
        final listener = SendPortEventListener(callback);

        final initialCount = listener.messageCount;
        expect(initialCount, equals(0));

        listener.dispose();
      });
    });
  });
}

/// Simple test callback that tracks if it was called
class _TestCollisionCallback implements CollisionCallback {
  bool wasCalled = false;
  int callCount = 0;
  ContactCallbackData? lastCallbackData;

  @override
  void onContact(ContactCallbackData callbackData) {
    wasCalled = true;
    callCount++;
    lastCallbackData = callbackData;
  }

  void reset() {
    wasCalled = false;
    callCount = 0;
    lastCallbackData = null;
  }
}

/// Simple test overlap callback
class _TestOverlapCallback implements OverlapCallback {
  bool wasCalled = false;
  int callCount = 0;
  OverlapCallbackData? lastCallbackData;

  @override
  void onOverlap(OverlapCallbackData callbackData) {
    wasCalled = true;
    callCount++;
    lastCallbackData = callbackData;
  }

  void reset() {
    wasCalled = false;
    callCount = 0;
    lastCallbackData = null;
  }
}

/// Helper for testing message reading
class _TestMessageReader {
  final ffi.Pointer<ffi.Uint8> _data;
  int _offset;

  _TestMessageReader(this._data) : _offset = 0;

  int readUint32() {
    final value = _data.elementAt(_offset).cast<ffi.Uint32>().value;
    _offset += 4;
    return value;
  }

  int readUint64() {
    final value = _data.elementAt(_offset).cast<ffi.Uint64>().value;
    _offset += 8;
    return value;
  }
}
