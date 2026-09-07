#include <deque>
#include <mutex>
#ifndef __EMSCRIPTEN__
#include "dart_api_dl.h"
#include "dart_version.h"
#include "internal/dart_api_dl_impl.h"
// Resolve only the thread-safe posting API; no Dart VM linkage is required.
static Dart_PostCObject_Type postDartMessage = nullptr;
#endif
/*
 * SendPort Event Listener Implementation
 *
 * This file implements a thread-safe EventListener that sends collision data
 * to Dart via SendPort/ReceivePort for multi-threaded scenarios.
 */

#include "c_api/rp3d_c_api.h"
#include <cstring>
#include <vector>
#include <atomic>
#include <iostream>
#include <reactphysics3d/reactphysics3d.h>
#include <reactphysics3d/engine/EventListener.h>
#include <reactphysics3d/collision/OverlapCallback.h>

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
    std::mutex _mutex;
    std::deque<std::vector<uint8_t>> _messages;

    void enqueue(const MessageBuffer& buffer) {
        {
            std::lock_guard<std::mutex> lock(_mutex);
            _messages.emplace_back(buffer.data(), buffer.data() + buffer.size());
        }
#ifndef __EMSCRIPTEN__
        if (postDartMessage && _sendPortId) {
            Dart_CObject notification;
            notification.type = Dart_CObject_kInt32;
            notification.value.as_int32 = 1;
            postDartMessage(static_cast<Dart_Port_DL>(_sendPortId), &notification);
        }
#endif
    }

public:
    SendPortEventListener(uint64_t sendPortId)
        : _sendPortId(sendPortId)
        , _messageCount(0)
    {
    }

    ~SendPortEventListener() override = default;

    /// Called when contacts occur during collision
    virtual void onContact(const CollisionCallback::CallbackData& callbackData) override {
        _messageCount++;
        MessageBuffer _buffer;

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
        enqueue(_buffer);
    }

    /// Called when trigger overlaps occur
    virtual void onTrigger(const OverlapCallback::CallbackData& callbackData) override {
        _messageCount++;
        MessageBuffer _buffer;

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
        enqueue(_buffer);
    }

    uint32_t messageSize() {
        std::lock_guard<std::mutex> lock(_mutex);
        return _messages.empty() ? 0 : static_cast<uint32_t>(_messages.front().size());
    }
    uint32_t read(uint8_t* data, uint32_t capacity) {
        std::lock_guard<std::mutex> lock(_mutex);
        if (_messages.empty()) return 0;
        uint32_t size = static_cast<uint32_t>(_messages.front().size());
        if (capacity < size || !data) return 0;
        std::memcpy(data, _messages.front().data(), size);
        _messages.pop_front();
        return size;
    }
    void clear() {
        std::lock_guard<std::mutex> lock(_mutex);
        _messages.clear();
    }
};

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
        return;
    }

    reactphysics3d::PhysicsWorld* rp3dWorld = reinterpret_cast<reactphysics3d::PhysicsWorld*>(world);
    reactphysics3d::EventListener* rp3dListener = reinterpret_cast<reactphysics3d::EventListener*>(listener);

    rp3dWorld->setEventListener(rp3dListener);

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

}


extern "C" EMSCRIPTEN_KEEPALIVE int rp3d_initialize_dart_api(void* data) {
#ifndef __EMSCRIPTEN__
    static std::mutex mutex;
    std::lock_guard<std::mutex> lock(mutex);
    if (postDartMessage) return 0;
    const DartApi* api = static_cast<const DartApi*>(data);
    if (!api || api->major != DART_API_DL_MAJOR_VERSION) return -1;
    for (const DartApiEntry* entry = api->functions; entry->name; ++entry) {
        if (std::strcmp(entry->name, "Dart_PostCObject") == 0) {
            postDartMessage = reinterpret_cast<Dart_PostCObject_Type>(entry->function);
            break;
        }
    }
    return postDartMessage ? 0 : -1;
#else
    return 0;
#endif
}
extern "C" EMSCRIPTEN_KEEPALIVE uint32_t rp3d_listener_message_size(RP3D_EventListener* listener) {
    return reinterpret_cast<SendPortEventListener*>(listener)->messageSize();
}
extern "C" EMSCRIPTEN_KEEPALIVE uint32_t rp3d_listener_read_message(RP3D_EventListener* listener, uint8_t* data, uint32_t capacity) {
    return reinterpret_cast<SendPortEventListener*>(listener)->read(data, capacity);
}
extern "C" EMSCRIPTEN_KEEPALIVE void rp3d_listener_clear_messages(RP3D_EventListener* listener) {
    reinterpret_cast<SendPortEventListener*>(listener)->clear();
}
