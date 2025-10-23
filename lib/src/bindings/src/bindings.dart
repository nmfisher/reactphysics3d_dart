/// Platform-specific bindings for ReactPhysics3D.
///
/// This file conditionally exports the appropriate implementation based on the platform:
/// - Native platforms (iOS, Android, Desktop): Uses FFI bindings
/// - Web platform: Uses JS interop bindings
/// - Unsupported platforms: Uses stub implementation

// Export the appropriate bindings based on platform
export 'rp3d_stub.dart'
    if (dart.library.ffi) 'rp3d_ffi.g.dart'
    if (dart.library.js_interop) 'rp3d_js_interop.g.dart';
