-- This is a custom GUID we'll assign to our custom soldier blueprint.
local customSoldierGuid = Guid('261E43BF-259B-41D2-BF3B-0000DEADBEEF')
local customSoldierDataGuid = Guid('261E43BF-259B-41D2-BF3B-0001DEADBEEF')
local customPhysicsGuid = Guid('261E43BF-259B-41D2-BF3B-0002DEADBEEF')
local customGroundStateDataGuid = Guid('261E43BF-259B-41D2-BF3B-0003DEADBEEF')
local customCharacterStatePoseInfoGuid = Guid('261E43BF-259B-41D2-BF3B-0004DEADBEEF')
local customJumpStateDataGuid = Guid('261E43BF-259B-41D2-BF3B-0005DEADBEEF')
local customInAirStateDataGuid = Guid('261E43BF-259B-41D2-BF3B-0006DEADBEEF')



Events:Subscribe('Level:RegisterEntityResources', function(levelData)
	local characterPhysics = nil
	local originalSoldierBp = SoldierBlueprint(ResourceManager:SearchForInstanceByGuid(Guid("261E43BF-259B-41D2-BF3B-9AE4DDA96AD2")))

	-- Clone the original soldier blueprint and assign it our custom GUID and name.
	local customSoldierBp = SoldierBlueprint(originalSoldierBp:Clone(customSoldierGuid))
	customSoldierBp.name = 'Characters/Soldiers/HiddenSoldier'

	-- We also need to clone the original SoldierEntityData and replace all references to it.
	local originalSoldierData = customSoldierBp.object
	local customSoldierData = SoldierEntityData(originalSoldierData:Clone(customSoldierDataGuid))

	customSoldierBp.object = customSoldierData

	for _, connection in pairs(customSoldierBp.propertyConnections) do
		if connection.source == originalSoldierData then
			connection.source = customSoldierData
		end

		if connection.target == originalSoldierData then
			connection.target = customSoldierData
		end
	end

	for _, connection in pairs(customSoldierBp.linkConnections) do
		if connection.source == originalSoldierData then
			connection.source = customSoldierData
		end

		if connection.target == originalSoldierData then
			connection.target = customSoldierData
		end
	end

	for _, connection in pairs(customSoldierBp.eventConnections) do
		if connection.source == originalSoldierData then
			connection.source = customSoldierData
		end

		if connection.target == originalSoldierData then
			connection.target = customSoldierData
		end
	end

	local customCharacterPhysics = CharacterPhysicsData(customSoldierData.characterPhysics:Clone(customPhysicsGuid))
	local customOnGroundStateData = OnGroundStateData(customCharacterPhysics.states[1]:Clone(customGroundStateDataGuid))
	local customCharacterStatePoseInfo = CharacterStatePoseInfo(customOnGroundStateData.poseInfo[1]:Clone(customCharacterStatePoseInfoGuid))
	local customJumpStateData = JumpStateData(customCharacterPhysics.states[2]:Clone(customJumpStateDataGuid))
	local customInAirStateData = InAirStateData(customCharacterPhysics.states[3]:Clone(customInAirStateDataGuid))

	customOnGroundStateData.poseInfo[1] = customCharacterStatePoseInfo
	customCharacterPhysics.states[1] = customOnGroundStateData
	customCharacterPhysics.states[2] = customJumpStateData
	customCharacterPhysics.states[3] = customInAirStateData
	local db = ResourceManager:FindDatabasePartition(Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"))

	--[[local guids = {}

	for i, v in pairs(customCharacterPhysics.states) do
		guids[i] = MathUtils:RandomGuid()
		customCharacterPhysics.states[i] = v:Clone(guids[i])
		db:AddInstance(customCharacterPhysics.states[i])

	end]]--

	customSoldierData.characterPhysics = customCharacterPhysics

	-- Change the soldier's max health.
	customSoldierData.maxHealth = 120


	-- Add our new soldier blueprint to the partition.
	-- This will make it so we can later look it up by its GUID.
	db:AddInstance(customSoldierBp)
	db:AddInstance(customCharacterStatePoseInfo)
	db:AddInstance(customOnGroundStateData)
	db:AddInstance(customJumpStateData)
	db:AddInstance(customInAirStateData)
	--[[for _, guid in pairs(guids) do
		db:AddInstance()
	end]]--
	db:AddInstance(customCharacterPhysics)

	-- In order for our custom soldier to be usable we need to register it with the engine.
	-- This means that during this event we need to create a new registry container and add
	-- all relevant datacontainers to the respective arrays.
	local registry = RegistryContainer()

	-- Locate the custom soldier BP, get its data, and add to the registry container.
	-- You can fetch the BP in the same way when you want to spawn a player with it.
	local customSoldierBp = SoldierBlueprint(ResourceManager:SearchForInstanceByGuid(customSoldierGuid))

	local soldierData = customSoldierBp.object
	local customOnGroundStateData = OnGroundStateData(ResourceManager:SearchForInstanceByGuid(customGroundStateDataGuid))
	local customCharacterStatePoseInfo = CharacterStatePoseInfo(ResourceManager:SearchForInstanceByGuid(customCharacterStatePoseInfoGuid))
	local customJumpStateData = JumpStateData(ResourceManager:SearchForInstanceByGuid(customJumpStateDataGuid))
	local customInAirStateData = InAirStateData(ResourceManager:SearchForInstanceByGuid(customInAirStateDataGuid))

	local customCharacterPhysics = CharacterPhysicsData(ResourceManager:SearchForInstanceByGuid(customPhysicsGuid))

	registry.blueprintRegistry:add(customSoldierBp)
	registry.entityRegistry:add(soldierData)
	registry.assetRegistry:add(customCharacterPhysics)
	registry.assetRegistry:add(customOnGroundStateData)
	registry.assetRegistry:add(customCharacterStatePoseInfo)
	registry.assetRegistry:add(customJumpStateData)
	registry.assetRegistry:add(customInAirStateData)

	--for _, guid in pairs(guids) do
	--	registry.assetRegistry:add(ResourceManager:SearchForInstanceByGuid(guid))
	--end

	-- And then add the registry to the game compartment.
	ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)
end)
