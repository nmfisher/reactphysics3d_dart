import 'dart:typed_data';
import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart' as ffi;

/// Interface for physics common operations
abstract class PhysicsCommon extends BaseRP3DType<ffi.Pointer<ffi.RP3D_PhysicsCommon>> {
  /// Create a new physics world
  PhysicsWorld createPhysicsWorld();

  /// Create a box shape
  BoxShape createBoxShape(Vector3 extent);

  /// Create a sphere shape
  SphereShape createSphereShape(double radius);

  /// Create a capsule shape
  CapsuleShape createCapsuleShape(double radius, double height);

  /// Create a height field from float height data
  HeightField createHeightFieldFloat({
    required int rows,
    required int columns,
    required Float32List heights,
    required double minHeight,
    required double maxHeight,
  });

  /// Create a height field from integer height data
  HeightField createHeightFieldInt({
    required int rows,
    required int columns,
    required Int32List heights,
    required double minHeight,
    required double maxHeight,
    required double integerHeightScale,
  });

  /// Create a height field shape from height field data
  HeightFieldShape createHeightFieldShape(HeightField heightField);

  /// Create a triangle vertex array from vertex and index data
  TriangleVertexArray createTriangleVertexArray({
    required Float32List vertices,
    required Uint32List indices,
  });

  /// Create a polygon vertex array from vertex and index data
  PolygonVertexArray createPolygonVertexArray({
    required Float32List vertices,
    required Uint32List indices,
    required Uint32List polygonIndices,
  });

  /// Create a vertex array from vertex data
  VertexArray createVertexArray(Float32List vertices);

  /// Create a triangle mesh from triangle vertex array
  TriangleMesh createTriangleMesh(TriangleVertexArray triangleVertexArray);

  /// Create a convex mesh from triangle vertex array
  ConvexMesh createConvexMeshFromTriangles(TriangleVertexArray triangleVertexArray);

  /// Create a convex mesh from polygon vertex array
  ConvexMesh createConvexMeshFromPolygons(PolygonVertexArray polygonVertexArray);

  /// Create a convex mesh from vertex array
  ConvexMesh? createConvexMeshFromVertices(VertexArray vertexArray);

  /// Create a convex mesh shape from convex mesh
  ConvexMeshShape createConvexMeshShape(ConvexMesh convexMesh, {Vector3? scaling});

  /// Create a concave mesh shape from triangle mesh
  ConcaveMeshShape createConcaveMeshShape(TriangleMesh triangleMesh, {Vector3? scaling});
}