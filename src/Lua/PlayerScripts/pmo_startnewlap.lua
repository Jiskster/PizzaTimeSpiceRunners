PTSR.StartNewLap = function(mobj)
	local player = mobj.player

	if not player.pizzaface and not player.spectator and player.playerstate ~= PST_DEAD and mobj.valid then
		PTSR.LapTP(player, true)

		S_StartSound(nil, sfx_lap2, player)
		
		
		player.laptime = 0
		
		
		player.lapsdid = $ + 1
		PTSR.laps = $ + 1
		
		
		
		/* Unused code idk what tf this is for
		if player.lapsdid > PTSR.laps
			PTSR.laps = player.lapsdid
		end
		*/
		
		-- Elfilin support
		
		if player.elfilin and player.mo.elfilin_portal then
			player.mo.elfilin_portal.fuse = 1
		end

		if not PTSR.timeover then
			S_ChangeMusic(PTSR.ReturnPizzaTimeMusic(mobj.player), true)
		end
	else -- FAKE LAP -- 
		mobj.player.stuntime = TICRATE*CV_PTSR.fakelapstun.value
		P_SetOrigin(mobj, PTSR.end_location.x*FRACUNIT,PTSR.end_location.y*FRACUNIT, PTSR.end_location.z*FRACUNIT)
		mobj.angle = PTSR.end_location.angle - ANGLE_90
	end
	
end 