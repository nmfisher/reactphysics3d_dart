// Compile-only smoke test for the web (JS interop) bindings.
//
// lib/src/bindings/src/bindings.dart picks the JS interop bindings through a
// conditional export, so `dart analyze` on the VM never sees them. This entry
// point pulls in the whole package so `dart compile js` type checks the
// ffigen_js runtime and the generated bindings together with the hand-written
// implementation files.
//
// Run with:
//   dart compile js -o /tmp/web_bindings_smoke.js tool/web_bindings_smoke.dart
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void main() {
  final physics = FFIReactPhysics3D();
  final world = physics.physicsCommon.createPhysicsWorld();
  final body = world.createRigidBody(
    transform: (position: Vector3(0, 10, 0), orientation: Quaternion.identity()),
  );
  world.update(1.0 / 60.0);
  assert(body.transform.position.y < 10.0);
}
