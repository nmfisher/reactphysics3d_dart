import '../bindings/src/bindings.dart';
import '../../reactphysics3d_dart.dart';

/// FFI implementation of DebugRenderer
class FFIDebugRenderer implements DebugRenderer {
  final Pointer<RP3D_DebugRenderer> _ptr;

  FFIDebugRenderer(this._ptr);

  @override
  Pointer<RP3D_DebugRenderer> get handle => _ptr;

  @override
  void setIsDebugItemDisplayed(DebugItem item, bool isDisplayed) {
    rp3d_debug_renderer_set_is_debug_item_displayed(
      _ptr,
      item.value,
      isDisplayed ? 1 : 0,
    );
  }

  @override
  bool getIsDebugItemDisplayed(DebugItem item) {
    final result = rp3d_debug_renderer_get_is_debug_item_displayed(
      _ptr,
      item.value,
    );
    return result != 0;
  }

  @override
  int getNbLines() {
    return rp3d_debug_renderer_get_nb_lines(_ptr);
  }

  @override
  int getNbTriangles() {
    return rp3d_debug_renderer_get_nb_triangles(_ptr);
  }

  @override
  List<DebugLine> getLines() {
    final nbLines = getNbLines();
    if (nbLines == 0) {
      return [];
    }

    // Allocate arrays for vertices and colors
    final vertices = makeFloat32List(nbLines * 6); // 2 points × 3 coords
    final colors = makeInt32List(nbLines);

    try {
      // Get the debug lines data
      rp3d_debug_renderer_get_lines_array(
        _ptr,
        vertices.address,
        colors.address.cast(),
      );

      // Convert to Dart objects
      final lines = <DebugLine>[];
      for (int i = 0; i < nbLines; i++) {
        final point1 = Vector3(
          vertices[i * 6 + 0],
          vertices[i * 6 + 1],
          vertices[i * 6 + 2],
        );
        final point2 = Vector3(
          vertices[i * 6 + 3],
          vertices[i * 6 + 4],
          vertices[i * 6 + 5],
        );
        final color = colors[i];

        lines.add(DebugLine(point1: point1, point2: point2, color: color));
      }

      return lines;
    } finally {
      vertices.free();
      colors.free();
    }
  }

  @override
  List<DebugTriangle> getTriangles() {
    final nbTriangles = getNbTriangles();
    if (nbTriangles == 0) {
      return [];
    }

    // Allocate arrays for vertices and colors
    final vertices = makeFloat32List(nbTriangles * 9); // 3 points × 3 coords
    final colors = makeInt32List(nbTriangles);

    try {
      // Get the debug triangles data
      rp3d_debug_renderer_get_triangles_array(_ptr, vertices.address, colors.address.cast());

      // Convert to Dart objects
      final triangles = <DebugTriangle>[];
      for (int i = 0; i < nbTriangles; i++) {
        final point1 = Vector3(
          vertices[i * 9 + 0],
          vertices[i * 9 + 1],
          vertices[i * 9 + 2],
        );
        final point2 = Vector3(
          vertices[i * 9 + 3],
          vertices[i * 9 + 4],
          vertices[i * 9 + 5],
        );
        final point3 = Vector3(
          vertices[i * 9 + 6],
          vertices[i * 9 + 7],
          vertices[i * 9 + 8],
        );
        final color = colors[i];

        triangles.add(
          DebugTriangle(
            point1: point1,
            point2: point2,
            point3: point3,
            color: color,
          ),
        );
      }

      return triangles;
    } finally {
      vertices.free();
      colors.free();
    }
  }
}
