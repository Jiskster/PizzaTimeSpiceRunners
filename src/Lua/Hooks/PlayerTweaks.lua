addHook("MobjDeath", function(target, inflictor, source)
	if CV_PTSR.scoreonkill.value and PTSR.IsPTSR() and source and source.valid and source.player and source.player.valid then
		local player = source.player
		local gm_metadata = PTSR.currentModeMetadata()
		local ring_score = gm_metadata.ring_score or PTSR.ring_score
		
		player.scoreadd = 0
		
		if (target.flags & MF_ENEMY) then 
			target.flags = $ & (~MF_ENEMY) -- so we dont get score from enemies

			if not player.ptsr.pizzaface then
				PTSR:AddCombo(player)
				PTSR:AddComboTime(player, player.ptsr.combo_maxtime)
			end
			
			-- Increase attraction shield timer when an enemy is killed.
			if player.ptsr.atrraction_timer then
				player.ptsr.atrraction_timer = min($ + (TICRATE/2), 15*TICRATE) -- can only go up to 15 seconds.
			end

			return
		elseif (target.type == MT_RING or target.type == MT_COIN)
			player.ptsr.rings_on_lap = $ + 1

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