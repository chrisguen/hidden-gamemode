require('__shared/customsoldier_hidden')

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
