PTSR.StartNewLap = function(mobj)
	local player = mobj.player

	if not player.ptsr.pizzaface and not player.spectator and player.playerstate ~= PST_DEAD and mobj.valid then
		PTSR.LapTP(player, true)

		S_StartSound(nil, sfx_lap2, player)
		if not multiplayer and PTSR.aipf then
			PTSR:SpawnPFAI()
		end
		
		player.ptsr.laptime = 0
		
		
		player.ptsr.laps = $ + 1
		PTSR.laps = $ + 1
		
		
		
		/* Unused code idk what tf this is for
		if player.ptsr.laps > PTSR.laps
			PTSR.laps = player.ptsr.laps
		end
		*/
		
		-- Elfilin support
		
		if player.elfilin and player.mo.elfilin_portal then
			player.mo.elfilin_portal.fuse = 1
		end

		if not CV_PTSR.nomusic.value then -- if music on
			if not PTSR.timeover then
				if PTSR.MusicList.Laps[player.ptsr.laps] and mapmusname ~= PTSR.MusicList.Laps[player.ptsr.laps] then
					S_ChangeMusic(PTSR.MusicList.Laps[player.ptsr.laps], true, player)
				end
			end
		end
	else -- FAKE LAP -- 
		mobj.pfstuntime = TICRATE*CV_PTSR.fakelapstun.value
		P_SetOrigin(mobj, PTSR.end_location.x*FRACUNIT,PTSR.end_location.y*FRACUNIT, PTSR.end_location.z*FRACUNIT)
		mobj.angle = PTSR.end_location.angle - ANGLE_90
	end
	
end 