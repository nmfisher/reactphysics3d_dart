/// Debug items that can be rendered by the DebugRenderer
enum DebugItem {
  /// Display collider AABBs
  colliderAABB(1),

  /// Display collider broadphase AABBs
  colliderBroadphaseAABB(2),

  /// Display collision shapes
  collisionShape(4),

  /// Display contact points
  contactPoint(8),

  /// Display contact normals
  contactNormal(16);

  const DebugItem(this.value);

  final int value;
}
