# Collision event implementation

Synchronous queries copy native contact data into Dart values and free the native
query result in a finally block. Body/collider references resolve through the
owning world's registry, preserving wrapper identity and disposed-state checks.

Each automatic listener owns a mutex-protected FIFO of serialized packets. Native
builds resolve Dart_PostCObject from the SDK's versioned dynamic API table and post
ReceivePort notifications after enqueueing. Web builds use a Dart timer to drain
the same per-listener queue. `poll()` supports immediate synchronous delivery.

Readers query the next packet's size and allocate enough memory; there is no fixed
64 KiB limit. Contact and trigger packets share the same body/collider layout.
Trigger packets carry zero contact points. The queue is transport-thread-safe;
access to a physics world must still be serialized.

Listener detachment and body/collider destruction clear queued packets. A delivery
generation prevents callbacks that destroy/recreate objects from exposing stale
pointer packets later in the same drain. Retained Dart references remain guarded
by their original object's lifetime.

See [test/lifecycle_regression_test.dart](test/lifecycle_regression_test.dart) for
end-to-end ownership, automatic delivery, trigger, and large-packet coverage.
