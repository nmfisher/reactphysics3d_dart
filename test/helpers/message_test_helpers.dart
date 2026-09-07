import 'dart:ffi' as ffi;
import 'package:reactphysics3d_dart/src/bindings/src/bindings.dart';

/// Helper function to create a buffer for testing SendPort communication
///
/// This can be used to test the SendPort integration without needing
/// actual collisions to occur.
ffi.Pointer<ffi.Uint8> createTestMessageBuffer() {
  // Create a simple test message with one contact pair
  const size = 4 + // message type
      4 + // nb pairs
      8 + 8 + 8 + 8 + // pointers
      4 + // event type
      4 + // nb points
      1 * 4 + 3 * 4 + 3 * 4 + 3 * 4; // one point

  final buffer = calloc.allocate<ffi.Uint8>(size);
  final writer = MessageWriter(buffer);

  writer.writeUint32(0); // Message type: contact data
  writer.writeUint32(1); // 1 pair

  // Write a dummy pair
  writer.writeUint64(0x1000); // body1
  writer.writeUint64(0x2000); // body2
  writer.writeUint64(0x3000); // collider1
  writer.writeUint64(0x4000); // collider2
  writer.writeInt32(0); // event type: start
  writer.writeUint32(1); // 1 point

  // Write a dummy point
  writer.writeFloat(1.0); // penetration depth
  writer.writeFloat(0.0); writer.writeFloat(1.0); writer.writeFloat(0.0); // normal
  writer.writeFloat(0.0); writer.writeFloat(0.0); writer.writeFloat(0.0); // point1
  writer.writeFloat(0.0); writer.writeFloat(0.0); writer.writeFloat(0.0); // point2

  return buffer;
}

/// Helper class for writing binary messages to native buffers
class MessageWriter {
  final ffi.Pointer<ffi.Uint8> _data;
  late final ByteData _byteData;
  int _offset;

  MessageWriter(this._data) : _offset = 0 {
    // Create a reasonable buffer size for testing (64KB)
    _byteData = ByteData.view(_data.asTypedList(65536).buffer);
  }

  void writeUint32(int value) {
    _byteData.setUint32(_offset, value, Endian.little);
    _offset += 4;
  }

  void writeInt32(int value) {
    _byteData.setInt32(_offset, value, Endian.little);
    _offset += 4;
  }

  void writeUint64(int value) {
    _byteData.setUint64(_offset, value, Endian.little);
    _offset += 8;
  }

  void writeFloat(double value) {
    _byteData.setFloat32(_offset, value, Endian.little);
    _offset += 4;
  }

  int get offset => _offset;
}
