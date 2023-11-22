mobjinfo[MT_PT_PARRY] = {
	doomednum = -1,
	spawnstate = S_PT_PARRY,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 32*FU,
	height = 48*FU,
	flags = MF_NOCLIP|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_PT_PARRY] = {
    sprite = SPR_PRRY,
    frame = FF_TRANS50|A,
    tics = -1,
    nextstate = S_PT_PARRY
}


-- simple midgame joining blocker & more
addHook("PlayerSpawn", function(player)
	player.lapsdid = $ or 0
	player.laptime = $ or 0 
	if player.realmo and player.realmo.valid then
		if player.pizzaface then
			return
		end
		if PTSR.pizzatime and leveltime then
			if PTSR.gamemode == 2 then
				if not player.pizzaface then
					chatprint("\x83*"..player.name.."\x82 has been infected.")
					if DiscordBot then
						DiscordBot.Data.msgsrb2 = $ .. "[" .. #player .. "]:pizza: **" .. player.name .. "** has been infected!\n"
					end
					player.pizzaface = true
				end
			else
				player.spectator = true
			end
		end
	end
end)

addHook("PlayerSpawn", function(player)
	player["PT@hudstuff"] = PTSR.hudstuff
end)

addHook("PlayerThink", function(player)
	if player.deadtimer > 5*TICRATE and PTSR.pizzatime and not player.spectator then
		player.playerstate = PST_REBORN
	end

	if PTSR.pizzatime and PTSR.timeover then
		player.powers[pw_sneakers] = 1
	end
end)

addHook("PlayerThink", function(player)
	local hudst = player["PT@hudstuff"]
	
	if hudst then
		if not hudst.wait_tics then
			if hudst.anim_active then
				if not hudst.rev then -- normal
					hudst.anim = $ + 1
				else -- reverse
					hudst.anim = $ - 1
				end
				
				if hudst.anim > 45 then
					hudst.anim = $ - 1
					hudst.rev = true
					hudst.wait_tics = 4*TICRATE
				elseif not hudst.anim and hudst.stop then
					hudst.anim_active = false
					hudst.rev = false
					hudst.wait_tics = 0 -- just in case
				end
			end
		else
			hudst.wait_tics = $ - 1
			if hudst.wait_tics == 1 then
				hudst.stop = true
			end
		end
	end
end)

addHook("ThinkFrame", do
	local exitingCount, playerCount = PTSR_COUNT()
	if PTSR.pizzatime then
		PTSR.pizzatime_tics = $ + 1
		if PTSR.timeleft and (exitingCount ~= playerCount) and CV_PTSR.timelimit.value then
			PTSR.timeleft = $ - 1
			if not PTSR.timeleft then
				PTSR.timeover = true
				local timeover_text = "\x8F*Overtime! Spawned another pizza face!"
				chatprint(timeover_text)
				
				for i,deathring in ipairs(PTSR.deathrings) do
					if deathring and deathring.valid and deathring.rings_kept then
						deathring.rings_kept = $ * 3
					end
				end
				
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ":alarm_clock: Overtime!\n"
				end

				local newpizaface = P_SpawnMobj(PTSR.end_location.x*FRACUNIT,
				PTSR.end_location.y*FRACUNIT,
				PTSR.end_location.z*FRACUNIT, 
				MT_PIZZA_ENEMY)
			end
		end
		
		if PTSR.timeover then
			PTSR.timeover_tics = $ + 1
		end
	end 
end)

addHook("PlayerThink", function(player)
	local pmo = player.mo
	local hudst = player["PT@hudstuff"]
	local maxholdtime = PTSR.laphold -- HOLDFORLAP

	if player.mo and player.mo.valid then
		if player.hold_newlap == nil then
			player.hold_newlap = 0
		end

		if player.exiting and not (player.lapsdid >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value) then 
			if (player.cmd.buttons & BT_ATTACK) then
				player.hold_newlap = $ + 1
			else
				player.hold_newlap = 0
			end
		end

		if player.hold_newlap then
		 	if player.hold_newlap >= PTSR.laphold then
				PTSR.StartNewLap(player.mo)
				hudst.anim_active = true
				hudst.anim = 1

				player.hold_newlap = 0
			end
		end 
		
		-- increment laptime
		if player.laptime ~= nil and PTSR.pizzatime and not player.exiting 
		and not player.mo.pizza_in and not player.mo.pizza_out then
			player.laptime = $ + 1
		end
		
		-- elfilin support: KILL THE DAMN PLAYER WHEN TRYING TO RIDE A PIZZAFACE
		-- ridingplayer isnt a player_t this is so clickbait!!!
		if player.elfilin and player.elfilin.ridingplayer 
		and player.mo and player.mo.valid and
		player.elfilin.ridingplayer.valid and
		player.elfilin.ridingplayer.player.pizzaface and player.playerstate == PST_LIVE then
			--P_KillMobj(player.mo,player.elfilin.ridingplayer)
			player.elfilin.ridingplayer = 0
		end
		--endsupport
		local range = 250*FRACUNIT -- higher blockmap range so it doesnt look choppy
		local real_range = 110*FRACUNIT
		searchBlockmap("objects", function(refmobj, foundmobj)
			if R_PointToDist2(foundmobj.x, foundmobj.y, pmo.x, pmo.y) < real_range 
			and L_ZCollide(foundmobj,pmo) then
				if foundmobj.type == MT_RING or foundmobj.type == MT_COIN and not foundmobj.tayken then
					foundmobj["very secure x"] = foundmobj.x
					foundmobj["very secure y"] = foundmobj.y
					foundmobj["very secure z"] = foundmobj.z
					local vs_x = foundmobj["very secure x"]
					local vs_y = foundmobj["very secure y"]
					local vs_z = foundmobj["very secure z"]
					
					P_SetOrigin(foundmobj, pmo.x,pmo.y,pmo.z)
					P_SetOrigin(foundmobj, vs_x,vs_y,vs_z)
					foundmobj.tayken = true
				else
					return false
				end
			end
		end, 
		player.mo,
		player.mo.x-range, player.mo.x+range,
		player.mo.y-range, player.mo.y+range)		
	end
end)

-- rank thinker
addHook("PlayerThink", function(player)
	-- a 6th of the max rank points, multiply later
	-- idk what pec is supposed to mean but i guess it means a fraction of the maxrank points
	local pec = (PTSR.maxrankpoints)/6
	
	--player.ptsr_rank = "P"
	-- boy what the hellllll o ma god way ayyaay
	if player.score < pec then
		-- this is real p rank
		-- cry like a wittle babyy!
		player.ptsr_rank = "D"
	elseif player.score <= pec*2 then
		player.ptsr_rank = "C"
		
	elseif player.score <= pec*4 then
		player.ptsr_rank = "B"
	elseif player.score <= pec*8 then
		player.ptsr_rank = "A"
	elseif player.score <= pec*13 then
		player.ptsr_rank = "S"
	else
		/*
		if player.timeshit then
			player.ptsr_rank = "S"
		else
			player.ptsr_rank = "P"
		end
		*/
		
		player.ptsr_rank = "P"
	end
	
end)

-- Parry
addHook("PlayerThink", function(player)
	if not (player and player.mo and player.mo.valid) then return end
	if (player.playerstate == PST_DEAD) or (player.exiting) then return end 
	
	local cmd = player.cmd
	local pmo = player.mo
	
	if not player.mo.ptsr_parry_cooldown then
		if cmd.buttons & BT_ATTACK then
			if not player.mo.pre_parry then -- pre parry start
				local failparrysfx = {
					sfx_prepr1,
					sfx_prepr2,
					sfx_prepr3
				}
				
				local gotapf = false

				local range = 10000*FRACUNIT -- higher blockmap range so it doesnt look choppy
				local real_range = CV_PTSR.parry_radius.value
				searchBlockmap("objects", function(refmobj, foundmobj)
					if R_PointToDist2(foundmobj.x, foundmobj.y, pmo.x, pmo.y) < real_range 
					and abs(foundmobj.z-pmo.z) < CV_PTSR.parry_height.value then
						if foundmobj.type == MT_PIZZA_ENEMY or foundmobj.flags & MF_ENEMY
						or (foundmobj.type == MT_PLAYER and CV_PTSR.parry_friendlyfire.value and PTSR.pizzatime) then
							if foundmobj.type == MT_PLAYER then
								if foundmobj.player and foundmobj.player.valid 
								and foundmobj.player.powers[pw_invulnerability] then
									return
								end
							end
							local anglefromplayer = R_PointToAngle2(foundmobj.x, foundmobj.y, pmo.x, pmo.y)

							foundmobj.pfstunmomentum = true
							foundmobj.pfstuntime = CV_PTSR.parrystuntime.value
							P_SetObjectMomZ(foundmobj, CV_PTSR.parryknockback_z.value)
							P_InstaThrust(foundmobj, anglefromplayer - ANGLE_180, CV_PTSR.parryknockback_xy.value)

							// TODO: Remake this parry animation
							local parry = P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, MT_PT_PARRY)
							P_SpawnGhostMobj(parry)
							P_SetScale(parry, 3*FRACUNIT)
							parry.fuse = 5
							
							local parry2 = P_SpawnMobj(foundmobj.x, foundmobj.y, foundmobj.z, MT_PT_PARRY)
							P_SpawnGhostMobj(parry)
							P_SetScale(parry2, 3*FRACUNIT)
							parry2.fuse = 5

							S_StartSound(player.mo, sfx_pzprry)
							L_SpeedCap(player.mo, 30*FRACUNIT)

							player.mo.ptsr_parry_cooldown = CV_PTSR.parrycooldown.value

							gotapf = true
						end
					end
				end, 
				player.mo,
				player.mo.x-range, player.mo.x+range,
				player.mo.y-range, player.mo.y+range)

				if not gotapf then
					S_StartSound(player.mo, failparrysfx[P_RandomRange(1,3)])
					local tryparry = P_SpawnGhostMobj(player.mo)
					tryparry.color = SKINCOLOR_WHITE
					tryparry.fuse = 2
					P_SetScale(tryparry, (3*FRACUNIT)/2)
					L_SpeedCap(player.mo, 5*FRACUNIT)

					player.mo.ptsr_parry_cooldown = CV_PTSR.parrycooldown.value
				end
			
				player.mo.pre_parry = true
			end
		else
			player.mo.pre_parry = false
		end
	end
	
	if player.mo.ptsr_parry_cooldown then
		player.mo.ptsr_parry_cooldown = $ - 1
		if not player.mo.ptsr_parry_cooldown then
			S_StartSound(player.mo, sfx_ngskid)
			local tryparry = P_SpawnGhostMobj(player.mo)
			tryparry.color = SKINCOLOR_GOLDENROD
			tryparry.fuse = 5
			P_SetScale(tryparry, (3*FRACUNIT)/2)
		end
	end
end)