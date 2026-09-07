/// Shared validity state for native objects and their borrowed views.
class NativeLifetime {
  final NativeLifetime? parent;
  bool _disposed = false;
  NativeLifetime([this.parent]);
  bool get isDisposed => _disposed || (parent?.isDisposed ?? false);
  void check() {
    if (isDisposed) throw StateError('Native physics object has been disposed');
  }

  void invalidate() {
    _disposed = true;
  }
}
