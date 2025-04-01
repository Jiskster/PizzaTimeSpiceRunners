local controls_angle = PTSR.Require("Pizzaface/Functions/ControlsAngle")
local player_pf_movement = PTSR.Require("Pizzaface/Functions/PlayerPFMovement")

--Player Pizza Face Thinker
addHook("PlayerThink", function(player)
	player.ptsr.pizzastyle = $ or 1
	player.realmo.pfstuntime = $ or 0
	if not PTSR.IsPTSR() then return end
	if player.realmo and player.realmo.valid and player.ptsr.pizzaface and leveltime then
		PTSR.addw2sobject(player.realmo)
		
		player.powers[pw_carry] = 0
		
		if player.redgreen == nil then
			player.redgreen = $ or false
		end
		player.pizzacharge = $ or 0
		player.pizzachargecooldown = $ or 0

		player.realmo.scale = 2*FU
		player.spectator = false -- dont give up! dont spectate as pizzaface! (theres another check when spawning so idk

		if player.realmo.pfstuntime then -- player freeze decrement (mainly for pizza faces)
			player.realmo.pfstuntime = $ - 1
			-- # No Momentum # --
			player.mo.momx = 0
			player.mo.momy = 0
			player.mo.momz = 0
			-- # No Momentum # --
			--player.pflags = $|PF_FULLSTASIS
			if not player.realmo.pfstuntime then -- once it hits zero, LAUGH AHHHHAHHAAHAHAHHAHAH
				if CV_PTSR.pizzalaugh.value and not player.pizzachargecooldown
					S_StartSound(player.mo, PTSR.PFMaskData[player.ptsr.pizzastyle].sound)
				end

				if not PTSR.showtime -- hiiii adding onto this for showtime
					PTSR.showtime = true
					local anim = animationtable['pizzaface']
					if anim then
						anim:ChangeAnimation('PIZZAFACE_SHOWTIME', 3, 8, false)
					end
				end
				
				player.realmo.pfstunmomentum = false
			elseif PTSR.pizzatime_tics < CV_PTSR.pizzatimestun.value*TICRATE then
				player.mo.momx = 0
				player.mo.momy = 0
				player.mo.momz = 0

				if player.facechangecooldown then
					player.facechangecooldown = $ - 1
				else
					local change = 0
					if player.cmd.sidemove > 5 then
						change = $ + 1
					elseif player.cmd.sidemove < -5 then
						change = $ - 1
					end
					if change ~= 0 then
						S_StartSound(nil, sfx_menu1, player)
						player.facechangecooldown = TICRATE/3
						local changeTo = (player.ptsr.pizzastyle + change + #PTSR.PFMaskData - 1) % #PTSR.PFMaskData + 1
						player.ptsr.pizzastyle = changeTo
						
						/* TODO: Make these save with an i/o system
						if consoleplayer == player then
							CV_StealthSet(CV_PTSR.pizzastyle, changeTo)
						end
						*/
					end
				end
			end
		else
			-- player is not stunned? neat!
			player_pf_movement(player)
		end
		
		-- A bit messy putting a variable here but okay.
		if player.mo.pfstuntime2 then
			player.mo.pfstuntime2 = $ - 1
			
			if not player.mo.pfstunmomentum then
				player.mo.momx = $/3
				player.mo.momy = $/3
				player.mo.momz = $/3
			end
		end

		if player.mo.skin ~= "sonic" then
			-- compatibility issues might occur, quick, switch back to sonic!
			R_SetPlayerSkin(player, "sonic")
		end		

		if (not player.ptsr.pizzamask or not player.ptsr.pizzamask.valid) then
			player.ptsr.pizzamask = P_SpawnMobj(player.realmo.x,player.realmo.y,player.realmo.z,MT_PIZZAMASK)
			player.ptsr.pizzamask.targetplayer = player --dream reference
			player.ptsr.pizzamask.scale = PTSR.PFMaskData[1].scale
		end

		if player.ptsr.pizzamask then
			player.realmo.flags2 = $|MF2_DONTDRAW -- invisible so that the pizza mask can draw over.
		else
			player.mo.color = SKINCOLOR_ORANGE
			player.mo.colorized = true
		end

		if not (leveltime % 3) and player.ptsr.pizzamask and player.ptsr.pizzamask.valid and player.speed > FRACUNIT then
			if (player ~= displayplayer) or (camera.chase and player == displayplayer) then
				local colors = PTSR.PFMaskData[player.ptsr.pizzastyle].trails
				local ghost = P_SpawnGhostMobj(player.ptsr.pizzamask)
				P_SetOrigin(ghost, player.ptsr.pizzamask.x, player.ptsr.pizzamask.y, player.ptsr.pizzamask.z)
				ghost.fuse = 11
				ghost.colorized = true

				if player.redgreen then
					ghost.color = colors[1]
				else
					ghost.color = colors[2]
				end
				ghost.frame = $|FF_TRANS10|FF_FULLBRIGHT
			end
			player.redgreen = not player.redgreen
		end

		if player.ptsr.outofgame or PTSR.quitting then
			player.pizzacharge = 0
		end
		
		if not player.ptsr.outofgame and (player.ptsr.pfbuttons & BT_ATTACK)
		and not player.ptsr.pizzachase and not PTSR.quitting and not player.realmo.pfstuntime and not player.pizzachargecooldown then -- basically check if you're active in general
			if player.pizzacharge < TICRATE then
				player.pizzacharge = $ + 1
			else
				PTSR.pfRandomTP(player.mo, true) -- Tp to random active player
			end
		elseif player.pizzacharge > 0 then
			player.pizzacharge = $ - 1
		end

		if player.pizzachargecooldown then
			player.pizzachargecooldown = $ - 1
		end

		--check for quit time, because its sorta like "camping" since we're not receiving
		--any inputs for this PF
		if (player.realmo.pfstuntime or player.quittime) then
			local pmo = player.mo
			local findrange = 2500*FRACUNIT
			local zrange = 400*FU
			searchBlockmap("objects", function(refmobj, foundmobj)
				local strength = 3*FRACUNIT
				local speed = FU + (PTSR.timeover_tics*CV_PTSR.overtime_speed.value)
				
				strength = FixedMul(strength, speed)
				
				if foundmobj and abs(pmo.z-foundmobj.z) < zrange
				and foundmobj.valid and P_CheckSight(pmo, foundmobj) then
					if (foundmobj.type == MT_PLAYER) and ((leveltime/2)%2) == 0 then
						if foundmobj.player and foundmobj.player.valid and
						(foundmobj.player.spectator or foundmobj.player.ptsr.pizzaface or foundmobj.player.ptsr.outofgame) then
							return
						end
						
						if P_IsObjectOnGround(foundmobj) then
							strength = $ * 4
						end
						
						P_FlyTo(foundmobj,pmo.x,pmo.y,pmo.z,strength,true)
					end
				end
			end,pmo,
			pmo.x-findrange,pmo.x+findrange,
			pmo.y-findrange,pmo.y+findrange)
		end
	end
end)