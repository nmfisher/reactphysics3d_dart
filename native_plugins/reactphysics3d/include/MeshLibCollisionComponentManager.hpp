#pragma once

#include <cmath>
#include <vector>
#include <memory>
#include <string>
#include <filesystem>
#include <mutex>

#include <IPluginComponentManager.hpp>

#include "c_api/TMeshLib.h"
#include "c_api/TMeshLibCollisionManager.h"
#include "VolumeInternal.h"

#include <filament/Engine.h>
#include <filament/utils/SingleInstanceComponentManager.h>
#include <filament/Box.h>
#include <math/vec3.h>
#include <math/mat4.h>

namespace meshlib {

    using namespace thermion;

    class MeshLibCollisionComponentManager : public utils::SingleInstanceComponentManager<MeshLibCollisionComponent>,
                                           public IPluginComponentManager {
    public:
        MeshLibCollisionComponentManager();
        ~MeshLibCollisionComponentManager();

        void update(float deltaTime) override;
        const char* getName() const override;
        void cleanup() override;

        void setEngine(filament::Engine *engine); 
        void addCollisionComponent(utils::Entity entity, float radius);

        void setVoxelVolume(Volume *volume);
        bool isColliding(utils::Entity entity) const;


    private:
        std::unique_ptr<Volume> globalVoxelVolume;
        mutable std::mutex mVolumeMutex;

        float sampleVolumeTrilinear(const Volume* volume, float x, float y, float z);
        filament::math::float3 transformPoint(const filament::math::mat4f& transform, const filament::math::float3& point);
        filament::math::float3 calculateGradientNormal(
            const Volume* volume,
            float x, float y, float z,
            float epsilon = 0.1f
        );

        bool checkEntityCollision(
            utils::Entity entity,
            const Volume* volume,
            const filament::Box& entityBounds,
            const filament::math::mat4f& worldTransform,
            float threshold = 0.0f
        );

        filament::Engine* mEngine = nullptr;
    };

    MeshLibCollisionComponentManager *getMeshLibCollisionManager();

} // namespace meshlib