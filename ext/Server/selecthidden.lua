local currentHiddenPlayer
playerDamageTable = {}

--Dont allow Teamchanges
Hooks:Install('Player:SelectTeam', 1, function(hook, player, team)
    hook:Return()
end)

-- Save Damage done to Hidden in Table
Hooks:Install('Soldier:Damage', 1, function(hook, soldier, info, giverInfo)
    giverInfo = DamageGiverInfo(giverInfo)
    --exclude hidden attacks, suicide ...
    if giverInfo.giver ~= currentHiddenPlayer and giverInfo.damageType ~= DamageType.Suicide then
        --print(DamageInfo(info).damage .. "dmg done to hidden from " .. giverInfo.giver.name)
        for p,_ in pairs(playerDamageTable) do
            if p == giverInfo.giver then
                playerDamageTable[p] = playerDamageTable[p] + DamageInfo(info).damage
                return
            end
        end
        playerDamageTable[giverInfo.giver] = DamageInfo(info).damage
    end
end)

function startRound()
    playersOnServer = PlayerManager:GetPlayers()
    if next(playerDamageTable) == nil then
        --empty dmgTable so make Hidden random
        currentHiddenPlayer = playersOnServer[MathUtils:GetRandomInt(1, PlayerManager:GetPlayerCount())]

    else
        local probabilityTable = {}
        local totalDmg
        for p, dmg in pairs(playerDamageTable) do
            totalDmg = totalDmg + dmg
        end
        for p, dmg in pairs(playerDamageTable) do
            probabilityTable[p] = dmg/totalDmg
        end
        currentHiddenPlayer = GetWeightedRandomKey(playerDamageTable)
        currentHiddenPlayer.teamId = TeamId.Team1
    end
    for _, player in pairs(playersOnServer) do
        if player ~= currentHiddenPlayer then
            player.teamId = TeamId.Team2
        end
    end
end

function GetWeightedRandomKey( tab )
    local sum = 0

    for _, chance in pairs( tab ) do
        sum = sum + chance
    end

    local select = MathUtils:GetRandom(0,1) * sum

    for key, chance in pairs( tab ) do
        select = select - chance
        if select < 0 then return key end
    end
end

function getHiddenPlayer()
    return currentHiddenPlayer
end