PTSR.ResetPlayerVars = function(player)	
	player.pizzaface = false
	player.pizzamask = nil
	player.stuntime = 0
	player.spectator = false
	player.lapsdid = 0
	player.laptime = 0
	player.ptsr_outofgame = 0
	player.ptvote_selection = 0
	player.ptvote_voted = false
	player["PT@hudstuff"] = PTSR_shallowcopy(PTSR.hudstuff)
end
