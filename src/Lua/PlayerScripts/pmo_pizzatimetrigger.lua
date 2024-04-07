PTSR.PizzaTimeTrigger = function(mobj)
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]

	local aimode = true

	if gm_metadata.player_pizzaface then
		aimode = false
	end

	if not (PTSR.pizzatime and PTSR.spawn_location_atdefault) then
		if DiscordBot then
			local discord_pizzatime_text = "This text isn't supposed to show. Uh oh!"
			
			if aimode then
				discord_pizzatime_text = ":pizza: Pizza Time has started!\n"
			else
				discord_pizzatime_text = ":pizza: Pizza Time has started! Pizzas:\n"
			end
			
			DiscordBot.Data.msgsrb2 = $ .. discord_pizzatime_text
		end
		
		PTSR.pizzatime = true
		PTAnimFunctions.NewAnimation('pizzaface', 'PIZZAFACE_SLEEPING', 2, 11, true)
		PTAnimFunctions.NewAnimation('john', 'JOHN', 2, 22, true)
		PTAnimFunctions.NewAnimation('redjohn', 'REDJOHN', 1, 22, true)

		local thesign = P_SpawnMobj(0,0,0, MT_SIGN)
		P_SetOrigin(thesign, PTSR.spawn_location.x*FRACUNIT, PTSR.spawn_location.y*FRACUNIT, PTSR.spawn_location.z*FRACUNIT)
		
		if multiplayer and aimode and not CV_PTSR.nopizza.value then
			PTSR:SpawnPFAI()
		end
		
		thesign.angle = PTSR.spawn_location.angle
		
		if thesign.subsector then
			PTSR.endsector = thesign.subsector.sector
		end
		
		PTSR.timeleft = CV_PTSR.timelimit.value*TICRATE*60
		PTSR.maxtime = CV_PTSR.timelimit.value*TICRATE*60
		
		PTSR.maxlaps = CV_PTSR.default_maxlaps.value

		-- Custom timelimit Header 
		if mapheaderinfo[gamemap].ptsr_timelimit then -- in minutes
			PTSR.timeleft = tonumber(mapheaderinfo[gamemap].ptsr_timelimit)*TICRATE*60
			PTSR.maxtime = tonumber(mapheaderinfo[gamemap].ptsr_timelimit)*TICRATE*60
		elseif mapheaderinfo[gamemap].ptsr_timelimit_secs then -- in seconds
			PTSR.timeleft = tonumber(mapheaderinfo[gamemap].ptsr_timelimit_secs)*TICRATE
			PTSR.maxtime = tonumber(mapheaderinfo[gamemap].ptsr_timelimit_secs)*TICRATE
		end
		
		-- Custon maxlaps header
		if mapheaderinfo[gamemap].ptsr_maxlaps and CV_PTSR.default_maxlaps.value then -- if header and not 0
			PTSR.maxlaps = tonumber(mapheaderinfo[gamemap].ptsr_maxlaps)
		end
		
		if gm_metadata["instant_overtime"] then
			PTSR.timeleft = 1
		end
		
		PTSR.laps = 1 -- new day new me
		
		PTSR_DoHook("onpizzatime")
		
		-- player pf only stuff
		if multiplayer and not aimode and not CV_PTSR.nopizza.value then
			local count = PTSR_COUNT()

			if count.active > 1 then
				if CV_PTSR.pizzachoosetype.value == 1 then
					mobj.player.pizzaface = true
					mobj.pfstuntime = CV_PTSR.pizzatimestun.value*TICRATE
					chatprint("\x85*"..mobj.player.name.." has become a pizza!") 
					if DiscordBot then
						DiscordBot.Data.msgsrb2 = $ .. "- [" .. #mobj.player .. "] **" .. mobj.player.name .. "**\n"
					end
				else
					local active_playernums = {}
					local playerschoosing = CV_PTSR.pizzacount.value
					
					if count.active < playerschoosing then
						playerschoosing = 1
					end
					if playerschoosing then
						-- store every playernum
						for player in players.iterate() do
							if CV_PTSR.pizzachoosetype.value == 3 and player == mobj.player then
								continue
							end
							if player.quittime then
								player.spectator = true
								continue
							end
							
							table.insert(active_playernums, #player)
						end
						-- loop for every pizza needed
						for i=1,playerschoosing do
							local chosen_playernum = P_RandomRange(1,#active_playernums) -- random entry in table
							local chosen_player = active_playernums[chosen_playernum] -- get the chosen value in table
							players[chosen_player].pizzaface = true
							players[chosen_player].realmo.pfstuntime = CV_PTSR.pizzatimestun.value*TICRATE
							
							chatprint("\x85*"..players[chosen_player].name.." has become a pizza!") 
							if DiscordBot then
								DiscordBot.Data.msgsrb2 = $ .. "- [" .. chosen_player .. "] **" .. players[chosen_player].name .. "**\n"
							end
							
							table.remove(active_playernums, chosen_playernum) -- so we dont repeat the pizza given
						end
					end
				end
			end
		end

		for player in players.iterate() do
			local pmo = player.mo
			if not (pmo and pmo.valid) then continue end
			player.lapsdid = 1
			P_SetOrigin(pmo, PTSR.end_location.x*FRACUNIT,PTSR.end_location.y*FRACUNIT, PTSR.end_location.z*FRACUNIT)
			pmo.angle = PTSR.end_location.angle - ANGLE_90
			
			local angle_frompotal = mapheaderinfo[gamemap].ptsr_lapangle 
			if angle_frompotal and tonumber(angle_frompotal) then
				pmo.angle = FixedAngle(tonumber(angle_frompotal)*FRACUNIT)
			end
			
			if not player.pizzaface then
				player.powers[pw_invulnerability] = CV_PTSR.tpinv.value*TICRATE+20
				--player.powers[pw_nocontrol] = 20
				L_SpeedCap(player.mo, 0)
				local thrust = FixedHypot(player.mo.momx, player.mo.momy)*2
				P_InstaThrust(player.mo, player.mo.angle, thrust)
			end
		end
		
		if PTSR.john and PTSR.john.valid then
			local john = PTSR.john
			PTSR.KnockJohnPillar(john)
		end
		
		if not PTSR.timeover then
			S_ChangeMusic(PTSR.ReturnPizzaTimeMusic(mobj.player), true)
		end
	end
end