local espOn = false
local maxDistance = 70

Events:Subscribe('Extension:Loaded', function()
    WebUI:Init()
    WebUI:Show()
end)

Events:Subscribe('Client:UpdateInput', function(delta)
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_J) then
        --print(PlayerManager:GetLocalPlayer().soldier.transform.trans)
        espOn = true
        WebUI:ExecuteJS('ShowMarker(true)')
    end

    if InputManager:WentKeyUp(InputDeviceKeys.IDK_J) then
        espOn = false
        WebUI:ExecuteJS('ShowMarker(false)')
    end
end)

Events:Subscribe('Engine:Update', function(delta, simulationDelta)
    if espOn == false then
        return
    end

    players = PlayerManager:GetPlayers()
    
    localPlayer = PlayerManager:GetLocalPlayer()

    local coordinates = {}
    local distances = {}

    for i, player in pairs(players) do
        if localPlayer.soldier ~= nil and player.soldier ~= nil then
            if localPlayer.soldier.transform.trans:Distance(player.soldier.transform.trans) < maxDistance then
                coordinates[i] = ClientUtils:WorldToScreen(player.soldier.transform.trans)
                distances[i] = localPlayer.soldier.transform.trans:Distance(player.soldier.transform.trans)
                --print("Distance to player: " .. player.name .. " is " .. tostring(localPlayer.soldier.transform.trans:Distance(player.soldier.transform.trans)))
            end
        end
    end

    if #coordinates <= 1 then
        return
    end

    local data = {
        cords = coordinates,
        dist = distances,
    }

    local dataJson = json.encode(data)

    --print(data)

    -- Update WebUI marker.
    --WebUI:ExecuteJS('UpdateMarkers('.. dataJson .. ');')
    WebUI:ExecuteJS('UpdateMarker('.. coordinates[2].x ..','.. coordinates[2].y.. "," .. distances[2] ..')' )

end)