-- doesnt actually trigger or increment lap, just tps you
PTSR.LapTP = function(player, invincibility)
	if not player and not player.mo and not player.mo.valid then return end -- safety
	PTSR_DoHook("laptp", player, invincibility)
	player.powers[pw_carry] = 0
	
	player.ptsr.outofgame = 0
	
	P_SetOrigin(player.mo, PTSR.end_location.x,PTSR.end_location.y, PTSR.end_location.z)
	
	player.mo.angle = PTSR.end_location.angle - ANGLE_90
	
	if invincibility then
		player.powers[pw_invulnerability] = max($,CV_PTSR.tpinv.value*TICRATE) -- converts to seconds
	end

	player.ptsr.current_score = player.score
	player.ptsr.score_shakeTime = FU
	player.ptsr.score_objects = {}
end
