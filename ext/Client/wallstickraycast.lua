stick = false
local raycastUpdateEvent
local velocityFreezeEvent
-- Max distance we are going to raycast.
local MAX_CAST_DISTANCE = 1.5

-- Raycast is expensive, so we throttle the amount of updates.
local RAYCAST_RATE = 0.2

-- Save time since last raycast.
local lastDelta = 0

function Raycast()
    -- We get the camera transform, from which we will start the raycast. We get the direction from then forward vector. Camera transform
    -- is inverted, so we have to invert theis vector.
    local transform = ClientUtils:GetCameraTransform()
    local direction = Vec3(transform.forward.x * -1, transform.forward.y * -1, transform.forward.z * -1)

    if transform.trans == Vec3(0,0,0) then
        return
    end

    -- We want the raycast to start not at head height, but at weapon heigth, so we lower it.
    local castStart = Vec3(
            transform.trans.x,
            transform.trans.y ,
            transform.trans.z)

    -- We get the raycast end transform with the calculated direction and the max distance.
    local castEnd = Vec3(
            transform.trans.x + (direction.x * MAX_CAST_DISTANCE),
            transform.trans.y + (direction.y * MAX_CAST_DISTANCE),
            transform.trans.z + (direction.z * MAX_CAST_DISTANCE))

    -- Perform raycast, returns a RayCastHit object.
    local raycast = RaycastManager:Raycast(castStart, castEnd, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

    local localPlayer = PlayerManager:GetLocalPlayer()

    if localPlayer == nil then
        return
    end

    if raycast ~= nil then
        NetEvents:Send("stick")


    else
        NetEvents:Send("unstick")
        if velocityFreezeEvent ~= nil then
            velocityFreezeEvent:Unsubscribe()
        end
    end
end
Events:Subscribe('Client:UpdateInput', function(delta)
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_C) and raycastUpdateEvent == nil then
        raycastUpdateEvent = Events:Subscribe('UpdateManager:Update', function(delta, pass)
            -- Only do raycast on presimulation UpdatePass
            if pass ~= UpdatePass.UpdatePass_PreSim then
                return
            end

            lastDelta = lastDelta + delta

            -- If the last time since the last raycast reaches the set rate we repeat the raycast.
            if lastDelta >= RAYCAST_RATE then
                lastDelta = 0
                Raycast()
            end
        end)
    end
end)
Events:Subscribe('Client:UpdateInput', function(delta)
    if InputManager:WentKeyUp(InputDeviceKeys.IDK_C) then
        if raycastUpdateEvent ~= nil then
            NetEvents:Send("unstick")
            print("velocityFreezeEvent unsub")
            raycastUpdateEvent:Unsubscribe()
        end
    end
end)