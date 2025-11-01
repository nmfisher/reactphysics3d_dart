import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart' as ffi_mem;
import 'package:reactphysics3d_dart/src/implementation/ffi_physics_world.dart';

import '../../reactphysics3d_dart.dart';
import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;
import '../interfaces/physics_common.dart';
import '../interfaces/physics_world.dart';
import '../interfaces/collision_shape.dart';
import 'ffi_collision_shape.dart';

/// Concrete implementation of physics common operations
class FFIPhysicsCommon implements PhysicsCommon {
  ffi.Pointer<ffi_gen.RP3D_PhysicsCommon>? _handle;

  @override
  ffi.Pointer<ffi_gen.RP3D_PhysicsCommon> get handle => _handle!;

  FFIPhysicsCommon() {
    _handle = ffi_gen.rp3d_physics_common_create();
    if (_handle == ffi.nullptr) {
      throw Exception('Failed to create PhysicsCommon');
    }
  }

  void dispose() {
    if (_handle != null) {
      ffi_gen.rp3d_physics_common_destroy(_handle!);
      _handle = null;
    }
  }

  @override
  PhysicsWorld createPhysicsWorld() {
    _checkDisposed();
    final worldHandle = ffi_gen.rp3d_physics_common_create_physics_world(
      _handle!,
    );
    if (worldHandle == ffi.nullptr) {
      throw Exception('Failed to create PhysicsWorld');
    }
    return FFIPhysicsWorld(worldHandle);
  }

  @override
  BoxShape createBoxShape(Vector3 extent) {
    _checkDisposed();
    final extentsPtr = _toFFIVector3(extent);
    try {
      final shapeHandle = ffi_gen.rp3d_physics_common_create_box_shape(
        _handle!,
        extentsPtr,
      );
      if (shapeHandle == ffi.nullptr) {
        throw Exception('Failed to create BoxShape');
      }
      return FFIBoxShape.internal(shapeHandle, this);
    } finally {
      ffi_mem.calloc.free(extentsPtr);
    }
  }

  @override
  SphereShape createSphereShape(double radius) {
    _checkDisposed();
    final shapeHandle = ffi_gen.rp3d_physics_common_create_sphere_shape(
      _handle!,
      radius,
    );
    if (shapeHandle == ffi.nullptr) {
      throw Exception('Failed to create SphereShape');
    }
    return FFISphereShape.internal(shapeHandle, this);
  }

  @override
  CapsuleShape createCapsuleShape(double radius, double height) {
    _checkDisposed();
    final shapeHandle = ffi_gen.rp3d_physics_common_create_capsule_shape(
      _handle!,
      radius,
      height,
    );
    if (shapeHandle == ffi.nullptr) {
      throw Exception('Failed to create CapsuleShape');
    }
    return FFICapsuleShape.internal(shapeHandle, this);
  }

  @override
  HeightField createHeightField({
    required int rows,
    required int columns,
    required List<double> heights,
    required double minHeight,
    required double maxHeight,
  }) {
    _checkDisposed();

    // Validate inputs
    if (rows <= 0 || columns <= 0) {
      throw ArgumentError('Rows and columns must be positive');
    }
    if (heights.length != rows * columns) {
      throw ArgumentError('Heights array length must match rows * columns');
    }

    // Convert height list to float array
    final heightsPtr = ffi_mem.calloc<ffi.Float>(heights.length);
    for (int i = 0; i < heights.length; i++) {
      heightsPtr[i] = heights[i];
    }

    try {
      final heightFieldHandle = ffi_gen.rp3d_physics_common_create_height_field(
        _handle!,
        rows,
        columns,
        heightsPtr,
        minHeight,
        maxHeight,
      );
      if (heightFieldHandle == ffi.nullptr) {
        throw Exception('Failed to create HeightField');
      }
      return FFIHeightField.internal(heightFieldHandle, this);
    } finally {
      ffi_mem.calloc.free(heightsPtr);
    }
  }

  @override
  HeightFieldShape createHeightFieldShape(HeightField heightField) {
    _checkDisposed();
    final ffiHeightField = heightField as FFIHeightField;
    final shapeHandle = ffi_gen.rp3d_physics_common_create_height_field_shape(
      _handle!,
      ffiHeightField.handle,
    );
    if (shapeHandle == ffi.nullptr) {
      throw Exception('Failed to create HeightFieldShape');
    }
    return FFIHeightFieldShape.internal(shapeHandle, this);
  }

  void _checkDisposed() {
    if (_handle == null) {
      throw Exception('PhysicsCommon has been disposed');
    }
  }

  /// Internal getter for shape classes to call destroy methods
  ffi.Pointer<ffi_gen.RP3D_PhysicsCommon>? get handleForShapes => _handle;

  @override
  TriangleVertexArray createTriangleVertexArray({
    required int verticesCount,
    required Float32List vertices,
    required int verticesStride,
    required int indicesCount,
    required Uint32List indices,
    required int indicesStride,
  }) {
    _checkDisposed();

    // Validate inputs
    if (verticesCount <= 0) {
      throw ArgumentError('Vertices count must be positive');
    }
    if (vertices.length < verticesCount * verticesStride ~/ 4) {
      throw ArgumentError(
        'Vertices array too small for specified count and stride',
      );
    }
    if (indicesCount <= 0) {
      throw ArgumentError('Indices count must be positive');
    }
    if (indices.length < indicesCount) {
      throw ArgumentError('Indices array too small for specified count');
    }

    // Allocate vertex data
    final verticesPtr = ffi_mem.calloc<ffi.Float>(
      verticesCount * verticesStride ~/ 4,
    );
    for (int i = 0; i < vertices.length; i++) {
      verticesPtr[i] = vertices[i];
    }

    // Allocate index data
    final indicesPtr = ffi_mem.calloc<ffi.Uint32>(indicesCount);
    for (int i = 0; i < indices.length; i++) {
      indicesPtr[i] = indices[i];
    }

    final triangleArrayHandle = ffi_gen.rp3d_triangle_vertex_array_create(
      verticesCount,
      verticesPtr,
      verticesStride,
      indicesCount,
      indicesPtr,
      indicesStride,
    );
    if (triangleArrayHandle == ffi.nullptr) {
      // Clean up allocated memory if array creation failed
      ffi_mem.calloc.free(verticesPtr);
      ffi_mem.calloc.free(indicesPtr);
      throw Exception('Failed to create TriangleVertexArray');
    }
    return FFITriangleVertexArray.internal(triangleArrayHandle, verticesPtr, indicesPtr);
  }

  @override
  PolygonVertexArray createPolygonVertexArray({
    required int verticesCount,
    required Float32List vertices,
    required int verticesStride,
    required int indicesCount,
    required Uint32List indices,
    required int indicesStride,
    required Uint32List polygonIndices,
    required int polygonIndicesStride,
  }) {
    _checkDisposed();

    // Polygon vertex arrays are not yet implemented
    throw UnimplementedError(
      'PolygonVertexArray creation is not yet implemented',
    );
  }

  @override
  TriangleMesh createTriangleMesh(TriangleVertexArray triangleVertexArray) {
    _checkDisposed();
    final ffiTriangleArray = triangleVertexArray as FFITriangleVertexArray;
    final triangleMeshHandle = ffi_gen.rp3d_physics_common_create_triangle_mesh(
      _handle!,
      ffiTriangleArray.handle,
    );
    if (triangleMeshHandle == ffi.nullptr) {
      throw Exception('Failed to create TriangleMesh');
    }
    return FFITriangleMesh.internal(triangleMeshHandle, this);
  }

  @override
  ConvexMesh createConvexMeshFromTriangles(
    TriangleVertexArray triangleVertexArray,
  ) {
    _checkDisposed();
    final ffiTriangleArray = triangleVertexArray as FFITriangleVertexArray;
    final convexMeshHandle = ffi_gen
        .rp3d_physics_common_create_convex_mesh_from_triangles(
          _handle!,
          ffiTriangleArray.handle,
        );
    if (convexMeshHandle == ffi.nullptr) {
      throw Exception(
        'Failed to create ConvexMesh from triangles - invalid vertex data or algorithm failed',
      );
    }
    return FFIConvexMesh.internal(convexMeshHandle, this);
  }

  @override
  ConvexMesh createConvexMeshFromPolygons(
    PolygonVertexArray polygonVertexArray,
  ) {
    _checkDisposed();
    // Convex mesh from polygons is not yet implemented
    throw UnimplementedError(
      'ConvexMesh creation from polygons is not yet implemented',
    );
  }

  @override
  ConvexMeshShape createConvexMeshShape(ConvexMesh convexMesh) {
    _checkDisposed();
    final ffiConvexMesh = convexMesh as FFIConvexMesh;
    final convexMeshShapeHandle = ffi_gen
        .rp3d_physics_common_create_convex_mesh_shape(
          _handle!,
          ffiConvexMesh.handle,
        );
    if (convexMeshShapeHandle == ffi.nullptr) {
      throw Exception('Failed to create ConvexMeshShape');
    }
    return FFIConvexMeshShape.internal(convexMeshShapeHandle, this);
  }

  @override
  ConcaveMeshShape createConcaveMeshShape(
    TriangleMesh triangleMesh, {
    Vector3? scaling,
  }) {
    _checkDisposed();
    final ffiTriangleMesh = triangleMesh as FFITriangleMesh;

    final scalePtr = _toFFIVector3(scaling ?? Vector3.all(1.0));
    try {
      final concaveMeshShapeHandle = ffi_gen
          .rp3d_physics_common_create_concave_mesh_shape(
            _handle!,
            ffiTriangleMesh.handle,
            scalePtr,
          );
      if (concaveMeshShapeHandle == ffi.nullptr) {
        throw Exception('Failed to create ConcaveMeshShape');
      }
      return FFIConcaveMeshShape.internal(concaveMeshShapeHandle, this);
    } finally {
      ffi_mem.calloc.free(scalePtr);
    }
  }

  /// Helper function to convert Vector3 to FFI Vector3
  ffi.Pointer<ffi_gen.RP3D_Vector3> _toFFIVector3(Vector3 v) {
    final ptr = ffi_mem.calloc<ffi_gen.RP3D_Vector3>();
    ptr.ref.x = v.x;
    ptr.ref.y = v.y;
    ptr.ref.z = v.z;
    return ptr;
  }
}
