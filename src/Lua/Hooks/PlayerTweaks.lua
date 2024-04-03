-- Doesn't limit to grabbing rings. you get extra score on killing other stuff too
addHook("MobjDeath", function(target, inflictor, source)
	if CV_PTSR.scoreonkill.value and PTSR.IsPTSR() and source and source.valid and source.player and source.player.valid then
		local player = source.player
		if (target.flags & MF_ENEMY) then 
			P_AddPlayerScore(player, 800)
		elseif (target.type == MT_RING or target.type == MT_COIN)
			P_AddPlayerScore(player, 100)
		end
	end
end)