import 'dart:typed_data';
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

class Callback extends CollisionCallback {
  int pairs = 0;
  @override
  void onContact(ContactCallbackData data) {
    pairs += data.nbContactPairs;
  }
}

void main() {
  initializeReactPhysics3DWeb();
  final physics = createReactPhysics3D();
  try {
    final world = physics.createWorld();
    final body = world.createRigidBody();
    final shape = physics.createBoxShape(Vector3.all(0.5));
    final collider = body.addCollider(shape);
    final cachedMaterial = collider.material;
    for (var i = 0; i < 64; i++) {
      final extra = body.addCollider(shape);
      body.removeCollider(extra);
    }
    cachedMaterial.setFrictionCoefficient(0.75);
    check(collider.material.frictionCoefficient == 0.75, 'borrowed material');
    collider.collisionCategoryBits = 0x8001;
    check(collider.collisionCategoryBits == 0x8001, 'collision masks');
    body.updateMassPropertiesFromColliders();
    world.update(1 / 60);
    check(body.transform.position.y < 0, 'gravity');
    check(body.transform.getOpenGLMatrix()[15] == 1, 'matrix output');
    for (var i = 0; i < 100000; i++) {
      body.transform;
    }
    check(world.getGravity().y < 0, 'temporary stack scopes');
    final second = world.createRigidBody();
    second.addCollider(shape).setAsTrigger(true);
    final callback = Callback();
    final listener = SendPortEventListener(callback);
    world.setEventListener(listener);
    world.update(1 / 60);
    listener.poll();
    check(callback.pairs > 0, 'trigger callbacks');
    listener.dispose();
    final query = Callback();
    world.testCollision(query);
    world.testOverlap(query);
    check(query.pairs > 0, 'synchronous query layout');
    final polygon = physics.createPolygonVertexArray(
      vertices: Float32List.fromList([0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]),
      indices: Uint32List.fromList([0, 2, 1, 0, 1, 3, 0, 3, 2, 1, 2, 3]),
      polygonIndices: Uint32List.fromList([3, 0, 3, 3, 3, 6, 3, 9]),
    );
    check(polygon.getFaceCount() == 4, 'polygon count');
    check(
      polygon.getPolygonFace(3)['indexBase'] == 9,
      'polygon output buffers',
    );
    check(polygon.getIndex(11) == 3, 'uint32 pointer');
    physics.createConvexMeshFromPolygons(polygon);
    final heights = physics.createHeightFieldFloat(
      rows: 400,
      columns: 400,
      heights: Float32List(160000),
      minHeight: 0,
      maxHeight: 0,
    );
    physics.createHeightFieldShape(heights);
    world.dispose();
    try {
      body.mass;
      throw StateError('stale handle accepted');
    } on StateError catch (e) {
      check(e.message != 'stale handle accepted', 'stale handle');
    }
    print('WebAssembly smoke test passed');
  } finally {
    physics.dispose();
  }
}
