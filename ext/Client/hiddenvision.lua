local hiddenVision = nil

function setHiddenVision()
    if hiddenVision ~= nil then
        return
    end

    local hiddenVisionData = VisualEnvironmentEntityData()
    hiddenVisionData.enabled = true
    hiddenVisionData.visibility = 1.0
    hiddenVisionData.priority = 999999

    local shaderParams = ShaderParamsComponentData()
    shaderParams.value = Vec4(1.0, 1.0, 1.0, 1.0)
    shaderParams.parameterName = 'FLIRData'

    local outdoorLight = OutdoorLightComponentData()
    outdoorLight.enable = true
    outdoorLight.sunColor = Vec3(0.15, 0.15, 0.15)
    outdoorLight.skyColor = Vec3(0.01, 0.01, 0.01)
    outdoorLight.groundColor = Vec3(0.01, 0.01, 0.01)

    local colorCorrection = ColorCorrectionComponentData()
    colorCorrection.enable = true
    colorCorrection.brightness = Vec3(2.0, 2.0, 2.0)
    colorCorrection.contrast = Vec3(1.1, 1.1, 1.1)
    colorCorrection.saturation = Vec3(0.4, 0.04, 0.03)
    colorCorrection.hue = 0.0
    colorCorrection.colorGradingTexture = TextureAsset(ResourceManager:SearchForInstanceByGuid(Guid('E79F27A1-7B97-4A63-8ED8-372FE5012A31')))
    colorCorrection.colorGradingEnable = true

    local vignette = VignetteComponentData()
    vignette.enable = true
    vignette.scale = Vec2(2.5, 2.5)
    vignette.exponent = 2.0
    vignette.color = Vec3(0.12, 0.0, 0.0)
    vignette.opacity = 0.4

    local fog = FogComponentData()
    fog.enable = true
    fog.fogDistanceMultiplier = 1.0
    fog.fogGradientEnable = true
    fog.start = 5.0
    fog.endValue = 15.0
    fog.curve = Vec4(3.108949, -4.2201934, 2.0970724, -0.001664313)
    fog.fogColorEnable = true
    fog.fogColor = Vec3(1.0, 1.0, 1.0)
    fog.fogColorStart = 0.0
    fog.fogColorEnd = 1000.0
    fog.fogColorCurve = Vec4(4.8581696, -6.213437, 3.202797, -0.026411323)
    fog.transparencyFadeStart = -500.0
    fog.transparencyFadeEnd = 1500.0
    fog.transparencyFadeClamp = 1.0

    hiddenVisionData.components:add(shaderParams)
    hiddenVisionData.runtimeComponentCount = hiddenVisionData.runtimeComponentCount + 1

    hiddenVisionData.components:add(outdoorLight)
    hiddenVisionData.runtimeComponentCount = hiddenVisionData.runtimeComponentCount + 1

    hiddenVisionData.components:add(colorCorrection)
    hiddenVisionData.runtimeComponentCount = hiddenVisionData.runtimeComponentCount + 1

    hiddenVisionData.components:add(vignette)
    hiddenVisionData.runtimeComponentCount = hiddenVisionData.runtimeComponentCount + 1

    --infectedVisionData.components:add(fog)
    --infectedVisionData.runtimeComponentCount = infectedVisionData.runtimeComponentCount + 1

    hiddenVision = EntityManager:CreateEntity(hiddenVisionData, LinearTransform())

    if hiddenVision ~= nil then
        hiddenVision:Init(Realm.Realm_Client, true)
    end
end

function removeHiddenVision()
    if hiddenVision ~= nil then
        hiddenVision:Destroy()
        hiddenVision = nil
    end
end



Events:Subscribe('Extension:Unloading', function()
    removeHiddenVision()
end)