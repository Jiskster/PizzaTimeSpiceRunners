local plyrgravity = 27*FU/20

addHook("ThinkFrame", function() 
	for player in players.iterate do
		if not (player.mo and player.mo.valid) then continue end
		
		local rlgrav = P_GetMobjGravity(player.mo)
		player.jumpfactor = FixedMul(skins[player.mo.skin].jumpfactor, plyrgravity)
		if player.charability == CA_DOUBLEJUMP then
			player.actionspd = FixedMul(skins[player.mo.skin].actionspd, plyrgravity)
		end
		if player.charability == CA_THOK then
			player.actionspd = max(5*skins[player.mo.skin].normalspeed/4, FixedDiv(R_PointToDist2(0,0, player.mo.momx, player.mo.momy), player.mo.scale))
		end
		if player.mo.eflags & MFE_SPRUNG then
			player.springied = true
		end
		if P_IsObjectOnGround(player.mo) or (player.mo.state ~= S_PLAY_SPRING and player.mo.state ~= S_PLAY_FALL) then
			player.springied = false
		end
		if not P_IsObjectOnGround(player.mo)
		and not P_PlayerInPain(player)
		and player.playerstate ~= PST_DEAD
		and not (player.mo.flags & MF_NOGRAVITY)
		and not player.powers[pw_tailsfly]
		and not player.homing
		and not player.powers[pw_carry]
		and not player.glidetime
		and not player.springied
		and not player.stickceil then
			player.mo.momz = $ - rlgrav + FixedMul(plyrgravity, rlgrav)
		end
	end 
end)