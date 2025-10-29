import 'package:test/test.dart';

import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

void main() {
  group('ReactPhysics3D', () {
    late ReactPhysics3D physics3D;

    setUp(() {
      physics3D = createReactPhysics3D();
    });

    tearDown(() {
      // Note: Dispose is not yet available in abstract interface
      // Would need to add dispose() method to ReactPhysics3D interface
    });

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

      test('createSphereShape should create a SphereShape with given radius', () {
        const radius = 2.5;
        final sphereShape = physics3D.createSphereShape(radius);

        expect(sphereShape, isNotNull);
        expect(sphereShape, isA<SphereShape>());
      });

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

      test('createCapsuleShape should create a CapsuleShape with given radius and height', () {
        const radius = 1.0;
        const height = 3.0;
        final capsuleShape = physics3D.createCapsuleShape(radius, height);

        expect(capsuleShape, isNotNull);
        expect(capsuleShape, isA<CapsuleShape>());
      });

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
        final rigidBody = physics3D.createRigidBody(world, transform: transform);
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
      });

      test('should create a RigidBody with kinematic body type', () {
        final rigidBody = physics3D.createRigidBody(
          world,
          type: BodyType.KINEMATIC,
        );
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        expect(rigidBody.type, equals(BodyType.KINEMATIC));
      });

      test('should create a RigidBody with dynamic body type (default)', () {
        final rigidBody = physics3D.createRigidBody(
          world,
          type: BodyType.DYNAMIC,
        );
        expect(rigidBody, isNotNull);
        expect(rigidBody, isA<RigidBody>());
        expect(rigidBody.type, equals(BodyType.DYNAMIC));
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

      test('setIsGravityEnabled should enable/disable gravity without throwing', () {
        // Should not throw any exceptions
        expect(() => world.setIsGravityEnabled(true), returnsNormally);
        expect(() => world.setIsGravityEnabled(false), returnsNormally);
      });

      test('enableSleeping should enable/disable sleeping technique without throwing', () {
        // Should not throw any exceptions
        expect(() => world.enableSleeping(true), returnsNormally);
        expect(() => world.enableSleeping(false), returnsNormally);
      });

      test('setSleepLinearVelocity should set sleep linear velocity without throwing', () {
        const sleepVelocity = 0.02;
        // Should not throw any exceptions
        expect(() => world.setSleepLinearVelocity(sleepVelocity), returnsNormally);
      });

      test('setSleepAngularVelocity should set sleep angular velocity without throwing', () {
        const sleepVelocity = 3.0 * (3.14159 / 180.0); // 3 degrees in radians
        // Should not throw any exceptions
        expect(() => world.setSleepAngularVelocity(sleepVelocity), returnsNormally);
      });

      test('setTimeBeforeSleep should set time before sleep without throwing', () {
        const timeBeforeSleep = 1.0;
        // Should not throw any exceptions
        expect(() => world.setTimeBeforeSleep(timeBeforeSleep), returnsNormally);
      });

      test('getNbRigidBodies should return zero for new world', () {
        final nbRigidBodies = world.getNbRigidBodies();
        expect(nbRigidBodies, isA<int>());
        expect(nbRigidBodies, equals(0)); // New world should have no rigid bodies
      });

    });
  });
}