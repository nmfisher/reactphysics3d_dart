import 'package:vector_math/vector_math.dart';

/// 3D Transform (position + orientation)
///
/// A simple wrapper around Vector3 and Quaternion from vector_math.
/// ReactPhysics3D uses separate position and orientation rather than a matrix.
class Transform {
  final Vector3 position;
  final Quaternion orientation;

  Transform(this.position, this.orientation);

  factory Transform.identity() =>
      Transform(Vector3.zero(), Quaternion.identity());

  Vector3 getPosition() => position;
  Quaternion getOrientation() => orientation;

  @override
  String toString() => 'Transform(position: $position, orientation: $orientation)';

  @override
  bool operator ==(Object other) =>
      other is Transform &&
      position == other.position &&
      orientation == other.orientation;

  @override
  int get hashCode => Object.hash(position, orientation);
}
