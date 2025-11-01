import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';

import 'ffi_reactphysics3d.dart' show FFIReactPhysics3D;
import 'interfaces/interfaces.dart';

export 'package:vector_math/vector_math_64.dart'
    show Vector3, Quaternion, Aabb3;
export 'exceptions.dart';
export 'ffi_reactphysics3d.dart' show FFIReactPhysics3D;
export 'interfaces/interfaces.dart';

typedef Transform = ({Vector3 position, Quaternion orientation});

extension TransformIdentity on Transform {
  static Transform identity() {
    return (position: Vector3.zero(), orientation: Quaternion.identity());
  }
}

/// Body type enumeration
enum BodyType {
  STATIC,
  KINEMATIC,
  DYNAMIC,
}

/// Abstract interface for ReactPhysics3D physics engine
abstract class ReactPhysics3D {
  PhysicsCommon get physicsCommon;
  PhysicsWorld createWorld();
  BoxShape createBoxShape(Vector3 extent);
  SphereShape createSphereShape(double radius);
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

  RigidBody createRigidBody(
    PhysicsWorld world, {
    Transform? transform,
    BodyType type = BodyType.DYNAMIC,
    double mass = 1.0,
  });

}

/// Factory function to create the FFI implementation of ReactPhysics3D
ReactPhysics3D createReactPhysics3D() {
  return FFIReactPhysics3D();
}
