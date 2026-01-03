import 'collider.dart';
import 'rigid_body.dart';

/// Event types for overlap (trigger) events
enum OverlapEventType {
  /// New overlap between triggers (they were not overlapping in previous frame)
  overlapStart,

  /// Triggers were already overlapping and this is a continued overlap
  overlapStay,

  /// Triggers were overlapping but are not overlapping anymore
  overlapExit,
}

/// Represents an overlap pair between two trigger colliders
class OverlapPair {
  /// First collider in the overlap
  final Collider collider1;

  /// Second collider in the overlap
  final Collider collider2;

  /// First body in the overlap
  final RigidBody body1;

  /// Second body in the overlap
  final RigidBody body2;

  /// Type of overlap event
  final OverlapEventType eventType;

  const OverlapPair({
    required this.collider1,
    required this.collider2,
    required this.body1,
    required this.body2,
    required this.eventType,
  });

  @override
  String toString() {
    return 'OverlapPair('
        'collider1: $collider1, '
        'collider2: $collider2, '
        'body1: $body1, '
        'body2: $body2, '
        'eventType: $eventType)';
  }
}

/// Callback data containing information about trigger overlaps
class OverlapCallbackData {
  /// All overlap pairs reported in this callback
  final List<OverlapPair> overlapPairs;

  const OverlapCallbackData({required this.overlapPairs});

  /// Get the number of overlap pairs
  int get nbOverlapPairs => overlapPairs.length;

  /// Get a specific overlap pair by index
  OverlapPair getOverlapPair(int index) {
    if (index < 0 || index >= overlapPairs.length) {
      throw RangeError('Overlap pair index $index out of range (0-${overlapPairs.length - 1})');
    }
    return overlapPairs[index];
  }

  @override
  String toString() {
    return 'OverlapCallbackData(nbOverlapPairs: $nbOverlapPairs, overlapPairs: $overlapPairs)';
  }
}

/// Abstract callback class for overlap (trigger) events
///
/// This class can be used to register a callback for trigger overlap queries.
/// You should implement your own class inherited from this one and implement
/// the onOverlap() method. This method will be called each time an overlap
/// event is reported.
abstract class OverlapCallback {
  /// This method is called when trigger overlaps occur
  ///
  /// [callbackData] contains data about all the overlaps that occurred
  void onOverlap(OverlapCallbackData callbackData);
}
