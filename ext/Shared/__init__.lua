require('__shared/customsoldier_hidden')
--require("__client/wallstick")
--local charPhyData = CharacterPhysicsData(ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-0002DEADBEEF')))
--charPhyData:MakeWritable()

Events:Subscribe('makeSuperSoldier', function()
    local characterStatePoseInfo = CharacterStatePoseInfo(ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-0004DEADBEEF')))
    characterStatePoseInfo:MakeWritable()
    characterStatePoseInfo.sprintMultiplier = 4

    JumpStateData(charPhyData.states[2]).jumpHeight = 5
    --charPhyData.states[1].poseInfo[2]:MakeWritable()
    CharacterStatePoseInfo(charPhyData.states[1].poseInfo[2]).velocity = 10

    local inAirStateData = InAirStateData(ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-0006DEADBEEF')))
    inAirStateData:MakeWritable()
    inAirStateData.freeFallVelocity = 50
end)

--[[Events:Subscribe('Player:UpdateInput', function(player, deltaTime)

    -- check if player is null, if it is: dont continue
    if player == nil then
        return
    end

    local entryInput = player.input

    -- check entryinput if its null, if it is: dont continue
    if entryInput == nil then
        return
    end

    -- check if our player has a soldier, if not dont continue
    if player.soldier == nil then
        return
    end

    -- Get physics on this soldier
    local soldierPhysics = player.soldier.physicsEntityBase

    -- check if we have physics on this soldier, if not dont continue
    if soldierPhysics == nil then
        return
    end

    -- this is same as on both client and server
    --print(tostring(ClientUtils:GetCameraTransform().trans))

    local newVelocity = Vec3(0,0.326667,0)
    --local newVelocity = Vec3(0,20,30)


    -- Add velocity on the server as well, so other players can see it
    soldierPhysics.linearVelocity = newVelocity

end)]]--
