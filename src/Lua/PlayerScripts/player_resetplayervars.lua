PTSR.ResetPlayerVars = function(player)	
	player.spectator = false
	player.ptsr = PTSR_shallowcopy(PTSR.default_playervars)
	
	player.ptvote_selection = 0
	player.ptvote_voted = false
end