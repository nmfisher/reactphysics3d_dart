import 'dart:ffi' as ffi;
import 'base_rp3d_type.dart';

import '../bindings/src/rp3d_ffi.g.dart' as ffi_gen;

/// Interface for physics materials
abstract class Material extends BaseRP3DType<ffi.Pointer<ffi_gen.RP3D_Material>> {
  /// Get the bounciness coefficient (0 = no bounce, 1 = perfect bounce)
  double get bounciness;

  /// Set the bounciness coefficient
  void setBounciness(double value);

  /// Get the friction coefficient
  double get frictionCoefficient;

  /// Set the friction coefficient
  void setFrictionCoefficient(double value);

  /// Get the rolling resistance
  double get rollingResistance;

  /// Set the rolling resistance
  void setRollingResistance(double value);

  /// Get the mass density
  double get massDensity;

  /// Set the mass density
  void setMassDensity(double value);
}