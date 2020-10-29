
NetEvents:Subscribe("netMakeSuperSoldier", function()
    Events:Dispatch("customEvent")
end)

Console:Register('setspec', 'SetSpectating true or false', function(args)
    if args[1] == true then
        SpectatorManager:SetSpectating(true)
        else SpectatorManager:SetSpectating(false)
    end
end)

