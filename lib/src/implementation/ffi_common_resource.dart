import '../bindings/src/bindings.dart';
import 'ffi_physics_common.dart';
import 'native_lifetime.dart';

/// A factory-owned allocation. Dependents must release their references first.
abstract class FFICommonResource<T extends NativeType> {
  final Pointer<T> rawHandle;
  final FFIPhysicsCommon common;
  late final NativeLifetime lifetime = NativeLifetime(common.lifetime);
  final Set<Object> users = {};
  FFICommonResource(this.rawHandle, this.common) {
    common.resources.add(this);
  }
  Pointer<T> get handle {
    lifetime.check();
    return rawHandle;
  }

  void dispose() {
    if (lifetime.isDisposed) return;
    if (users.isNotEmpty) {
      throw StateError('Remove dependent colliders or shapes before disposal');
    }
    destroyNative();
    lifetime.invalidate();
    common.resources.remove(this);
  }

  void destroyNative();
  void requireSameCommon(FFIPhysicsCommon owner) {
    lifetime.check();
    if (!identical(common, owner)) {
      throw ArgumentError(
        'Physics objects must belong to the same PhysicsCommon',
      );
    }
  }
}
