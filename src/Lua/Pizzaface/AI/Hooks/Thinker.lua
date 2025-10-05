local CLOSE_TRANS = TR_TRANS50
local already_announced_tornado = true

-- Ai Pizza Face Thinker
addHook("MobjThinker", function(mobj)
	local gm_metadata = PTSR.currentModeMetadata()
	
	local laughsound = mobj.laughsound or sfx_pizzah
	local maskdata = PTSR.PFMaskData[mobj.pizzastyle or 1]

	PTSR.addw2sobject(mobj)

	local beingHidden = false

	if displayplayer and displayplayer.valid then
		if R_PointToDist(mobj.x,mobj.y) <= 100*mobj.scale
		or ((mobj.cameraman and mobj.cameraman.valid) and (displayplayer.awayviewmobj == mobj.cameraman))
			mobj.frame = $|CLOSE_TRANS
			beingHidden = true
		else
			mobj.frame = $ &~CLOSE_TRANS
		end
	end
	
	--Set up camera point for PFViewpoint
	if not (mobj.cameraman and mobj.cameraman.valid)
		mobj.cameraman = P_SpawnMobjFromMobj(mobj,
			P_ReturnThrustX(nil,mobj.angle,-140*mobj.scale),
			P_ReturnThrustY(nil,mobj.angle,-140*mobj.scale),
			130*mobj.scale,
			MT_THOK
		)
		mobj.cameraman.flags2 = $|MF2_DONTDRAW
		mobj.cameraman.tics,mobj.cameraman.fuse = -1,-1
		mobj.cameraman.angle = mobj.angle
	else
		mobj.cameraman.momx = mobj.momx
		mobj.cameraman.momy = mobj.momy
		mobj.cameraman.momz = mobj.momz
		mobj.cameraman.angle = mobj.angle

		local vertang = 0
		
		if (mobj.pizza_target and mobj.pizza_target.valid)
			vertang = R_PointToAngle2(0,
				mobj.z,
				R_PointToDist2(mobj.pizza_target.x, mobj.pizza_target.y, mobj.x, mobj.y),
				mobj.pizza_target.z
			)
		end


		P_MoveOrigin(mobj.cameraman,
			mobj.x + P_ReturnThrustX(nil,mobj.angle,-140*mobj.scale),
			mobj.y + P_ReturnThrustY(nil,mobj.angle,-140*mobj.scale),
			mobj.z + P_ReturnThrustX(nil,vertang,110*mobj.scale)
		)
	end

	if not PTSR.pizzatime then return end
	
	if PTSR_DoHook("pfprestunthink", mobj) then
		return
	end
	
	if mobj.pfstuntime then
		mobj.pfstuntime = $ - 1
		if not mobj.pfstunmomentum then
			L_SpeedCap(mobj, 0) -- Freeze! You peasant food!
		end

		if not mobj.pfstuntime then -- If we just got to 0
			if not PTSR.showtime // hiiii adding onto this for showtime
				PTSR.showtime = true
				
				PTSR.resetHudState("PIZZAFACE_SHOWTIME")
				
				S_StartSound(nil, laughsound)
			end
			mobj.pfstunmomentum = false
		end
		return
	end
	
	-- Used for shields
	if mobj.pfstuntime2 then
		mobj.pfstuntime2 = $ - 1
		
		if not mobj.pfstunmomentum then
			mobj.momx = $/3
			mobj.momy = $/3
			mobj.momz = $/3
		end
	end
	
	PTSR.pfFindPlayer(mobj)
	if PTSR_DoHook("pfthink", mobj) then
		return
	end
	
	if mobj.pizza_target and mobj.pizza_target.valid and mobj.pizza_target.health and mobj.pizza_target.player and mobj.pizza_target.player.valid and
	PTSR.pfCanChase(mobj.pizza_target.player) then
		local speed = CV_PTSR.aispeed.value
		local dist = R_PointToDist2(mobj.pizza_target.x, mobj.pizza_target.y, mobj.x, mobj.y)
		local offset_speed = 0
		local p_target = mobj.pizza_target
		local targeting_player = mobj.pizza_target.player
		
		local bandfactor = maskdata.rubberrange or 500*FU

		--higher range = weaker banding
		--lower range = stronger banding
		local rubber_range = FixedMul(bandfactor,mobj.pizza_target.scale)
		
		if CV_PTSR.airubberband.value then
			offset_speed = FixedMul(speed, FU+FixedDiv(dist - rubber_range, rubber_range))
			offset_speed = $-speed
			if offset_speed < 0 then offset_speed = 0 end
		end
		
		if p_target.eflags & MFE_UNDERWATER then
			speed = FixedDiv($, 2*FRACUNIT)
		end
		
		--Slow down if our target is springing next to a wall
		if (p_target.player.panim == PA_SPRING)
		and (p_target.player.speed <= 15*p_target.scale) then
			speed = FixedDiv($, 2*FRACUNIT)
		end
		
		if PTSR.timeover and not gm_metadata.core_endurance then
			local yum = FRACUNIT + (PTSR.timeover_tics*CV_PTSR.overtime_speed.value)
			
			speed = FixedMul($, yum)
		end
		
		if gm_metadata.core_endurance then
			speed = FixedMul($, PTSR.pizzaface_speed_multi)
		end
		
		if gm_metadata.pfspeedmulti then
			local newspeed = gm_metadata.pfspeedmulti
			
			speed = FixedMul($, newspeed)
		end
		
		if mobj.pfspeedmulti then -- for hooks
			speed = FixedMul($, mobj.pfspeedmulti)
		end
		
		local val = CV_PTSR.aileash.value
		if not multiplayer then
			val = min($, 5000*FU) --prevents despawning
		end
		if dist > val then
			if not mobj.pfstuntime then
				PTSR.pfRandomTP(mobj, true)
			end
		end

		-- t in tx means "player that we're TARGETING"
        -- means "TEXAS" actually
		local tx = mobj.pizza_target.x
		local ty = mobj.pizza_target.y
		local tz = mobj.pizza_target.z
		
		if maskdata.momentum then
			-- a bit of yoink from FlyTo
			local sped = 3*speed/2
			local flyto = P_AproxDistance(P_AproxDistance(tx - mobj.x, ty - mobj.y), tz - mobj.z)
			if flyto < 1 then
				flyto = 1
			end
            local tmomx = FixedMul(FixedDiv(tx - mobj.x, flyto), sped)
            local tmomy = FixedMul(FixedDiv(ty - mobj.y, flyto), sped)
            local tmomz = FixedMul(FixedDiv(tz - mobj.z, flyto), sped)
			-- and again
			local sped2 = speed/15
			local flyto2 = P_AproxDistance(P_AproxDistance(tmomx - mobj.momx, tmomy - mobj.momy), tmomz - mobj.momz)
			if flyto2 < 1 then
				flyto2 = 1
			end
            mobj.momx = $ + FixedMul(FixedDiv(tmomx - mobj.momx, flyto2), sped2)
            mobj.momy = $ + FixedMul(FixedDiv(tmomy - mobj.momy, flyto2), sped2)
            mobj.momz = $ + FixedMul(FixedDiv(tmomz - mobj.momz, flyto2), sped2)
			L_SpeedCap(mobj, sped)
		else
			--WAAITTTTTTTTT!!!!!!!! If we're already really close to our target, don't move at all!
			
			if mobj.pfstuntime2 then
				if dist < speed then
					speed = dist
				end
			end
			
			P_FlyTo(mobj, tx, ty, tz, speed, true)
		end
		
		mobj.angle = R_PointToAngle2(mobj.x, mobj.y, tx, ty)

		if not (leveltime % 6) then
			local colors = maskdata.trails
			local ghost = P_SpawnGhostMobj(mobj)
			P_SetOrigin(ghost, mobj.x, mobj.y, mobj.z)
			ghost.fuse = 22
			ghost.colorized = true

			ghost.color = (mobj.redgreen) and colors[1] or colors[2]
			mobj.redgreen = not mobj.redgreen
			ghost.frame = $|FF_TRANS10|FF_FULLBRIGHT
			--WEird ass interpolation is PISSing me off
			P_SetOrigin(ghost,ghost.x,ghost.y,ghost.z)
			
			--But if PF is already close to the camera, dont get in the
			--way more
			if R_PointToDist(mobj.x,mobj.y) <= 100*mobj.scale
			or beingHidden
				ghost.flags2 = $|MF2_DONTDRAW
			end
		end

		if not maskdata.momentum then
			L_SpeedCap(mobj, speed+(offset_speed))
		end
	else
		if not mobj.pfstunmomentum then
			L_SpeedCap(mobj, 0)
		end
	end

	if PTSR.timeover and not PTSR.gameover and gm_metadata.dustdevil then
		local timeend = gm_metadata.dustdeviltimer or CV_PTSR.dustdeviltimerend.value
		
		PTSR.dustdeviltimer = $ + 1
		
		if PTSR.dustdeviltimer >= timeend then
			P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_ALIVEDUSTDEVIL)
			PTSR.dustdeviltimer = 0
			local tornado_text = "\x86*A tornado spawned!"
			chatprint(tornado_text)
			
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. ":cloud_tornado: A tornado spawned!\n"
			end
		end
	end
end, MT_PIZZA_ENEMY)