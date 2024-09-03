PTSR.ParrySpendRequirement = 20 
PTSR.ParryHitLagFrames = 5
PTSR.ParryStunFrames = 45

PTSR.ParryList = {

}

PTSR.HitlagList = {

}

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

addHook("ThinkFrame", function()
	-- Hitlag Table:
	for object, v in pairs(PTSR.HitlagList) do
		if v.time_left then
			v.time_left = $ - 1
			
			if not v.time_left then
				if v.old_momx ~= nil and v.old_momy ~= nil and v.old_momz ~= nil then
					if object and object.valid then
						object.momx = v.old_momx;
						object.momy = v.old_momy;
						object.momz = v.old_momz;
						object.flags = $ & ~MF_NOTHINK
					end
				end
				
				PTSR.HitlagList[object] = nil
				continue
			end
			
			if object and object.valid then
				local player = object.player
				
				if v.old_x ~= nil and v.old_y ~= nil and v.old_z ~= nil and
				v.old_state ~= nil and v.old_frame ~= nil then
					P_SetOrigin(object, v.old_x, v.old_y, v.old_z);
					
					object.state = v.old_state;
					object.frame = v.old_frame;
					
					object.momx = 0;
					object.momy = 0;
					object.momz = 0;
					
					if player and player.valid then
						if player == displayplayer then
							camera.momx = 0
							camera.momy = 0
							camera.momz = 0
						end
					end
				end
			else
				PTSR.HitlagList[object] = nil
				continue
			end
		end
	end
	
	-- Parry-stun Table:
	for object, v in pairs(PTSR.ParryList) do
		if v.time_left then
			v.time_left = $ - 1
			
			if not v.time_left then
				if object and object.valid then
					local player = object.player
					
					if player and player.valid then
						object.state = S_PLAY_FALL
					end
				end
				
				PTSR.ParryList[object] = nil
				continue
			end
			
			if object and object.valid then
				local player = object.player
				local speed = FixedHypot(object.momx, object.momy)
				
				if (leveltime % 3) == 0 then
					local ghost = P_SpawnGhostMobj(object)
				
					if ghost and ghost.valid then
						ghost.color = SKINCOLOR_WHITE
						ghost.colorized = true
					end
				end
				
				if player and player.valid then
					player.drawangle = v.add_angle 
					v.add_angle = $ + FixedAngle(speed*2)
					object.state = S_PLAY_PAIN
					player.pflags = $|PF_THOKKED
				else
					object.angle = $ + v.add_angle 
					v.add_angle = $ + FixedAngle(speed*2)
				end
				
				if (object.eflags & MFE_JUSTHITFLOOR) then
					S_StartSound(object, sfx_s3k49)
					P_SetObjectMomZ(object, 7*FRACUNIT)
					
					v.time_left = $ - TICRATE
					
					if v.time_left <= 0 then
						if object and object.valid then
							local player = object.player
							
							if player and player.valid then
								object.state = S_PLAY_FALL
							end
						end
						
						PTSR.ParryList[object] = nil
						continue
					end
				end
			else
				PTSR.ParryList[object] = nil
				continue
			end
		end
	end
end)

addHook("MobjMoveBlocked", function(mobj, thing, line)
	if line and line.valid then
		if PTSR.ParryList[mobj] then
			local speed = FixedHypot(mobj.momx, mobj.momy)
			local ang = R_PointToAngle2(line.v1.x, line.v1.y, line.v2.x, line.v2.y)
			local side = mobj.subsector.sector == line.frontsector and 1 or -1
			
			S_StartSound(mobj, sfx_s3k49)
			P_InstaThrust(mobj, ang-ANGLE_90*side, 30*FU)
		end
	end
end)

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
	local knockback_xy = CV_PTSR.parryknockback_xy.value
	local knockback_z = CV_PTSR.parryknockback_z.value
	local victim_speed = FixedHypot(victim.momx, victim.momy)

	local haswhirlwind = false
	
	if parrier.player and parrier.player.valid then
		haswhirlwind = (parrier.player.powers[pw_shield] & SH_WHIRLWIND)
	end
	
	victim.pfstunmomentum = true
	victim.pfstuntime = CV_PTSR.parrystuntime.value

	if haswhirlwind then
		knockback_xy = $ * 2
	end
	
	if not _isPF(victim) then
		if PTSR.isOvertime() then
			knockback_xy = $ * 3
		end
	end
	
	if victim_speed > 100*FU then
		knockback_xy = $ * 2
	end
	
	P_SetObjectMomZ(victim, knockback_z)
	P_InstaThrust(victim, anglefromparrier + ANGLE_180, knockback_xy)
end

PTSR.DoHitlag = function(mobj)
	mobj.flags = $ | MF_NOTHINK
	
	if PTSR.HitlagList[mobj] and PTSR.HitlagList[mobj].timeleft then
		PTSR.HitlagList[mobj].timeleft = $ + PTSR.ParryHitLagFrames
	else
		PTSR.HitlagList[mobj] = {
			time_left = PTSR.ParryHitLagFrames,
			old_x = mobj.x,
			old_y = mobj.y,
			old_z = mobj.z,
			old_momx = mobj.momx,
			old_momy = mobj.momy,
			old_momz = mobj.momz,
			old_state = mobj.state,
			old_frame = mobj.frame,
		}
	end
end

PTSR.StopHitlag = function(mobj, dontapplymom)
	if PTSR.HitlagList[mobj] then
		if not dontapplymom then
			if v.old_momx ~= nil and v.old_momy ~= nil and v.old_momz ~= nil then
				v.object.momx = v.old_momx;
				v.object.momy = v.old_momy;
				v.object.momz = v.old_momz;
				v.object.flags = $ & ~MF_NOTHINK
			end
			
			PTSR.HitlagList[mobj] = nil
		end
	end
end

addHook("PlayerThink", function(player)
	if not (player and player.mo and player.mo.valid) then return end
	if (player.playerstate == PST_DEAD) or (player.ptsr.outofgame) then return end 
	if (player.ptsr.pizzaface) then return end
	if PTSR.gameover then return end

	local cmd = player.cmd
	local pmo = player.mo
	
	local gm_metadata = PTSR.currentModeMetadata()
	local can_parry = PTSR_DoHook("canparry", player)

	if can_parry == nil then
		can_parry = true
	end

	if not player.mo.ptsr.parry_cooldown
	and not player.mo.pizza_in
	and not player.mo.pizza_out then
		if cmd.buttons & BT_ATTACK
		and can_parry then
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
								-- Prevents players from parrying pizza face before he is released.
								if (foundmobj.pfstuntime and not foundmobj.pfstunmomentum) then
									return
								end
								
								PTSR:AddComboTime(player, player.ptsr.combo_maxtime/4)
								
								gotapf = true
							else
								local set_timeleft = PTSR.ParryStunFrames
				
								if PTSR.isOvertime() then
									set_timeleft = $*2
								end
								
								if PTSR.ParryList[foundmobj]
								and PTSR.ParryList[foundmobj].time_left then
									PTSR.ParryList[foundmobj].time_left = $ + set_timeleft
								else
									PTSR.ParryList[foundmobj] = {
										time_left = set_timeleft,
										add_angle = 0,
									}
								end
	
								PTSR_DoHook("onparried", foundmobj, pmo)
							end

							if PTSR_DoHook("onparry", pmo, foundmobj) == true then
								return true
							end

							PTSR.DoParry(player.mo, foundmobj)
							player.ptsr.lastparryframe = leveltime

							PTSR.DoParryAnim(player.mo, true, _isPF(foundmobj) and player.rings >= PTSR.ParrySpendRequirement)
							PTSR.DoParryAnim(foundmobj)
							
							PTSR.DoHitlag(player.mo)
							PTSR.DoHitlag(foundmobj)
							
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