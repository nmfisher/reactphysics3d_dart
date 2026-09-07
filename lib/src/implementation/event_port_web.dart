import 'dart:async';

// WebAssembly has no Dart native port. Drain on the browser's event loop.
class EventPort {
  late final Timer _timer;
  EventPort(void Function() notify) {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => notify());
  }
  int get id => 0;
  void close() => _timer.cancel();
}
