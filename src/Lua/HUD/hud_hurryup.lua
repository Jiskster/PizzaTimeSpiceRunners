local hurryup_hud = function(v, player)
	if not PTSR.timeleft then return end
	
	local x = 450*FRACUNIT
	local y = 100*FRACUNIT
	local timedif = 20*TICRATE-PTSR.timeleft
	local timestring = G_TicsToMTIME(PTSR.timeleft)
	
	x = $ - ((timedif) * FRACUNIT*3)
	
	if (PTSR.timeleft <= 20*TICRATE and multiplayer and PTSR.client_allowhurryupmusic) and x > -200*FRACUNIT then
		customhud.CustomFontString(v, x, y, timestring, "PTFNT", nil, "center", FRACUNIT, SKINCOLOR_WHITE)
	end
end

customhud.SetupItem("PTSR_hurryup", ptsr_hudmodname, hurryup_hud, "game", 0)