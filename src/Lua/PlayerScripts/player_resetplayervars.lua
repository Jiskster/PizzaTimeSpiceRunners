PTSR.ResetPlayerVars = function(player)	
	player.pizzaface = false
	player.pizzamask = nil
	player.spectator = false
	player.lapsdid = 0
	player.laptime = 0
	player.ptsr_outofgame = 0
	player.ptsr_gotrevivedonce = false
	player.ptsr_justrevived = false
	player.ptsr_totalscore = $ or bigint.new(0)
	player.lastparryframe = nil
	player.ptvote_selection = 0
	player.ptvote_voted = false
	player["PT@hudstuff"] = PTSR_shallowcopy(PTSR.hudstuff)
end