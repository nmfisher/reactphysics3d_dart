import 'native_lifetime.dart';
import '../bindings/src/bindings.dart';
import '../interfaces/material.dart';

/// FFI implementation of Material
class FFIMaterial implements Material {
  // Collider components can be compacted or reallocated while still alive.
  final Pointer<RP3D_Material> Function() _resolve;
  final NativeLifetime lifetime;
  FFIMaterial(this._resolve, this.lifetime);
  Pointer<RP3D_Material> get _ptr {
    lifetime.check();
    return _resolve();
  }

  @override
  Pointer<RP3D_Material> get handle => _ptr;

  @override
  double get bounciness => rp3d_material_get_bounciness(_ptr);

  @override
  void setBounciness(double value) => rp3d_material_set_bounciness(_ptr, value);

  @override
  double get frictionCoefficient =>
      rp3d_material_get_friction_coefficient(_ptr);

  @override
  void setFrictionCoefficient(double value) =>
      rp3d_material_set_friction_coefficient(_ptr, value);

  @override
  double get rollingResistance {
    lifetime.check();
    throw UnsupportedError(
      'Rolling resistance is not supported by this ReactPhysics3D version',
    );
  }

  @override
  void setRollingResistance(double value) {
    lifetime.check();
    throw UnsupportedError(
      'Rolling resistance is not supported by this ReactPhysics3D version',
    );
  }

  @override
  double get massDensity => rp3d_material_get_mass_density(_ptr);

  @override
  void setMassDensity(double value) =>
      rp3d_material_set_mass_density(_ptr, value);
}
