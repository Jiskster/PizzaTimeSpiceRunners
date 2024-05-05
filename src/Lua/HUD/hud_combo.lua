local combo_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	
	if not PTSR.PlayerHasCombo(player) and not player.ptsr.combo_outro_tics then 
		return
	end
	
	local prank_able = player.ptsr.combo_timesfailed == 0 and player.ptsr.combo_times_started == 1 
	
	local bar = v.cachePatch("PTSR_COMBOBAR")
	local indic
	
	if prank_able then
		indic = v.cachePatch("PTSR_INDIC0"..tostring((leveltime%8)+1)) -- in dick :skull:
	else
		indic = v.cachePatch("PTSR_FAIL_INDIC0"..tostring((leveltime%8)+1))
	end
	
	local colormap = v.getColormap(player.skin, player.skincolor)
	local bar_x = 5*FU; 
	
	
	local bar_y = 30*FU
	local indic_max = 67*FU
	local combo_timeleft = player.ptsr.combo_timeleft
	local combo_timeleft_prev = player.ptsr.combo_timeleft_prev
	local combo_tween_time = player.ptsr.combo_tweentime or 0
	local combo_maxtime = player.ptsr.combo_maxtime
	local combo_count = player.ptsr.combo_count
	local combo_outro_tics = player.ptsr.combo_outro_tics
	local combo_outro_count = player.ptsr.combo_outro_count
	local belowhalf = (player.ptsr.combo_timeleft < player.ptsr.combo_maxtime/2)
	local belowquarter = (player.ptsr.combo_timeleft < player.ptsr.combo_maxtime/4)
	
	-- sway side to side
	if not combo_outro_tics then
		bar_x = $ + sin(FixedAngle(FU)*(leveltime*4))*2 
	end
	
	local tween_popin_time = TICRATE
	local tween_popin_div = FixedDiv(min(player.ptsr.combo_elapsed, tween_popin_time), tween_popin_time) -- down to up value
	local ese_popin = ease.outback(tween_popin_div, -100*FU, 0)
	
	local tween_popout_time = PTSR.combo_outro_tics
	local tween_popout_div = FixedDiv(player.ptsr.combo_outro_tics*FU, tween_popout_time*FU) -- up to down value
	local ese_popout = player.ptsr.combo_outro_tics and ease.linear(tween_popout_div, -400*FU, 0) or 0
	
	local ese = ease.outexpo(FU - FixedDiv(combo_tween_time*FU, PTSR.combotween*FU), combo_timeleft_prev, combo_timeleft)
	local meat = combo_tween_time and ese or combo_timeleft
	-- (tl/maxtime)*indic_max
	local indic_newx = FixedMul(FixedDiv(meat*FU, combo_maxtime*FU), indic_max)
	
	bar_x = $ + ese_popin + ese_popout
	
	if not combo_outro_tics then
		if belowquarter then
			bar_y = $ + sin(FixedAngle(FU)*(leveltime*32)*2)*2
		elseif belowhalf then
			bar_y = $ + sin(FixedAngle(FU)*(leveltime*32)*2)
		end
	end

	v.drawScaled(bar_x + indic_newx, bar_y+20*FU, FU/2, indic, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	v.drawScaled(bar_x, bar_y, FU/2, bar, V_SNAPTOLEFT|V_SNAPTOTOP, colormap)
	
	do -- very normal code
		local combostring = tostring(combo_count)
		
		if combo_outro_tics then -- save it my bro!
			combostring = tostring(combo_outro_count)
		end
		
		local input = combostring:reverse() -- HACK: grrr i cant indent to the right so i do this
		local numsleft = {}
		local length = combostring:len()
		
		for i=1,length do
			table.insert(numsleft, tonumber(input:sub(i,i)))
			
			customhud.CustomFontChar(v, bar_x+(25*FU) - ((i-1)*12*FU), bar_y+(40*FU) - ((i-1)*4*FU), string.byte(numsleft[i]), "COMBO", (V_SNAPTOLEFT|V_SNAPTOTOP), FU/2, player.skincolor)
		end
	end
	
	if combo_outro_tics then
		v.drawString(15, 100, "UNFINISHED", V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawString(15, 108, "P RANK ISNT JUST", V_SNAPTOLEFT|V_SNAPTOTOP, "thin")
		v.drawString(15, 116, "HOLDING W ANYMORE :)", V_SNAPTOLEFT|V_SNAPTOTOP, "thin")
	end
end

customhud.SetupItem("PTSR_combo", ptsr_hudmodname, combo_hud, "game", 0)