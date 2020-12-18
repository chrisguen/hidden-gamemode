local espOn = false
local maxDistance = 70

Events:Subscribe('Extension:Loaded', function()
    WebUI:Init()
    WebUI:Show()
end)

Events:Subscribe('Client:UpdateInput', function(delta)
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_J) then
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

    local screenPos = {}

    for i, player in pairs(players) do
        if localPlayer.soldier ~= nil and player.soldier ~= nil then
            if localPlayer.team ~= player.team then
                if localPlayer.soldier.transform.trans:Distance(player.soldier.transform.trans) < maxDistance then

                    screenPos[i] = {
                        x = ClientUtils:WorldToScreen(player.soldier.transform.trans).x,
                        y = ClientUtils:WorldToScreen(player.soldier.transform.trans).y,
                        dist = localPlayer.soldier.transform.trans:Distance(player.soldier.transform.trans)
                    }
                end
            end
        end
    end

    if #screenPos == 0 then
        return
    end

    print(screenPos)

    local dataJson = json.encode(screenPos)

    print(dataJson)

    -- Update WebUI marker.
    WebUI:ExecuteJS('UpdateMarkers('.. dataJson .. ');')

end)