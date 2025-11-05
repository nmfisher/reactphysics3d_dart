import 'dart:typed_data';
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

    group('mesh shapes', () {
      group('TriangleVertexArray', () {
        test('should create triangle vertex array with valid data', () {
          // Define simple triangle vertices
          final vertices = Float32List.fromList([
            0.0, 0.0, 0.0,  // Vertex 0
            1.0, 0.0, 0.0,  // Vertex 1
            0.5, 1.0, 0.0,  // Vertex 2
          ]);

          // Define triangle indices
          final indices = Uint32List.fromList([0, 1, 2]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 3,
            vertices: vertices,
            verticesStride: 12, // 3 floats * 4 bytes
            indicesCount: 3,
            indices: indices,
            indicesStride: 4, // 1 uint32 * 4 bytes
          );

          expect(triangleArray, isNotNull);
          expect(triangleArray, isA<TriangleVertexArray>());

          // Clean up
          triangleArray.dispose();
        });

        test('should throw error for invalid vertex count', () {
          final vertices = Float32List.fromList([0.0, 0.0, 0.0]);
          final indices = Uint32List.fromList([0]);

          expect(
            () => physics3D.createTriangleVertexArray(
              verticesCount: 0, // Invalid
              vertices: vertices,
              verticesStride: 12,
              indicesCount: 1,
              indices: indices,
              indicesStride: 4,
            ),
            throwsA(isA<ArgumentError>()),
          );
        });

        test('should throw error for insufficient vertices array', () {
          final vertices = Float32List.fromList([0.0, 0.0]); // Too short
          final indices = Uint32List.fromList([0, 1, 2]);

          expect(
            () => physics3D.createTriangleVertexArray(
              verticesCount: 3,
              vertices: vertices,
              verticesStride: 12,
              indicesCount: 3,
              indices: indices,
              indicesStride: 4,
            ),
            throwsA(isA<ArgumentError>()),
          );
        });

        test('should throw error for invalid index count', () {
          final vertices = Float32List.fromList([0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 1.0, 0.0]);
          final indices = Uint32List.fromList([0]);

          expect(
            () => physics3D.createTriangleVertexArray(
              verticesCount: 3,
              vertices: vertices,
              verticesStride: 12,
              indicesCount: 0, // Invalid
              indices: indices,
              indicesStride: 4,
            ),
            throwsA(isA<ArgumentError>()),
          );
        });
      });

      group('ConvexMesh', () {
        test('should create convex mesh from cube triangle data', () {
          // Test successful convex mesh creation from well-spaced cube vertices

          // Define well-spaced cube vertices (8 points)
          final vertices = Float32List.fromList([
            -10.0, -10.0, -10.0,  // 0
             10.0, -10.0, -10.0,  // 1
             10.0,  10.0, -10.0,  // 2
            -10.0,  10.0, -10.0,  // 3
            -10.0, -10.0,  10.0,  // 4
             10.0, -10.0,  10.0,  // 5
             10.0,  10.0,  10.0,  // 6
            -10.0,  10.0,  10.0,  // 7
          ]);

          // Define cube triangle indices (12 triangles)
          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2,  0, 2, 3,
            // Top face
            4, 7, 6,  4, 6, 5,
            // Front face
            0, 4, 5,  0, 5, 1,
            // Back face
            2, 6, 7,  2, 7, 3,
            // Left face
            0, 3, 7,  0, 7, 4,
            // Right face
            1, 5, 6,  1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 8,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 36,
            indices: indices,
            indicesStride: 4,
          );

          try {
            // This should now work successfully with fixed memory management
            final convexMesh = physics3D.createConvexMeshFromTriangles(triangleArray);
            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Clean up
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should handle invalid vertex data gracefully', () {
          // Test with too few vertices (should fail gracefully)
          final vertices = Float32List.fromList([
            0.0, 0.0, 0.0,  // Only one vertex
          ]);

          final indices = Uint32List.fromList([0, 0, 0]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 1,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 3,
            indices: indices,
            indicesStride: 4,
          );

          try {
            expect(
              () => physics3D.createConvexMeshFromTriangles(triangleArray),
              throwsA(isA<Exception>()),
            );
          } finally {
            triangleArray.dispose();
          }
        });
      });

      group('ConcaveMesh (TriangleMesh)', () {
        test('should create triangle mesh from triangle data', () {
          // Define simple box vertices
          final vertices = Float32List.fromList([
            -1.0, -1.0, -1.0,  // 0
             1.0, -1.0, -1.0,  // 1
             1.0, -1.0,  1.0,  // 2
            -1.0, -1.0,  1.0,  // 3
            -1.0,  1.0, -1.0,  // 4
             1.0,  1.0, -1.0,  // 5
             1.0,  1.0,  1.0,  // 6
            -1.0,  1.0,  1.0,  // 7
          ]);

          // Define box triangle indices
          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2,  0, 2, 3,
            // Top face
            4, 7, 6,  4, 6, 5,
            // Front face
            0, 4, 5,  0, 5, 1,
            // Back face
            2, 6, 7,  2, 7, 3,
            // Left face
            0, 3, 7,  0, 7, 4,
            // Right face
            1, 5, 6,  1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 8,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 36,
            indices: indices,
            indicesStride: 4,
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
            -1.0, -1.0, -1.0,  // 0
             1.0, -1.0, -1.0,  // 1
             1.0, -1.0,  1.0,  // 2
            -1.0, -1.0,  1.0,  // 3
            -1.0,  1.0, -1.0,  // 4
             1.0,  1.0, -1.0,  // 5
             1.0,  1.0,  1.0,  // 6
            -1.0,  1.0,  1.0,  // 7
          ]);

          // Define box triangle indices with known relationships
          final indices = Uint32List.fromList([
            // Bottom face (y = -1)
            0, 1, 2,  0, 2, 3,
            // Top face (y = 1)
            4, 7, 6,  4, 6, 5,
            // Front face (z = 1)
            2, 6, 7,  2, 7, 3,
            // Back face (z = -1)
            0, 4, 5,  0, 5, 1,
            // Left face (x = -1)
            0, 3, 7,  0, 7, 4,
            // Right face (x = 1)
            1, 5, 6,  1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 8,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 36,
            indices: indices,
            indicesStride: 4,
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
              expect(triangleMesh.getTriangleCount(), greaterThan(8)); // Should have most triangles

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
                if (triangleSet.length == 3 && triangleSet.containsAll(bottomSet)) {
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
                if ((triangleSet.length == 3 && triangleSet.containsAll(topSet1)) ||
                    (triangleSet.length == 3 && triangleSet.containsAll(topSet2))) {
                  foundTopTriangle = true;

                  // Verify these are indeed the top face vertices (y = 1)
                  for (int vertexIndex in triangleIndices) {
                    final vertex = triangleMesh.getVertex(vertexIndex);
                    expect(vertex.y, closeTo(1.0, meshTolerance));
                  }
                }
              }

              expect(foundBottomTriangle, isTrue, reason: 'Should find bottom face triangle');
              expect(foundTopTriangle, isTrue, reason: 'Should find top face triangle');

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
            -1.0, -1.0, -1.0,  // 0
             1.0, -1.0, -1.0,  // 1
             1.0,  1.0, -1.0,  // 2
            -1.0,  1.0, -1.0,  // 3
            -1.0, -1.0,  1.0,  // 4
             1.0, -1.0,  1.0,  // 5
             1.0,  1.0,  1.0,  // 6
            -1.0,  1.0,  1.0,  // 7
          ]);

          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2,  0, 2, 3,
            // Top face
            4, 7, 6,  4, 6, 5,
            // Front face
            0, 4, 5,  0, 5, 1,
            // Back face
            2, 6, 7,  2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6,  1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 8,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 36,
            indices: indices,
            indicesStride: 4,
          );

          try {
            // This should now work successfully
            final convexMesh = physics3D.createConvexMeshFromTriangles(triangleArray);

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
      });

      group('ConcaveMeshShape', () {
        test('should create concave mesh shape from triangle mesh', () {
          // Create simple L-shaped terrain
          final vertices = Float32List.fromList([
            // L-shape vertices
            0.0, 0.0, 0.0,   // 0
            2.0, 0.0, 0.0,   // 1
            2.0, 0.0, 1.0,   // 2
            1.0, 0.0, 1.0,   // 3
            1.0, 0.0, 2.0,   // 4
            0.0, 0.0, 2.0,   // 5
          ]);

          final indices = Uint32List.fromList([
            // L-shape triangles (6 triangles)
            0, 1, 2,  0, 2, 3,  // First part of L
            0, 3, 5,  3, 4, 5,  // Second part of L
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 6,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 12,
            indices: indices,
            indicesStride: 4,
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
            0.0, 0.0, 0.0,  // 0
            1.0, 0.0, 0.0,  // 1
            0.5, 1.0, 0.0,  // 2
          ]);

          final indices = Uint32List.fromList([0, 1, 2]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 3,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 3,
            indices: indices,
            indicesStride: 4,
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
        test('should create convex mesh shape and integrate with rigid body', () {
          final world = physics3D.createWorld();

          // Test successful convex mesh creation and rigid body integration

          // Define simple cube vertices
          final vertices = Float32List.fromList([
            -2.0, -2.0, -2.0,  // 0
             2.0, -2.0, -2.0,  // 1
             2.0,  2.0, -2.0,  // 2
            -2.0,  2.0, -2.0,  // 3
            -2.0, -2.0,  2.0,  // 4
             2.0, -2.0,  2.0,  // 5
             2.0,  2.0,  2.0,  // 6
            -2.0,  2.0,  2.0,  // 7
          ]);

          final indices = Uint32List.fromList([
            // Bottom face
            0, 1, 2,  0, 2, 3,
            // Top face
            4, 7, 6,  4, 6, 5,
            // Front face
            0, 4, 5,  0, 5, 1,
            // Back face
            2, 6, 7, 2, 7, 3,
            // Left face
            0, 3, 7, 0, 7, 4,
            // Right face
            1, 5, 6,  1, 6, 2,
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 8,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 36,
            indices: indices,
            indicesStride: 4,
          );

          try {
            // This should now work successfully with fixed memory management
            final convexMesh = physics3D.createConvexMeshFromTriangles(triangleArray);
            expect(convexMesh, isNotNull);
            expect(convexMesh, isA<ConvexMesh>());

            // Create convex mesh shape
            final convexShape = physics3D.createConvexMeshShape(convexMesh);
            expect(convexShape, isNotNull);
            expect(convexShape, isA<ConvexMeshShape>());

            // Test integration with rigid body
            final rigidBody = physics3D.createRigidBody(world, type: BodyType.DYNAMIC);
            final collider = rigidBody.addCollider(convexShape);
            expect(collider, isNotNull);

            // Clean up
            convexShape.dispose();
            convexMesh.dispose();
          } finally {
            triangleArray.dispose();
          }
        });

        test('should add concave mesh shape to static rigid body', () {
          final world = physics3D.createWorld();

          // Create simple concave mesh (L-shape)
          final vertices = Float32List.fromList([
            0.0, 0.0, 0.0,   // 0
            2.0, 0.0, 0.0,   // 1
            2.0, 0.0, 1.0,   // 2
            1.0, 0.0, 1.0,   // 3
            1.0, 0.0, 2.0,   // 4
            0.0, 0.0, 2.0,   // 5
          ]);

          final indices = Uint32List.fromList([
            0, 1, 2,  0, 2, 3,  // First part of L
            0, 3, 5,  3, 4, 5,  // Second part of L
          ]);

          final triangleArray = physics3D.createTriangleVertexArray(
            verticesCount: 6,
            vertices: vertices,
            verticesStride: 12,
            indicesCount: 12,
            indices: indices,
            indicesStride: 4,
          );

          try {
            final triangleMesh = physics3D.createTriangleMesh(triangleArray);

            try {
              final concaveShape = physics3D.createConcaveMeshShape(triangleMesh);

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
          rigidBody.setTransform((orientation: Quaternion.identity(), position:Vector3(1,2,3)));
          // Get the transform from the rigid body (should be identity by default)
          final transform = rigidBody.transform;

          // Get the OpenGL matrix
          final matrix = transform.getOpenGLMatrix();

          expect(matrix, isNotNull);
          expect(matrix, isA<Float32List>());
          expect(matrix.length, equals(16));

          expect(matrix[0], closeTo(1.0, 1e-6));  // m00
          expect(matrix[1], closeTo(0.0, 1e-6));  // m01
          expect(matrix[2], closeTo(0.0, 1e-6));  // m02
          expect(matrix[3], closeTo(0.0, 1e-6));  // m03
          expect(matrix[4], closeTo(0.0, 1e-6));  // m10
          expect(matrix[5], closeTo(1.0, 1e-6));  // m11
          expect(matrix[6], closeTo(0.0, 1e-6));  // m12
          expect(matrix[7], closeTo(0.0, 1e-6));  // m13
          expect(matrix[8], closeTo(0.0, 1e-6));  // m20
          expect(matrix[9], closeTo(0.0, 1e-6));  // m21
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
            orientation: Quaternion.identity()
          );

          final rigidBody = physics3D.createRigidBody(world, transform: translatedTransform);
          final matrix = rigidBody.transform.getOpenGLMatrix();

          expect(matrix, isNotNull);
          expect(matrix.length, equals(16));

          // For a translation-only transform, the rotation part should be identity
          // and the translation should be in the last column (m30, m31, m32)
          expect(matrix[0], closeTo(1.0, 1e-6));  // m00
          expect(matrix[5], closeTo(1.0, 1e-6));  // m11
          expect(matrix[10], closeTo(1.0, 1e-6)); // m22
          expect(matrix[15], closeTo(1.0, 1e-6)); // m33

          // Translation should be in m30, m31, m32 (column-major order)
          expect(matrix[12], closeTo(5.0, 1e-6));  // m30
          expect(matrix[13], closeTo(-3.0, 1e-6)); // m31
          expect(matrix[14], closeTo(2.0, 1e-6));  // m32

          // All other elements should be zero
          expect(matrix[1], closeTo(0.0, 1e-6));  // m01
          expect(matrix[2], closeTo(0.0, 1e-6));  // m02
          expect(matrix[3], closeTo(0.0, 1e-6));  // m03
          expect(matrix[4], closeTo(0.0, 1e-6));  // m10
          expect(matrix[6], closeTo(0.0, 1e-6));  // m12
          expect(matrix[7], closeTo(0.0, 1e-6));  // m13
          expect(matrix[8], closeTo(0.0, 1e-6));  // m20
          expect(matrix[9], closeTo(0.0, 1e-6));  // m21
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
