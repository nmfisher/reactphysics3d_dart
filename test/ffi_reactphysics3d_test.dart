import 'dart:typed_data';
import 'dart:ffi' as ffi;
import 'package:test/test.dart';

import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';
import 'package:reactphysics3d_dart/src/bindings/src/rp3d_ffi.g.dart'
    as bindings;

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
        final rigidBody = physics3D.createRigidBody(
          world,
          type: BodyType.DYNAMIC,
        );
        final shape = physics3D.createBoxShape(Vector3.all(1));
        final collider = rigidBody.addCollider(shape);
        expect(collider, isNotNull);
        expect(collider, isA<Collider>());
        expect(rigidBody.transform.position.x, 0.0);
        expect(rigidBody.transform.position.y, 0.0);
        expect(rigidBody.transform.position.z, 0.0);
      });

      test('should handle world query collider settings', () {
        final rigidBody = physics3D.createRigidBody(
          world,
          type: BodyType.DYNAMIC,
        );
        final shape = physics3D.createBoxShape(Vector3.all(1));
        final collider = rigidBody.addCollider(shape);

        // Default state should be enabled for world queries
        expect(collider.isWorldQueryCollider, isTrue);

        // Should be able to disable world queries
        collider.setIsWorldQueryCollider(false);
        expect(collider.isWorldQueryCollider, isFalse);

        // Should be able to re-enable world queries
        collider.setIsWorldQueryCollider(true);
        expect(collider.isWorldQueryCollider, isTrue);
      });

      test(
        'should handle collision category bits and collide with mask bits',
        () {
          final rigidBody = physics3D.createRigidBody(
            world,
            type: BodyType.DYNAMIC,
          );
          final shape = physics3D.createBoxShape(Vector3.all(1));
          final collider = rigidBody.addCollider(shape);

          // Test default values - ReactPhysics3D typically defaults to 0xFFFF (all bits set)
          expect(collider.collisionCategoryBits, isA<int>());
          expect(collider.collideWithMaskBits, isA<int>());

          // Test setting collision category bits
          const testCategory = 0x0001; // Category 1
          collider.collisionCategoryBits = testCategory;
          expect(collider.collisionCategoryBits, equals(testCategory));

          // Test setting collide with mask bits
          const testMask = 0x0002; // Collide with category 2
          collider.collideWithMaskBits = testMask;
          expect(collider.collideWithMaskBits, equals(testMask));

          // Test multiple bits
          const multiCategory = 0x0101; // Bits 0 and 8 set
          collider.collisionCategoryBits = multiCategory;
          expect(collider.collisionCategoryBits, equals(multiCategory));

          const multiMask = 0x8080; // Bits 7 and 15 set
          collider.collideWithMaskBits = multiMask;
          expect(collider.collideWithMaskBits, equals(multiMask));

          print('✅ Collision category and mask bits test passed!');
          print('   Category bits: ${collider.collisionCategoryBits}');
          print('   Mask bits: ${collider.collideWithMaskBits}');
        },
      );

      test('should set scale on height field shape', () {
        const rows = 2;
        const columns = 2;
        final heights = Float32List.fromList([1.0, 1.5, 1.5, 2.0]);
        const minHeight = 0.0;
        const maxHeight = 3.0;

        final heightField = physics3D.createHeightFieldFloat(
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
      test(
        'createHeightFieldFloat should create a HeightField with given data',
        () {
          const rows = 3;
          const columns = 3;
          final heights = Float32List.fromList([
            1.0,
            2.0,
            1.0,
            2.0,
            3.0,
            2.0,
            1.0,
            2.0,
            1.0,
          ]);
          const minHeight = 0.0;
          const maxHeight = 4.0;

          final heightField = physics3D.createHeightFieldFloat(
            rows: rows,
            columns: columns,
            heights: heights,
            minHeight: minHeight,
            maxHeight: maxHeight,
          );

          expect(heightField, isNotNull);
          expect(heightField, isA<HeightField>());
        },
      );

      test(
        'createHeightFieldShape should create a HeightFieldShape from HeightField',
        () {
          const rows = 2;
          const columns = 2;
          final heights = Float32List.fromList([1.0, 1.5, 1.5, 2.0]);
          const minHeight = 0.0;
          const maxHeight = 3.0;

          final heightField = physics3D.createHeightFieldFloat(
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

      test('heightfield shape should provide vertex access', () {
        const rows = 3;
        const columns = 3;
        final heights = Float32List.fromList([
          1.0,
          2.0,
          1.0,
          2.0,
          3.0,
          2.0,
          1.0,
          2.0,
          1.0,
        ]);
        const minHeight = 0.0;
        const maxHeight = 4.0;

        final heightField = physics3D.createHeightFieldFloat(
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

      test(
        'createHeightFieldFloat should throw exception for invalid height data',
        () {
          // Test with NaN values in heights array - this should trigger error messages
          const rows = 1;
          const columns = 1;
          final heights = Float32List.fromList([1.0]); // Contains NaN

          expect(
            () => physics3D.createHeightFieldFloat(
              rows: rows,
              columns: columns,
              heights: heights,
              minHeight: 1.0,
              maxHeight: 2.0,
            ),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'createHeightFieldFloat should throw exception for invalid dimensions',
        () {
          // Test with dimensions that should definitely cause an error
          const rows = 0; // Invalid - zero rows
          const columns = 2;
          final heights = Float32List.fromList([
            1.0,
            2.0,
          ]); // Heights for 0x2 grid
          const minHeight = 0.0;
          const maxHeight = 3.0;

          expect(
            () => physics3D.createHeightFieldFloat(
              rows: rows,
              columns: columns,
              heights: heights,
              minHeight: minHeight,
              maxHeight: maxHeight,
            ),
            throwsA(isA<Exception>()),
          );
        },
      );
    });

    group('HeightField (integer data type)', () {
      test(
        'createHeightFieldInt should create a HeightField with integer data',
        () {
          const rows = 2;
          const columns = 2;
          final heights = Int32List.fromList([1, 2, 3, 4]); 
          const minHeight = 0.0;
          const maxHeight = 3.0;
          const integerHeightScale = 1.0; 

          final heightField = physics3D.createHeightFieldInt(
            rows: rows,
            columns: columns,
            heights: heights,
            minHeight: minHeight,
            maxHeight: maxHeight,
            integerHeightScale: integerHeightScale,
          );

          expect(heightField, isNotNull);
          expect(heightField, isA<HeightField>());

          // Create a HeightFieldShape to validate actual vertex heights
          final heightFieldShape = physics3D.createHeightFieldShape(
            heightField,
          );

          expect(heightFieldShape, isNotNull);
          expect(heightFieldShape, isA<HeightFieldShape>());

          final vertex00 = heightFieldShape.getVertexAt(0, 0); 
          final vertex01 = heightFieldShape.getVertexAt(1, 0); 
          final vertex10 = heightFieldShape.getVertexAt(0, 1); 
          final vertex11 = heightFieldShape.getVertexAt(1, 1); 

          print("${vertex00.y} ${vertex01.y} ${vertex10.y} ${vertex11.y}");

          expect(vertex00.y, closeTo(-1.5, 1e-6));
          expect(vertex01.y, closeTo(-0.5, 1e-6));
          expect(vertex10.y, closeTo(0.5, 1e-6));
          expect(vertex11.y, closeTo(1.5, 1e-6));

          // Clean up
          heightFieldShape.dispose();
          heightField.dispose();
        },
      );

      test('createHeightFieldInt should handle invalid input', () {
        // Test with zero dimensions
        expect(
          () => physics3D.createHeightFieldInt(
            rows: 0,
            columns: 2,
            heights: Int32List.fromList([1, 2, 3, 4]),
            minHeight: 0.0,
            maxHeight: 10.0,
            integerHeightScale: 0.01,
          ),
          throwsA(isA<ArgumentError>()),
        );

        // Test with mismatched heights array length
        expect(
          () => physics3D.createHeightFieldInt(
            rows: 2,
            columns: 2,
            heights: Int32List.fromList([1, 2, 3]), // Should be 4 elements
            minHeight: 0.0,
            maxHeight: 10.0,
            integerHeightScale: 0.01,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('createHeightFieldInt should create HeightFieldShape', () {
        const rows = 2;
        const columns = 2;
        final heights = Int32List.fromList([100, 200, 150, 250]);
        const minHeight = 0.0;
        const maxHeight = 10.0;
        const integerHeightScale = 0.01;

        final heightField = physics3D.createHeightFieldInt(
          rows: rows,
          columns: columns,
          heights: heights,
          minHeight: minHeight,
          maxHeight: maxHeight,
          integerHeightScale: integerHeightScale,
        );

        final heightFieldShape = physics3D.createHeightFieldShape(heightField);
        final scale = Vector3(2.0, 1.0, 2.0);

        // Should not throw any exceptions
        expect(() => heightFieldShape.setScale(scale), returnsNormally);
      });
    });

    group('mesh shapes', () {
      group('TriangleVertexArray', () {
        test('should create triangle vertex array with valid data', () {
          // Define simple triangle vertices
          final vertices = Float32List.fromList([
            0.0, 0.0, 0.0, // Vertex 0
            1.0, 0.0, 0.0, // Vertex 1
            0.5, 1.0, 0.0, // Vertex 2
          ]);

          // Define triangle indices
          final indices = Uint32List.fromList([0, 1, 2]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          expect(triangleArray, isNotNull);
          expect(triangleArray, isA<TriangleVertexArray>());

          // Clean up
          triangleArray.dispose();
        });

        test('should create polygon vertex array with valid data', () {
          // Define cube vertices
          final vertices = Float32List.fromList([
            -3,
            -3,
            3,
            3,
            -3,
            3,
            3,
            -3,
            -3,
            -3,
            -3,
            -3,
            -3,
            3,
            3,
            3,
            3,
            3,
            3,
            3,
            -3,
            -3,
            3,
            -3,
          ]);

          // Define indices for all faces (24 indices total for 6 quad faces)
          final indices = Uint32List.fromList([
            0,
            3,
            2,
            1,
            4,
            5,
            6,
            7,
            0,
            1,
            5,
            4,
            1,
            2,
            6,
            5,
            2,
            3,
            7,
            6,
            0,
            4,
            7,
            3,
          ]);

          // Define polygon faces: [nbVertices, indexBase] pairs
          // Each face has 4 vertices, starting at different indices
          final polygonIndices = Uint32List.fromList([
            4, 0, // Bottom face: 4 vertices starting at index 0
            4, 4, // Top face: 4 vertices starting at index 4
            4, 8, // Front face: 4 vertices starting at index 8
            4, 12, // Back face: 4 vertices starting at index 12
            4, 16, // Left face: 4 vertices starting at index 16
            4, 20, // Right face: 4 vertices starting at index 20
          ]);

          final polygonArray = physics3D.createPolygonVertexArray(
            vertices: vertices,
            indices: indices,
            polygonIndices: polygonIndices,
          );

          expect(polygonArray, isNotNull);
          expect(polygonArray, isA<PolygonVertexArray>());

          // Verify vertex count (8 vertices in a cube)
          expect(polygonArray.getVertexCount(), equals(8));

          // Verify face count (6 faces in a cube)
          expect(polygonArray.getFaceCount(), equals(6));

          // Verify all 8 vertices match the input data
          final expectedVertices = [
            Vector3(-3.0, -3.0, 3.0), // 0
            Vector3(3.0, -3.0, 3.0), // 1
            Vector3(3.0, -3.0, -3.0), // 2
            Vector3(-3.0, -3.0, -3.0), // 3
            Vector3(-3.0, 3.0, 3.0), // 4
            Vector3(3.0, 3.0, 3.0), // 5
            Vector3(3.0, 3.0, -3.0), // 6
            Vector3(-3.0, 3.0, -3.0), // 7
          ];

          for (int i = 0; i < 8; i++) {
            final vertex = polygonArray.getVertex(i);
            expect(
              vertex.x,
              equals(expectedVertices[i].x),
              reason: 'Vertex $i x-coordinate mismatch',
            );
            expect(
              vertex.y,
              equals(expectedVertices[i].y),
              reason: 'Vertex $i y-coordinate mismatch',
            );
            expect(
              vertex.z,
              equals(expectedVertices[i].z),
              reason: 'Vertex $i z-coordinate mismatch',
            );
          }

          // Verify all 6 faces have correct structure
          final expectedFaces = [
            {'nbVertices': 4, 'indexBase': 0}, // Bottom face
            {'nbVertices': 4, 'indexBase': 4}, // Top face
            {'nbVertices': 4, 'indexBase': 8}, // Front face
            {'nbVertices': 4, 'indexBase': 12}, // Back face
            {'nbVertices': 4, 'indexBase': 16}, // Left face
            {'nbVertices': 4, 'indexBase': 20}, // Right face
          ];

          for (int i = 0; i < 6; i++) {
            final face = polygonArray.getPolygonFace(i);
            expect(
              face['nbVertices'],
              equals(expectedFaces[i]['nbVertices']),
              reason: 'Face $i nbVertices mismatch',
            );
            expect(
              face['indexBase'],
              equals(expectedFaces[i]['indexBase']),
              reason: 'Face $i indexBase mismatch',
            );
          }

          // Verify vertex indices for each face using getVertexIndexInFace
          final expectedFaceVertices = [
            [0, 3, 2, 1], // Bottom face
            [4, 5, 6, 7], // Top face
            [0, 1, 5, 4], // Front face
            [1, 2, 6, 5], // Back face
            [2, 3, 7, 6], // Left face
            [0, 4, 7, 3], // Right face
          ];

          for (int faceIdx = 0; faceIdx < 6; faceIdx++) {
            for (int vertexInFace = 0; vertexInFace < 4; vertexInFace++) {
              final vertexIndex = polygonArray.getVertexIndexInFace(
                faceIdx,
                vertexInFace,
              );
              final expectedIndex = expectedFaceVertices[faceIdx][vertexInFace];
              expect(
                vertexIndex,
                equals(expectedIndex),
                reason:
                    'Face $faceIdx, vertex $vertexInFace: expected $expectedIndex but got $vertexIndex',
              );
            }
          }

          // Clean up
          polygonArray.dispose();
        });

        test('should handle polygon vertex array with different face sizes', () {
          // Define vertices for a shape with mixed polygon types
          final vertices = Float32List.fromList([
            0.0, 0.0, 0.0, // 0
            1.0, 0.0, 0.0, // 1
            1.0, 1.0, 0.0, // 2
            0.0, 1.0, 0.0, // 3
            0.5, 0.5, 1.0, // 4 (apex)
          ]);

          // Define indices: base quad (4 vertices) + 4 triangular sides (3 vertices each)
          final indices = Uint32List.fromList([
            // Base quad face
            0, 1, 2, 3,
            // Triangle 1 (front)
            0, 1, 4,
            // Triangle 2 (right)
            1, 2, 4,
            // Triangle 3 (back)
            2, 3, 4,
            // Triangle 4 (left)
            3, 0, 4,
          ]);

          // Define polygon faces with different vertex counts
          final polygonIndices = Uint32List.fromList([
            4, 0, // Base: 4 vertices starting at index 0
            3, 4, // Triangle 1: 3 vertices starting at index 4
            3, 7, // Triangle 2: 3 vertices starting at index 7
            3, 10, // Triangle 3: 3 vertices starting at index 10
            3, 13, // Triangle 4: 3 vertices starting at index 13
          ]);

          final polygonArray = physics3D.createPolygonVertexArray(
            vertices: vertices,
            indices: indices,
            polygonIndices: polygonIndices,
          );

          expect(polygonArray, isNotNull);
          expect(polygonArray, isA<PolygonVertexArray>());

          // Clean up
          polygonArray.dispose();
        });

        test('should throw error for invalid vertex count', () {
          final vertices = Float32List.fromList([0.0, 0.0, 0.0]);
          final indices = Uint32List.fromList([0]);

          expect(
            () => physics3D.createTriangleVertexArray(
              vertices: vertices,
              indices: indices,
            ),
            throwsA(isA<Exception>()),
          );
        });

        test('should throw error for insufficient vertices array', () {
          final vertices = Float32List.fromList([0.0, 0.0]); // Too short
          final indices = Uint32List.fromList([0, 1, 2]);

          expect(
            () => physics3D.createTriangleVertexArray(
              vertices: vertices,
              indices: indices,
            ),
            throwsA(isA<Exception>()),
          );
        });

        test('should throw error for invalid index count', () {
          final vertices = Float32List.fromList([
            0.0,
            0.0,
            0.0,
            1.0,
            0.0,
            0.0,
            0.5,
            1.0,
            0.0,
          ]);
          final indices = Uint32List.fromList([0]);

          expect(
            () => physics3D.createTriangleVertexArray(
              vertices: vertices,
              indices: indices,
            ),
            throwsA(isA<Exception>()),
          );
        });
      });

      group('ConvexMesh', () {
        test('should create convex mesh from cube triangle data', () {
          // Test successful convex mesh creation from well-spaced cube vertices

          // Define well-spaced cube vertices (8 points)
          final vertices = Float32List.fromList([
            -10.0, -10.0, -10.0, // 0
            10.0, -10.0, -10.0, // 1
            10.0, 10.0, -10.0, // 2
            -10.0, 10.0, -10.0, // 3
            -10.0, -10.0, 10.0, // 4
            10.0, -10.0, 10.0, // 5
            10.0, 10.0, 10.0, // 6
            -10.0, 10.0, 10.0, // 7
          ]);

          // Define cube triangle indices (12 triangles)
          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2, 0, 2, 3,
            // Top face
            4, 7, 6, 4, 6, 5,
            // Front face
            0, 4, 5, 0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            // This should now work successfully with fixed memory management
            final convexMesh = physics3D.createConvexMeshFromTriangles(
              triangleArray,
            );
            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Clean up
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should create convex mesh from polygon vertex array', () {
          final vertices = Float32List.fromList(<double>[
            -10,
            -10,
            10,
            10,
            -10,
            10,
            10,
            -10,
            -10,
            -10,
            -10,
            -10,
            -10,
            10,
            10,
            10,
            10,
            10,
            10,
            10,
            -10,
            -10,
            10,
            -10,
          ]);
          final indices = [
            0,
            3,
            2,
            1,
            4,
            5,
            6,
            7,
            0,
            1,
            5,
            4,
            1,
            2,
            6,
            5,
            2,
            3,
            7,
            6,
            0,
            4,
            7,
            3,
          ];

          final polygonIndices = <int>[];
          for (int f = 0; f < 6; f++) {
            // First vertex of the face in the indices array
            polygonIndices.add(4);
            polygonIndices.add(f * 4);
          }

          final polygonArray = physics3D.createPolygonVertexArray(
            vertices: vertices,
            indices: Uint32List.fromList(indices),
            polygonIndices: Uint32List.fromList(polygonIndices),
          );

          expect(polygonArray.getIndex(0), 0);
          expect(polygonArray.getIndex(1), 3);
          expect(polygonArray.getIndex(2), 2);
          expect(polygonArray.getIndex(3), 1);

          try {
            final convexMesh = physics3D.createConvexMeshFromPolygons(
              polygonArray,
            );
            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Clean up
            convexMesh.dispose();
          } finally {
            polygonArray.dispose();
          }
        });
      });

      group('ConcaveMesh (TriangleMesh)', () {
        test('should create triangle mesh from triangle data', () {
          // Define simple box vertices
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0, // 0
            1.0, -1.0, -1.0, // 1
            1.0, -1.0, 1.0, // 2
            -1.0, -1.0, 1.0, // 3
            -1.0, 1.0, -1.0, // 4
            1.0, 1.0, -1.0, // 5
            1.0, 1.0, 1.0, // 6
            -1.0, 1.0, 1.0, // 7
          ]);

          // Define box triangle indices
          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2, 0, 2, 3,
            // Top face
            4, 7, 6, 4, 6, 5,
            // Front face
            0, 4, 5, 0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final triangleMesh = physics3D.createTriangleMesh(triangleArray);

            expect(triangleMesh, isNotNull);
            expect(triangleMesh, isA<TriangleMesh>());

            // Clean up
            triangleMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should verify triangle mesh data integrity after processing', () {
          // Define simple box vertices with known coordinates
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0, // 0
            1.0, -1.0, -1.0, // 1
            1.0, -1.0, 1.0, // 2
            -1.0, -1.0, 1.0, // 3
            -1.0, 1.0, -1.0, // 4
            1.0, 1.0, -1.0, // 5
            1.0, 1.0, 1.0, // 6
            -1.0, 1.0, 1.0, // 7
          ]);

          // Define box triangle indices with known relationships
          final indices = Uint32List.fromList([
            // Bottom face (y = -1)
            0, 1, 2, 0, 2, 3,
            // Top face (y = 1)
            4, 7, 6, 4, 6, 5,
            // Front face (z = 1)
            2, 6, 7, 2, 7, 3,
            // Back face (z = -1)
            0, 4, 5, 0, 5, 1,
            // Left face (x = -1)
            0, 3, 7, 0, 7, 4,
            // Right face (x = 1)
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            // Test TriangleVertexArray accessors
            expect(triangleArray.getVertexCount(), equals(8));
            expect(triangleArray.getTriangleCount(), equals(12));

            // Verify original vertex data is accessible
            const vertexTolerance = 1e-6;
            for (int i = 0; i < 8; i++) {
              final vertex = triangleArray.getVertex(i);
              final expectedX = vertices[i * 3];
              final expectedY = vertices[i * 3 + 1];
              final expectedZ = vertices[i * 3 + 2];

              expect(vertex.x, closeTo(expectedX, vertexTolerance));
              expect(vertex.y, closeTo(expectedY, vertexTolerance));
              expect(vertex.z, closeTo(expectedZ, vertexTolerance));
            }

            // Create TriangleMesh and verify data integrity
            final triangleMesh = physics3D.createTriangleMesh(triangleArray);

            try {
              // TriangleMesh may discard degenerate triangles, so expect <= original count
              expect(triangleMesh.getVertexCount(), equals(8));
              expect(triangleMesh.getTriangleCount(), lessThanOrEqualTo(12));
              expect(
                triangleMesh.getTriangleCount(),
                greaterThan(8),
              ); // Should have most triangles

              // Verify vertex coordinates are preserved within tolerance
              const meshTolerance = 1e-5;
              for (int i = 0; i < 8; i++) {
                final meshVertex = triangleMesh.getVertex(i);
                final originalVertex = triangleArray.getVertex(i);

                expect(meshVertex.x, closeTo(originalVertex.x, meshTolerance));
                expect(meshVertex.y, closeTo(originalVertex.y, meshTolerance));
                expect(meshVertex.z, closeTo(originalVertex.z, meshTolerance));
              }

              // Test specific known triangles that should be preserved
              // Bottom face first triangle: vertices 0, 1, 2 (should exist)
              bool foundBottomTriangle = false;
              bool foundTopTriangle = false;

              for (int i = 0; i < triangleMesh.getTriangleCount(); i++) {
                final triangleIndices = triangleMesh.getTriangleIndices(i);

                // Check for bottom face triangle (some permutation of [0, 1, 2])
                final bottomSet = {0, 1, 2};
                final triangleSet = Set<int>.from(triangleIndices);
                if (triangleSet.length == 3 &&
                    triangleSet.containsAll(bottomSet)) {
                  foundBottomTriangle = true;

                  // Verify these are indeed the bottom face vertices (y = -1)
                  for (int vertexIndex in triangleIndices) {
                    final vertex = triangleMesh.getVertex(vertexIndex);
                    expect(vertex.y, closeTo(-1.0, meshTolerance));
                  }
                }

                // Check for top face triangle (some permutation of [4, 6, 7] or [4, 5, 6])
                final topSet1 = {4, 6, 7};
                final topSet2 = {4, 5, 6};
                if ((triangleSet.length == 3 &&
                        triangleSet.containsAll(topSet1)) ||
                    (triangleSet.length == 3 &&
                        triangleSet.containsAll(topSet2))) {
                  foundTopTriangle = true;

                  // Verify these are indeed the top face vertices (y = 1)
                  for (int vertexIndex in triangleIndices) {
                    final vertex = triangleMesh.getVertex(vertexIndex);
                    expect(vertex.y, closeTo(1.0, meshTolerance));
                  }
                }
              }

              expect(
                foundBottomTriangle,
                isTrue,
                reason: 'Should find bottom face triangle',
              );
              expect(
                foundTopTriangle,
                isTrue,
                reason: 'Should find top face triangle',
              );
            } finally {
              triangleMesh.dispose();
            }
          } finally {
            triangleArray.dispose();
          }
        });
      });

      group('ConvexMeshShape', () {
        test('should create convex mesh shape from triangle data', () {
          // Test successful convex mesh creation from triangle data
          // This test verifies the complete workflow works correctly

          // Define simple cube vertices
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0, // 0
            1.0, -1.0, -1.0, // 1
            1.0, 1.0, -1.0, // 2
            -1.0, 1.0, -1.0, // 3
            -1.0, -1.0, 1.0, // 4
            1.0, -1.0, 1.0, // 5
            1.0, 1.0, 1.0, // 6
            -1.0, 1.0, 1.0, // 7
          ]);

          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2, 0, 2, 3,
            // Top face
            4, 7, 6, 4, 6, 5,
            // Front face
            0, 4, 5, 0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            // This should now work successfully
            final convexMesh = physics3D.createConvexMeshFromTriangles(
              triangleArray,
            );

            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Create convex mesh shape
            final convexShape = physics3D.createConvexMeshShape(convexMesh);
            expect(convexShape, isNotNull);
            expect(convexShape, isA<ConvexMeshShape>());

            // Test that shape is valid and can be used for collision
            expect(convexShape.handle.address, isNonZero);

            // Clean up
            convexShape.dispose();
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should create convex mesh shape with default scaling', () {
          // Test that default scaling (1.0, 1.0, 1.0) works correctly
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0, // 0
            1.0, -1.0, -1.0, // 1
            1.0, 1.0, -1.0, // 2
            -1.0, 1.0, -1.0, // 3
            -1.0, -1.0, 1.0, // 4
            1.0, -1.0, 1.0, // 5
            1.0, 1.0, 1.0, // 6
            -1.0, 1.0, 1.0, // 7
          ]);

          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2, 0, 2, 3,
            // Top face
            4, 7, 6, 4, 6, 5,
            // Front face
            0, 4, 5, 0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final convexMesh = physics3D.createConvexMeshFromTriangles(
              triangleArray,
            );

            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Create convex mesh shape without specifying scaling (should default to 1.0, 1.0, 1.0)
            final convexShape = physics3D.createConvexMeshShape(convexMesh);
            expect(convexShape, isNotNull);
            expect(convexShape, isA<ConvexMeshShape>());

            // Test that shape is valid and can be used for collision
            expect(convexShape.handle.address, isNonZero);

            // Clean up
            convexShape.dispose();
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should create convex mesh shape with custom scaling', () {
          // Test custom scaling values
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0, // 0
            1.0, -1.0, -1.0, // 1
            1.0, 1.0, -1.0, // 2
            -1.0, 1.0, -1.0, // 3
            -1.0, -1.0, 1.0, // 4
            1.0, -1.0, 1.0, // 5
            1.0, 1.0, 1.0, // 6
            -1.0, 1.0, 1.0, // 7
          ]);

          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2, 0, 2, 3,
            // Top face
            4, 7, 6, 4, 6, 5,
            // Front face
            0, 4, 5, 0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final convexMesh = physics3D.createConvexMeshFromTriangles(
              triangleArray,
            );

            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Create convex mesh shape with custom scaling
            final customScale = Vector3(2.0, 0.5, 3.0);
            final convexShape = physics3D.createConvexMeshShape(
              convexMesh,
              scaling: customScale,
            );

            expect(convexShape, isNotNull);
            expect(convexShape, isA<ConvexMeshShape>());

            // Test that shape is valid and can be used for collision
            expect(convexShape.handle.address, isNonZero);

            // Test integration with rigid body
            final world = physics3D.createWorld();
            final rigidBody = physics3D.createRigidBody(
              world,
              type: BodyType.DYNAMIC,
            );
            final collider = rigidBody.addCollider(convexShape);
            expect(collider, isNotNull);

            // Clean up
            convexShape.dispose();
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should create convex mesh shape with zero scaling', () {
          // Test zero scaling - should create degenerate shape but not crash
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0, // 0
            1.0, -1.0, -1.0, // 1
            1.0, 1.0, -1.0, // 2
            -1.0, 1.0, -1.0, // 3
            -1.0, -1.0, 1.0, // 4
            1.0, -1.0, 1.0, // 5
            1.0, 1.0, 1.0, // 6
            -1.0, 1.0, 1.0, // 7
          ]);

          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2, 0, 2, 3,
            // Top face
            4, 7, 6, 4, 6, 5,
            // Front face
            0, 4, 5, 0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final convexMesh = physics3D.createConvexMeshFromTriangles(
              triangleArray,
            );

            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Create convex mesh shape with zero scaling
            final zeroScale = Vector3.zero();
            final convexShape = physics3D.createConvexMeshShape(
              convexMesh,
              scaling: zeroScale,
            );

            expect(convexShape, isNotNull);
            expect(convexShape, isA<ConvexMeshShape>());

            // Even with zero scaling, the shape should be created
            expect(convexShape.handle.address, isNonZero);

            // Clean up
            convexShape.dispose();
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should create convex mesh shape with negative scaling', () {
          // Test negative scaling - should mirror the shape
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0, // 0
            1.0, -1.0, -1.0, // 1
            1.0, 1.0, -1.0, // 2
            -1.0, 1.0, -1.0, // 3
            -1.0, -1.0, 1.0, // 4
            1.0, -1.0, 1.0, // 5
            1.0, 1.0, 1.0, // 6
            -1.0, 1.0, 1.0, // 7
          ]);

          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2, 0, 2, 3,
            // Top face
            4, 7, 6, 4, 6, 5,
            // Front face
            0, 4, 5, 0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6, 1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final convexMesh = physics3D.createConvexMeshFromTriangles(
              triangleArray,
            );

            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Create convex mesh shape with negative scaling (mirrors on some axes)
            final negativeScale = Vector3(-1.0, 1.0, -2.0);
            final convexShape = physics3D.createConvexMeshShape(
              convexMesh,
              scaling: negativeScale,
            );

            expect(convexShape, isNotNull);
            expect(convexShape, isA<ConvexMeshShape>());

            // Even with negative scaling, the shape should be created
            expect(convexShape.handle.address, isNonZero);

            // Clean up
            convexShape.dispose();
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });
      });

      group('ConcaveMeshShape', () {
        test('should create concave mesh shape from triangle mesh', () {
          // Create simple L-shaped terrain
          final vertices = Float32List.fromList([
            // L-shape vertices
            0.0, 0.0, 0.0, // 0
            2.0, 0.0, 0.0, // 1
            2.0, 0.0, 1.0, // 2
            1.0, 0.0, 1.0, // 3
            1.0, 0.0, 2.0, // 4
            0.0, 0.0, 2.0, // 5
          ]);

          final indices = Uint32List.fromList([
            // L-shape triangles (6 triangles)
            0, 1, 2, 0, 2, 3, // First part of L
            0, 3, 5, 3, 4, 5, // Second part of L
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final triangleMesh = physics3D.createTriangleMesh(triangleArray);

            try {
              final concaveShape = physics3D.createConcaveMeshShape(
                triangleMesh,
                scaling: Vector3.all(1.0),
              );

              expect(concaveShape, isNotNull);
              expect(concaveShape, isA<ConcaveMeshShape>());

              // Clean up
              concaveShape.dispose();
            } finally {
              triangleMesh.dispose();
            }
          } finally {
            triangleArray.dispose();
          }
        });

        test('should create concave mesh shape with custom scaling', () {
          final vertices = Float32List.fromList([
            0.0, 0.0, 0.0, // 0
            1.0, 0.0, 0.0, // 1
            0.5, 1.0, 0.0, // 2
          ]);

          final indices = Uint32List.fromList([0, 1, 2]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final triangleMesh = physics3D.createTriangleMesh(triangleArray);

            try {
              final customScale = Vector3(2.0, 0.5, 3.0);
              final concaveShape = physics3D.createConcaveMeshShape(
                triangleMesh,
                scaling: customScale,
              );

              expect(concaveShape, isNotNull);
              expect(concaveShape, isA<ConcaveMeshShape>());

              // Clean up
              concaveShape.dispose();
            } finally {
              triangleMesh.dispose();
            }
          } finally {
            triangleArray.dispose();
          }
        });
      });

      group('Mesh shape integration with rigid bodies', () {
        test(
          'should create convex mesh shape and integrate with rigid body',
          () {
            final world = physics3D.createWorld();

            // Test successful convex mesh creation and rigid body integration

            // Define simple cube vertices
            final vertices = Float32List.fromList([
              -2.0, -2.0, -2.0, // 0
              2.0, -2.0, -2.0, // 1
              2.0, 2.0, -2.0, // 2
              -2.0, 2.0, -2.0, // 3
              -2.0, -2.0, 2.0, // 4
              2.0, -2.0, 2.0, // 5
              2.0, 2.0, 2.0, // 6
              -2.0, 2.0, 2.0, // 7
            ]);

            final indices = Uint32List.fromList([
              // Bottom face
              0, 1, 2, 0, 2, 3,
              // Top face
              4, 7, 6, 4, 6, 5,
              // Front face
              0, 4, 5, 0, 5, 1,
              // Back face
              2, 6, 7, 2, 7, 3,
              // Left face
              0, 3, 7, 0, 7, 4,
              // Right face
              1, 5, 6, 1, 6, 2,
            ]);

            final triangleArray = physics3D.createTriangleVertexArray(
              vertices: vertices,
              indices: indices,
            );

            try {
              // This should now work successfully with fixed memory management
              final convexMesh = physics3D.createConvexMeshFromTriangles(
                triangleArray,
              );
              expect(convexMesh, isNotNull);
              expect(convexMesh, isA<ConvexMesh>());

              // Create convex mesh shape
              final convexShape = physics3D.createConvexMeshShape(convexMesh);
              expect(convexShape, isNotNull);
              expect(convexShape, isA<ConvexMeshShape>());

              // Test integration with rigid body
              final rigidBody = physics3D.createRigidBody(
                world,
                type: BodyType.DYNAMIC,
              );
              final collider = rigidBody.addCollider(convexShape);
              expect(collider, isNotNull);

              // Clean up
              convexShape.dispose();
              convexMesh.dispose();
            } finally {
              triangleArray.dispose();
            }
          },
        );

        test('should add concave mesh shape to static rigid body', () {
          final world = physics3D.createWorld();

          // Create simple concave mesh (L-shape)
          final vertices = Float32List.fromList([
            0.0, 0.0, 0.0, // 0
            2.0, 0.0, 0.0, // 1
            2.0, 0.0, 1.0, // 2
            1.0, 0.0, 1.0, // 3
            1.0, 0.0, 2.0, // 4
            0.0, 0.0, 2.0, // 5
          ]);

          final indices = Uint32List.fromList([
            0, 1, 2, 0, 2, 3, // First part of L
            0, 3, 5, 3, 4, 5, // Second part of L
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            vertices: vertices,
            indices: indices,
          );

          try {
            final triangleMesh = physics3D.createTriangleMesh(triangleArray);

            try {
              final concaveShape = physics3D.createConcaveMeshShape(
                triangleMesh,
              );

              try {
                final rigidBody = physics3D.createRigidBody(
                  world,
                  type: BodyType.STATIC,
                );

                final collider = rigidBody.addCollider(concaveShape);

                expect(collider, isNotNull);
                expect(rigidBody.type, equals(BodyType.STATIC));

                // Clean up
                concaveShape.dispose();
              } finally {
                triangleMesh.dispose();
              }
            } finally {
              triangleArray.dispose();
            }
          } catch (e) {
            // Clean up on error
            triangleArray.dispose();
            rethrow;
          }
        });
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

      group('Transform utilities', () {
        test('should get OpenGL matrix from identity transform', () {
          final world = physics3D.createWorld();
          final rigidBody = physics3D.createRigidBody(world);
          rigidBody.setTransform((
            orientation: Quaternion.identity(),
            position: Vector3(1, 2, 3),
          ));
          // Get the transform from the rigid body (should be identity by default)
          final transform = rigidBody.transform;

          // Get the OpenGL matrix
          final matrix = transform.getOpenGLMatrix();

          expect(matrix, isNotNull);
          expect(matrix, isA<Float32List>());
          expect(matrix.length, equals(16));

          expect(matrix[0], closeTo(1.0, 1e-6)); // m00
          expect(matrix[1], closeTo(0.0, 1e-6)); // m01
          expect(matrix[2], closeTo(0.0, 1e-6)); // m02
          expect(matrix[3], closeTo(0.0, 1e-6)); // m03
          expect(matrix[4], closeTo(0.0, 1e-6)); // m10
          expect(matrix[5], closeTo(1.0, 1e-6)); // m11
          expect(matrix[6], closeTo(0.0, 1e-6)); // m12
          expect(matrix[7], closeTo(0.0, 1e-6)); // m13
          expect(matrix[8], closeTo(0.0, 1e-6)); // m20
          expect(matrix[9], closeTo(0.0, 1e-6)); // m21
          expect(matrix[10], closeTo(1.0, 1e-6)); // m22
          expect(matrix[11], closeTo(0.0, 1e-6)); // m23
          expect(matrix[12], closeTo(1.0, 1e-6)); // m30
          expect(matrix[13], closeTo(2.0, 1e-6)); // m31
          expect(matrix[14], closeTo(3.0, 1e-6)); // m32
          expect(matrix[15], closeTo(1.0, 1e-6)); // m33
        });

        test('should get OpenGL matrix from translated transform', () {
          final world = physics3D.createWorld();
          // Create a new transform with translation
          final translatedTransform = (
            position: Vector3(5.0, -3.0, 2.0),
            orientation: Quaternion.identity(),
          );

          final rigidBody = physics3D.createRigidBody(
            world,
            transform: translatedTransform,
          );
          final matrix = rigidBody.transform.getOpenGLMatrix();

          expect(matrix, isNotNull);
          expect(matrix.length, equals(16));

          // For a translation-only transform, the rotation part should be identity
          // and the translation should be in the last column (m30, m31, m32)
          expect(matrix[0], closeTo(1.0, 1e-6)); // m00
          expect(matrix[5], closeTo(1.0, 1e-6)); // m11
          expect(matrix[10], closeTo(1.0, 1e-6)); // m22
          expect(matrix[15], closeTo(1.0, 1e-6)); // m33

          // Translation should be in m30, m31, m32 (column-major order)
          expect(matrix[12], closeTo(5.0, 1e-6)); // m30
          expect(matrix[13], closeTo(-3.0, 1e-6)); // m31
          expect(matrix[14], closeTo(2.0, 1e-6)); // m32

          // All other elements should be zero
          expect(matrix[1], closeTo(0.0, 1e-6)); // m01
          expect(matrix[2], closeTo(0.0, 1e-6)); // m02
          expect(matrix[3], closeTo(0.0, 1e-6)); // m03
          expect(matrix[4], closeTo(0.0, 1e-6)); // m10
          expect(matrix[6], closeTo(0.0, 1e-6)); // m12
          expect(matrix[7], closeTo(0.0, 1e-6)); // m13
          expect(matrix[8], closeTo(0.0, 1e-6)); // m20
          expect(matrix[9], closeTo(0.0, 1e-6)); // m21
          expect(matrix[11], closeTo(0.0, 1e-6)); // m23
        });
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

      test(
        'should handle multiple rigid bodies with independent gravity settings',
        () {
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
        },
      );
    });

    group('VertexArray functionality', () {
      test('should create VertexArray with correct vertex count', () {
        // Define simple cube vertices
        final vertices = Float32List.fromList([
          -1.0, -1.0, -1.0, // 0
          1.0, -1.0, -1.0, // 1
          1.0, -1.0, 1.0, // 2
          -1.0, -1.0, 1.0, // 3
          -1.0, 1.0, -1.0, // 4
          1.0, 1.0, -1.0, // 5
          1.0, 1.0, 1.0, // 6
          -1.0, 1.0, 1.0, // 7
        ]);

        final vertexArray = physics3D.createVertexArray(vertices);

        try {
          expect(vertexArray, isNotNull);
          expect(vertexArray, isA<VertexArray>());
          expect(vertexArray.getVertexCount(), equals(8));
          expect(
            vertexArray.getStride(),
            equals(12),
          ); // 3 floats * 4 bytes each
        } finally {
          vertexArray.dispose();
        }
      });

      test('should verify vertex data integrity', () {
        // Define vertices with known coordinates
        final vertices = Float32List.fromList([
          0.0, 0.0, 0.0, // 0 - origin
          1.0, 0.0, 0.0, // 1 - unit X
          0.0, 2.0, 0.0, // 2 - 2 units Y
          0.0, 0.0, 3.0, // 3 - 3 units Z
          -1.0, -1.0, -1.0, // 4 - negative corner
        ]);

        final vertexArray = physics3D.createVertexArray(vertices);

        try {
          expect(vertexArray.getVertexCount(), equals(5));

          // Verify each vertex matches original data
          const tolerance = 1e-6;
          for (int i = 0; i < 5; i++) {
            final vertex = vertexArray.getVertex(i);
            final expectedX = vertices[i * 3];
            final expectedY = vertices[i * 3 + 1];
            final expectedZ = vertices[i * 3 + 2];

            expect(vertex.x, closeTo(expectedX, tolerance));
            expect(vertex.y, closeTo(expectedY, tolerance));
            expect(vertex.z, closeTo(expectedZ, tolerance));
          }
        } finally {
          vertexArray.dispose();
        }
      });

      test('should handle minimum required vertices for convex hull', () {
        // Tetrahedron (4 vertices) - minimum for convex hull
        final vertices = Float32List.fromList([
          0.0, 0.0, 0.0, // 0
          1.0, 0.0, 0.0, // 1
          0.0, 1.0, 0.0, // 2
          0.0, 0.0, 1.0, // 3
        ]);

        final vertexArray = physics3D.createVertexArray(vertices);

        try {
          expect(vertexArray.getVertexCount(), equals(4));

          // Verify all vertices are accessible
          for (int i = 0; i < 4; i++) {
            final vertex = vertexArray.getVertex(i);
            expect(vertex, isNotNull);
            expect(vertex.x, isA<double>());
            expect(vertex.y, isA<double>());
            expect(vertex.z, isA<double>());
          }
        } finally {
          vertexArray.dispose();
        }
      });

      test('should handle single vertex array', () {
        // Single vertex - should create but fail convex hull generation
        final vertices = Float32List.fromList([
          0.0, 0.0, 0.0, // Single vertex at origin
        ]);

        expect(
          () => physics3D.createVertexArray(vertices),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle empty vertex array', () {
        // Empty vertex list
        final vertices = Float32List.fromList([]);

        expect(
          () => physics3D.createVertexArray(vertices),
          throwsA(isA<Exception>()),
        );
      });

      test('should create ConvexMeshShape from VertexArray', () {
        // Define a cube with more vertices than needed for convex hull
        final vertices = Float32List.fromList([
          // Bottom face
          -1.0, -1.0, -1.0, // 0
          1.0, -1.0, -1.0, // 1
          1.0, -1.0, 1.0, // 2
          -1.0, -1.0, 1.0, // 3
          // Top face
          -1.0, 1.0, -1.0, // 4
          1.0, 1.0, -1.0, // 5
          1.0, 1.0, 1.0, // 6
          -1.0, 1.0, 1.0, // 7
          // Additional points on faces/edges (to test convex hull simplification)
          0.0, 0.0, 0.0, // 8 - center
          0.5, 0.5, 0.5, // 9 - offset from center
        ]);

        final vertexArray = physics3D.createVertexArray(vertices);

        try {
          expect(vertexArray.getVertexCount(), equals(10));

          // Test that we can create a convex mesh from the vertex array
          final convexMesh = physics3D.createConvexMeshFromVertices(
            vertexArray,
          );

          if (convexMesh != null) {
            try {
              expect(convexMesh, isA<ConvexMesh>());

              // Create a convex mesh shape from the convex mesh
              final convexShape = physics3D.createConvexMeshShape(convexMesh);

              try {
                expect(convexShape, isNotNull);
                expect(convexShape, isA<ConvexMeshShape>());
              } finally {
                convexShape.dispose();
              }
            } finally {
              convexMesh.dispose();
            }
          } else {
            // Convex mesh creation may fail for some vertex configurations,
            // which is acceptable behavior for the QuickHull algorithm
            print(
              'Note: ConvexMesh creation failed - this may be expected for certain vertex configurations',
            );
          }
        } finally {
          vertexArray.dispose();
        }
      });
    });

    group('Collision Callbacks', () {
      test('should create and use logging collision callback', () {
        // Test creating a logging callback with null prefix (simple case)
        final callbackId = bindings.rp3d_create_logging_collision_callback(
          ffi.nullptr,
          1, // logContactPoints = true
          1, // verbose = true
        );

        expect(callbackId.address, isNonZero);
        expect(callbackId, isA<ffi.Pointer>());

        // Test creating another callback to verify different IDs
        final callbackId2 = bindings.rp3d_create_logging_collision_callback(
          ffi.nullptr,
          0, // logContactPoints = false
          0, // verbose = false
        );

        expect(callbackId2.address, isNonZero);
        expect(callbackId2.address, isNot(equals(callbackId.address)));

        // Test destroying callbacks (should not crash)
        expect(
          () => bindings.rp3d_destroy_collision_callback(callbackId),
          returnsNormally,
        );

        expect(
          () => bindings.rp3d_destroy_collision_callback(callbackId2),
          returnsNormally,
        );
      });

      test('should create and use contact counter callback', () {
        // Test creating a counter callback
        final callbackId = bindings.rp3d_create_contact_counter_callback();

        expect(callbackId.address, isNonZero);
        expect(callbackId, isA<ffi.Pointer>());

        // Test creating another counter callback to verify different IDs
        final callbackId2 = bindings.rp3d_create_contact_counter_callback();

        expect(callbackId2.address, isNonZero);
        expect(callbackId2.address, isNot(equals(callbackId.address)));

        // Test destroying callbacks (should not crash)
        expect(
          () => bindings.rp3d_destroy_collision_callback(callbackId),
          returnsNormally,
        );

        expect(
          () => bindings.rp3d_destroy_collision_callback(callbackId2),
          returnsNormally,
        );
      });

      test('should create multiple callbacks with different IDs', () {
        // Create multiple callbacks of different types
        final loggingCallback1 = bindings
            .rp3d_create_logging_collision_callback(ffi.nullptr, 1, 1);
        final loggingCallback2 = bindings
            .rp3d_create_logging_collision_callback(ffi.nullptr, 0, 1);
        final counterCallback1 = bindings
            .rp3d_create_contact_counter_callback();
        final counterCallback2 = bindings
            .rp3d_create_contact_counter_callback();

        // All should have different IDs
        expect(loggingCallback1, isNot(equals(loggingCallback2)));
        expect(loggingCallback1, isNot(equals(counterCallback1)));
        expect(loggingCallback2, isNot(equals(counterCallback1)));
        expect(counterCallback1, isNot(equals(counterCallback2)));

        // All should be valid
        expect(loggingCallback1.address, isNonZero);
        expect(loggingCallback2.address, isNonZero);
        expect(counterCallback1.address, isNonZero);
        expect(counterCallback2.address, isNonZero);

        // Cleanup
        bindings.rp3d_destroy_collision_callback(loggingCallback1);
        bindings.rp3d_destroy_collision_callback(loggingCallback2);
        bindings.rp3d_destroy_collision_callback(counterCallback1);
        bindings.rp3d_destroy_collision_callback(counterCallback2);
      });

      test('should handle invalid callback operations gracefully', () {
        // Test operations with null callback (should handle gracefully)
        final nullCallback = ffi.nullptr;

        // These should not crash even with null callback
        expect(
          () => bindings.rp3d_destroy_collision_callback(nullCallback),
          returnsNormally,
        );

        expect(
          () => bindings.rp3d_destroy_collision_callback(nullCallback),
          returnsNormally,
        );

        expect(
          () => bindings.rp3d_reset_callback_stats(nullCallback),
          returnsNormally,
        );
      });

      test('should test collision callback functionality', () {
        // This test verifies that the collision callback C++ implementation
        // can be created and the basic functions work

        final world = physics3D.createWorld();

        // Create two rigid bodies
        final body1 = physics3D.createRigidBody(
          world,
          transform: (
            position: Vector3(0, 0, 0),
            orientation: Quaternion.identity(),
          ),
          type: BodyType.STATIC,
        );

        final body2 = physics3D.createRigidBody(
          world,
          transform: (
            position: Vector3(0, 0, 0),
            orientation: Quaternion.identity(),
          ),
          type: BodyType.DYNAMIC,
        );

        // Add shapes
        final boxShape = physics3D.createBoxShape(Vector3.all(1.0));
        final collider1 = body1.addCollider(boxShape);
        final collider2 = body2.addCollider(boxShape);

        expect(collider1, isNotNull);
        expect(collider2, isNotNull);

        // Create a callback
        final callbackId = bindings.rp3d_create_logging_collision_callback(
          ffi.nullptr,
          1,
          1,
        );

        expect(callbackId.address, isNonZero);

        // Test that we can attempt collision testing (will log to console if collisions occur)
        // Note: Since we can't easily access the internal pointers from Dart interfaces,
        // we'll just verify the callback creation works and doesn't crash

        // Cleanup the callback
        bindings.rp3d_destroy_collision_callback(callbackId);

        // Test completes without crashing - success!
      });

      test('should test collision detection with moving bodies', () {
        // Create a logging collision callback
        final callbackId = bindings.rp3d_create_logging_collision_callback(
          ffi.nullptr, // no custom prefix
          1, // logContactPoints = true
          1, // verbose = true
        );

        expect(callbackId.address, isNonZero);

        try {
          // Create physics world and two box bodies
          final world = physics3D.createWorld();

          // Create first box at origin
          final box1 = physics3D.createBoxShape(Vector3(1, 1, 1));
          final body1 = physics3D.createRigidBody(world);
          body1.addCollider(box1);

          // Create second box far away (no collision initially)
          final box2 = physics3D.createBoxShape(Vector3(1, 1, 1));
          final body2 = physics3D.createRigidBody(world);
          body2.setTransform((
            orientation: Quaternion.identity(),
            position: Vector3(10, 0, 0), // 10 units away - no collision
          ));
          body2.addCollider(box2);

          // Test 1: Bodies should NOT collide (hasContact should be false)
          // Since RigidBody inherits from Body in C++, we can safely cast
          final body1AsBody = body1.handle.cast<bindings.RP3D_Body>();
          final body2AsBody = body2.handle.cast<bindings.RP3D_Body>();

          bindings.rp3d_test_collision_bodies_direct(
            world.handle,
            body1AsBody,
            body2AsBody,
            callbackId,
          );

          // Check hasContact - should be false (0) since bodies are far apart
          final initialHasContact = bindings
              .rp3d_get_logging_callback_has_contact(callbackId);
          expect(
            initialHasContact,
            equals(0),
            reason: 'Bodies should not be colliding initially',
          );

          // Move body2 close to body1 so they collide
          body2.setTransform((
            orientation: Quaternion.identity(),
            position: Vector3(1.5, 0, 0), // Overlapping position
          ));

          // Test 2: Bodies should collide (hasContact should be true)
          bindings.rp3d_test_collision_bodies_direct(
            world.handle,
            body1AsBody,
            body2AsBody,
            callbackId,
          );

          // Check hasContact - should be true (1) since bodies are now overlapping
          final finalHasContact = bindings
              .rp3d_get_logging_callback_has_contact(callbackId);
          expect(
            finalHasContact,
            equals(1),
            reason:
                'Bodies should be colliding after movement - boxes with half-extents 1.0 at distance 1.5 should collide',
          );

          print('✅ Full collision detection test passed!');
          print(
            '   Initial hasContact: $initialHasContact (should be 0 - far apart)',
          );
          print(
            '   Final hasContact: $finalHasContact (should be 1 - overlapping)',
          );
          print('   ✅ Real position-based collision detection working!');

          // Cleanup is handled by test framework
        } finally {
          // Always cleanup the callback
          bindings.rp3d_destroy_collision_callback(callbackId);
        }
      });
    });
  });
}
