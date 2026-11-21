/// Platform-specific bindings for ReactPhysics3D.
///
/// Uses FFI on native targets and JS interop in browsers.
library;

// Export factory function from appropriate implementation
export 'dart:typed_data';

export 'ffi.dart'
    if (dart.library.ffi) 'ffi.dart'
    if (dart.library.js_interop) 'js_interop.dart';

