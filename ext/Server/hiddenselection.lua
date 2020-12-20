require("__shared/roundstate")
require("__shared/timers")
local currentHiddenPlayer
local minPlayers = 1
local deadPlayers = 0
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
        --print(DamageInfo(info).damage .. "dmg done to hidden from " .. giverInfo.giver.name)
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
        irisWin()
    else
        if deadPlayers ~= 0 and player.alive == false then
            deadPlayers = deadPlayers - 1
        end
    end
end)

Events:Subscribe('Player:Killed', function(player, inflictor, position, weapon, isRoadKill, isHeadShot, wasVictimInReviveState, info)
    if player.name == currentHiddenPlayer then
        irisWin()
    else deadPlayers = deadPlayers + 1
        if deadPlayers == PlayerManager:GetPlayerCount() - 1 then
            hiddenWin()
        end
    end
end)

Events:Subscribe('Level:Destroy', function()
    currentHiddenPlayer = nil
    playerDamageTable = {}
end)

Events:Subscribe('Player:Authenticated', function(player)
    if roundstate == RoundState.Playing then
        player.teamId = TeamId.Team2
    elseif roundstate == RoundState.PreRound then
        preRound()
    end
end)



function startRound()
    print("Starting new round...")
    if roundstate == RoundState.PreRound then

        playersOnServer = PlayerManager:GetPlayers()

        local playerCount = GetPlayerCount()
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

        playerDamageTable = {}
        for _,playerx in pairs(playersOnServer) do
            if playerx.soldier ~= nil then
                -- The player must be dead if we want to spawn him somewhere so if he is already alive...we kill him.
                playerx.soldier:Kill()
            end
            if player.name ~= currentHiddenPlayer then
                player.teamId = TeamId.Team2
            else playerx.teamId = TeamId.Team1
                 spawnHidden(playerx)
            end
        end
        roundstate = RoundState.Playing
        NetEvents:SendToLocal('setHiddenVision', PlayerManager:GetPlayerByName(currentHiddenPlayer))
        SoldierEntity(PlayerManager:GetPlayerByName(currentHiddenPlayer).soldier).maxHealth = playerCount * 150
        SoldierEntity(PlayerManager:GetPlayerByName(currentHiddenPlayer).soldier).health = playerCount * 150
    end
end

function restartRound()
    roundstate = RoundState.PreRound
    currentHiddenPlayer = nil
    playerDamageTable = {}
    players = PlayerManager:GetPlayers()
    for _, i in pairs(players) do
        i.soldier:Kill()
    end
    startRound()
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
    NetEvents:SendToLocal('removeHiddenVision', PlayerManager:GetPlayerByName(currentHiddenPlayer))
    ChatManager:Yell("New Round will begin in 10", 4)
    Timers:Timeout(5, function()
        preRound()
    end)
end

function hiddenWin()
    print("Team Hidden won")
    ChatManager:Yell("The Hidden Wins!", 5)
    endRound()
end

function irisWin()
    print("Team I.R.I.S won")
    ChatManager:Yell("I.R.I.S Wins!", 5)
    endRound()
end

function preRound()
    if PlayerManager:GetPlayerCount() >= minPlayers then
        roundstate = RoundState.PreRound
        ChatManager:Yell("The round will begin in 10 seconds.", 3)
        Timers:Timeout(10,function ()
            startRound()
        end)
        --TODO: Display message in WebUi
    else ChatManager:Yell("Waiting for players", 10)
    end
end

preRound()


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
    local knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')

    hiderCustomization = CustomizeSoldierData()
    hiderCustomization.activeSlot = WeaponSlot.WeaponSlot_5
    hiderCustomization.removeAllExistingWeapons = true
    hiderCustomization.overrideCriticalHealthThreshold = 1.0

    local unlockWeapon = UnlockWeaponAndSlot()
    unlockWeapon.weapon = SoldierWeaponUnlockAsset(knife)
    unlockWeapon.slot = WeaponSlot.WeaponSlot_5

    hiderCustomization.weapons:add(unlockWeapon)
    player.soldier:ApplyCustomization(hiderCustomization)
end

function spawnIrisSoldier(player, pos)
    local transform = LinearTransform(
            Vec3(1, 0, 0),
            Vec3(0, 1, 0),
            Vec3(0, 0, 1),
            Vec3(6.5, 74, 1.821289)
    )


end