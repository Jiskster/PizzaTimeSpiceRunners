-- Doesn't limit to grabbing rings. you get extra score on killing other stuff too
addHook("MobjDeath", function(target, inflictor, source)
	if CV_PTSR.scoreonkill.value and PTSR.IsPTSR() and source and source.valid and source.player and source.player.valid then
		local player = source.player
		local gm_metadata = PTSR.currentModeMetadata()
		local ring_score = gm_metadata.ring_score or PTSR.ring_score
		local enemy_score = gm_metadata.enemy_score or PTSR.enemy_score
		
		if (target.flags & MF_ENEMY) then 
			P_AddPlayerScore(player, enemy_score)
			
			if not player.ptsr.pizzaface then
				PTSR:AddCombo(player)
				PTSR:AddComboTime(player, player.ptsr.combo_maxtime)
			end
		elseif (target.type == MT_RING or target.type == MT_COIN)
			P_AddPlayerScore(player, ring_score)
			
			if not player.ptsr.pizzaface then
				PTSR:AddComboTime(player, TICRATE)
			end
		end
	end
end)