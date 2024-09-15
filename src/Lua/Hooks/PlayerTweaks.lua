local score_table = {
	[1] = 100,
	[2] = 200,
	[3] = 500,
}

-- Doesn't limit to grabbing rings. you get extra score on killing other stuff too
addHook("MobjDeath", function(target, inflictor, source)
	if CV_PTSR.scoreonkill.value and PTSR.IsPTSR() and source and source.valid and source.player and source.player.valid then
		local player = source.player
		local gm_metadata = PTSR.currentModeMetadata()
		local ring_score = gm_metadata.ring_score or PTSR.ring_score
		local real_scoreadd = player.scoreadd + 1
		local scoreadd_deduct = 0

		if score_table[real_scoreadd] then
			scoreadd_deduct = score_table[real_scoreadd]
		elseif real_scoreadd >= 4 and real_scoreadd <= 14 then
			scoreadd_deduct = 1000
		elseif real_scoreadd > 14 then
			scoreadd_deduct = 10000
		end
		
		if (target.flags & MF_ENEMY) then 
			player.score = max(0, -scoreadd_deduct) -- remove score given from enemies
			
			if not player.ptsr.pizzaface then
				PTSR:AddCombo(player)
				PTSR:AddComboTime(player, player.ptsr.combo_maxtime)
			end
			return
		elseif (target.type == MT_RING or target.type == MT_COIN)
			P_AddPlayerScore(player, ring_score)
			PTSR.add_wts_score(player, target, ring_score)
			
			if not player.ptsr.pizzaface then
				PTSR:AddComboTime(player, TICRATE)
			end
			return
		end
	end

	if source and source.valid then
		if source.player
		and source.player.ptsr then
			source.player.ptsr.current_score = source.player.score
		end
	end
end)

addHook("MobjDamage",function(mo,inf,sor)
	if PTSR.IsPTSR() and sor and sor.valid and sor.player and sor.player.valid then
		if (mo.flags & MF_ENEMY)
		and mo.health
			if PTSR.PlayerHasCombo(sor.player)
				PTSR:AddComboTime(sor.player, TICRATE)
			end
		end
	end
end)