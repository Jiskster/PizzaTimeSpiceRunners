local overtime_hud = function(v, player)
	if not PTSR.timeover then return end
	local left_tween 
	local right_tween 
	
	local text_its = v.cachePatch("OT_ITS")
	local text_overtime = v.cachePatch("OT_OVERTIME")
	
	local anim_len = 5*TICRATE/3 -- 1.6__ secs
	local anim_delay = 1*TICRATE
	local anim_lastframe = (anim_len*2)+(anim_delay)
	local left_end = 0 -- end pos of left
	local right_end = 110 -- end pos of right
	
	local shake_dist = 2
	local shakex_1 = v.RandomRange(-shake_dist, shake_dist)
	local shakey_1 = v.RandomRange(-shake_dist, shake_dist)
	local shakex_2 = v.RandomRange(-shake_dist, shake_dist)
	local shakey_2 = v.RandomRange(-shake_dist, shake_dist)
	
	local div = min(FixedDiv(PTSR.timeover_tics*FU, anim_len*FU), FU)
	local div_end = min(FixedDiv((PTSR.timeover_tics - anim_delay - anim_len)*FU, (anim_len)*FU), FU)

	if PTSR.timeover_tics <= anim_len + anim_delay then -- come in
		left_tween = ease.outquint(div, left_end-400, left_end)
		right_tween = ease.outquint(div, right_end+400, right_end)
	else -- come out
		left_tween = ease.inquint(div_end, left_end, left_end-400)
		right_tween = ease.inquint(div_end, right_end, right_end+400)
	end
	
	if PTSR.timeover_tics <= anim_lastframe then -- draw
		v.drawScaled(
			(left_tween+shakex_1)*FU,
			(80+shakey_1)*FU,
			FU/2,
			text_its
		)
		
		v.drawScaled(
			(right_tween+shakex_2)*FU,
			(80+shakey_2)*FU,
			FU/2,
			text_overtime
		)
		
		/* Beta Text (Broken positions)
			v.drawLevelTitle(left_tween+shakex_1, 100+shakey_1, "It's ", V_REDMAP)
			v.drawLevelTitle(right_tween+shakex_2, 100+shakey_2, "Overtime!", V_REDMAP)
		*/
	end
end

customhud.SetupItem("PTSR_overtime", ptsr_hudmodname, overtime_hud, "game", 0)