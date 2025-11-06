// import 'dart:typed_data';

// import 'rp3d_js_interop.g.dart';
// import 'dart:js_interop';
// import 'dart:js_interop_unsafe';

// export 'dart:typed_data';
// export 'dart:js_interop';
// export 'dart:js_interop_unsafe';
// export 'rp3d_js_interop.g.dart';

// final _allocations = <TypedData>{};

// Uint8List makeUint8List(int length) {
//   var ptr = malloc<Uint8>(length);
//   var buf = _NativeLibrary.instance._emscripten_make_uint8_buffer(ptr, length);
//   var uint8List = buf.toDart;
//   _allocations.add(uint8List);
//   return uint8List;
// }

// Int32List makeInt32List(int length) {
//   var ptr = stackAlloc<Int32>(length * 4);
//   var buf = _NativeLibrary.instance._emscripten_make_int32_buffer(ptr, length);
//   var int32List = buf.toDart;
//   _allocations.add(int32List);
//   return int32List;
// }

// Float32List makeFloat32List(int length) {
//   var ptr = stackAlloc<Float32>(length * 4);
//   var buf = _NativeLibrary.instance._emscripten_make_f32_buffer(ptr, length);
//   var f32List = buf.toDart;
//   _allocations.add(f32List);
//   return f32List;
// }

// extension type _NativeLibrary(JSObject _) implements JSObject {
//   static _NativeLibrary get instance =>
//       NativeLibrary.instance as _NativeLibrary;

//   external JSUint8Array _emscripten_make_uint8_buffer(
//     Pointer<Uint8> ptr,
//     int length,
//   );
//   external JSUint16Array _emscripten_make_uint16_buffer(
//     Pointer<Uint16> ptr,
//     int length,
//   );
//   external JSInt16Array _emscripten_make_int16_buffer(
//     Pointer<Int16> ptr,
//     int length,
//   );
//   external JSInt32Array _emscripten_make_int32_buffer(
//     Pointer<Int32> ptr,
//     int length,
//   );
//   external JSFloat32Array _emscripten_make_f32_buffer(
//     Pointer<Float32> ptr,
//     int length,
//   );
//   external JSFloat64Array _emscripten_make_f64_buffer(
//     Pointer<Float64> ptr,
//     int length,
//   );
//   external Pointer _emscripten_get_byte_offset(JSObject obj);

//   external int _emscripten_stack_get_base();
//   external Pointer _emscripten_stack_get_current();
//   external int _emscripten_stack_get_free();

//   external void _execute_queue();

//   @JS('stackSave')
//   external Pointer<Void> stackSave();

//   @JS('stackRestore')
//   external void stackRestore(Pointer<Void> ptr);
// }

// extension FreeTypedData<T> on TypedData {
//   void free() {
//     Pointer<Void>(this.offsetInBytes).free();
//     _allocations.remove(this);
//   }
// }
