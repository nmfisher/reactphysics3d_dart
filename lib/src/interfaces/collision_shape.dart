import '../bindings/src/bindings.dart';
import '../bindings/src/bindings.dart' as ffi;
import 'package:vector_math/vector_math_64.dart';
import 'base_rp3d_type.dart';

/// A factory-owned shape, shareable by colliders from the same factory.
/// Remove all attached colliders before disposing the shape. The factory also
/// disposes it during shutdown. Access after disposal throws StateError.
abstract class CollisionShape
    extends BaseRP3DType<Pointer<RP3D_CollisionShape>> {
  /// Release this shape. Idempotent; throws StateError while colliders use it.
  void dispose();
}

/// Interface for box collision shapes
abstract class BoxShape extends CollisionShape {}

/// Interface for sphere collision shapes
abstract class SphereShape extends CollisionShape {}

/// Interface for capsule collision shapes
abstract class CapsuleShape extends CollisionShape {}

/// Interface for height field data
abstract class HeightField
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_HeightField>> {
  /// Release this data after disposing its shapes. Idempotent.
  void dispose();
}

/// Interface for height field collision shapes
abstract class HeightFieldShape extends CollisionShape {
  /// Get a local vertex: row is along Z, column along X; both are zero-based.
  Vector3 getVertexAt(int row, int column);

  /// Set the scale of the collision shape
  void setScale(Vector3 scale);
}

/// Interface for triangle vertex array data
abstract class TriangleVertexArray
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_TriangleVertexArray>> {
  /// Dispose of the triangle vertex array
  void dispose();

  /// Get the number of vertices in the array
  int getVertexCount();

  /// Get the number of triangles in the array
  int getTriangleCount();

  /// Get the vertex coordinates at the specified index
  Vector3 getVertex(int index);

  /// Get the three vertex indices for the specified triangle
  List<int> getTriangleIndices(int triangleIndex);
}

/// Interface for vertex array data
abstract class VertexArray
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_VertexArray>> {
  /// Dispose of the vertex array
  void dispose();

  /// Get the number of vertices in the array
  int getVertexCount();

  /// Get the stride (number of bytes) between consecutive vertices
  int getStride();

  /// Get the vertex coordinates at the specified index
  Vector3 getVertex(int index);
}

/// Interface for polygon vertex array data
abstract class PolygonVertexArray
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_PolygonVertexArray>> {
  /// Dispose of the polygon vertex array
  void dispose();

  /// Get the number of vertices in the array
  int getVertexCount();

  /// Get the number of polygon faces in the array
  int getFaceCount();

  /// Get the vertex coordinates at the specified index
  Vector3 getVertex(int index);

  /// Get the polygon face information at the specified index
  /// Returns a map with 'nbVertices' and 'indexBase' keys
  Map<String, int> getPolygonFace(int faceIndex);

  /// Get the stride (number of bytes) between consecutive indices
  int getIndicesStride();

  /// Get the index value at the specified position in the indices array
  int getIndex(int indexPosition);

  /// Get the vertex index for a specific vertex in a face
  /// [faceIndex] is the index of the face (0-based)
  /// [vertexInFace] is the position of the vertex within the face (0-based)
  /// Returns the actual vertex index in the vertices array
  int getVertexIndexInFace(int faceIndex, int vertexInFace);
}

/// Interface for triangle mesh data
abstract class TriangleMesh
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_TriangleMesh>> {
  /// Release this mesh after disposing its shapes. Idempotent.
  void dispose();

  /// Get the number of vertices in the mesh
  int getVertexCount();

  /// Get the number of triangles in the mesh
  int getTriangleCount();

  /// Get the vertex coordinates at the specified index
  Vector3 getVertex(int index);

  /// Get the three vertex indices for the specified triangle
  List<int> getTriangleIndices(int triangleIndex);
}

/// Interface for convex mesh data
abstract class ConvexMesh
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_ConvexMesh>> {
  /// Release this mesh after disposing its shapes. Idempotent.
  void dispose();
}

/// Interface for convex mesh collision shapes
abstract class ConvexMeshShape extends CollisionShape {}

/// Interface for concave mesh collision shapes
abstract class ConcaveMeshShape extends CollisionShape {}
