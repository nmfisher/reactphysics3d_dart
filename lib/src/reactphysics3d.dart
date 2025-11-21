import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';
import 'ffi_reactphysics3d.dart' show FFIReactPhysics3D;
import 'interfaces/interfaces.dart';
import 'bindings/src/bindings.dart' as bindings;

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

extension TransformExtension on Transform {
  /// Get the OpenGL matrix representation of this transform
  /// Returns a 4x4 column-major matrix as Float32List
  Float32List getOpenGLMatrix() {
    // Create FFI transform struct
    final ffiTransform = bindings.StructAllocator.create<bindings.RP3D_Transform>();
    ffiTransform.position.x = position.x;
    ffiTransform.position.y = position.y;
    ffiTransform.position.z = position.z;
    ffiTransform.orientation.x = orientation.x;
    ffiTransform.orientation.y = orientation.y;
    ffiTransform.orientation.z = orientation.z;
    ffiTransform.orientation.w = orientation.w;

    final matrixPointer = Float32List(16);

    // Call the native function - cast to Pointer<Float> for the API
    bindings.rp3d_transform_get_opengl_matrix(
      ffiTransform.address,
      matrixPointer.address.cast(),
    );

    return matrixPointer;
  }
}

/// Body type enumeration
enum BodyType { STATIC, KINEMATIC, DYNAMIC }

/// Ray for raycasting queries
class Ray {
  final Vector3 point1;
  final Vector3 point2;

  Ray(this.point1, this.point2);
}

/// Raycast hit information
class RaycastInfo {
  final RigidBody? body;
  final Collider? collider;
  final Vector3 worldPoint;
  final Vector3 worldNormal;
  final double hitFraction;

  RaycastInfo({
    required this.body,
    required this.collider,
    required this.worldPoint,
    required this.worldNormal,
    required this.hitFraction,
  });
}

/// Abstract interface for ReactPhysics3D physics engine
abstract class ReactPhysics3D {
  PhysicsCommon get physicsCommon;
  PhysicsWorld createWorld();
  BoxShape createBoxShape(Vector3 extent);
  SphereShape createSphereShape(double radius);
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
  HeightFieldShape createHeightFieldShape(HeightField heightField, { Vector3? scaling});

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
  ConvexMeshShape createConvexMeshShape(ConvexMesh convexMesh, {Vector3? scaling});

  /// Create a concave mesh shape from triangle mesh
  ConcaveMeshShape createConcaveMeshShape(
    TriangleMesh triangleMesh, {
    Vector3? scaling,
  });

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
