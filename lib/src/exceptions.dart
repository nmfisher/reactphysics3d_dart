/// Exception thrown by ReactPhysics3D operations
class ReactPhysics3DException implements Exception {
  final String message;

  const ReactPhysics3DException(this.message);

  @override
  String toString() => 'ReactPhysics3DException: $message';
}
