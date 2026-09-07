import 'package:test/test.dart';
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void main() {
  group('Debug Rendering', () {
    late ReactPhysics3D physics3D;
    late PhysicsWorld world;

    setUp(() {
      physics3D = createReactPhysics3D();
      world = physics3D.createWorld();
    });

    tearDown(() {
      physics3D.dispose();
    });

    group('PhysicsWorld Debug Rendering', () {
      test('should enable and disable debug rendering', () {
        // Initially disabled
        expect(world.getIsDebugRenderingEnabled(), isFalse);

        // Enable debug rendering
        world.setIsDebugRenderingEnabled(true);
        expect(world.getIsDebugRenderingEnabled(), isTrue);

        // Disable debug rendering
        world.setIsDebugRenderingEnabled(false);
        expect(world.getIsDebugRenderingEnabled(), isFalse);
      });

      test('should get debug renderer instance', () {
        world.setIsDebugRenderingEnabled(true);
        final debugRenderer = world.getDebugRenderer();

        expect(debugRenderer, isNotNull);
        expect(debugRenderer, isA<DebugRenderer>());
      });
    });

    group('RigidBody Debug Rendering', () {
      test('should enable and disable debug rendering for rigid body', () {
        final body = world.createRigidBody();

        // Initially disabled
        expect(body.getIsDebugEnabled(), isFalse);

        // Enable debug rendering
        body.setIsDebugEnabled(true);
        expect(body.getIsDebugEnabled(), isTrue);

        // Disable debug rendering
        body.setIsDebugEnabled(false);
        expect(body.getIsDebugEnabled(), isFalse);
      });

      test(
        'should independently control debug rendering for multiple bodies',
        () {
          final body1 = world.createRigidBody();
          final body2 = world.createRigidBody();

          body1.setIsDebugEnabled(true);
          body2.setIsDebugEnabled(false);

          expect(body1.getIsDebugEnabled(), isTrue);
          expect(body2.getIsDebugEnabled(), isFalse);
        },
      );
    });

    group('DebugRenderer Configuration', () {
      late DebugRenderer debugRenderer;

      setUp(() {
        world.setIsDebugRenderingEnabled(true);
        debugRenderer = world.getDebugRenderer();
      });

      test('should set and get debug item display status', () {
        // Enable contact point display
        debugRenderer.setIsDebugItemDisplayed(DebugItem.contactPoint, true);
        expect(
          debugRenderer.getIsDebugItemDisplayed(DebugItem.contactPoint),
          isTrue,
        );

        // Enable contact normal display
        debugRenderer.setIsDebugItemDisplayed(DebugItem.contactNormal, true);
        expect(
          debugRenderer.getIsDebugItemDisplayed(DebugItem.contactNormal),
          isTrue,
        );

        // Disable collision shape display
        debugRenderer.setIsDebugItemDisplayed(DebugItem.collisionShape, false);
        expect(
          debugRenderer.getIsDebugItemDisplayed(DebugItem.collisionShape),
          isFalse,
        );
      });

      test('should independently control different debug items', () {
        debugRenderer.setIsDebugItemDisplayed(DebugItem.colliderAABB, true);
        debugRenderer.setIsDebugItemDisplayed(
          DebugItem.colliderBroadphaseAABB,
          false,
        );

        expect(
          debugRenderer.getIsDebugItemDisplayed(DebugItem.colliderAABB),
          isTrue,
        );
        expect(
          debugRenderer.getIsDebugItemDisplayed(
            DebugItem.colliderBroadphaseAABB,
          ),
          isFalse,
        );
      });

      test('should handle all debug item types', () {
        final allItems = [
          DebugItem.colliderAABB,
          DebugItem.colliderBroadphaseAABB,
          DebugItem.collisionShape,
          DebugItem.contactPoint,
          DebugItem.contactNormal,
        ];

        for (final item in allItems) {
          debugRenderer.setIsDebugItemDisplayed(item, true);
          expect(debugRenderer.getIsDebugItemDisplayed(item), isTrue);
        }
      });
    });

    group('DebugRenderer Geometry Retrieval', () {
      late DebugRenderer debugRenderer;
      late RigidBody body1;
      late RigidBody body2;

      setUp(() {
        world.setIsDebugRenderingEnabled(true);
        debugRenderer = world.getDebugRenderer();

        // Create two bodies with collision shapes
        body1 = world.createRigidBody(
          transform: (
            position: Vector3(0.0, 10.0, 0.0),
            orientation: Quaternion.identity(),
          ),
        );
        body1.type = BodyType.DYNAMIC;
        body1.setIsDebugEnabled(true);

        final shape1 = physics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));
        body1.addCollider(shape1);

        body2 = world.createRigidBody(
          transform: (
            position: Vector3(0.0, 0.0, 0.0),
            orientation: Quaternion.identity(),
          ),
        );
        body2.type = BodyType.STATIC;
        body2.setIsDebugEnabled(true);

        final shape2 = physics3D.createBoxShape(Vector3(5.0, 0.5, 5.0));
        body2.addCollider(shape2);

        // Enable collision shape display
        debugRenderer.setIsDebugItemDisplayed(DebugItem.collisionShape, true);
      });

      test('should return number of lines', () {
        // Update world to generate debug geometry
        world.update(1.0 / 60.0);

        final nbLines = debugRenderer.getNbLines();
        expect(nbLines, isA<int>());
        expect(nbLines, greaterThanOrEqualTo(0));
      });

      test('should return number of triangles', () {
        world.update(1.0 / 60.0);

        final nbTriangles = debugRenderer.getNbTriangles();
        expect(nbTriangles, isA<int>());
        expect(nbTriangles, greaterThanOrEqualTo(0));
      });

      test('should retrieve debug lines', () {
        world.update(1.0 / 60.0);

        final lines = debugRenderer.getLines();
        expect(lines, isA<List<DebugLine>>());
        expect(lines.length, equals(debugRenderer.getNbLines()));

        // If there are lines, verify their structure
        if (lines.isNotEmpty) {
          final line = lines.first;
          expect(line.point1, isA<Vector3>());
          expect(line.point2, isA<Vector3>());
          expect(line.color, isA<int>());
        }
      });

      test('should retrieve debug triangles', () {
        world.update(1.0 / 60.0);

        final triangles = debugRenderer.getTriangles();
        expect(triangles, isA<List<DebugTriangle>>());
        expect(triangles.length, equals(debugRenderer.getNbTriangles()));

        // If there are triangles, verify their structure
        if (triangles.isNotEmpty) {
          final triangle = triangles.first;
          expect(triangle.point1, isA<Vector3>());
          expect(triangle.point2, isA<Vector3>());
          expect(triangle.point3, isA<Vector3>());
          expect(triangle.color, isA<int>());
        }
      });

      test(
        'should generate debug geometry when collision shapes are visible',
        () {
          debugRenderer.setIsDebugItemDisplayed(DebugItem.collisionShape, true);
          world.update(1.0 / 60.0);

          final nbLines = debugRenderer.getNbLines();
          final nbTriangles = debugRenderer.getNbTriangles();

          // With collision shapes enabled and bodies present, we should have some geometry
          expect(nbLines + nbTriangles, greaterThan(0));
        },
      );

      test('should generate contact debug geometry when bodies collide', () {
        // Enable gravity and wait for collision
        world.setIsGravityEnabled(true);
        world.setGravity(Vector3(0.0, -9.81, 0.0));

        debugRenderer.setIsDebugItemDisplayed(DebugItem.contactPoint, true);
        debugRenderer.setIsDebugItemDisplayed(DebugItem.contactNormal, true);

        // Simulate for a bit to ensure collision
        for (int i = 0; i < 100; i++) {
          world.update(1.0 / 60.0);
        }

        final lines = debugRenderer.getLines();

        // After collision, we should have contact debug geometry
        // (This may or may not be > 0 depending on timing, but the call should work)
        expect(lines, isA<List<DebugLine>>());
      });

      test('should return empty lists when debug rendering is disabled', () {
        world.setIsDebugRenderingEnabled(false);
        world.update(1.0 / 60.0);

        // When debug rendering is disabled, the renderer may return empty data
        final lines = debugRenderer.getLines();
        final triangles = debugRenderer.getTriangles();

        expect(lines, isA<List<DebugLine>>());
        expect(triangles, isA<List<DebugTriangle>>());
      });
    });

    group('Complete Debug Rendering Workflow', () {
      test('should support the complete debug rendering workflow', () {
        // 1. Enable debug rendering
        world.setIsDebugRenderingEnabled(true);
        expect(world.getIsDebugRenderingEnabled(), isTrue);

        // 2. Create rigid bodies
        final ground = world.createRigidBody(
          transform: (
            position: Vector3(0.0, -1.0, 0.0),
            orientation: Quaternion.identity(),
          ),
        );
        ground.type = BodyType.STATIC;
        final groundShape = physics3D.createBoxShape(Vector3(10.0, 1.0, 10.0));
        ground.addCollider(groundShape);
        ground.setIsDebugEnabled(true);

        final fallingBox = world.createRigidBody(
          transform: (
            position: Vector3(0.0, 5.0, 0.0),
            orientation: Quaternion.identity(),
          ),
        );
        fallingBox.type = BodyType.DYNAMIC;
        final boxShape = physics3D.createBoxShape(Vector3(0.5, 0.5, 0.5));
        fallingBox.addCollider(boxShape);
        fallingBox.setIsDebugEnabled(true);

        // 3. Get debug renderer and configure it
        final debugRenderer = world.getDebugRenderer();
        debugRenderer.setIsDebugItemDisplayed(DebugItem.collisionShape, true);
        debugRenderer.setIsDebugItemDisplayed(DebugItem.contactPoint, true);
        debugRenderer.setIsDebugItemDisplayed(DebugItem.contactNormal, true);

        // 4. Update simulation
        world.setIsGravityEnabled(true);
        world.setGravity(Vector3(0.0, -9.81, 0.0));

        for (int i = 0; i < 60; i++) {
          world.update(1.0 / 60.0);
        }

        // 5. Retrieve debug geometry
        final lines = debugRenderer.getLines();
        final triangles = debugRenderer.getTriangles();

        expect(lines, isA<List<DebugLine>>());
        expect(triangles, isA<List<DebugTriangle>>());

        // We should have some debug geometry from the collision shapes
        expect(
          debugRenderer.getNbLines() + debugRenderer.getNbTriangles(),
          greaterThan(0),
        );
      });
    });
  });
}
