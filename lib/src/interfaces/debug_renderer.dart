import '../bindings/src/bindings.dart' as ffi;

import '../../reactphysics3d_dart.dart';
import '../bindings/src/bindings.dart' as ffi;

/// Interface for the debug renderer
abstract class DebugRenderer
    extends BaseRP3DType<ffi.Pointer<ffi.RP3D_DebugRenderer>> {
  /// Set whether a debug item should be displayed
  void setIsDebugItemDisplayed(DebugItem item, bool isDisplayed);

  /// Get whether a debug item is displayed
  bool getIsDebugItemDisplayed(DebugItem item);

  /// Get the number of debug lines
  int getNbLines();

  /// Get the number of debug triangles
  int getNbTriangles();

  /// Get all debug lines
  /// Returns a list of DebugLine objects
  List<DebugLine> getLines();

  /// Get all debug triangles
  /// Returns a list of DebugTriangle objects
  List<DebugTriangle> getTriangles();
}
