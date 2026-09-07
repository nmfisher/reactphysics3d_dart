import 'dart:typed_data';
import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart' as ffi;

/// Interface for physics common operations
abstract class PhysicsCommon
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_PhysicsCommon>> {
  /// Destroy this factory and all its resources. Safe to call again.
  void dispose();

  /// Destroy an owned world and its bodies/colliders.
  void destroyPhysicsWorld(PhysicsWorld world);

  /// Create a new physics world
  PhysicsWorld createPhysicsWorld();

  /// Create a box from positive half-extents, not full dimensions.
  BoxShape createBoxShape(Vector3 extent);

  /// Create a sphere shape
  SphereShape createSphereShape(double radius);

  /// Create a Y-axis capsule; height excludes the two hemispherical caps.
  CapsuleShape createCapsuleShape(double radius, double height);

  /// Copy row-major heights (row * columns + column); rows run along Z.
  /// Native bounds are computed from the samples and centered around zero.
  /// minHeight/maxHeight are compatibility parameters and do not set bounds.
  HeightField createHeightFieldFloat({
    required int rows,
    required int columns,
    required Float32List heights,
    required double minHeight,
    required double maxHeight,
  });

  /// Copy row-major integer heights, multiplied by integerHeightScale.
  /// Bounds are computed from samples; minHeight/maxHeight are not used.
  HeightField createHeightFieldInt({
    required int rows,
    required int columns,
    required Int32List heights,
    required double minHeight,
    required double maxHeight,
    required double integerHeightScale,
  });

  /// Create a height field shape from height field data
  HeightFieldShape createHeightFieldShape(
    HeightField heightField, {
    Vector3? scaling,
  });

  /// Copy finite XYZ vertices and triangle index triples into native storage.
  /// The resulting descriptor can be disposed after constructing a mesh.
  TriangleVertexArray createTriangleVertexArray({
    required Float32List vertices,
    required Uint32List indices,
  });

  /// Copy XYZ vertices, vertex indices and (vertex count, index base) face pairs.
  /// Faces may have different vertex counts; each must have at least three.
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
  ConvexMesh createConvexMeshFromTriangles(
    TriangleVertexArray triangleVertexArray,
  );

  /// Create a convex mesh from polygon vertex array
  ConvexMesh createConvexMeshFromPolygons(
    PolygonVertexArray polygonVertexArray,
  );

  /// Create a convex mesh from vertex array
  ConvexMesh? createConvexMeshFromVertices(VertexArray vertexArray);

  /// Create a convex mesh shape from convex mesh
  ConvexMeshShape createConvexMeshShape(
    ConvexMesh convexMesh, {
    Vector3? scaling,
  });

  /// Create a concave mesh shape from triangle mesh
  ConcaveMeshShape createConcaveMeshShape(
    TriangleMesh triangleMesh, {
    Vector3? scaling,
  });
}
