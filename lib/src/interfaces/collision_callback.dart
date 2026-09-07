import 'package:vector_math/vector_math_64.dart';
import 'collider.dart';
import 'rigid_body.dart';

/// Event types for contact events
enum ContactEventType {
  /// New contact between colliders (they were not touching in previous frame)
  contactStart,

  /// Colliders were already touching and this is a new or updated contact
  contactStay,

  /// Colliders were in contact but are not in contact anymore
  contactExit,
}

/// Represents a contact point between two colliders
class ContactPoint {
  /// Penetration depth between the two colliders at this contact point
  final double penetrationDepth;

  /// World-space contact normal (vector from first body toward second body)
  final Vector3 worldNormal;

  /// Contact point on the first collider in the local-space of the first collider
  final Vector3 localPointOnCollider1;

  /// Contact point on the second collider in the local-space of the second collider
  final Vector3 localPointOnCollider2;

  const ContactPoint({
    required this.penetrationDepth,
    required this.worldNormal,
    required this.localPointOnCollider1,
    required this.localPointOnCollider2,
  });

  @override
  String toString() {
    return 'ContactPoint('
        'penetrationDepth: $penetrationDepth, '
        'worldNormal: $worldNormal, '
        'localPointOnCollider1: $localPointOnCollider1, '
        'localPointOnCollider2: $localPointOnCollider2)';
  }
}

/// Contact snapshot. Point values are copied; body/collider references remain
/// borrowed live objects and expire on destruction. Trigger pairs have no points.
class ContactPair {
  /// Contact points between the two colliders
  final List<ContactPoint> contactPoints;

  /// First body in contact
  final RigidBody body1;

  /// Second body in contact
  final RigidBody body2;

  /// First collider in contact (from body1)
  final Collider collider1;

  /// Second collider in contact (from body2)
  final Collider collider2;

  /// Type of contact event
  final ContactEventType eventType;

  const ContactPair({
    required this.contactPoints,
    required this.body1,
    required this.body2,
    required this.collider1,
    required this.collider2,
    required this.eventType,
  });

  /// Get the number of contact points in this contact pair
  int get nbContactPoints => contactPoints.length;

  /// Get a specific contact point by index
  ContactPoint getContactPoint(int index) {
    if (index < 0 || index >= contactPoints.length) {
      throw RangeError(
        'Contact point index $index out of range (0-${contactPoints.length - 1})',
      );
    }
    return contactPoints[index];
  }

  @override
  String toString() {
    return 'ContactPair('
        'contactPoints: $contactPoints, '
        'body1: $body1, '
        'body2: $body2, '
        'collider1: $collider1, '
        'collider2: $collider2, '
        'eventType: $eventType)';
  }
}

/// Callback data containing information about contacts between bodies
class ContactCallbackData {
  /// All contact pairs reported in this callback
  final List<ContactPair> contactPairs;

  const ContactCallbackData({required this.contactPairs});

  /// Get the number of contact pairs
  int get nbContactPairs => contactPairs.length;

  /// Get a specific contact pair by index
  ContactPair getContactPair(int index) {
    if (index < 0 || index >= contactPairs.length) {
      throw RangeError(
        'Contact pair index $index out of range (0-${contactPairs.length - 1})',
      );
    }
    return contactPairs[index];
  }

  @override
  String toString() {
    return 'ContactCallbackData(nbContactPairs: $nbContactPairs, contactPairs: $contactPairs)';
  }
}

/// Abstract callback class for collision events
///
/// This class can be used to register a callback for collision test queries.
/// You should implement your own class inherited from this one and implement
/// the onContact() method. This method will be called each time a contact
/// point is reported.
abstract class CollisionCallback {
  /// This method is called when some contacts occur
  ///
  /// [callbackData] contains data about all the contacts that occurred
  void onContact(ContactCallbackData callbackData);
}
