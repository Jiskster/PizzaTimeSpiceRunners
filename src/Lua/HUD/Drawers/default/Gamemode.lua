local gamemode_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if not multiplayer then return end
	
	local currentGamemode = PTSR.gamemode_list[PTSR.gamemode].name or "Unnamed"
	
	for i=0,2 do
		v.drawString(320, 0 + (i*8), "\x8A"..currentGamemode.." IS THE MODE", V_SNAPTORIGHT|V_SNAPTOTOP|V_50TRANS|V_ADD, "right")
	end
end

return "Gamemode", gamemode_hud
