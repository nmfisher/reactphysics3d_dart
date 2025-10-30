import 'package:reactphysics3d_dart/src/implementation/ffi_collision_shape.dart';
import 'package:test/test.dart';

import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void main() {
  group('ReactPhysics3D', () {
    late ReactPhysics3D physics3D;

    setUp(() {
      physics3D = createReactPhysics3D();
    });

    tearDown(() {});

    group('createWorld', () {
      test('should create a PhysicsWorld instance', () {
        final world = physics3D.createWorld();
        expect(world, isNotNull);
        expect(world, isA<PhysicsWorld>());
      });

      test('should create multiple distinct world instances', () {
        final world1 = physics3D.createWorld();
        final world2 = physics3D.createWorld();

        expect(world1, isNot(equals(world2)));
        expect(world1, isA<PhysicsWorld>());
        expect(world2, isA<PhysicsWorld>());
      });
    });

    group('shape creation methods', () {
      test('createBoxShape should create a BoxShape with given extent', () {
        final extent = Vector3(2.0, 3.0, 4.0);
        final boxShape = physics3D.createBoxShape(extent);

        expect(boxShape, isNotNull);
        expect(boxShape, isA<BoxShape>());
      });

      test('createBoxShape should handle zero extent', () {
        final extent = Vector3.zero();
        final boxShape = physics3D.createBoxShape(extent);

        expect(boxShape, isNotNull);
        expect(boxShape, isA<BoxShape>());
      });

      test('createBoxShape should handle negative extent values', () {
        final extent = Vector3(-1.0, -2.0, -3.0);
        final boxShape = physics3D.createBoxShape(extent);

        expect(boxShape, isNotNull);
        expect(boxShape, isA<BoxShape>());
      });

      test(
        'createSphereShape should create a SphereShape with given radius',
        () {
          const radius = 2.5;
          final sphereShape = physics3D.createSphereShape(radius);

          expect(sphereShape, isNotNull);
          expect(sphereShape, isA<SphereShape>());
        },
      );

      test('createSphereShape should handle zero radius', () {
        const radius = 0.0;
        final sphereShape = physics3D.createSphereShape(radius);

        expect(sphereShape, isNotNull);
        expect(sphereShape, isA<SphereShape>());
      });

      test('createSphereShape should handle negative radius', () {
        const radius = -1.5;
        final sphereShape = physics3D.createSphereShape(radius);

        expect(sphereShape, isNotNull);
        expect(sphereShape, isA<SphereShape>());
      });

      test(
        'createCapsuleShape should create a CapsuleShape with given radius and height',
        () {
          const radius = 1.0;
          const height = 3.0;
          final capsuleShape = physics3D.createCapsuleShape(radius, height);

          expect(capsuleShape, isNotNull);
          expect(capsuleShape, isA<CapsuleShape>());
        },
      );

      test('createCapsuleShape should handle zero radius and height', () {
        const radius = 0.0;
        const height = 0.0;
        final capsuleShape = physics3D.createCapsuleShape(radius, height);

        expect(capsuleShape, isNotNull);
        expect(capsuleShape, isA<CapsuleShape>());
      });

      test('createCapsuleShape should handle negative radius and height', () {
        const radius = -1.0;
        const height = -2.0;
        final capsuleShape = physics3D.createCapsuleShape(radius, height);

        expect(capsuleShape, isNotNull);
        expect(capsuleShape, isA<CapsuleShape>());
      });
    });

    group('createRigidBody', () {
      late PhysicsWorld world;

      setUp(() {
        world = physics3D.createWorld();
      });

      tearDown(() {
        // Note: World cleanup would be handled by dispose() in main tearDown
      });

      test('should create a RigidBody with default parameters', () {
        final rigidBody = physics3D.createRigidBody(world);
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        // Default type should be DYNAMIC
        expect(rigidBody.type, equals(BodyType.DYNAMIC));
      });

      test('should create a RigidBody with identity transform', () {
        final transform = TransformIdentity.identity();
        final rigidBody = physics3D.createRigidBody(
          world,
          transform: transform,
        );
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
      });

      test('should create a RigidBody with custom mass', () {
        const customMass = 5.5;
        final rigidBody = physics3D.createRigidBody(world, mass: customMass);
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        expect(rigidBody.mass, equals(customMass));
      });

      test('should create a RigidBody with static body type', () {
        final rigidBody = physics3D.createRigidBody(
          world,
          type: BodyType.STATIC,
        );
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        expect(rigidBody.type, equals(BodyType.STATIC));
        expect(rigidBody.transform.position.x, 0.0);
        expect(rigidBody.transform.position.y, 0.0);
        expect(rigidBody.transform.position.z, 0.0);
      });

      test('should create a RigidBody with kinematic body type', () {
        final rigidBody = physics3D.createRigidBody(
          world,
          type: BodyType.KINEMATIC,
        );
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        expect(rigidBody.type, equals(BodyType.KINEMATIC));
        expect(rigidBody.transform.position.x, 0.0);
        expect(rigidBody.transform.position.y, 0.0);
        expect(rigidBody.transform.position.z, 0.0);
      });

      test('should create a RigidBody with dynamic body type (default)', () {
        final rigidBody = physics3D.createRigidBody(
          world,
          type: BodyType.DYNAMIC,
        );
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        expect(rigidBody.type, equals(BodyType.DYNAMIC));

        expect(rigidBody.transform.position.x, 0.0);
        expect(rigidBody.transform.position.y, 0.0);
        expect(rigidBody.transform.position.z, 0.0);
      });

      test('should create a RigidBody with all custom parameters', () {
        final transform = TransformIdentity.identity();
        const customMass = 10.0;
        final rigidBody = physics3D.createRigidBody(
          world,
          transform: transform,
          type: BodyType.DYNAMIC,
          mass: customMass,
        );
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        expect(rigidBody.mass, equals(customMass));
      });

      test('should create multiple distinct RigidBody instances', () {
        final rigidBody1 = physics3D.createRigidBody(world);
        final rigidBody2 = physics3D.createRigidBody(world);

        expect(rigidBody1, isNotNull);
        expect(rigidBody1, isA<RigidBody>());
        expect(rigidBody2, isNotNull);
        expect(rigidBody2, isA<RigidBody>());
        expect(rigidBody1, isNot(equals(rigidBody2)));
      });

      test('should add collider', () {
        final rigidBody = physics3D.createRigidBody(world, type: BodyType.DYNAMIC);
        final shape = physics3D.createBoxShape(Vector3.all(1));
        final collider = rigidBody.addCollider(shape);
        expect(rigidBody.transform.position.x, 0.0);
        expect(rigidBody.transform.position.y, 0.0);
        expect(rigidBody.transform.position.z, 0.0);
      });


      test('should set scale on height field shape', () {
        const rows = 2;
        const columns = 2;
        final heights = [1.0, 1.5, 1.5, 2.0];
        const minHeight = 0.0;
        const maxHeight = 3.0;

        final heightField = physics3D.createHeightField(
          rows: rows,
          columns: columns,
          heights: heights,
          minHeight: minHeight,
          maxHeight: maxHeight,
        );

        final heightFieldShape = physics3D.createHeightFieldShape(heightField);
        final scale = Vector3(2.0, 1.0, 2.0);

        // Should not throw any exceptions
        expect(() => heightFieldShape.setScale(scale), returnsNormally);
      });
    });

    group('dispose', () {
      test('should create objects without throwing exceptions', () {
        final testPhysics3D = createReactPhysics3D();

        // Create some objects first (skip RigidBody since it's not implemented yet)
        final world = testPhysics3D.createWorld();
        final boxShape = testPhysics3D.createBoxShape(Vector3(1.0, 1.0, 1.0));

        // Verify objects were created successfully
        expect(world, isNotNull);
        expect(boxShape, isNotNull);

        // Verify RigidBody creation works
        final rigidBody = testPhysics3D.createRigidBody(world);
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
      });
    });

    group('heightfield creation methods', () {
      test('createHeightField should create a HeightField with given data', () {
        const rows = 3;
        const columns = 3;
        final heights = [1.0, 2.0, 1.0, 2.0, 3.0, 2.0, 1.0, 2.0, 1.0];
        const minHeight = 0.0;
        const maxHeight = 4.0;

        final heightField = physics3D.createHeightField(
          rows: rows,
          columns: columns,
          heights: heights,
          minHeight: minHeight,
          maxHeight: maxHeight,
        );

        expect(heightField, isNotNull);
        expect(heightField, isA<HeightField>());
      });

      test(
        'createHeightFieldShape should create a HeightFieldShape from HeightField',
        () {
          const rows = 2;
          const columns = 2;
          final heights = [1.0, 1.5, 1.5, 2.0];
          const minHeight = 0.0;
          const maxHeight = 3.0;

          final heightField = physics3D.createHeightField(
            rows: rows,
            columns: columns,
            heights: heights,
            minHeight: minHeight,
            maxHeight: maxHeight,
          );

          final heightFieldShape = physics3D.createHeightFieldShape(
            heightField,
          );

          expect(heightFieldShape, isNotNull);
          expect(heightFieldShape, isA<HeightFieldShape>());
        },
      );

      test('createHeightField should handle invalid input', () {
        expect(
          () => physics3D.createHeightField(
            rows: 0,
            columns: 2,
            heights: [1.0, 2.0],
            minHeight: 0.0,
            maxHeight: 3.0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => physics3D.createHeightField(
            rows: 2,
            columns: 2,
            heights: [1.0], // Incorrect length
            minHeight: 0.0,
            maxHeight: 3.0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('heightfield shape should provide vertex access', () {
        const rows = 3;
        const columns = 3;
        final heights = [1.0, 2.0, 1.0, 2.0, 3.0, 2.0, 1.0, 2.0, 1.0];
        const minHeight = 0.0;
        const maxHeight = 4.0;

        final heightField = physics3D.createHeightField(
          rows: rows,
          columns: columns,
          heights: heights,
          minHeight: minHeight,
          maxHeight: maxHeight,
        );

        final heightFieldShape = physics3D.createHeightFieldShape(heightField);

        // Test getting vertex at a valid position
        final vertex = heightFieldShape.getVertexAt(1, 1);
        expect(vertex, isNotNull);
        expect(vertex, isA<Vector3>());
      });
    });

    group('integration tests', () {
      test('should create complete physics simulation setup', () {
        final world = physics3D.createWorld();
        final boxShape = physics3D.createBoxShape(Vector3(2.0, 2.0, 2.0));
        final sphereShape = physics3D.createSphereShape(1.5);
        final capsuleShape = physics3D.createCapsuleShape(1.0, 3.0);

        final transform1 = TransformIdentity.identity();
        final transform2 = TransformIdentity.identity();
        final transform3 = TransformIdentity.identity();

        expect(world, isNotNull);
        expect(boxShape, isNotNull);
        expect(sphereShape, isNotNull);
        expect(capsuleShape, isNotNull);

        // Verify that RigidBody creation works
        final rigidBody1 = physics3D.createRigidBody(
          world,
          transform: transform1,
          mass: 2.0,
        );
        final rigidBody2 = physics3D.createRigidBody(
          world,
          transform: transform2,
          mass: 1.5,
          type: BodyType.DYNAMIC,
        );
        final rigidBody3 = physics3D.createRigidBody(
          world,
          transform: transform3,
          type: BodyType.KINEMATIC,
        );

        expect(rigidBody1, isNotNull);
        expect(rigidBody1, isA<RigidBody>());
        expect(rigidBody1.mass, equals(2.0));

        expect(rigidBody2, isNotNull);
        expect(rigidBody2, isA<RigidBody>());
        expect(rigidBody2.mass, equals(1.5));

        expect(rigidBody3, isNotNull);
        expect(rigidBody3, isA<RigidBody>());
      });
    });

    group('PhysicsWorld methods', () {
      late PhysicsWorld world;

      setUp(() {
        world = physics3D.createWorld();
      });

      test(
        'setIsGravityEnabled should enable/disable gravity without throwing',
        () {
          // Should not throw any exceptions
          expect(() => world.setIsGravityEnabled(true), returnsNormally);
          expect(() => world.setIsGravityEnabled(false), returnsNormally);
        },
      );

      test(
        'enableSleeping should enable/disable sleeping technique without throwing',
        () {
          // Should not throw any exceptions
          expect(() => world.enableSleeping(true), returnsNormally);
          expect(() => world.enableSleeping(false), returnsNormally);
        },
      );

      test(
        'setSleepLinearVelocity should set sleep linear velocity without throwing',
        () {
          const sleepVelocity = 0.02;
          // Should not throw any exceptions
          expect(
            () => world.setSleepLinearVelocity(sleepVelocity),
            returnsNormally,
          );
        },
      );

      test(
        'setSleepAngularVelocity should set sleep angular velocity without throwing',
        () {
          const sleepVelocity = 3.0 * (3.14159 / 180.0); // 3 degrees in radians
          // Should not throw any exceptions
          expect(
            () => world.setSleepAngularVelocity(sleepVelocity),
            returnsNormally,
          );
        },
      );

      test(
        'setTimeBeforeSleep should set time before sleep without throwing',
        () {
          const timeBeforeSleep = 1.0;
          // Should not throw any exceptions
          expect(
            () => world.setTimeBeforeSleep(timeBeforeSleep),
            returnsNormally,
          );
        },
      );

      test('getNbRigidBodies should return zero for new world', () {
        final nbRigidBodies = world.getNbRigidBodies();
        expect(nbRigidBodies, isA<int>());
        expect(
          nbRigidBodies,
          equals(0),
        ); // New world should have no rigid bodies
      });
    });

    group('RigidBody gravity control', () {
      late PhysicsWorld world;

      setUp(() {
        world = physics3D.createWorld();
      });

      tearDown(() {
        // Note: World cleanup would be handled by dispose() in main tearDown
      });

      test('should create rigid body with gravity enabled by default', () {
        final rigidBody = physics3D.createRigidBody(world);
        expect(rigidBody.isGravityEnabled, isTrue);
      });

      test('should disable gravity for rigid body', () {
        final rigidBody = physics3D.createRigidBody(world);

        // Disable gravity
        rigidBody.enableGravity(false);
        expect(rigidBody.isGravityEnabled, isFalse);
      });

      test('should re-enable gravity for rigid body', () {
        final rigidBody = physics3D.createRigidBody(world);

        // Disable gravity first
        rigidBody.enableGravity(false);
        expect(rigidBody.isGravityEnabled, isFalse);

        // Re-enable gravity
        rigidBody.enableGravity(true);
        expect(rigidBody.isGravityEnabled, isTrue);
      });

      test('should support gravity control via property setter', () {
        final rigidBody = physics3D.createRigidBody(world);

        // Test property getter
        expect(rigidBody.isGravityEnabled, isTrue);

        // Test property setter
        rigidBody.isGravityEnabled = false;
        expect(rigidBody.isGravityEnabled, isFalse);

        rigidBody.isGravityEnabled = true;
        expect(rigidBody.isGravityEnabled, isTrue);
      });

      test('should handle multiple rigid bodies with independent gravity settings', () {
        final rigidBody1 = physics3D.createRigidBody(world);
        final rigidBody2 = physics3D.createRigidBody(world);
        final rigidBody3 = physics3D.createRigidBody(world);

        // All should start with gravity enabled
        expect(rigidBody1.isGravityEnabled, isTrue);
        expect(rigidBody2.isGravityEnabled, isTrue);
        expect(rigidBody3.isGravityEnabled, isTrue);

        // Disable gravity for body 2 only
        rigidBody2.enableGravity(false);

        expect(rigidBody1.isGravityEnabled, isTrue);
        expect(rigidBody2.isGravityEnabled, isFalse);
        expect(rigidBody3.isGravityEnabled, isTrue);

        // Enable gravity for body 3 only (should remain enabled)
        rigidBody3.enableGravity(true);

        expect(rigidBody1.isGravityEnabled, isTrue);
        expect(rigidBody2.isGravityEnabled, isFalse);
        expect(rigidBody3.isGravityEnabled, isTrue);
      });
    });
  });
}
