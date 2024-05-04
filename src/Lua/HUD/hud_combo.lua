local combo_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if not PTSR.PlayerHasCombo(player) then return end
	
	local bar = v.cachePatch("PTSR_COMBOBAR")
	local indic = v.cachePatch("PTSR_INDIC01") -- in dick :skull:
	local colormap = v.getColormap(player.skin, player.skincolor)
	local bar_x = 5*FU; bar_x = $ + sin(FixedAngle(FU)*(leveltime*4))*2 -- sway side to side
	local bar_y = 30*FU
	local indic_max = 67*FU
	local combo_timeleft = player.ptsr.combo_timeleft
	local combo_maxtime = player.ptsr.combo_maxtime
	local belowhalf = (player.ptsr.combo_timeleft < player.ptsr.combo_maxtime/2)
	-- (tl/maxtime)*indic_max
	local indic_newx = FixedMul(FixedDiv(combo_timeleft*FU, combo_maxtime*FU), indic_max)
	
	if belowhalf then
		bar_y = $ + sin(FixedAngle(FU)*(leveltime*32)*2)*2
	end

	
	v.drawScaled(bar_x + indic_newx, bar_y+20*FU, FU/2, indic, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.drawScaled(bar_x, bar_y, FU/2, bar, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
end

customhud.SetupItem("PTSR_combo", ptsr_hudmodname, combo_hud, "game", 0)