require('__shared/customsoldier_hidden')


Events:Subscribe('makeSuperSoldier', function()
    local characterStatePoseInfo = CharacterStatePoseInfo(ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-0004DEADBEEF')))
    characterStatePoseInfo:MakeWritable()
    characterStatePoseInfo.sprintMultiplier = 4
end)
