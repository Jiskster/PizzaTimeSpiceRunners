local combo_hud = function(v, player)
	local bar = v.cachePatch("PTSR_COMBOBAR")
	local indic = v.cachePatch("PTSR_INDIC01") -- in dick :skull:
	local colormap = v.getColormap(player.skin, player.skincolor)
	local bar_x = 5*FU
	local bar_y = 30*FU
	local indic_max = 67*FU

	bar_x = $ + sin(FixedAngle(FU)*(leveltime*4))*2 -- sway side to side
	
	v.drawScaled(bar_x + indic_max, bar_y+20*FU, FU/2, indic, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.drawScaled(bar_x, bar_y, FU/2, bar, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
end

customhud.SetupItem("PTSR_combo", ptsr_hudmodname, combo_hud, "game", 0)