local hurryup_hud = function(v, player)
	local x = 450*FRACUNIT
	local y = 100*FRACUNIT
	
	local timestring = G_TicsToMTIME(PTSR.timeleft)
	
	if (PTSR.timeleft <= 20*TICRATE and multiplayer and PTSR.client_allowhurryupmusic) then
		local timedif = 20*TICRATE-PTSR.timeleft
		customhud.CustomFontString(v, x-((timedif)*FRACUNIT*3), y, timestring, "PTFNT", nil, "center", FRACUNIT, SKINCOLOR_WHITE)
	end
end

customhud.SetupItem("PTSR_hurryup", ptsr_hudmodname, hurryup_hud, "game", 0)