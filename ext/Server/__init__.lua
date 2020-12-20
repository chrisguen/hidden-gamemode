require('hiddenselection')
require("__shared/roundstate")

ServerUtils:SetCustomGameModeName("Source:Hidden")

function SpawnHidden(player)

end



-- Debug commands
Events:Subscribe('Player:Chat', function(player, recipientMask, message)
	if message == '!spawn' then
		SpawnHidden(player)
	elseif message == "super" then
		Events:DispatchLocal("makeSuperSoldier")
		NetEvents:BroadcastLocal('netMakeSuperSoldier')
	elseif message == "init" then
		roundstate = RoundState.PreRound
	elseif message == "restart" then
		restartRound()
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
	elseif message == "dmg" then
		local testmsg = "DamageTable: "
		for localplayer, dmg in pairs(playerDamageTable) do
			testmsg = testmsg .. localplayer.name .. " " .. tostring(dmg) .. "	"
			print(testmsg)
		end
		ChatManager:Yell(testmsg, 4)
	elseif message == "start" then
		startRound()
		ChatManager:Yell("Current hidden: " .. getHiddenPlayer(), 4)
	elseif message == "team1" then
		player.teamId = TeamId.Team1
	elseif message == "team2" then
		player.teamId = TeamId.Team2
	else
		ChatManager:Yell(message, 3)
	end
end)
