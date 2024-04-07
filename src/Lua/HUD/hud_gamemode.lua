local gamemode_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if not multiplayer then return end
	
	local currentGamemode = PTSR.gamemode_list[PTSR.gamemode].name or "Unnamed"
	
	v.drawString(320, 0, "\x8A"..currentGamemode, V_SNAPTORIGHT|V_SNAPTOTOP|V_50TRANS|V_ADD, "thin-right")
end

customhud.SetupItem("PTSR_gamemode", ptsr_hudmodname, gamemode_hud, "game", 0) -- show gamemode type
