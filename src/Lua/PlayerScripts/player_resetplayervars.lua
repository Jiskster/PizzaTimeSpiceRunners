PTSR.ResetPlayerVars = function(player)	
	player.pizzaface = false
	player.pizzamask = nil
	player.spectator = false
	player.lapsdid = 0
	player.laptime = 0
	player.ptsr_outofgame = 0
	player.ptsr_gotrevivedonce = false
	player.ptsr_justrevived = false
	player.ptsr_totalscore = $ or "0"
	player.ptsr_lastscore = nil -- exists to save score when you die, is for rank screen when you die.
	player.ptsr_lastrank = nil -- same reason as ptsr_lastscore but rank
	player.ptsr_lastlaps = nil -- same reason as ptsr_lastscore but laps
	player.lastparryframe = nil
	player.ptvote_selection = 0
	player.ptvote_voted = false
	player["PT@hudstuff"] = PTSR_shallowcopy(PTSR.hudstuff)
end