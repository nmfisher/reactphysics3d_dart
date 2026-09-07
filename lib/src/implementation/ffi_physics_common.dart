import 'native_lifetime.dart';
import 'ffi_common_resource.dart';
import 'package:reactphysics3d_dart/src/implementation/ffi_physics_world.dart';
import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart';
import 'ffi_collision_shape.dart';

/// Concrete implementation of physics common operations
class FFIPhysicsCommon implements PhysicsCommon {
  Pointer<RP3D_PhysicsCommon>? _handle;
  final lifetime = NativeLifetime();
  final worlds = <FFIPhysicsWorld>{};
  final resources = <FFICommonResource<NativeType>>[];

  @override
  Pointer<RP3D_PhysicsCommon> get handle {
    lifetime.check();
    return _handle!;
  }

  FFIPhysicsCommon() {
    _handle = rp3d_physics_common_create();
    if (_handle == nullptr) {
      throw Exception('Failed to create PhysicsCommon');
    }
  }

  @override
  void dispose() {
    if (lifetime.isDisposed) return;
    for (final world in worlds.toList()) {
      world.dispose();
    }
    for (final resource in resources.reversed.toList()) {
      resource.dispose();
    }
    rp3d_physics_common_destroy(handle);
    _handle = null;
    lifetime.invalidate();
  }

  @override
  void destroyPhysicsWorld(PhysicsWorld world) {
    lifetime.check();
    if (world is! FFIPhysicsWorld || !identical(world.common, this)) {
      throw ArgumentError('World belongs to another PhysicsCommon');
    }
    world.dispose();
  }

  @override
  PhysicsWorld createPhysicsWorld() {
    _checkDisposed();
    final worldHandle = rp3d_physics_common_create_physics_world(_handle!);
    if (worldHandle == nullptr) {
      throw Exception('Failed to create PhysicsWorld');
    }
    final world = FFIPhysicsWorld(worldHandle, this);
    worlds.add(world);
    return world;
  }

  @override
  BoxShape createBoxShape(Vector3 extent) {
    final stack = saveNativeStack();
    try {
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
    } finally {
      restoreNativeStack(stack);
    }
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

  // Allocate 1024-byte error buffer
  static final int errorBufferSize = 1024;

  @override
  HeightField createHeightFieldFloat({
    required int rows,
    required int columns,
    required Float32List heights,
    required double minHeight,
    required double maxHeight,
  }) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();

      // Validate inputs
      if (rows <= 0 || columns <= 0) {
        throw Exception('Rows and columns must be positive');
      }
      if (heights.length != rows * columns) {
        throw Exception('Heights array length must match rows * columns');
      }

      // Initialize error buffer with null bytes
      final _error = makeUint8List(errorBufferSize);
      _error.fillRange(0, _error.length, 0);

      final heightFieldHandle = rp3d_physics_common_create_height_field_float(
        _handle!,
        rows,
        columns,
        heights.address,
        minHeight,
        maxHeight,
        _error.address.cast(),
        errorBufferSize,
      );

      if (heightFieldHandle == nullptr || _error[0] != 0) {
        if (heightFieldHandle != nullptr) {
          rp3d_physics_common_destroy_height_field(handle, heightFieldHandle);
        }
        final message = String.fromCharCodes(
          _error,
        ).split('\x00').where((part) => part.isNotEmpty).join('; ');
        throw Exception(
          'Failed to create HeightField${message.isEmpty ? "" : ": $message"}',
        );
      }

      return FFIHeightField.internal(heightFieldHandle, this)
        ..rows = rows
        ..columns = columns;
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  HeightField createHeightFieldInt({
    required int rows,
    required int columns,
    required Int32List heights,
    required double minHeight,
    required double maxHeight,
    required double integerHeightScale,
  }) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();

      // Validate inputs
      if (rows <= 0 || columns <= 0) {
        throw ArgumentError('Rows and columns must be positive');
      }
      if (heights.length != rows * columns) {
        throw ArgumentError('Heights array length must match rows * columns');
      }

      final _error = makeUint8List(errorBufferSize);
      _error.fillRange(0, _error.length, 0);

      final heightFieldHandle = rp3d_physics_common_create_height_field_int(
        _handle!,
        rows,
        columns,
        heights.address,
        minHeight,
        maxHeight,
        integerHeightScale,
        _error.address.cast(),
        errorBufferSize,
      );

      if (heightFieldHandle == nullptr || _error[0] != 0) {
        if (heightFieldHandle != nullptr) {
          rp3d_physics_common_destroy_height_field(handle, heightFieldHandle);
        }
        final message = String.fromCharCodes(
          _error,
        ).split('\x00').where((part) => part.isNotEmpty).join('; ');
        throw Exception(
          'Failed to create HeightField${message.isEmpty ? "" : ": $message"}',
        );
      }

      return FFIHeightField.internal(heightFieldHandle, this)
        ..rows = rows
        ..columns = columns;
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  HeightFieldShape createHeightFieldShape(
    HeightField heightField, {
    Vector3? scaling,
  }) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();
      scaling ??= Vector3.all(1);
      final rpScaling = _toFFIVector3(scaling);
      final ffiHeightField = heightField as FFIHeightField;
      ffiHeightField.requireSameCommon(this);
      final shapeHandle = rp3d_physics_common_create_height_field_shape(
        _handle!,
        ffiHeightField.handle,
        rpScaling.address,
      );
      if (shapeHandle == nullptr) {
        throw Exception('Failed to create HeightFieldShape');
      }
      return FFIHeightFieldShape.internal(shapeHandle, this, ffiHeightField);
    } finally {
      restoreNativeStack(stack);
    }
  }

  void _checkDisposed() {
    if (_handle == null) {
      throw StateError('PhysicsCommon has been disposed');
    }
  }

  @override
  TriangleVertexArray createTriangleVertexArray({
    required Float32List vertices,
    required Uint32List indices,
  }) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();
      if (vertices.length % 3 != 0 || vertices.any((v) => !v.isFinite)) {
        throw ArgumentError('Vertices must contain finite XYZ triples');
      }
      if (indices.any((i) => i >= vertices.length ~/ 3)) {
        throw ArgumentError('Vertex index out of range');
      }
      if (vertices.length < 9 || indices.isEmpty || indices.length % 3 != 0) {
        throw ArgumentError('Triangle indices must contain complete triples');
      }

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
      return FFITriangleVertexArray.internal(triangleArrayHandle, this);
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  PolygonVertexArray createPolygonVertexArray({
    required Float32List vertices,
    required Uint32List indices,
    required Uint32List polygonIndices,
  }) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();
      if (vertices.length % 3 != 0 || vertices.any((v) => !v.isFinite)) {
        throw ArgumentError('Vertices must contain finite XYZ triples');
      }
      if (indices.any((i) => i >= vertices.length ~/ 3)) {
        throw ArgumentError('Vertex index out of range');
      }
      if (polygonIndices.isEmpty || polygonIndices.length.isOdd) {
        throw ArgumentError(
          'Faces must contain (vertex count, index base) pairs',
        );
      }
      for (var i = 0; i < polygonIndices.length; i += 2) {
        if (polygonIndices[i] < 3 ||
            polygonIndices[i + 1] + polygonIndices[i] > indices.length) {
          throw ArgumentError('Invalid polygon face descriptor');
        }
      }

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
        polygonIndices.length ~/ 2,
      );

      if (polygonArrayHandle == nullptr) {
        throw Exception('Failed to create PolygonVertexArray');
      }

      return FFIPolygonVertexArray.internal(
        polygonArrayHandle,
        this,
        indices.length,
      );
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  VertexArray createVertexArray(Float32List vertices) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();
      if (vertices.length % 3 != 0 || vertices.any((v) => !v.isFinite)) {
        throw ArgumentError('Vertices must contain finite XYZ triples');
      }

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

      return FFIVertexArray.internal(vertexArrayHandle, this);
    } finally {
      restoreNativeStack(stack);
    }
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
  ConvexMeshShape createConvexMeshShape(
    ConvexMesh convexMesh, {
    Vector3? scaling,
  }) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();
      final ffiConvexMesh = convexMesh as FFIConvexMesh;
      ffiConvexMesh.requireSameCommon(this);

      final scalePtr = _toFFIVector3(scaling ?? Vector3.all(1.0));

      final convexMeshShapeHandle =
          rp3d_physics_common_create_convex_mesh_shape(
            _handle!,
            ffiConvexMesh.handle,
            scalePtr.address,
          );
      if (convexMeshShapeHandle == nullptr) {
        throw Exception('Failed to create ConvexMeshShape');
      }
      return FFIConvexMeshShape.internal(
        convexMeshShapeHandle,
        this,
        ffiConvexMesh,
      );
    } finally {
      restoreNativeStack(stack);
    }
  }

  @override
  ConcaveMeshShape createConcaveMeshShape(
    TriangleMesh triangleMesh, {
    Vector3? scaling,
  }) {
    final stack = saveNativeStack();
    try {
      _checkDisposed();
      final ffiTriangleMesh = triangleMesh as FFITriangleMesh;
      ffiTriangleMesh.requireSameCommon(this);

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
      return FFIConcaveMeshShape.internal(
        concaveMeshShapeHandle,
        this,
        ffiTriangleMesh,
      );
    } finally {
      restoreNativeStack(stack);
    }
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
