import '../bindings/src/bindings.dart' as ffi;
import 'base_rp3d_type.dart';

/// A borrowed collider material; it expires when that collider is removed.
abstract class Material extends BaseRP3DType<ffi.Pointer<ffi.RP3D_Material>> {
  /// Get the bounciness coefficient (0 = no bounce, 1 = perfect bounce)
  double get bounciness;

  /// Set the bounciness coefficient
  void setBounciness(double value);

  /// Get the friction coefficient
  double get frictionCoefficient;

  /// Set the friction coefficient
  void setFrictionCoefficient(double value);

  /// Unsupported by this engine version; throws UnsupportedError.
  double get rollingResistance;

  /// Unsupported by this engine version; throws UnsupportedError.
  void setRollingResistance(double value);

  /// Get the mass density
  double get massDensity;

  /// Set the mass density
  void setMassDensity(double value);
}
