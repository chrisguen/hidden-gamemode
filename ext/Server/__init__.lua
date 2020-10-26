local playerDamage
local currentHiddenPlayer
local playerDamageTable = {}

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
	if next(playerDamageTable) == nil then
		--empty dmgTable so make Hidden random
		playersOnServer = PlayerManager:GetPlayers()
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

function selectHidden()
		local players = PlayerManager:GetPlayers()
end

function SpawnHidden(player)
	if player == nil then
		return
	elseif player.soldier ~= nil then
		-- The player must be dead if we want to spawn him somewhere so if he is already alive...we kill him.
		player.soldier:Kill(true)
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

-- Debug commands
Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	if message == '!spawn' then
		SpawnHidden(player)
	elseif message == "super" then
		Events:Dispatch("makeSuperSoldier")
		NetEvents:Broadcast('netMakeSuperSoldier')
	elseif message == "heal" then
		soldier = SoldierEntity(player.soldier)
		soldier.health = 500
	elseif message == "max" then
		soldier = SoldierEntity(player.soldier)
		soldier.maxHealth = 1000
	elseif message == "test" then
		soldier = SoldierEntity(player.soldier)
		if soldier.aimingEnabled then
			soldier.aimingEnabled = false
		else
			soldier.aimingEnabled = true
		end
	elseif message == "invis" then
		soldier = SoldierEntity(player.soldier)
		if soldier.forceInvisible then
			soldier.forceInvisible = false
		else
			soldier.forceInvisible = true
		end
	elseif message == "dmgTable" then
		local testmsg = "DamageTable: "
		for localplayer, dmg in pairs(playerDamageTable) do
			testmsg = testmsg .. localplayer.name .. " " .. tostring(dmg) .. "	"
			print(testmsg)
		end
		ChatManager:Yell(testmsg, 4)
	elseif message == "start" then
		startRound()
		ChatManager:Yell("Current hidden: " .. currentHiddenPlayer.name, 4)
	else
		ChatManager:Yell(message, 3)
	end
end)
