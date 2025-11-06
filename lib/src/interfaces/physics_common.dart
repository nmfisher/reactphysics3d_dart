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

  /// Create a height field from height data
  HeightField createHeightField({
    required int rows,
    required int columns,
    required List<double> heights,
    required double minHeight,
    required double maxHeight,
  });

  /// Create a height field shape from height field data
  HeightFieldShape createHeightFieldShape(HeightField heightField);

  /// Create a triangle vertex array from vertex and index data
  TriangleVertexArray createTriangleVertexArray({
    required int verticesCount,
    required Float32List vertices,
    required int verticesStride,
    required int indicesCount,
    required Uint32List indices,
    required int indicesStride,
  });

  /// Create a polygon vertex array from vertex and index data
  PolygonVertexArray createPolygonVertexArray({
    required int verticesCount,
    required Float32List vertices,
    required int verticesStride,
    required int indicesCount,
    required Uint32List indices,
    required int indicesStride,
    required Uint32List polygonIndices,
    required int polygonIndicesStride,
  });

  /// Create a triangle mesh from triangle vertex array
  TriangleMesh createTriangleMesh(TriangleVertexArray triangleVertexArray);

  /// Create a convex mesh from triangle vertex array
  ConvexMesh createConvexMeshFromTriangles(TriangleVertexArray triangleVertexArray);

  /// Create a convex mesh from polygon vertex array
  ConvexMesh createConvexMeshFromPolygons(PolygonVertexArray polygonVertexArray);

  /// Create a convex mesh shape from convex mesh
  ConvexMeshShape createConvexMeshShape(ConvexMesh convexMesh);

  /// Create a concave mesh shape from triangle mesh
  ConcaveMeshShape createConcaveMeshShape(TriangleMesh triangleMesh, {Vector3? scaling});
}