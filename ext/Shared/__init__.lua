--require('__shared/hiddensoldier')
require('__shared/customsoldier')

--ResourceManager:RegisterInstanceLoadHandler(Guid('3A3F3DEE-2405-4952-A2E9-09609EB5A234'), Guid('71F35CE6-150B-4818-B392-E493EB81167B'), function(instance)
--  local mesh = MeshMaterialVariation(instance)
--  mesh:MakeWritable()
--  shader = mesh.SurfaceShaderInstanceDataStruct
--  vectorParameters = shader.VectorParameters
-- vectorParameters.value = Vec4(0.0,0.0,0.0,0.0)
  
--end)


Events:Subscribe('makeSuperSoldier', function()
    local characterStatePoseInfo = CharacterStatePoseInfo(ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-0004DEADBEEF')))
    characterStatePoseInfo:MakeWritable()
    characterStatePoseInfo.sprintMultiplier = 4
end)
