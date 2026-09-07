import 'dart:async';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';
import 'package:reactphysics3d_dart/src/bindings/src/bindings.dart' as native;

class _Callback extends CollisionCallback {
  final void Function(ContactCallbackData) callback;
  _Callback(this.callback);
  @override
  void onContact(ContactCallbackData data) => callback(data);
}

void main() {
  late ReactPhysics3D physics;
  setUp(() => physics = createReactPhysics3D());
  tearDown(() => physics.dispose());

  test('public teardown invalidates all borrowed views and is idempotent', () {
    final world = physics.createWorld();
    final body = world.createRigidBody();
    final shape = physics.createBoxShape(Vector3.all(1));
    final collider = body.addCollider(shape);
    final material = collider.material;
    final debug = world.getDebugRenderer();
    expect(world.getRigidBody(0), same(body));
    expect(
      world.raycast(Ray(Vector3(0, 3, 0), Vector3(0, -3, 0)))!.body,
      same(body),
    );
    expect(() => shape.dispose(), throwsStateError);
    world.dispose();
    world.dispose();
    expect(() => world.update(1 / 60), throwsStateError);
    expect(() => body.mass, throwsStateError);
    expect(() => collider.material, throwsStateError);
    expect(() => material.frictionCoefficient, throwsStateError);
    expect(() => debug.getNbLines(), throwsStateError);
    shape.dispose();
    physics.dispose();
    physics.dispose();
    expect(() => physics.createWorld(), throwsStateError);
  });

  test(
    'body and collider removal invalidate aliases and reject foreign owners',
    () {
      final world = physics.createWorld();
      final other = physics.createWorld();
      final body = world.createRigidBody();
      final otherBody = other.createRigidBody();
      final shape = physics.createSphereShape(1);
      final collider = body.addCollider(shape);
      final material = collider.material;
      expect(() => other.destroyRigidBody(body), throwsArgumentError);
      expect(() => otherBody.removeCollider(collider), throwsArgumentError);
      body.removeCollider(collider);
      body.removeCollider(collider);
      expect(() => material.massDensity, throwsStateError);
      world.destroyRigidBody(body);
      world.destroyRigidBody(body);
      expect(world.getNbRigidBodies(), 0);
      expect(() => body.transform, throwsStateError);
      shape.dispose();
    },
  );

  test(
    'cached material follows component storage after other collider removal',
    () {
      final world = physics.createWorld();
      final shape = physics.createSphereShape(1);
      final first = world.createRigidBody();
      final firstCollider = first.addCollider(shape);
      final second = world.createRigidBody();
      final collider = second.addCollider(shape);
      final cached = collider.material;
      cached.setFrictionCoefficient(0.25);
      first.removeCollider(firstCollider);
      cached.setFrictionCoefficient(0.75);
      expect(collider.material.frictionCoefficient, closeTo(0.75, 1e-6));
      for (var i = 0; i < 64; i++) {
        second.addCollider(shape);
      }
      cached.setBounciness(0.5);
      expect(collider.material.bounciness, closeTo(0.5, 1e-6));
    },
  );

  test('factory resources reject cross-factory dependencies', () {
    final other = createReactPhysics3D();
    try {
      final shape = other.createSphereShape(1);
      expect(
        () => physics.createWorld().createRigidBody().addCollider(shape),
        throwsArgumentError,
      );
      final mesh = other.createConvexMeshFromVertices(
        other.createVertexArray(
          Float32List.fromList([0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]),
        ),
      )!;
      expect(() => physics.createConvexMeshShape(mesh), throwsArgumentError);
    } finally {
      other.dispose();
    }
  });

  test('native array descriptors own copies of input buffers', () {
    // Direct C API input avoids the Dart factory's extra copy: this failed when
    // the native descriptor retained a pointer into the Dart heap.
    final vertices = Float32List.fromList([0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]);
    final handle = native.rp3d_vertex_array_create(4, vertices.address, 12);
    try {
      vertices.fillRange(0, vertices.length, 99);
      final start = native.rp3d_vertex_array_get_vertices_start(handle);
      expect(start[0], 0);
      expect(start[3], 1);
    } finally {
      native.rp3d_vertex_array_destroy(handle);
    }
    final array = physics.createVertexArray(
      Float32List.fromList([0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]),
    );
    array.dispose();
    array.dispose();
    expect(() => array.getVertex(0), throwsStateError);
  });

  test(
    'polygon face counts come from descriptors and validate their bounds',
    () {
      final vertices = Float32List.fromList([
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
      ]);
      final array = physics.createPolygonVertexArray(
        vertices: vertices,
        indices: Uint32List.fromList([0, 2, 1, 0, 1, 3, 0, 3, 2, 1, 2, 3]),
        polygonIndices: Uint32List.fromList([3, 0, 3, 3, 3, 6, 3, 9]),
      );
      expect(array.getFaceCount(), 4);
      expect(array.getPolygonFace(3), {'nbVertices': 3, 'indexBase': 9});
      final mesh = physics.createConvexMeshFromPolygons(array);
      final shape = physics.createConvexMeshShape(mesh);
      array.dispose();
      expect(() => mesh.dispose(), throwsStateError);
      shape.dispose();
      mesh.dispose();
      expect(
        () => physics.createPolygonVertexArray(
          vertices: vertices,
          indices: Uint32List.fromList([0, 1, 2]),
          polygonIndices: Uint32List.fromList([4, 0]),
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'rectangular heightfields use row-major coordinates and guard their data',
    () {
      final field = physics.createHeightFieldFloat(
        rows: 2,
        columns: 3,
        heights: Float32List.fromList([0, 1, 2, 3, 4, 5]),
        minHeight: 0,
        maxHeight: 5,
      );
      final shape = physics.createHeightFieldShape(field);
      final vertex = shape.getVertexAt(1, 2);
      expect(vertex.x, closeTo(1, 1e-6));
      expect(vertex.y, closeTo(2.5, 1e-6));
      expect(vertex.z, closeTo(0.5, 1e-6));
      expect(() => shape.getVertexAt(2, 0), throwsRangeError);
      expect(() => field.dispose(), throwsStateError);
      shape.dispose();
      field.dispose();
      expect(() => shape.getVertexAt(0, 0), throwsStateError);
    },
  );

  test(
    'angular velocity, torque, force position and collider transforms work',
    () {
      final world = physics.createWorld()..setIsGravityEnabled(false);
      final body = world.createRigidBody();
      final collider = body.addCollider(physics.createBoxShape(Vector3.all(1)));
      body.updateMassPropertiesFromColliders();
      body.angularVelocity = Vector3(1, 2, 3);
      expect(body.angularVelocity, Vector3(1, 2, 3));
      body.angularVelocity = Vector3.zero();
      body.applyTorque(Vector3(0, 10, 0));
      world.update(1 / 60);
      expect(body.angularVelocity.y, greaterThan(0));
      body.angularVelocity = Vector3.zero();
      body.applyForce(Vector3(10, 0, 0), Vector3(0, 1, 0));
      world.update(1 / 60);
      expect(body.angularVelocity.z, lessThan(0));
      collider.localPosition = Vector3(1, 2, 3);
      expect(collider.localPosition, Vector3(1, 2, 3));
      expect(collider.shape, isA<BoxShape>());
      expect(() => body.applyImpulse(Vector3(1, 0, 0)), throwsUnsupportedError);
      expect(
        () => collider.material.setRollingResistance(0.1),
        throwsUnsupportedError,
      );
    },
  );

  test(
    'automatic listeners isolate worlds and deliver trigger start/stay/exit',
    () async {
      final a = physics.createWorld()..setIsGravityEnabled(false);
      final b = physics.createWorld()..setIsGravityEnabled(false);
      final shape = physics.createSphereShape(1);
      final first = a.createRigidBody();
      first.addCollider(shape).setAsTrigger(true);
      final second = a.createRigidBody(
        transform: (
          position: Vector3(1, 0, 0),
          orientation: Quaternion.identity(),
        ),
      );
      second.addCollider(shape);
      final calls = <ContactPair>[];
      final notification = Completer<void>();
      final listener = SendPortEventListener(
        _Callback((data) {
          calls.addAll(data.contactPairs);
          if (!notification.isCompleted) notification.complete();
        }),
      );
      final unrelated = SendPortEventListener(
        _Callback((_) => fail('Wrong world received event')),
      );
      addTearDown(listener.dispose);
      addTearDown(unrelated.dispose);
      a.setEventListener(listener);
      b.setEventListener(unrelated);
      expect(() => b.setEventListener(listener), throwsStateError);
      a.update(1 / 60);
      await notification.future.timeout(const Duration(seconds: 2));
      expect(calls.first.eventType, ContactEventType.contactStart);
      expect(calls.first.contactPoints, isEmpty);
      expect([calls.first.body1, calls.first.body2], contains(first));
      a.update(1 / 60);
      listener.poll();
      expect(calls.last.eventType, ContactEventType.contactStay);
      second.transform = (
        position: Vector3(10, 0, 0),
        orientation: Quaternion.identity(),
      );
      a.update(1 / 60);
      listener.poll();
      expect(calls.last.eventType, ContactEventType.contactExit);
      listener.dispose(); // Automatically detaches from a still-live world.
      a.update(1 / 60);
    },
  );

  test(
    'large event packets drain without truncation or repeated delivery',
    () async {
      final world = physics.createWorld()..setIsGravityEnabled(false);
      final shape = physics.createSphereShape(1);
      for (var i = 0; i < 48; i++) {
        world
            .createRigidBody(
              transform: (
                position: Vector3(i * 0.01, 0, 0),
                orientation: Quaternion.identity(),
              ),
            )
            .addCollider(shape);
      }
      var pairs = 0;
      final listener = SendPortEventListener(
        _Callback((data) => pairs += data.nbContactPairs),
      );
      addTearDown(listener.dispose);
      world.setEventListener(listener);
      world.update(1 / 60);
      expect(
        native.rp3d_listener_message_size(listener.pointer),
        greaterThan(65536),
      );
      listener.poll();
      expect(pairs, 48 * 47 ~/ 2);
      final before = pairs;
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(pairs, before);
      expect(native.rp3d_listener_message_size(listener.pointer), 0);
    },
  );
}
