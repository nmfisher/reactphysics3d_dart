import '../../reactphysics3d_dart.dart';

/// Represents a debug line with two points and a color
class DebugLine {
  /// First point of the line
  final Vector3 point1;

  /// Second point of the line
  final Vector3 point2;

  /// Color of the line (24-bit RGB packed into uint32: 0x00RRGGBB)
  final int color;

  const DebugLine({
    required this.point1,
    required this.point2,
    required this.color,
  });
}

/// Represents a debug triangle with three points and a color
class DebugTriangle {
  /// First point of the triangle
  final Vector3 point1;

  /// Second point of the triangle
  final Vector3 point2;

  /// Third point of the triangle
  final Vector3 point3;

  /// Color of the triangle (24-bit RGB packed into uint32: 0x00RRGGBB)
  final int color;

  const DebugTriangle({
    required this.point1,
    required this.point2,
    required this.point3,
    required this.color,
  });
}
