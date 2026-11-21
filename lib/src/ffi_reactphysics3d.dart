import './bindings/src/bindings.dart';
import '../reactphysics3d_dart.dart';
import 'implementation/ffi_physics_common.dart';
import 'implementation/ffi_physics_world.dart';

extension TransformStruct on Transform {
  void validate() {
    if (!position.x.isFinite || !position.y.isFinite || !position.z.isFinite) {
      throw ArgumentError('Transform position must be finite');
    }
    final lenSq = orientation.length2;
    if (!lenSq.isFinite || (lenSq - 1.0).abs() > 1e-3) {
      throw ArgumentError('Transform orientation must be a unit quaternion');
    }
  }

  /// Helper function to convert Transform to FFI Transform
  RP3D_Transform toStruct() {
    validate();
    final xform = StructAllocator.create<RP3D_Transform>();
    xform.position.x = position.x;
    xform.position.y = position.y;
    xform.position.z = position.z;
    xform.orientation.x = orientation.x;
    xform.orientation.y = orientation.y;
    xform.orientation.z = orientation.z;
    xform.orientation.w = orientation.w;
    return xform;
  }
}

extension TransformPointer on RP3D_Transform {
  Transform toDart() {
    var dartPosition = Vector3(position.x, position.y, position.z);
    var dartOrientation = Quaternion(
      orientation.x,
      orientation.y,
      orientation.z,
      orientation.w,
    );
    return (position: dartPosition, orientation: dartOrientation);
  }
}

class FFIReactPhysics3D implements ReactPhysics3D {
  final FFIPhysicsCommon _physicsCommon;

  @override
  PhysicsCommon get physicsCommon => _physicsCommon;

  FFIReactPhysics3D() : _physicsCommon = FFIPhysicsCommon();

  @override
  PhysicsWorld createWorld() {
    return _physicsCommon.createPhysicsWorld();
  }

  @override
  BoxShape createBoxShape(Vector3 extent) {
    return _physicsCommon.createBoxShape(extent);
  }

  @override
  SphereShape createSphereShape(double radius) {
    return _physicsCommon.createSphereShape(radius);
  }

  @override
  CapsuleShape createCapsuleShape(double radius, double height) {
    return _physicsCommon.createCapsuleShape(radius, height);
  }

  @override
  HeightField createHeightFieldFloat({
    required int rows,
    required int columns,
    required Float32List heights,
    required double minHeight,
    required double maxHeight,
  }) {
    return _physicsCommon.createHeightFieldFloat(
      rows: rows,
      columns: columns,
      heights: heights,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
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
    return _physicsCommon.createHeightFieldInt(
      rows: rows,
      columns: columns,
      heights: heights,
      minHeight: minHeight,
      maxHeight: maxHeight,
      integerHeightScale: integerHeightScale,
    );
  }

  @override
  HeightFieldShape createHeightFieldShape(
    HeightField heightField, {
    Vector3? scaling,
  }) {
    return _physicsCommon.createHeightFieldShape(heightField, scaling: scaling);
  }

  @override
  TriangleVertexArray createTriangleVertexArray({
    required Float32List vertices,
    required Uint32List indices,
  }) {
    _physicsCommon.lifetime.check();
    if (vertices.length < 9 || indices.length < 3) {
      throw const ReactPhysics3DException(
        "At least one triangle (3 vertices) required",
      );
    }
    return _physicsCommon.createTriangleVertexArray(
      vertices: vertices,
      indices: indices,
    );
  }

  @override
  PolygonVertexArray createPolygonVertexArray({
    required Float32List vertices,
    required Uint32List indices,
    required Uint32List polygonIndices,
  }) {
    return _physicsCommon.createPolygonVertexArray(
      vertices: vertices,

      indices: indices,

      polygonIndices: polygonIndices,
    );
  }

  @override
  VertexArray createVertexArray(Float32List vertices) {
    return _physicsCommon.createVertexArray(vertices);
  }

  @override
  TriangleMesh createTriangleMesh(TriangleVertexArray triangleVertexArray) {
    return _physicsCommon.createTriangleMesh(triangleVertexArray);
  }

  @override
  ConvexMesh createConvexMeshFromTriangles(
    TriangleVertexArray triangleVertexArray,
  ) {
    return _physicsCommon.createConvexMeshFromTriangles(triangleVertexArray);
  }

  @override
  ConvexMesh createConvexMeshFromPolygons(
    PolygonVertexArray polygonVertexArray,
  ) {
    return _physicsCommon.createConvexMeshFromPolygons(polygonVertexArray);
  }

  @override
  ConvexMesh? createConvexMeshFromVertices(VertexArray vertexArray) {
    return _physicsCommon.createConvexMeshFromVertices(vertexArray);
  }

  @override
  ConvexMeshShape createConvexMeshShape(
    ConvexMesh convexMesh, {
    Vector3? scaling,
  }) {
    return _physicsCommon.createConvexMeshShape(convexMesh, scaling: scaling);
  }

  @override
  ConcaveMeshShape createConcaveMeshShape(
    TriangleMesh triangleMesh, {
    Vector3? scaling,
  }) {
    return _physicsCommon.createConcaveMeshShape(
      triangleMesh,
      scaling: scaling,
    );
  }

  @override
  RigidBody createRigidBody(
    PhysicsWorld world, {
    Transform? transform,
    BodyType type = BodyType.DYNAMIC,
    double mass = 1.0,
  }) {
    _physicsCommon.lifetime.check();
    if (world is! FFIPhysicsWorld ||
        !identical(world.common, _physicsCommon)) {
      throw ArgumentError('World belongs to another PhysicsCommon');
    }
    if (!mass.isFinite || mass < 0) {
      throw ArgumentError.value(mass, 'mass', 'Must be finite and non-negative');
    }
    final rigidBody = world.createRigidBody(transform: transform);
    rigidBody.type = type;
    rigidBody.mass = mass;

    return rigidBody;
  }

  /// Dispose of the ReactPhysics3D instance
  @override
  void dispose() {
    _physicsCommon.dispose();
  }
}
