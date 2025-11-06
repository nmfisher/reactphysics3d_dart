import 'dart:typed_data';
import '../bindings/src/bindings.dart';
import 'package:vector_math/vector_math_64.dart';
import '../interfaces/collision_shape.dart';
import 'ffi_physics_common.dart';

/// Base implementation for collision shapes
abstract class FFICollisionShape implements CollisionShape {
  final Pointer<RP3D_CollisionShape> _handle;
  final FFIPhysicsCommon _common;

  FFICollisionShape._(this._handle, this._common);

  @override
  Pointer<RP3D_CollisionShape> get handle => _handle;

  @override
  void dispose() {
    _destroyShape();
  }

  void _destroyShape();
}

/// Box collision shape implementation
class FFIBoxShape extends FFICollisionShape implements BoxShape {
  FFIBoxShape.internal(Pointer<RP3D_BoxShape> handle, FFIPhysicsCommon common)
    : super._(handle.cast<RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final boxHandle = _handle.cast<RP3D_BoxShape>();
    rp3d_physics_common_destroy_box_shape(_common.handleForShapes!, boxHandle);
  }
}

/// Sphere collision shape implementation
class FFISphereShape extends FFICollisionShape implements SphereShape {
  FFISphereShape.internal(
    Pointer<RP3D_SphereShape> handle,
    FFIPhysicsCommon common,
  ) : super._(handle.cast<RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final sphereHandle = _handle.cast<RP3D_SphereShape>();
    rp3d_physics_common_destroy_sphere_shape(
      _common.handleForShapes!,
      sphereHandle,
    );
  }
}

/// Capsule collision shape implementation
class FFICapsuleShape extends FFICollisionShape implements CapsuleShape {
  FFICapsuleShape.internal(
    Pointer<RP3D_CapsuleShape> handle,
    FFIPhysicsCommon common,
  ) : super._(handle.cast<RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final capsuleHandle = _handle.cast<RP3D_CapsuleShape>();
    rp3d_physics_common_destroy_capsule_shape(
      _common.handleForShapes!,
      capsuleHandle,
    );
  }
}

/// Height field implementation
class FFIHeightField implements HeightField {
  final Pointer<RP3D_HeightField> _handle;
  final FFIPhysicsCommon _common;

  FFIHeightField.internal(this._handle, this._common);

  @override
  Pointer<RP3D_HeightField> get handle => _handle;

  @override
  void dispose() {
    rp3d_physics_common_destroy_height_field(_common.handleForShapes!, _handle);
  }
}

/// Height field shape implementation
class FFIHeightFieldShape extends FFICollisionShape
    implements HeightFieldShape {
  FFIHeightFieldShape.internal(
    Pointer<RP3D_HeightFieldShape> handle,
    FFIPhysicsCommon common,
  ) : super._(handle.cast<RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final heightFieldShapeHandle = _handle.cast<RP3D_HeightFieldShape>();
    rp3d_physics_common_destroy_height_field_shape(
      _common.handleForShapes!,
      heightFieldShapeHandle,
    );
  }

  @override
  void setScale(Vector3 scale) {
    final scalePtr = Struct.create<RP3D_Vector3>();

    scalePtr.x = scale.x;
    scalePtr.y = scale.y;
    scalePtr.z = scale.z;
    rp3d_concave_shape_set_scale(_handle.cast(), scalePtr.address);
  }

  @override
  Vector3 getVertexAt(int row, int column) {
    final outVertexPtr = Struct.create<RP3D_Vector3>();

    final heightFieldShapeHandle = _handle.cast<RP3D_HeightFieldShape>();
    rp3d_height_field_shape_get_vertex_at(
      heightFieldShapeHandle,
      row,
      column,
      outVertexPtr.address,
    );

    return Vector3(outVertexPtr.x, outVertexPtr.y, outVertexPtr.z);
  }
}

/// Triangle vertex array implementation
class FFITriangleVertexArray implements TriangleVertexArray {
  final Pointer<RP3D_TriangleVertexArray> _handle;
  final Float32List _vertices;
  final Int32List _indices;

  FFITriangleVertexArray.internal(this._handle, this._vertices, this._indices);

  @override
  Pointer<RP3D_TriangleVertexArray> get handle => _handle;

  @override
  void dispose() {
    // Free the vertex and index data first, then destroy the array
    _vertices.free();
    _indices.free();
    rp3d_triangle_vertex_array_destroy(_handle);
  }

  @override
  int getVertexCount() {
    return rp3d_triangle_vertex_array_get_nb_vertices(_handle);
  }

  @override
  int getTriangleCount() {
    return rp3d_triangle_vertex_array_get_nb_triangles(_handle);
  }

  @override
  Vector3 getVertex(int index) {
    final verticesStart = rp3d_triangle_vertex_array_get_vertices_start(
      _handle,
    );
    if (verticesStart == null) {
      throw Exception('Cannot get vertex data: vertices start pointer is null');
    }

    // Each vertex has 3 float components (x, y, z)
    final vertexPtr = verticesStart + (index * 3);
    return Vector3(
      vertexPtr.value,
      (vertexPtr + 1).value,
      (vertexPtr + 2).value,
    );
  }

  @override
  List<int> getTriangleIndices(int triangleIndex) {
    final out = makeInt32List(3);

    rp3d_triangle_vertex_array_get_triangle_vertices_indices(
      _handle,
      triangleIndex,
      out.address.cast(),
    );

    return out;
  }
}

/// Polygon vertex array implementation
class FFIPolygonVertexArray implements PolygonVertexArray {
  final Pointer<RP3D_PolygonVertexArray> _handle;

  FFIPolygonVertexArray.internal(this._handle);

  @override
  Pointer<RP3D_PolygonVertexArray> get handle => _handle;

  @override
  void dispose() {
    rp3d_polygon_vertex_array_destroy(_handle);
  }
}

/// Triangle mesh implementation
class FFITriangleMesh implements TriangleMesh {
  final Pointer<RP3D_TriangleMesh> _handle;
  final FFIPhysicsCommon _common;

  FFITriangleMesh.internal(this._handle, this._common);

  @override
  Pointer<RP3D_TriangleMesh> get handle => _handle;

  @override
  void dispose() {
    rp3d_physics_common_destroy_triangle_mesh(
      _common.handleForShapes!,
      _handle,
    );
  }

  @override
  int getVertexCount() {
    return rp3d_triangle_mesh_get_nb_vertices(_handle);
  }

  @override
  int getTriangleCount() {
    return rp3d_triangle_mesh_get_nb_triangles(_handle);
  }

  @override
  Vector3 getVertex(int index) {
    final outVertex = Struct.create<RP3D_Vector3>();

    rp3d_triangle_mesh_get_vertex(_handle, index, outVertex.address);
    return Vector3(outVertex.x, outVertex.y, outVertex.z);
  }

  @override
  List<int> getTriangleIndices(int triangleIndex) {
    final out = makeInt32List(3);

    rp3d_triangle_mesh_get_triangle_vertices_indices(
      _handle,
      triangleIndex,
      out.address.cast(),
    );

    return out;
  }
}

/// Convex mesh implementation
class FFIConvexMesh implements ConvexMesh {
  final Pointer<RP3D_ConvexMesh> _handle;
  final FFIPhysicsCommon _common;

  FFIConvexMesh.internal(this._handle, this._common);

  @override
  Pointer<RP3D_ConvexMesh> get handle => _handle;

  @override
  void dispose() {
    rp3d_physics_common_destroy_convex_mesh(_common.handleForShapes!, _handle);
  }
}

/// Convex mesh shape implementation
class FFIConvexMeshShape extends FFICollisionShape implements ConvexMeshShape {
  FFIConvexMeshShape.internal(
    Pointer<RP3D_ConvexMeshShape> handle,
    FFIPhysicsCommon common,
  ) : super._(handle.cast<RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final convexMeshShapeHandle = _handle.cast<RP3D_ConvexMeshShape>();
    rp3d_physics_common_destroy_convex_mesh_shape(
      _common.handleForShapes!,
      convexMeshShapeHandle,
    );
  }
}

/// Concave mesh shape implementation
class FFIConcaveMeshShape extends FFICollisionShape
    implements ConcaveMeshShape {
  FFIConcaveMeshShape.internal(
    Pointer<RP3D_ConcaveMeshShape> handle,
    FFIPhysicsCommon common,
  ) : super._(handle.cast<RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final concaveMeshShapeHandle = _handle.cast<RP3D_ConcaveMeshShape>();
    rp3d_physics_common_destroy_concave_mesh_shape(
      _common.handleForShapes!,
      concaveMeshShapeHandle,
    );
  }
}
