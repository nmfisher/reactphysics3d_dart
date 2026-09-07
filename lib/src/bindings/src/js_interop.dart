import 'dart:typed_data';
import 'dart:js_interop';
import 'rp3d_js_interop.g.dart'
    hide
        makeUint8List,
        makeInt32List,
        makeUint32List,
        makeFloat32List,
        Uint8ListExtension,
        Int32ListExtension,
        UInt32ListExtension,
        Float32ListExtension;
export 'dart:typed_data';
export 'rp3d_js_interop.g.dart'
    hide
        makeUint8List,
        makeInt32List,
        makeUint32List,
        makeFloat32List,
        Uint8ListExtension,
        Int32ListExtension,
        UInt32ListExtension,
        Float32ListExtension;

// Temporary typed buffers use a scoped heap arena, so large terrain/mesh input
// cannot exhaust the Emscripten stack. Generated small structs use the stack.
final _buffers = <int>[];
typedef _Scope = ({int stack, int buffers});
_Scope saveNativeStack() => (
  stack: NativeLibrary.instance.stackSave().address,
  buffers: _buffers.length,
);
void restoreNativeStack(_Scope scope) {
  final memory = _Memory(NativeLibrary.instance);
  while (_buffers.length > scope.buffers) {
    memory._free(_buffers.removeLast());
  }
  NativeLibrary.instance.stackRestore(Pointer<Void>(scope.stack));
}

extension type _Memory(NativeLibrary _) implements JSObject {
  external int _malloc(int size);
  external void _free(int address);
}
Uint8List _allocate(int bytes) {
  final address = _Memory(
    NativeLibrary.instance,
  )._malloc(bytes == 0 ? 1 : bytes);
  if (address == 0) throw StateError('WebAssembly allocation failed');
  _buffers.add(address);
  return NativeLibrary.instance.HEAPU8.toDart.buffer.asUint8List(
    address,
    bytes,
  );
}

Uint8List makeUint8List(int length) => _allocate(length);
Int32List makeInt32List(int length) {
  final bytes = _allocate(length * 4);
  return bytes.buffer.asInt32List(bytes.offsetInBytes, length);
}

Uint32List makeUint32List(int length) {
  final bytes = _allocate(length * 4);
  return bytes.buffer.asUint32List(bytes.offsetInBytes, length);
}

Float32List makeFloat32List(int length) {
  final bytes = _allocate(length * 4);
  return bytes.buffer.asFloat32List(bytes.offsetInBytes, length);
}

int _address(TypedData data) {
  final JSObject array = switch (data) {
    Uint8List value => value.toJS,
    Int32List value => value.toJS,
    Uint32List value => value.toJS,
    Float32List value => value.toJS,
    _ => throw UnsupportedError('Unsupported typed buffer'),
  };
  // Keep SharedArrayBuffer as a JSObject; it is not a JSArrayBuffer.
  final view = _TypedArray(array);
  if (_sameObject(
    view.buffer,
    _TypedArray(NativeLibrary.instance.HEAPU8).buffer,
  )) {
    return view.byteOffset;
  }
  final copy = _allocate(data.lengthInBytes);
  copy.setAll(
    0,
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );
  return copy.offsetInBytes;
}

extension Uint8Address on Uint8List {
  Pointer<Uint8> get address => Pointer<Uint8>(_address(this));
}

extension Int32Address on Int32List {
  Pointer<Int32> get address => Pointer<Int32>(_address(this));
}

extension Uint32Address on Uint32List {
  Pointer<Uint32> get address => Pointer<Uint32>(_address(this));
}

extension Float32Address on Float32List {
  Pointer<Float> get address => Pointer<Float>(_address(this));
}

void initializeWebBindings(String moduleName) =>
    GeneratedBindings.initBindings(moduleName);

extension DartBigIntExtension on int {
  BigInt get toBigInt => BigInt.from(this);
}

// Layouts are wasm32 C structs, matching the generated field offsets.
extension CollisionDataRef on Pointer<RP3D_CollisionCallbackData> {
  RP3D_CollisionCallbackData get ref => RP3D_CollisionCallbackData(this);
}

extension OverlapDataRef on Pointer<RP3D_OverlapCallbackData> {
  RP3D_OverlapCallbackData get ref => RP3D_OverlapCallbackData(this);
}

extension ContactPairIndex on Pointer<RP3D_ContactPairData> {
  RP3D_ContactPairData operator [](int i) =>
      RP3D_ContactPairData(Pointer<RP3D_ContactPairData>(address + i * 28));
}

extension ContactPointIndex on Pointer<RP3D_ContactPointData> {
  RP3D_ContactPointData operator [](int i) =>
      RP3D_ContactPointData(Pointer<RP3D_ContactPointData>(address + i * 40));
}

extension OverlapPairIndex on Pointer<RP3D_OverlapPairData> {
  RP3D_OverlapPairData operator [](int i) =>
      RP3D_OverlapPairData(Pointer<RP3D_OverlapPairData>(address + i * 20));
}

extension Uint32PointerIndex on Pointer<Uint32> {
  int operator [](int i) =>
      NativeLibrary.instance
          .getValue(Pointer<Uint32>(address + i * 4), 'i32')
          .toDartInt &
      0xffffffff;
}

extension type _TypedArray(JSObject _) implements JSObject {
  external JSObject get buffer;
  external int get byteOffset;
}
@JS('Object.is')
external bool _sameObject(JSAny? a, JSAny? b);
