require("hiddenvision")
require("esp")
require("wallstickraycast")

NetEvents:Subscribe("netMakeSuperSoldier", function()
    Events:DispatchLocal("customEvent")
end)

NetEvents:Subscribe("setHiddenVision", function()
    setHiddenVision()
end)

NetEvents:Subscribe("removeHiddenVision", function()
    removeHiddenVision()
end)

Console:Register('stick', 'SetSpectating true or false', function(args)
    if args[1] == "true" then
        NetEvents:Send("stick")
        else NetEvents:Send("unstick")
    end
end)

Console:Register('vision', 'hiddenvision true or false', function(args)
    if args[1] == "true" then
        print("set")
        setHiddenVision()
    else removeHiddenVision()
    end
end)

Events:Subscribe('Client:UpdateInput', function(delta)
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_O) then
        NetEvents:Send('float')
    elseif InputManager:WentKeyUp(InputDeviceKeys.IDK_O) then
        NetEvents:Send('endFloat')
    end
end)