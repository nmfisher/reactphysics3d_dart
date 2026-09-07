import '../bindings/src/bindings.dart';
import 'package:vector_math/vector_math_64.dart';
import '../interfaces/collision_shape.dart';
import 'ffi_physics_common.dart';
import 'ffi_common_resource.dart';

abstract class FFICollisionShape extends FFICommonResource<RP3D_CollisionShape>
    implements CollisionShape {
  final FFICommonResource<NativeType>? data;
  FFICollisionShape(
    Pointer<RP3D_CollisionShape> handle,
    FFIPhysicsCommon common, [
    this.data,
  ]) : super(handle, common) {
    data?.users.add(this);
  }
  @override
  void dispose() {
    super.dispose();
    if (lifetime.isDisposed) data?.users.remove(this);
  }
}

class FFIBoxShape extends FFICollisionShape implements BoxShape {
  FFIBoxShape.internal(Pointer<RP3D_BoxShape> handle, FFIPhysicsCommon common)
    : super(handle.cast<RP3D_CollisionShape>(), common);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_box_shape(
      common.handle,
      handle.cast<RP3D_BoxShape>(),
    );
  }
}

class FFISphereShape extends FFICollisionShape implements SphereShape {
  FFISphereShape.internal(
    Pointer<RP3D_SphereShape> handle,
    FFIPhysicsCommon common,
  ) : super(handle.cast<RP3D_CollisionShape>(), common);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_sphere_shape(
      common.handle,
      handle.cast<RP3D_SphereShape>(),
    );
  }
}

class FFICapsuleShape extends FFICollisionShape implements CapsuleShape {
  FFICapsuleShape.internal(
    Pointer<RP3D_CapsuleShape> handle,
    FFIPhysicsCommon common,
  ) : super(handle.cast<RP3D_CollisionShape>(), common);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_capsule_shape(
      common.handle,
      handle.cast<RP3D_CapsuleShape>(),
    );
  }
}

class FFIHeightField extends FFICommonResource<RP3D_HeightField>
    implements HeightField {
  FFIHeightField.internal(
    Pointer<RP3D_HeightField> handle,
    FFIPhysicsCommon common,
  ) : super(handle, common);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_height_field(
      common.handle,
      handle.cast<RP3D_HeightField>(),
    );
  }

  // Set by the factory after successful native creation.
  int rows = 0;
  int columns = 0;
}

class FFIHeightFieldShape extends FFICollisionShape
    implements HeightFieldShape {
  FFIHeightFieldShape.internal(
    Pointer<RP3D_HeightFieldShape> handle,
    FFIPhysicsCommon common,
    FFIHeightField data,
  ) : super(handle.cast<RP3D_CollisionShape>(), common, data);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_height_field_shape(
      common.handle,
      handle.cast<RP3D_HeightFieldShape>(),
    );
  }

  @override
  void setScale(Vector3 scale) {
    final stack = saveNativeStack();
    try {
      if (!scale.x.isFinite ||
          !scale.y.isFinite ||
          !scale.z.isFinite ||
          scale.x <= 0 ||
          scale.y <= 0 ||
          scale.z <= 0) {
        throw ArgumentError('Scale components must be finite and positive');
      }
      final value = StructAllocator.create<RP3D_Vector3>();
      value.x = scale.x;
      value.y = scale.y;
      value.z = scale.z;
      rp3d_concave_shape_set_scale(handle.cast(), value.address);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  Vector3 getVertexAt(int row, int column) {
    final stack = saveNativeStack();
    try {
      final field = data! as FFIHeightField;
      RangeError.checkValueInInterval(row, 0, field.rows - 1, 'row');
      RangeError.checkValueInInterval(column, 0, field.columns - 1, 'column');
      final out = StructAllocator.create<RP3D_Vector3>();
      rp3d_height_field_shape_get_vertex_at(
        handle.cast(),
        row,
        column,
        out.address,
      );
      return Vector3(out.x, out.y, out.z);
    } finally {
      restoreNativeStack(stack);
    }
  }
}

class FFITriangleMesh extends FFICommonResource<RP3D_TriangleMesh>
    implements TriangleMesh {
  FFITriangleMesh.internal(
    Pointer<RP3D_TriangleMesh> handle,
    FFIPhysicsCommon common,
  ) : super(handle, common);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_triangle_mesh(
      common.handle,
      handle.cast<RP3D_TriangleMesh>(),
    );
  }

  @override
  int getVertexCount() => rp3d_triangle_mesh_get_nb_vertices(handle);
  @override
  int getTriangleCount() => rp3d_triangle_mesh_get_nb_triangles(handle);
  @override
  Vector3 getVertex(int index) {
    final stack = saveNativeStack();
    try {
      RangeError.checkValueInInterval(index, 0, getVertexCount() - 1, 'index');
      final out = StructAllocator.create<RP3D_Vector3>();
      rp3d_triangle_mesh_get_vertex(handle, index, out.address);
      return Vector3(out.x, out.y, out.z);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  List<int> getTriangleIndices(int index) {
    final stack = saveNativeStack();
    try {
      RangeError.checkValueInInterval(
        index,
        0,
        getTriangleCount() - 1,
        'index',
      );
      final out = makeInt32List(3);
      try {
        rp3d_triangle_mesh_get_triangle_vertices_indices(
          handle,
          index,
          out.address.cast(),
        );
        return List<int>.of(out);
      } finally {
        out.free();
      }
    } finally {
      restoreNativeStack(stack);
    }
  }
}

class FFIConvexMesh extends FFICommonResource<RP3D_ConvexMesh>
    implements ConvexMesh {
  FFIConvexMesh.internal(
    Pointer<RP3D_ConvexMesh> handle,
    FFIPhysicsCommon common,
  ) : super(handle, common);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_convex_mesh(
      common.handle,
      handle.cast<RP3D_ConvexMesh>(),
    );
  }
}

class FFIConvexMeshShape extends FFICollisionShape implements ConvexMeshShape {
  FFIConvexMeshShape.internal(
    Pointer<RP3D_ConvexMeshShape> handle,
    FFIPhysicsCommon common,
    FFIConvexMesh data,
  ) : super(handle.cast<RP3D_CollisionShape>(), common, data);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_convex_mesh_shape(
      common.handle,
      handle.cast<RP3D_ConvexMeshShape>(),
    );
  }
}

class FFIConcaveMeshShape extends FFICollisionShape
    implements ConcaveMeshShape {
  FFIConcaveMeshShape.internal(
    Pointer<RP3D_ConcaveMeshShape> handle,
    FFIPhysicsCommon common,
    FFITriangleMesh data,
  ) : super(handle.cast<RP3D_CollisionShape>(), common, data);
  @override
  void destroyNative() {
    rp3d_physics_common_destroy_concave_mesh_shape(
      common.handle,
      handle.cast<RP3D_ConcaveMeshShape>(),
    );
  }
}

class FFITriangleVertexArray extends FFICommonResource<RP3D_TriangleVertexArray>
    implements TriangleVertexArray {
  FFITriangleVertexArray.internal(super.rawHandle, super.common);
  @override
  void destroyNative() => rp3d_triangle_vertex_array_destroy(handle);
  @override
  int getVertexCount() => rp3d_triangle_vertex_array_get_nb_vertices(handle);
  @override
  int getTriangleCount() => rp3d_triangle_vertex_array_get_nb_triangles(handle);
  @override
  Vector3 getVertex(int index) {
    RangeError.checkValueInInterval(index, 0, getVertexCount() - 1, 'index');
    final start = rp3d_triangle_vertex_array_get_vertices_start(handle);
    return Vector3(
      start[index * 3],
      start[index * 3 + 1],
      start[index * 3 + 2],
    );
  }

  @override
  List<int> getTriangleIndices(int index) {
    final stack = saveNativeStack();
    try {
      RangeError.checkValueInInterval(
        index,
        0,
        getTriangleCount() - 1,
        'index',
      );
      final out = makeInt32List(3);
      try {
        rp3d_triangle_vertex_array_get_triangle_vertices_indices(
          handle,
          index,
          out.address.cast(),
        );
        return List<int>.of(out);
      } finally {
        out.free();
      }
    } finally {
      restoreNativeStack(stack);
    }
  }
}

class FFIVertexArray extends FFICommonResource<RP3D_VertexArray>
    implements VertexArray {
  FFIVertexArray.internal(super.rawHandle, super.common);
  @override
  void destroyNative() => rp3d_vertex_array_destroy(handle);
  @override
  int getVertexCount() => rp3d_vertex_array_get_nb_vertices(handle);
  @override
  int getStride() => rp3d_vertex_array_get_stride(handle);
  @override
  Vector3 getVertex(int index) {
    RangeError.checkValueInInterval(index, 0, getVertexCount() - 1, 'index');
    final start = rp3d_vertex_array_get_vertices_start(handle);
    return Vector3(
      start[index * 3],
      start[index * 3 + 1],
      start[index * 3 + 2],
    );
  }
}

class FFIPolygonVertexArray extends FFICommonResource<RP3D_PolygonVertexArray>
    implements PolygonVertexArray {
  final int indexCount;
  FFIPolygonVertexArray.internal(
    super.rawHandle,
    super.common,
    this.indexCount,
  );
  @override
  void destroyNative() => rp3d_polygon_vertex_array_destroy(handle);
  @override
  int getVertexCount() => rp3d_polygon_vertex_array_get_nb_vertices(handle);
  @override
  int getFaceCount() => rp3d_polygon_vertex_array_get_nb_faces(handle);
  @override
  Vector3 getVertex(int index) {
    final stack = saveNativeStack();
    try {
      RangeError.checkValueInInterval(index, 0, getVertexCount() - 1, 'index');
      final out = makeFloat32List(3);
      try {
        rp3d_polygon_vertex_array_get_vertex(handle, index, out.address);
        return Vector3(out[0], out[1], out[2]);
      } finally {
        out.free();
      }
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  Map<String, int> getPolygonFace(int index) {
    final stack = saveNativeStack();
    try {
      RangeError.checkValueInInterval(index, 0, getFaceCount() - 1, 'index');
      final count = makeUint32List(1);
      final base = makeUint32List(1);
      try {
        rp3d_polygon_vertex_array_get_polygon_face(
          handle,
          index,
          count.address,
          base.address,
        );
        return {'nbVertices': count[0], 'indexBase': base[0]};
      } finally {
        count.free();
        base.free();
      }
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  int getIndicesStride() =>
      rp3d_polygon_vertex_array_get_indices_stride(handle);
  @override
  int getIndex(int index) {
    RangeError.checkValueInInterval(index, 0, indexCount - 1, 'index');
    return rp3d_polygon_vertex_array_get_indices_start(handle)[index];
  }

  @override
  int getVertexIndexInFace(int faceIndex, int vertexInFace) {
    final face = getPolygonFace(faceIndex);
    RangeError.checkValueInInterval(
      vertexInFace,
      0,
      face['nbVertices']! - 1,
      'vertexInFace',
    );
    return rp3d_polygon_vertex_array_get_vertex_index_in_face(
      handle,
      faceIndex,
      vertexInFace,
    );
  }
}
