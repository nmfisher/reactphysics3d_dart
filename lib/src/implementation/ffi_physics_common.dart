import 'dart:typed_data';
import 'package:reactphysics3d_dart/src/implementation/ffi_physics_world.dart';
import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart';
import 'ffi_collision_shape.dart';

/// Concrete implementation of physics common operations
class FFIPhysicsCommon implements PhysicsCommon {
  Pointer<RP3D_PhysicsCommon>? _handle;

  @override
  Pointer<RP3D_PhysicsCommon> get handle => _handle!;

  FFIPhysicsCommon() {
    _handle = rp3d_physics_common_create();
    if (_handle == nullptr) {
      throw Exception('Failed to create PhysicsCommon');
    }
  }

  void dispose() {
    if (_handle != null) {
      rp3d_physics_common_destroy(_handle!);
      _handle = null;
    }
  }

  @override
  PhysicsWorld createPhysicsWorld() {
    _checkDisposed();
    final worldHandle = rp3d_physics_common_create_physics_world(_handle!);
    if (worldHandle == nullptr) {
      throw Exception('Failed to create PhysicsWorld');
    }
    return FFIPhysicsWorld(worldHandle);
  }

  @override
  BoxShape createBoxShape(Vector3 extent) {
    _checkDisposed();
    final extentsPtr = _toFFIVector3(extent);

    final shapeHandle = rp3d_physics_common_create_box_shape(
      _handle!,
      extentsPtr.address,
    );
    if (shapeHandle == nullptr) {
      throw Exception('Failed to create BoxShape');
    }
    return FFIBoxShape.internal(shapeHandle, this);
  }

  @override
  SphereShape createSphereShape(double radius) {
    _checkDisposed();
    final shapeHandle = rp3d_physics_common_create_sphere_shape(
      _handle!,
      radius,
    );
    if (shapeHandle == nullptr) {
      throw Exception('Failed to create SphereShape');
    }
    return FFISphereShape.internal(shapeHandle, this);
  }

  @override
  CapsuleShape createCapsuleShape(double radius, double height) {
    _checkDisposed();
    final shapeHandle = rp3d_physics_common_create_capsule_shape(
      _handle!,
      radius,
      height,
    );
    if (shapeHandle == nullptr) {
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
    final heightsPtr = makeFloat32List(heights.length);
    heightsPtr.setRange(0, heights.length, heights);

    final heightFieldHandle = rp3d_physics_common_create_height_field(
      _handle!,
      rows,
      columns,
      heightsPtr.address,
      minHeight,
      maxHeight,
    );
    if (heightFieldHandle == nullptr) {
      throw Exception('Failed to create HeightField');
    }
    return FFIHeightField.internal(heightFieldHandle, this);
  }

  @override
  HeightFieldShape createHeightFieldShape(HeightField heightField) {
    _checkDisposed();
    final ffiHeightField = heightField as FFIHeightField;
    final shapeHandle = rp3d_physics_common_create_height_field_shape(
      _handle!,
      ffiHeightField.handle,
    );
    if (shapeHandle == nullptr) {
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
  Pointer<RP3D_PhysicsCommon>? get handleForShapes => _handle;

  @override
  TriangleVertexArray createTriangleVertexArray({
    required Float32List vertices,
    required Uint32List indices,
  }) {
    _checkDisposed();

    // Allocate vertex data
    final verticesPtr = makeFloat32List(vertices.length);
    for (int i = 0; i < vertices.length; i++) {
      verticesPtr[i] = vertices[i];
    }

    // Allocate index data
    final indicesPtr = makeInt32List(indices.length);
    for (int i = 0; i < indices.length; i++) {
      indicesPtr[i] = indices[i];
    }

    final triangleArrayHandle = rp3d_triangle_vertex_array_create(
      vertices.length ~/ 3,
      verticesPtr.address,
      3 * sizeOf<Float>(),
      indices.length,
      indicesPtr.address.cast(),
      3 * sizeOf<Uint32>(),
    );
    if (triangleArrayHandle == nullptr) {
      throw Exception('Failed to create TriangleVertexArray');
    }
    return FFITriangleVertexArray.internal(
      triangleArrayHandle,
      verticesPtr,
      indicesPtr,
    );
  }

  @override
  PolygonVertexArray createPolygonVertexArray({
    required Float32List vertices,
    required Uint32List indices,
    required Uint32List polygonIndices,
  }) {
    _checkDisposed();

    // Allocate vertex data
    final verticesPtr = makeFloat32List(vertices.length);
    for (int i = 0; i < vertices.length; i++) {
      verticesPtr[i] = vertices[i];
    }

    // Allocate index data
    final indicesPtr = makeInt32List(indices.length);
    for (int i = 0; i < indices.length; i++) {
      indicesPtr[i] = indices[i];
    }

    // Allocate polygon indices data
    // Format: [nbVertices1, indexBase1, nbVertices2, indexBase2, ...]
    final polygonIndicesPtr = makeInt32List(polygonIndices.length);
    for (int i = 0; i < polygonIndices.length; i++) {
      polygonIndicesPtr[i] = polygonIndices[i];
    }

    final polygonArrayHandle = rp3d_polygon_vertex_array_create(
      vertices.length ~/ 3, // nbVertices (3 floats per vertex)
      verticesPtr.address,
      3 * sizeOf<Float>(), // verticesStride: 3 floats * 4 bytes
      indices.length, // nbIndices (used to determine nbFaces)
      indicesPtr.address.cast(),
      sizeOf<Uint32>(), // indicesStride: 4 bytes per int
      polygonIndicesPtr.address.cast(),
      2 * sizeOf<Uint32>(), // polygonIndicesStride: 2 values per face
    );

    if (polygonArrayHandle == nullptr) {
      throw Exception('Failed to create PolygonVertexArray');
    }

    return FFIPolygonVertexArray.internal(
      polygonArrayHandle,
      verticesPtr,
      indicesPtr,
      polygonIndicesPtr,
    );
  }

  @override
  VertexArray createVertexArray(Float32List vertices) {
    _checkDisposed();

    // Allocate vertex data
    final verticesPtr = makeFloat32List(vertices.length);
    for (int i = 0; i < vertices.length; i++) {
      verticesPtr[i] = vertices[i];
    }

    final vertexArrayHandle = rp3d_vertex_array_create(
      vertices.length ~/ 3, // nbVertices (3 floats per vertex)
      verticesPtr.address,
      3 * sizeOf<Float>(), // stride: 3 floats * 4 bytes
    );

    if (vertexArrayHandle == nullptr) {
      throw Exception('Failed to create VertexArray');
    }

    return FFIVertexArray.internal(vertexArrayHandle, verticesPtr);
  }

  @override
  TriangleMesh createTriangleMesh(TriangleVertexArray triangleVertexArray) {
    _checkDisposed();
    final ffiTriangleArray = triangleVertexArray as FFITriangleVertexArray;
    final triangleMeshHandle = rp3d_physics_common_create_triangle_mesh(
      _handle!,
      ffiTriangleArray.handle,
    );
    if (triangleMeshHandle == nullptr) {
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
    final convexMeshHandle =
        rp3d_physics_common_create_convex_mesh_from_triangles(
          _handle!,
          ffiTriangleArray.handle,
        );
    if (convexMeshHandle == nullptr) {
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

    final convexMeshHandle =
        rp3d_physics_common_create_convex_mesh_from_polygons(
          _handle!,
          polygonVertexArray.handle,
        );
    if (convexMeshHandle == nullptr) {
      throw Exception(
        'Failed to create ConvexMesh from triangles - invalid vertex data or algorithm failed',
      );
    }
    return FFIConvexMesh.internal(convexMeshHandle, this);
  }

  @override
  ConvexMesh? createConvexMeshFromVertices(VertexArray vertexArray) {
    _checkDisposed();
    final convexMeshHandle =
        rp3d_physics_common_create_convex_mesh_from_vertices(
          _handle!,
          vertexArray.handle,
        );

    // Return null if convex mesh creation failed (QuickHull algorithm can fail)
    if (convexMeshHandle == nullptr) {
      return null;
    }

    return FFIConvexMesh.internal(convexMeshHandle, this);
  }

  @override
  ConvexMeshShape createConvexMeshShape(ConvexMesh convexMesh, {Vector3? scaling}) {
    _checkDisposed();
    final ffiConvexMesh = convexMesh as FFIConvexMesh;

    final scalePtr = _toFFIVector3(scaling ?? Vector3.all(1.0));

    final convexMeshShapeHandle = rp3d_physics_common_create_convex_mesh_shape(
      _handle!,
      ffiConvexMesh.handle,
      scalePtr.address,
    );
    if (convexMeshShapeHandle == nullptr) {
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

    final concaveMeshShapeHandle =
        rp3d_physics_common_create_concave_mesh_shape(
          _handle!,
          ffiTriangleMesh.handle,
          scalePtr.address,
        );
    if (concaveMeshShapeHandle == nullptr) {
      throw Exception('Failed to create ConcaveMeshShape');
    }
    return FFIConcaveMeshShape.internal(concaveMeshShapeHandle, this);
  }

  /// Helper function to convert Vector3 to FFI Vector3
  RP3D_Vector3 _toFFIVector3(Vector3 v) {
    final ptr = StructAllocator.create<RP3D_Vector3>();
    ptr.x = v.x;
    ptr.y = v.y;
    ptr.z = v.z;
    return ptr;
  }
}
