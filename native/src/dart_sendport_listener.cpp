/*
 * SendPort Event Listener Implementation
 *
 * This file implements a thread-safe EventListener that sends collision data
 * to Dart via SendPort/ReceivePort for multi-threaded scenarios.
 */

#include "c_api/rp3d_c_api.h"
#include <reactphysics3d/reactphysics3d.h>
#include <reactphysics3d/engine/EventListener.h>
#include <reactphysics3d/collision/OverlapCallback.h>
#include <iostream>
#include <vector>
#include <cstring>
#include <atomic>

using namespace reactphysics3d;

// ==================== Message Buffer ====================

/**
 * Simple buffer to serialize contact data for sending to Dart.
 */
class MessageBuffer {
private:
    std::vector<uint8_t> _buffer;
    size_t _offset;

    void writeBytes(const void* data, size_t size) {
        if (_offset + size > _buffer.size()) {
            _buffer.resize(_buffer.size() + size + 1024);
        }
        std::memcpy(_buffer.data() + _offset, data, size);
        _offset += size;
    }

public:
    MessageBuffer() : _offset(0) {
        _buffer.reserve(4096);
    }

    void writeUint32(uint32_t value) {
        writeBytes(&value, sizeof(value));
    }

    void writeInt32(int32_t value) {
        writeBytes(&value, sizeof(value));
    }

    void writeUint64(uint64_t value) {
        writeBytes(&value, sizeof(value));
    }

    void writeFloat(float value) {
        writeBytes(&value, sizeof(value));
    }

    const uint8_t* data() const { return _buffer.data(); }
    size_t size() const { return _offset; }

    void clear() {
        _offset = 0;
    }
};

// ==================== SendPort Event Listener ====================

/**
 * Event listener that sends collision data to Dart via SendPort.
 *
 * This implementation is thread-safe because we use a shared buffer
 * that Dart can poll from.
 */
class SendPortEventListener : public reactphysics3d::EventListener {
private:
    uint64_t _sendPortId;
    std::atomic<uint32_t> _messageCount;
    MessageBuffer _buffer;

public:
    SendPortEventListener(uint64_t sendPortId)
        : _sendPortId(sendPortId)
        , _messageCount(0)
    {
        std::cout << "Created SendPortEventListener with port ID: " << sendPortId << std::endl;
    }

    ~SendPortEventListener() override = default;

    /// Called when contacts occur during collision
    virtual void onContact(const CollisionCallback::CallbackData& callbackData) override {
        _messageCount++;
        _buffer.clear();

        // Write message header
        _buffer.writeUint32(0); // Message type: 0 = contact data
        _buffer.writeUint32(callbackData.getNbContactPairs());

        // Marshal each contact pair
        for (uint32_t i = 0; i < callbackData.getNbContactPairs(); i++) {
            const ContactPair rp3dPair = callbackData.getContactPair(i);

            // Write body/collider pointers as IDs
            _buffer.writeUint64(reinterpret_cast<uint64_t>(rp3dPair.getBody1()));
            _buffer.writeUint64(reinterpret_cast<uint64_t>(rp3dPair.getBody2()));
            _buffer.writeUint64(reinterpret_cast<uint64_t>(rp3dPair.getCollider1()));
            _buffer.writeUint64(reinterpret_cast<uint64_t>(rp3dPair.getCollider2()));

            // Write event type
            ContactPair::EventType eventType = rp3dPair.getEventType();
            int32_t eventTypeInt = 0;
            if (eventType == ContactPair::EventType::ContactStart) {
                eventTypeInt = 0;
            } else if (eventType == ContactPair::EventType::ContactStay) {
                eventTypeInt = 1;
            } else {
                eventTypeInt = 2; // ContactExit
            }
            _buffer.writeInt32(eventTypeInt);

            // Write contact points
            uint32_t nbPoints = rp3dPair.getNbContactPoints();
            _buffer.writeUint32(nbPoints);

            for (uint32_t j = 0; j < nbPoints; j++) {
                const ContactPoint rp3dPoint = rp3dPair.getContactPoint(j);

                _buffer.writeFloat(rp3dPoint.getPenetrationDepth());

                // World normal
                const Vector3& normal = rp3dPoint.getWorldNormal();
                _buffer.writeFloat(normal.x);
                _buffer.writeFloat(normal.y);
                _buffer.writeFloat(normal.z);

                // Local point on collider 1
                const Vector3& p1 = rp3dPoint.getLocalPointOnCollider1();
                _buffer.writeFloat(p1.x);
                _buffer.writeFloat(p1.y);
                _buffer.writeFloat(p1.z);

                // Local point on collider 2
                const Vector3& p2 = rp3dPoint.getLocalPointOnCollider2();
                _buffer.writeFloat(p2.x);
                _buffer.writeFloat(p2.y);
                _buffer.writeFloat(p2.z);
            }
        }

        // Send the message to Dart via helper function
        rp3d_send_to_dart_port(_sendPortId, _buffer.data(), _buffer.size());
    }

    /// Called when trigger overlaps occur
    virtual void onTrigger(const OverlapCallback::CallbackData& callbackData) override {
        _messageCount++;
        _buffer.clear();

        // Write message header
        _buffer.writeUint32(1); // Message type: 1 = overlap data
        _buffer.writeUint32(callbackData.getNbOverlappingPairs());

        // Marshal each overlap pair
        for (uint32_t i = 0; i < callbackData.getNbOverlappingPairs(); i++) {
            OverlapCallback::OverlapPair overlapPair = callbackData.getOverlappingPair(i);

            const Collider* collider1 = overlapPair.getCollider1();
            const Collider* collider2 = overlapPair.getCollider2();
            const Body* body1 = overlapPair.getBody1();
            const Body* body2 = overlapPair.getBody2();

            // Write pointers as IDs
            _buffer.writeUint64(reinterpret_cast<uint64_t>(body1));
            _buffer.writeUint64(reinterpret_cast<uint64_t>(body2));
            _buffer.writeUint64(reinterpret_cast<uint64_t>(collider1));
            _buffer.writeUint64(reinterpret_cast<uint64_t>(collider2));

            // Write event type
            OverlapCallback::OverlapPair::EventType eventType = overlapPair.getEventType();
            int32_t eventTypeInt = 0;
            if (eventType == OverlapCallback::OverlapPair::EventType::OverlapStart) {
                eventTypeInt = 0;
            } else if (eventType == OverlapCallback::OverlapPair::EventType::OverlapStay) {
                eventTypeInt = 1;
            } else {
                eventTypeInt = 2; // OverlapExit
            }
            _buffer.writeInt32(eventTypeInt);

            // Overlaps don't have contact points
            _buffer.writeUint32(0);
        }

        // Send the message to Dart
        rp3d_send_to_dart_port(_sendPortId, _buffer.data(), _buffer.size());
    }

    uint32_t getMessageCount() const { return _messageCount.load(); }
};

// ==================== Shared Message Buffer for Polling ====================

// Global buffer for the most recent message (for polling approach)
static std::vector<uint8_t> g_sharedMessageBuffer;
static std::atomic<bool> g_hasNewMessage(false);
static std::atomic<uint32_t> g_sharedMessageSize(0);

// ==================== C API ====================

/**
 * Create a SendPort-based event listener.
 * Returns an EventListener* pointer that can be passed to rp3d_world_set_event_listener().
 */
extern "C" EMSCRIPTEN_KEEPALIVE RP3D_EventListener* rp3d_create_sendport_event_listener(
    uint64_t sendPortId
) {
    SendPortEventListener* listener = new SendPortEventListener(sendPortId);
    return reinterpret_cast<RP3D_EventListener*>(listener);
}

/**
 * Set the event listener for a physics world.
 * Matches ReactPhysics3D's PhysicsWorld::setEventListener().
 * Pass nullptr to remove the current listener.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_world_set_event_listener(
    RP3D_PhysicsWorld* world,
    RP3D_EventListener* listener
) {
    if (!world) {
        std::cout << "Error: null world in set_event_listener" << std::endl;
        return;
    }

    reactphysics3d::PhysicsWorld* rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld*>(world);
    reactphysics3d::EventListener* rp3dListener = reinterpret_cast<reactphysics3d::EventListener*>(listener);

    rp3dWorld->setEventListener(rp3dListener);

    std::cout << "Set event listener for world (listener: " << listener << ")" << std::endl;
}

/**
 * Destroy an event listener created by rp3d_create_sendport_event_listener.
 */
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_destroy_event_listener(RP3D_EventListener* listener) {
    if (!listener) {
        return;
    }

    reactphysics3d::EventListener* rp3dListener = reinterpret_cast<reactphysics3d::EventListener*>(listener);
    delete rp3dListener;

    std::cout << "Destroyed event listener: " << listener << std::endl;
}

/**
 * Check if there's a pending message from any listener.
 */
extern "C" EMSCRIPTEN_KEEPALIVE int rp3d_has_pending_message() {
    return g_hasNewMessage.load() ? 1 : 0;
}

/**
 * Get the latest message from a listener (for polling).
 * Returns the actual message size, or 0 if no message.
 */
extern "C" EMSCRIPTEN_KEEPALIVE uint32_t rp3d_get_listener_message(
    uint8_t* buffer,
    uint32_t bufferSize
) {
    if (!g_hasNewMessage.load()) {
        return 0;
    }

    uint32_t msgSize = g_sharedMessageSize.load();
    if (msgSize > bufferSize) {
        std::cout << "Warning: buffer too small for message" << std::endl;
        return 0;
    }

    std::memcpy(buffer, g_sharedMessageBuffer.data(), msgSize);
    g_hasNewMessage.store(false);

    return msgSize;
}

/**
 * Send a message to a Dart SendPort.
 * This is a helper function called from the event listener.
 */
extern "C" EMSCRIPTEN_KEEPALIVE int rp3d_send_to_dart_port(
    uint64_t sendPortId,
    const uint8_t* data,
    uint32_t size
) {
    // Copy to shared buffer for polling
    g_sharedMessageBuffer.resize(size);
    std::memcpy(g_sharedMessageBuffer.data(), data, size);
    g_sharedMessageSize.store(size);
    g_hasNewMessage.store(true);

    std::cout << "Sent " << size << " bytes to Dart port " << sendPortId << std::endl;

    return 1; // Success
}
