require("__shared/roundstate")
local currentHiddenPlayer
playerDamageTable = {}


--Dont allow Teamchanges
Hooks:Install('Player:SelectTeam', 1, function(hook, player, team)
    hook:Return()
end)

-- Save Damage done to Hidden in Table
Hooks:Install('Soldier:Damage', 1, function(hook, soldier, info, giverInfo)
    if giverInfo == nil then
        return
    end
    if giverInfo.giver == nil then
        return
    end
    giverInfo = DamageGiverInfo(giverInfo)

    --exclude hidden attacks, suicide ...
    if giverInfo.giver.name ~= currentHiddenPlayer and giverInfo.damageType ~= DamageType.Suicide then
        print(DamageInfo(info).damage .. "dmg done to hidden from " .. giverInfo.giver.name)
        if next(playerDamageTable) ~= nil then
            for p,_ in pairs(playerDamageTable) do
                if p == giverInfo.giver.name then
                    playerDamageTable[p] = playerDamageTable[p] + DamageInfo(info).damage
                    return
                end
            end
        end
        playerDamageTable[giverInfo.giver.name] = DamageInfo(info).damage
    end
end)

Events:Subscribe('Player:Left', function(player)
    for dmgPlayer, dmg in pairs(playerDamageTable) do
        if dmgPlayer == player.name then
            playerDamageTable[player] = nil
        end
    end
    if player.name == currentHiddenPlayer then
        endRound()
    end
end)

Events:Subscribe('Player:Killed', function(player, inflictor, position, weapon, isRoadKill, isHeadShot, wasVictimInReviveState, info)
    if player.name == currentHiddenPlayer then
        NetEvents:SendToLocal('removeHiddenVision', PlayerManager:GetPlayerByName(currentHiddenPlayer))
        ChatManager:Yell("I.R.I.S Wins!", 5)
        endRound()
    end
end)

Events:Subscribe('Level:Destroy', function()
    currentHiddenPlayer = nil
    playerDamageTable = {}
end)

Events:Subscribe('Player:Authenticated', function(player)
    if roundstate == RoundState.Playing then
        player.teamId = TeamId.Team2
    end
end)

function startRound()
    if roundstate == RoundState.PreRound then

        playersOnServer = PlayerManager:GetPlayers()

        local playerCount = 0
        if next(playerDamageTable) == nil then
            --empty dmgTable so make Hidden random
            currentHiddenPlayer = playersOnServer[MathUtils:GetRandomInt(1, PlayerManager:GetPlayerCount())].name

        else
            local probabilityTable = {}
            local totalDmg = 0
            for p, dmg in pairs(playerDamageTable) do
                totalDmg = totalDmg + dmg
            end
            for p, dmg in pairs(playerDamageTable) do
                probabilityTable[p] = dmg/totalDmg
            end
            currentHiddenPlayer = GetWeightedRandomKey(playerDamageTable)
            PlayerManager:GetPlayerByName(currentHiddenPlayer).teamId = TeamId.Team1
        end
        for _, player in pairs(playersOnServer) do
            if player.name ~= currentHiddenPlayer then
                player.teamId = TeamId.Team2
            end
            playerCount = playerCount + 1
        end
        playerDamageTable = {}
        for _,playerx in pairs(playersOnServer) do
            if playerx.soldier ~= nil then
                -- The player must be dead if we want to spawn him somewhere so if he is already alive...we kill him.
                playerx.soldier:Kill()
            end
        end
        spawnHidden(PlayerManager:GetPlayerByName(currentHiddenPlayer))
        SoldierEntity(PlayerManager:GetPlayerByName(currentHiddenPlayer).soldier).maxHealth = playerCount * 150
        SoldierEntity(PlayerManager:GetPlayerByName(currentHiddenPlayer).soldier).health = 10000
        roundstate = RoundState.Playing
        NetEvents:SendToLocal('setHiddenVision', PlayerManager:GetPlayerByName(currentHiddenPlayer))
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

function endRound()
    roundstate = RoundState.PostRound
end

function getHiddenPlayer()
    return currentHiddenPlayer
end

function spawnHidden(player)
    if player == nil then
        return
    elseif player.soldier ~= nil then
        -- The player must be dead if we want to spawn him somewhere so if he is already alive...we kill him.
        player.soldier:Kill()
    end

    -- We retrieve the weapon and attachment instances by their asset name.
    local weapon0    = ResourceManager:SearchForDataContainer('Weapons/M416/U_M416')
    local weaponAtt0 = ResourceManager:SearchForDataContainer('Weapons/M416/U_M416_ACOG')
    local weaponAtt1 = ResourceManager:SearchForDataContainer('Weapons/M416/U_M416_Silencer')


    local weapon1    = ResourceManager:SearchForDataContainer('Weapons/XP1_L85A2/U_L85A2')
    local weaponAtt2 = ResourceManager:SearchForDataContainer('Weapons/XP1_L85A2/U_L85A2_RX01')
    local weaponAtt3 = ResourceManager:SearchForDataContainer('Weapons/XP1_L85A2/U_L85A2_Silencer')


    player:SelectWeapon(WeaponSlot.WeaponSlot_0, weapon0, { weaponAtt0, weaponAtt1 })
    player:SelectWeapon(WeaponSlot.WeaponSlot_1, weapon1, { weaponAtt2, weaponAtt3 })

    -- Setting soldier class and appearance
    local soldierAsset = ResourceManager:SearchForDataContainer('Gameplay/Kits/RURecon')
    local appearance   = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Recon_Appearance_DrPepper')
    player:SelectUnlockAssets(soldierAsset, { appearance })

    -- Creating soldier
    local soldierBlueprint = ResourceManager:SearchForInstanceByGuid(Guid('261E43BF-259B-41D2-BF3B-0000DEADBEEF'))


    local transform = LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(0, 80, 0)
    )

    local soldier = player:CreateSoldier(soldierBlueprint, transform)

    if soldier == nil then
        print('Failed to create player soldier')
        return
    end

    -- Spawning soldier
    player:SpawnSoldierAt(soldier, transform, CharacterPoseType.CharacterPoseType_Stand)
end