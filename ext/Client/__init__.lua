require("hiddenvision")
require("esp")
require("wallstickraycast")
IngameSpectator = require(ingame-spectator)

NetEvents:Subscribe("netMakeSuperSoldier", function()
    Events:DispatchLocal("customEvent")
end)

NetEvents:Subscribe("setHiddenVision", function()
    setHiddenVision()
end)

NetEvents:Subscribe("removeHiddenVision", function()
    removeHiddenVision()
end)


NetEvents:Subscribe("spectate", function()
    if localPlayer.soldier ~= nil then
        return
    end
    IngameSpectator:enable()
end)

NetEvents:Subscribe("unspectate", function()
    IngameSpectator:disable()
end)


Console:Register('Spectate', 'Toggle spectator mode', function(args)
    if IngameSpectator:isEnabled() then
        IngameSpectator:disable()
        return 'Disabled in-game spectator.'
    end

    local localPlayer = PlayerManager:GetLocalPlayer()

    if localPlayer.soldier ~= nil then
        return 'Cannot enable in-game spectator while alive.'
    end

    IngameSpectator:enable()
    return 'Enabled in-game spectator.'
end)