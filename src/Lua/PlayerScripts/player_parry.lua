-- Parry animation function with sound parameter.
PTSR.DoParryAnim = function(mobj, withsound)
	local parry = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_PT_PARRY)
	P_SpawnGhostMobj(parry)
	P_SetScale(parry, 3*FRACUNIT)
	parry.fuse = 5
	
	if withsound then
		S_StartSound(mobj, sfx_pzprry)
	end
end

PTSR.DoParry = function(parrier, victim)
	local anglefromparrier = R_PointToAngle2(victim.x, victim.y, parrier.x, parrier.y)

	victim.pfstunmomentum = true
	victim.pfstuntime = CV_PTSR.parrystuntime.value
	P_SetObjectMomZ(victim, CV_PTSR.parryknockback_z.value)
	P_InstaThrust(victim, anglefromparrier - ANGLE_180, CV_PTSR.parryknockback_xy.value)
end

-- Parry Stuff
addHook("PlayerThink", function(player)
	if not (player and player.mo and player.mo.valid) then return end
	if (player.playerstate == PST_DEAD) or (player.ptsr_outofgame) then return end 
	if PTSR.gameover then return end

	local cmd = player.cmd
	local pmo = player.mo
	
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
	if not player.mo.ptsr_parry_cooldown then
		if cmd.buttons & BT_ATTACK then
			if not player.mo.pre_parry then -- pre parry start
				local failparrysfx = {
					sfx_prepr1,
					sfx_prepr2,
					sfx_prepr3
				}
				
				local friendlyfire = (CV_PTSR.parry_friendlyfire.value or gm_metadata.parry_friendlyfire)
				local gotapf = false
				local range = 1000*FU
				local real_range = CV_PTSR.parry_radius.value
				
				searchBlockmap("objects", function(refmobj, foundmobj)
					if R_PointToDist2(foundmobj.x, foundmobj.y, pmo.x, pmo.y) < real_range 
					and abs(foundmobj.z-pmo.z) < CV_PTSR.parry_height.value then
						if foundmobj.type == MT_PIZZA_ENEMY or foundmobj.flags & MF_ENEMY
						or (foundmobj.type == MT_PLAYER and friendlyfire and PTSR.pizzatime) then
							if foundmobj.type == MT_PLAYER then
								if foundmobj.player and foundmobj.player.valid 
								and foundmobj.player.powers[pw_invulnerability] then
									return
								end
							end
							
							if PTSR_DoHook("onparry", pmo) == true then
								return true
							end
							
							PTSR.DoParry(player.mo, foundmobj)
							player.lastparryframe = leveltime
							
							PTSR.DoParryAnim(player.mo, true)
							PTSR.DoParryAnim(foundmobj)

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
					player.lastparryframe = leveltime
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