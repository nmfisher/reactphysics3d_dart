import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as ffi_mem;
import 'package:vector_math/vector_math_64.dart';
import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;
import '../interfaces/collision_shape.dart';
import 'ffi_physics_common.dart';

/// Base implementation for collision shapes
abstract class FFICollisionShape implements CollisionShape {
  final ffi.Pointer<ffi_gen.RP3D_CollisionShape> _handle;
  final FFIPhysicsCommon _common;

  FFICollisionShape._(this._handle, this._common);

  @override
  ffi.Pointer<ffi_gen.RP3D_CollisionShape> get handle => _handle;

  @override
  void dispose() {
    _destroyShape();
  }

  void _destroyShape();
}

/// Box collision shape implementation
class FFIBoxShape extends FFICollisionShape implements BoxShape {
  FFIBoxShape.internal(ffi.Pointer<ffi_gen.RP3D_BoxShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final boxHandle = _handle.cast<ffi_gen.RP3D_BoxShape>();
    ffi_gen.rp3d_physics_common_destroy_box_shape(_common.handleForShapes!, boxHandle);
  }
}

/// Sphere collision shape implementation
class FFISphereShape extends FFICollisionShape implements SphereShape {
  FFISphereShape.internal(ffi.Pointer<ffi_gen.RP3D_SphereShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final sphereHandle = _handle.cast<ffi_gen.RP3D_SphereShape>();
    ffi_gen.rp3d_physics_common_destroy_sphere_shape(_common.handleForShapes!, sphereHandle);
  }
}

/// Capsule collision shape implementation
class FFICapsuleShape extends FFICollisionShape implements CapsuleShape {
  FFICapsuleShape.internal(ffi.Pointer<ffi_gen.RP3D_CapsuleShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final capsuleHandle = _handle.cast<ffi_gen.RP3D_CapsuleShape>();
    ffi_gen.rp3d_physics_common_destroy_capsule_shape(_common.handleForShapes!, capsuleHandle);
  }
}

/// Height field implementation
class FFIHeightField implements HeightField {
  final ffi.Pointer<ffi_gen.RP3D_HeightField> _handle;
  final FFIPhysicsCommon _common;

  FFIHeightField.internal(this._handle, this._common);

  @override
  ffi.Pointer<ffi_gen.RP3D_HeightField> get handle => _handle;

  @override
  void dispose() {
    ffi_gen.rp3d_physics_common_destroy_height_field(_common.handleForShapes!, _handle);
  }
}

/// Height field shape implementation
class FFIHeightFieldShape extends FFICollisionShape implements HeightFieldShape {
  FFIHeightFieldShape.internal(ffi.Pointer<ffi_gen.RP3D_HeightFieldShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final heightFieldShapeHandle = _handle.cast<ffi_gen.RP3D_HeightFieldShape>();
    ffi_gen.rp3d_physics_common_destroy_height_field_shape(_common.handleForShapes!, heightFieldShapeHandle);
  }

    @override
  void setScale(Vector3 scale) {
    final scalePtr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    try {
      scalePtr.ref.x = scale.x;
      scalePtr.ref.y = scale.y;
      scalePtr.ref.z = scale.z;
      ffi_gen.rp3d_concave_shape_set_scale(_handle.cast(), scalePtr);
    } finally {
      ffi_mem.calloc.free(scalePtr);
    }
  }

  @override
  Vector3 getVertexAt(int row, int column) {
    final outVertexPtr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    try {
      final heightFieldShapeHandle = _handle.cast<ffi_gen.RP3D_HeightFieldShape>();
      ffi_gen.rp3d_height_field_shape_get_vertex_at(heightFieldShapeHandle, row, column, outVertexPtr);

      return Vector3(
        outVertexPtr.ref.x,
        outVertexPtr.ref.y,
        outVertexPtr.ref.z,
      );
    } finally {
      ffi_mem.calloc.free(outVertexPtr);
    }
  }
}

/// Triangle vertex array implementation
class FFITriangleVertexArray implements TriangleVertexArray {
  final ffi.Pointer<ffi_gen.RP3D_TriangleVertexArray> _handle;
  final ffi.Pointer<ffi.Float> _verticesPtr;
  final ffi.Pointer<ffi.Uint32> _indicesPtr;

  FFITriangleVertexArray.internal(this._handle, this._verticesPtr, this._indicesPtr);

  @override
  ffi.Pointer<ffi_gen.RP3D_TriangleVertexArray> get handle => _handle;

  @override
  void dispose() {
    // Free the vertex and index data first, then destroy the array
    ffi_mem.calloc.free(_verticesPtr);
    ffi_mem.calloc.free(_indicesPtr);
    ffi_gen.rp3d_triangle_vertex_array_destroy(_handle);
  }

  @override
  int getVertexCount() {
    return ffi_gen.rp3d_triangle_vertex_array_get_nb_vertices(_handle);
  }

  @override
  int getTriangleCount() {
    return ffi_gen.rp3d_triangle_vertex_array_get_nb_triangles(_handle);
  }

  @override
  Vector3 getVertex(int index) {
    final verticesStart = ffi_gen.rp3d_triangle_vertex_array_get_vertices_start(_handle);
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
    final outV1Index = ffi_mem.calloc<ffi.Uint32>();
    final outV2Index = ffi_mem.calloc<ffi.Uint32>();
    final outV3Index = ffi_mem.calloc<ffi.Uint32>();

    try {
      ffi_gen.rp3d_triangle_vertex_array_get_triangle_vertices_indices(
        _handle,
        triangleIndex,
        outV1Index,
        outV2Index,
        outV3Index,
      );

      return [
        outV1Index.value,
        outV2Index.value,
        outV3Index.value,
      ];
    } finally {
      ffi_mem.calloc.free(outV1Index);
      ffi_mem.calloc.free(outV2Index);
      ffi_mem.calloc.free(outV3Index);
    }
  }
}

/// Polygon vertex array implementation
class FFIPolygonVertexArray implements PolygonVertexArray {
  final ffi.Pointer<ffi_gen.RP3D_PolygonVertexArray> _handle;

  FFIPolygonVertexArray.internal(this._handle);

  @override
  ffi.Pointer<ffi_gen.RP3D_PolygonVertexArray> get handle => _handle;

  @override
  void dispose() {
    ffi_gen.rp3d_polygon_vertex_array_destroy(_handle);
  }
}

/// Triangle mesh implementation
class FFITriangleMesh implements TriangleMesh {
  final ffi.Pointer<ffi_gen.RP3D_TriangleMesh> _handle;
  final FFIPhysicsCommon _common;

  FFITriangleMesh.internal(this._handle, this._common);

  @override
  ffi.Pointer<ffi_gen.RP3D_TriangleMesh> get handle => _handle;

  @override
  void dispose() {
    ffi_gen.rp3d_physics_common_destroy_triangle_mesh(_common.handleForShapes!, _handle);
  }

  @override
  int getVertexCount() {
    return ffi_gen.rp3d_triangle_mesh_get_nb_vertices(_handle);
  }

  @override
  int getTriangleCount() {
    return ffi_gen.rp3d_triangle_mesh_get_nb_triangles(_handle);
  }

  @override
  Vector3 getVertex(int index) {
    final outVertex = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    try {
      ffi_gen.rp3d_triangle_mesh_get_vertex(_handle, index, outVertex);
      return Vector3(
        outVertex.ref.x,
        outVertex.ref.y,
        outVertex.ref.z,
      );
    } finally {
      ffi_mem.calloc.free(outVertex);
    }
  }

  @override
  List<int> getTriangleIndices(int triangleIndex) {
    final outV1Index = ffi_mem.calloc<ffi.Uint32>();
    final outV2Index = ffi_mem.calloc<ffi.Uint32>();
    final outV3Index = ffi_mem.calloc<ffi.Uint32>();

    try {
      ffi_gen.rp3d_triangle_mesh_get_triangle_vertices_indices(
        _handle,
        triangleIndex,
        outV1Index,
        outV2Index,
        outV3Index,
      );

      return [
        outV1Index.value,
        outV2Index.value,
        outV3Index.value,
      ];
    } finally {
      ffi_mem.calloc.free(outV1Index);
      ffi_mem.calloc.free(outV2Index);
      ffi_mem.calloc.free(outV3Index);
    }
  }
}

/// Convex mesh implementation
class FFIConvexMesh implements ConvexMesh {
  final ffi.Pointer<ffi_gen.RP3D_ConvexMesh> _handle;
  final FFIPhysicsCommon _common;

  FFIConvexMesh.internal(this._handle, this._common);

  @override
  ffi.Pointer<ffi_gen.RP3D_ConvexMesh> get handle => _handle;

  @override
  void dispose() {
    ffi_gen.rp3d_physics_common_destroy_convex_mesh(_common.handleForShapes!, _handle);
  }
}

/// Convex mesh shape implementation
class FFIConvexMeshShape extends FFICollisionShape implements ConvexMeshShape {
  FFIConvexMeshShape.internal(ffi.Pointer<ffi_gen.RP3D_ConvexMeshShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final convexMeshShapeHandle = _handle.cast<ffi_gen.RP3D_ConvexMeshShape>();
    ffi_gen.rp3d_physics_common_destroy_convex_mesh_shape(_common.handleForShapes!, convexMeshShapeHandle);
  }
}

/// Concave mesh shape implementation
class FFIConcaveMeshShape extends FFICollisionShape implements ConcaveMeshShape {
  FFIConcaveMeshShape.internal(ffi.Pointer<ffi_gen.RP3D_ConcaveMeshShape> handle, FFIPhysicsCommon common)
      : super._(handle.cast<ffi_gen.RP3D_CollisionShape>(), common);

  @override
  void _destroyShape() {
    final concaveMeshShapeHandle = _handle.cast<ffi_gen.RP3D_ConcaveMeshShape>();
    ffi_gen.rp3d_physics_common_destroy_concave_mesh_shape(_common.handleForShapes!, concaveMeshShapeHandle);
  }
}