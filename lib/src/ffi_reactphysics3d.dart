import 'dart:ffi';

import 'package:reactphysics3d_dart/src/bindings/src/rp3d_ffi.g.dart';
import 'package:reactphysics3d_dart/src/interfaces/physics_common.dart';
import '../reactphysics3d_dart.dart';
import 'interfaces/physics_world.dart';
import 'interfaces/collision_shape.dart';
import 'interfaces/rigid_body.dart';
import 'interfaces/material.dart';
import 'interfaces/transform.dart';
import 'implementation/ffi_physics_common.dart';
import 'implementation/ffi_material.dart';

extension TransformStruct on Transform {
  /// Helper function to convert Transform to FFI Transform
  RP3D_Transform toStruct() {
    final xform = Struct.create<RP3D_Transform>();
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
  HeightField createHeightField({
    required int rows,
    required int columns,
    required List<double> heights,
    required double minHeight,
    required double maxHeight,
  }) {
    return _physicsCommon.createHeightField(
      rows: rows,
      columns: columns,
      heights: heights,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  HeightFieldShape createHeightFieldShape(HeightField heightField) {
    return _physicsCommon.createHeightFieldShape(heightField);
  }

  @override
  RigidBody createRigidBody(
    PhysicsWorld world, {
    Transform? transform,
    BodyType type = BodyType.DYNAMIC,
    double mass = 1.0,
  }) {
    final rigidBody = world.createRigidBody(transform:transform);
    rigidBody.type = type;
    rigidBody.mass = mass;

    return rigidBody;
  }

  /// Dispose of the ReactPhysics3D instance
  void dispose() {
    _physicsCommon.dispose();
  }
}
