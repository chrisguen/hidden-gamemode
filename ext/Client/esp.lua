local espOn = false
local maxDistance = 70

Events:Subscribe('Extension:Loaded', function()
    --WebUI:Init()
    --WebUI:Show()
end)

Events:Subscribe('Client:UpdateInput', function(delta)
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_J) then
        print(PlayerManager:GetLocalPlayer().soldier.transform.trans)
        espOn = true
    end

    if InputManager:WentKeyUp(InputDeviceKeys.IDK_J) then
        espOn = false
    end
end)

Events:Subscribe('Engine:Update', function(delta, simulationDelta)
    if espOn == false then
        return
    end

    players = PlayerManager:GetPlayers()
    
    localPlayer = PlayerManager:GetLocalPlayer()

    local coordinates = {}

    for i, player in pairs(players) do
        if localPlayer.soldier ~= nil then
            if localPlayer.soldier.transform.trans:Distance(player.soldier.transform.trans) < maxDistance then
                coordinates[i] = ClientUtils:WorldToScreen(player.soldier.transform.trans)
                print("Distance to player: " .. player.name .. " is " .. tostring(localPlayer.soldier.transform.trans:Distance(player.soldier.transform.trans)))
            end
        end
    end
    --local worldToScreen = ClientUtils:WorldToScreen(w2sMarkerPos)

    if worldToScreen == nil then
        return
    end

    -- Update WebUI marker.
    --WebUI:ExecuteJS('UpdateMarker('.. worldToScreen.x ..','.. worldToScreen.y..')' )
end)

--player.soldier.transform.trans