PTSR.ParrySpendRequirement = 20 
PTSR.ParryHitLagFrames = 5

-- Parry animation function with sound parameter.
mobjinfo[freeslot "MT_PTSR_LOSSRING"] = {
	spawnstate = S_RING,
	radius = 32*FU,
	height = 32*FU,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT
}

addHook("MobjThinker", function(mo)
	if not (mo and mo.valid) then return end
	local speed = mo.throwspeed or 16*FU

	mo.momx = FixedMul(speed, cos(mo.angle))
	mo.momy = FixedMul(speed, sin(mo.angle))
	mo.frame = $|FF_TRANS40

	if mo.z > mo.ceilingz
	or mo.z+mo.height < mo.floorz then
		P_RemoveMobj(mo)
		return
	end
end, MT_PTSR_LOSSRING)

PTSR.DoParryAnim = function(mobj, withsound, ringloss)
	local parry = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_PT_PARRY)
	P_SpawnGhostMobj(parry)
	P_SetScale(parry, 3*FRACUNIT)
	parry.fuse = 5
	
	if withsound then
		S_StartSound(mobj, sfx_pzprry)
	end

	if ringloss then
		for i = 1,20 do
			local ring = P_SpawnMobjFromMobj(mobj,
				0,0,0,
				MT_PTSR_LOSSRING)

			ring.throwspeed = P_RandomRange(-16, 16)*FU
			ring.angle = fixangle(P_RandomRange(0, 360)*FU)
			ring.momz = P_RandomRange(0, 32)*FU
		end
	end
end

PTSR.DoParry = function(parrier, victim)
	local anglefromparrier = R_PointToAngle2(victim.x, victim.y, parrier.x, parrier.y)
	
	local haswhirlwind = false
	
	if parrier.player and parrier.player.valid then
		haswhirlwind = (parrier.player.powers[pw_shield] & SH_WHIRLWIND)
	end
	
	victim.pfstunmomentum = true
	victim.pfstuntime = CV_PTSR.parrystuntime.value
	
	if not haswhirlwind then
		P_SetObjectMomZ(victim, CV_PTSR.parryknockback_z.value)
		P_InstaThrust(victim, anglefromparrier - ANGLE_180, CV_PTSR.parryknockback_xy.value)
	else
		P_SetObjectMomZ(victim, CV_PTSR.parryknockback_z.value*2)
		P_InstaThrust(victim, anglefromparrier - ANGLE_180, CV_PTSR.parryknockback_xy.value*2)
	end
end

-- Parry Stuff

-- helper function so we can get whose pizzaface easily
local function _isPF(mobj)
	if not mobj and mobj.valid then
		return false; end

	if mobj.type == MT_PLAYER
	and mobj.player
	and mobj.player.ptsr
	and mobj.player.ptsr.pizzaface then
		return true; end

	if mobj.type == MT_PIZZA_ENEMY then
		return true; end
end

addHook("PlayerThink", function(player)
	if not (player and player.mo and player.mo.valid) then return end
	if (player.playerstate == PST_DEAD) or (player.ptsr.outofgame) then return end 
	if (player.ptsr.pizzaface) then return end
	if PTSR.gameover then return end

	local cmd = player.cmd
	local pmo = player.mo
	
	local gm_metadata = PTSR.currentModeMetadata()
	
	if player.ptsr.parryhitlag then
		local data = player.ptsr.parryhitlagdata
		local ptime = leveltime-player.ptsr.parryhitlagtime

		if ptime >= PTSR.ParryHitLagFrames then
			player.mo.momx = data.momx
			player.mo.momy = data.momy
			player.mo.momz = data.momz

			player.ptsr.parryhitlag = false
		else
			P_SetOrigin(player.mo,
				data.x,
				data.y,
				data.z
			)
			player.mo.momx = 0
			player.mo.momy = 0
			player.mo.momz = 0
			player.mo.state = data.state
			player.mo.frame = data.frame
			player.drawangle = data.a
			
			if player == displayplayer then
				camera.momx = 0
				camera.momy = 0
				camera.momz = 0
			end
		end
	end

	if not player.mo.ptsr.parry_cooldown then
		if cmd.buttons & BT_ATTACK then
			if not player.mo.pre_parry then -- pre parry start
				local failparrysfx = {
					sfx_prepr1,
					sfx_prepr2,
					sfx_prepr3
				}
				
				local friendlyfire = (CV_PTSR.parry_friendlyfire.value or gm_metadata.parry_friendlyfire)
				local gotapf = false
				local gotanobject = false
				local range = 1000*FU
				local real_range = CV_PTSR.parry_radius.value
				
				searchBlockmap("objects", function(refmobj, foundmobj)
				
					if R_PointToDist2(foundmobj.x, foundmobj.y, pmo.x, pmo.y) < real_range 
					and abs(foundmobj.z-pmo.z) < CV_PTSR.parry_height.value then
						if _isPF(foundmobj) or foundmobj.flags & MF_ENEMY
						or (foundmobj.type == MT_PLAYER) then
							if foundmobj.type == MT_PLAYER then
								if foundmobj.player and foundmobj.player.valid then	
									if not foundmobj.player.ptsr.pizzaface then
										if not friendlyfire then
											return
										end
									
										if not PTSR.pizzatime then
											return
										end
										
										if foundmobj.player.powers[pw_invulnerability] then
											return
										end
									elseif PTSR.pizzatime_tics < CV_PTSR.pizzatimestun.value*TICRATE then
										return
									end
								end
							end
							
							if _isPF(foundmobj) then
								PTSR:AddComboTime(player, player.ptsr.combo_maxtime/4)
								
								foundmobj.pfhitlag = PTSR.ParryHitLagFrames
								
								gotapf = true
							end

							if PTSR_DoHook("onparry", pmo, foundmobj) == true then
								return true
							end

							PTSR.DoParry(player.mo, foundmobj)
							player.ptsr.lastparryframe = leveltime

							PTSR.DoParryAnim(player.mo, true, _isPF(foundmobj) and player.rings >= PTSR.ParrySpendRequirement)
							PTSR.DoParryAnim(foundmobj)
							
							if not player.ptsr.parryhitlag then
								local data = player.ptsr.parryhitlagdata
								data.x = player.mo.x
								data.y = player.mo.y
								data.z = player.mo.z
								data.momx = player.mo.momx
								data.momy = player.mo.momy
								data.momz = player.mo.momz
								data.a = player.drawangle
								data.state = player.mo.state
								data.frame = player.mo.frame
							end
							
							player.ptsr.parryhitlag = true
							player.ptsr.parryhitlagtime = leveltime
							
							gotanobject = true
						end
					end
				end,
				player.mo,
				player.mo.x-range, player.mo.x+range,
				player.mo.y-range, player.mo.y+range)

				if not gotanobject then
					S_StartSound(player.mo, failparrysfx[P_RandomRange(1,3)])
					local tryparry = P_SpawnGhostMobj(player.mo)
					tryparry.color = SKINCOLOR_WHITE
					tryparry.fuse = 2
					P_SetScale(tryparry, (3*FRACUNIT)/2)
					player.ptsr.lastparryframe = leveltime
					player.mo.ptsr.parry_cooldown = CV_PTSR.parrycooldown.value
				end
				
				if gotapf then
					if player.rings >= 150 then
						player.rings = $-($/10)
					elseif player.rings >= PTSR.ParrySpendRequirement then
						player.rings = max(0, $ - PTSR.ParrySpendRequirement)
					else -- you're broke buddy
						player.mo.ptsr.parry_cooldown = CV_PTSR.pfparrycooldown.value
					end
				else
					player.mo.ptsr.parry_cooldown = CV_PTSR.parrycooldown.value
				end
			
				player.mo.pre_parry = true
			end
		else
			player.mo.pre_parry = false
		end
	end
	
	if player.mo.ptsr.parry_cooldown then
		player.mo.ptsr.parry_cooldown = $ - 1
		if not player.mo.ptsr.parry_cooldown then
			S_StartSound(player.mo, sfx_ngskid)
			local tryparry = P_SpawnGhostMobj(player.mo)
			tryparry.color = SKINCOLOR_GOLDENROD
			tryparry.fuse = 5
			P_SetScale(tryparry, (3*FRACUNIT)/2)
		end
	end
end)