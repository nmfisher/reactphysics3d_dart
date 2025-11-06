import '../bindings/src/bindings.dart';
import '../interfaces/material.dart';

/// FFI implementation of Material
class FFIMaterial implements Material {
  final Pointer<RP3D_Material> _ptr;

  FFIMaterial(this._ptr);

  @override
  Pointer<RP3D_Material> get handle => _ptr;

  @override
  double get bounciness => rp3d_material_get_bounciness(_ptr);

  @override
  void setBounciness(double value) => rp3d_material_set_bounciness(_ptr, value);

  @override
  double get frictionCoefficient => rp3d_material_get_friction_coefficient(_ptr);

  @override
  void setFrictionCoefficient(double value) => rp3d_material_set_friction_coefficient(_ptr, value);

  @override
  double get rollingResistance => 0.0; // Not implemented yet

  @override
  void setRollingResistance(double value) {
    // Not implemented yet
  }

  @override
  double get massDensity => rp3d_material_get_mass_density(_ptr);

  @override
  void setMassDensity(double value) => rp3d_material_set_mass_density(_ptr, value);
}