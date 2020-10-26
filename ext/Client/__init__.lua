print("mod loaded")
NetEvents:Subscribe("netMakeSuperSoldier", function()
    Events:Dispatch("customEvent")
end)