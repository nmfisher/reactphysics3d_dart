/// Web (JS interop) bindings for ReactPhysics3D.
///
/// Counterpart of [ffi.dart] for the wasm build: re-exports the generated
/// bindings and provides the same helper surface (typed data allocation,
/// pointer element access) so the hand-written implementation files compile
/// unchanged against either platform.
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'rp3d_js_interop.g.dart';

export 'dart:typed_data';
export 'rp3d_js_interop.g.dart';

/// The Emscripten heap that backs the wasm module.
JSArrayBuffer get _heapBuffer =>
    NativeLibrary.instance.HEAPU8.buffer as JSArrayBuffer;

/// Wraps Emscripten heap memory at [address] in a typed list view.
///
/// Views created here read and write the wasm heap directly, so buffers
/// passed to the native module as out-parameters are readable afterwards,
/// matching `make*List` on the FFI side.
Uint8List _view8(int address, int length) =>
    JSUint8Array(_heapBuffer, address, length).toDart;

Int16List _view16(int address, int length) =>
    JSInt16Array(_heapBuffer, address, length).toDart;

Int32List _view32(int address, int length) =>
    JSInt32Array(_heapBuffer, address, length).toDart;

Uint32List _viewU32(int address, int length) =>
    JSUint32Array(_heapBuffer, address, length).toDart;

Float32List _viewF32(int address, int length) =>
    JSFloat32Array(_heapBuffer, address, length).toDart;

Uint8List makeUint8List(int length) =>
    _view8(malloc<Uint8>(length).address, length);

Int16List makeInt16List(int length) =>
    _view16(malloc<Uint16>(length * 2).address, length);

Int32List makeInt32List(int length) =>
    _view32(malloc<Int32>(length * 4).address, length);

Uint32List makeUint32List(int length) =>
    _viewU32(malloc<Uint32>(length * 4).address, length);

Float32List makeFloat32List(int length) =>
    _viewF32(malloc<Float32>(length * 4).address, length);

/// Reads a 32-bit unsigned value at [index], mirroring `Pointer<Uint32>[i]`
/// from `dart:ffi`.
extension Uint32PointerElement on Pointer<Uint32> {
  int operator [](int index) =>
      NativeLibrary.instance
          .getValue(Pointer<Uint32>(address + index * 4), 'i32')
          .toDartInt &
      0xFFFFFFFF;
}

/// Byte sizes of the structs that shared code indexes into, matching the
/// `stackAlloc` sizes emitted in rp3d_js_interop.g.dart (which in turn follow
/// the layouts in rp3d_c_api.h). Update both together if the C structs change.
const _structSizes = <Type, int>{
  RP3D_ContactPairData: 28,
  RP3D_ContactPointData: 40,
  RP3D_OverlapPairData: 20,
};

Pointer<T> _structAt<T extends Struct>(Pointer<T> pointer, int index) =>
    Pointer<T>(pointer.address + index * (_structSizes[T] ?? 0));

/// Mirrors `Pointer<T>[i]` from `dart:ffi` for the struct arrays returned by
/// the synchronous collision and overlap tests.
extension ContactPairDataPointerElement on Pointer<RP3D_ContactPairData> {
  RP3D_ContactPairData operator [](int index) =>
      RP3D_ContactPairData(_structAt(this, index));
}

extension ContactPointDataPointerElement on Pointer<RP3D_ContactPointData> {
  RP3D_ContactPointData operator [](int index) =>
      RP3D_ContactPointData(_structAt(this, index));
}

extension OverlapPairDataPointerElement on Pointer<RP3D_OverlapPairData> {
  RP3D_OverlapPairData operator [](int index) =>
      RP3D_OverlapPairData(_structAt(this, index));
}

/// Mirrors `Pointer<T>.ref` from `dart:ffi` for the structs the synchronous
/// collision and overlap tests return.
extension CollisionCallbackDataRef on Pointer<RP3D_CollisionCallbackData> {
  RP3D_CollisionCallbackData get ref => RP3D_CollisionCallbackData(this);
}

extension OverlapCallbackDataRef on Pointer<RP3D_OverlapCallbackData> {
  RP3D_OverlapCallbackData get ref => RP3D_OverlapCallbackData(this);
}
