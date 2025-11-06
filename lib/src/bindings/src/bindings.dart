/// Platform-specific bindings for ReactPhysics3D.
///
/// This file conditionally exports the appropriate implementation based on the platform:
/// - Native platforms (iOS, Android, Desktop): Uses FFI bindings
/// - Web platform: Uses JS interop bindings
/// - Unsupported platforms: Uses stub implementation

// Export factory function from appropriate implementation
export 'ffi.dart'
    if (dart.library.ffi) 'ffi.dart'
    if (dart.library.js_interop) 'rp3d_js_interop.g.dart';
