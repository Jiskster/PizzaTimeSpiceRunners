local combo_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if not PTSR.PlayerHasCombo(player) then return end
	
	local bar = v.cachePatch("PTSR_COMBOBAR")
	local indic = v.cachePatch("PTSR_INDIC0"..tostring((leveltime%8)+1)) -- in dick :skull:
	local colormap = v.getColormap(player.skin, player.skincolor)
	local bar_x = 5*FU; bar_x = $ + sin(FixedAngle(FU)*(leveltime*4))*2 -- sway side to side
	local bar_y = 30*FU
	local indic_max = 67*FU
	local combo_timeleft = player.ptsr.combo_timeleft
	local combo_timeleft_prev = player.ptsr.combo_timeleft_prev
	local combo_tween_time = player.ptsr.combo_tweentime or 0
	local combo_maxtime = player.ptsr.combo_maxtime
	local combo_count = player.ptsr.combo_count
	local belowhalf = (player.ptsr.combo_timeleft < player.ptsr.combo_maxtime/2)

	local ese = ease.outexpo(FU - FixedDiv(combo_tween_time*FU, PTSR.combotween*FU), combo_timeleft_prev, combo_timeleft)
	local meat = combo_tween_time and ese or combo_timeleft
	-- (tl/maxtime)*indic_max
	local indic_newx = FixedMul(FixedDiv(meat*FU, combo_maxtime*FU), indic_max)
	
	if belowhalf then
		bar_y = $ + sin(FixedAngle(FU)*(leveltime*32)*2)*2
	end

	v.drawScaled(bar_x + indic_newx, bar_y+20*FU, FU/2, indic, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.drawScaled(bar_x, bar_y, FU/2, bar, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	
	-- very normal code
	local combostring = tostring(combo_count)
	local input = combostring:reverse() -- HACK: grrr i cant indent to the right so i do this
	local numsleft = {}
	local length = combostring:len()
	
	for i=1,length do
		table.insert(numsleft, tonumber(input:sub(i,i)))
		
		customhud.CustomFontChar(v, bar_x+(25*FU) - ((i-1)*12*FU), bar_y+(40*FU) - ((i-1)*4*FU), string.byte(numsleft[i]), "COMBO", (V_SNAPTOLEFT|V_SNAPTOTOP), FU/2, player.skincolor)
	end
end

customhud.SetupItem("PTSR_combo", ptsr_hudmodname, combo_hud, "game", 0)