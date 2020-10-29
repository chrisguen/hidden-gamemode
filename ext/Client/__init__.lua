require("hiddenvision")

NetEvents:Subscribe("netMakeSuperSoldier", function()
    Events:DispatchLocal("customEvent")
end)

NetEvents:Subscribe("setHiddenVision", function()
    setHiddenVision()
end)

NetEvents:Subscribe("removeHiddenVision", function()
    removeHiddenVision()
end)

Console:Register('setspec', 'SetSpectating true or false', function(args)
    if args[1] == "true" then
        SpectatorManager:SetSpectating(true)
        else SpectatorManager:SetSpectating(false)
    end
end)

Console:Register('vision', 'hiddenvision true or false', function(args)
    if args[1] == "true" then
        print("set")
        setHiddenVision()
    else removeHiddenVision()
    end
end)

