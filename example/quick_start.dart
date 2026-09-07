import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void main() {
  final physics = createReactPhysics3D();
  try {
    final world = physics.createWorld();
    final body = world.createRigidBody(
      transform: (
        position: Vector3(0, 20, 0),
        orientation: Quaternion.identity(),
      ),
    );
    body.addCollider(physics.createBoxShape(Vector3.all(0.5)));
    body.updateMassPropertiesFromColliders();
    for (var i = 0; i < 60; i++) {
      world.update(1 / 60);
    }
    print(body.transform.position);
  } finally {
    physics.dispose();
  }
}
