import 'dart:ffi';
import 'dart:isolate';
import '../bindings/src/rp3d_ffi.g.dart';

class EventPort {
  late final ReceivePort _port;
  EventPort(void Function() notify) {
    if (rp3d_initialize_dart_api(NativeApi.initializeApiDLData) != 0) {
      throw StateError('Failed to initialize the Dart native messaging API');
    }
    _port = ReceivePort()..listen((_) => notify());
  }
  int get id => _port.sendPort.nativePort;
  void close() => _port.close();
}
