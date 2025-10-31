import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

import '../../reactphysics3d_dart.dart';
import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// FFI implementation of DebugRenderer
class FFIDebugRenderer implements DebugRenderer {
  final ffi.Pointer<ffi_gen.RP3D_DebugRenderer> _ptr;

  FFIDebugRenderer(this._ptr);

  @override
  ffi.Pointer<ffi_gen.RP3D_DebugRenderer> get handle => _ptr;

  @override
  void setIsDebugItemDisplayed(DebugItem item, bool isDisplayed) {
    ffi_gen.rp3d_debug_renderer_set_is_debug_item_displayed(
      _ptr,
      item.value,
      isDisplayed ? 1 : 0,
    );
  }

  @override
  bool getIsDebugItemDisplayed(DebugItem item) {
    final result = ffi_gen.rp3d_debug_renderer_get_is_debug_item_displayed(
      _ptr,
      item.value,
    );
    return result != 0;
  }

  @override
  int getNbLines() {
    return ffi_gen.rp3d_debug_renderer_get_nb_lines(_ptr);
  }

  @override
  int getNbTriangles() {
    return ffi_gen.rp3d_debug_renderer_get_nb_triangles(_ptr);
  }

  @override
  List<DebugLine> getLines() {
    final nbLines = getNbLines();
    if (nbLines == 0) {
      return [];
    }

    // Allocate arrays for vertices and colors
    final vertices = calloc<ffi.Float>(nbLines * 6); // 2 points × 3 coords
    final colors = calloc<ffi.Uint32>(nbLines);

    try {
      // Get the debug lines data
      ffi_gen.rp3d_debug_renderer_get_lines_array(_ptr, vertices, colors);

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

        lines.add(DebugLine(
          point1: point1,
          point2: point2,
          color: color,
        ));
      }

      return lines;
    } finally {
      calloc.free(vertices);
      calloc.free(colors);
    }
  }

  @override
  List<DebugTriangle> getTriangles() {
    final nbTriangles = getNbTriangles();
    if (nbTriangles == 0) {
      return [];
    }

    // Allocate arrays for vertices and colors
    final vertices = calloc<ffi.Float>(nbTriangles * 9); // 3 points × 3 coords
    final colors = calloc<ffi.Uint32>(nbTriangles);

    try {
      // Get the debug triangles data
      ffi_gen.rp3d_debug_renderer_get_triangles_array(_ptr, vertices, colors);

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

        triangles.add(DebugTriangle(
          point1: point1,
          point2: point2,
          point3: point3,
          color: color,
        ));
      }

      return triangles;
    } finally {
      calloc.free(vertices);
      calloc.free(colors);
    }
  }
}
