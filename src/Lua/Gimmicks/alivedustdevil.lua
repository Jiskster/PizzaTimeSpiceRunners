-- script by Jisk

local nopull_list = {
	[MT_PIZZAPORTAL] = true,
	[MT_STARPOST] = true
}

freeslot("MT_ALIVEDUSTDEVIL", "S_ALIVEDUSTDEVIL_STAND", "S_ALIVEDUSTDEVIL_RUN")

mobjinfo[MT_ALIVEDUSTDEVIL] = {
	doomednum = -1,
	spawnstate = S_ALIVEDUSTDEVIL_STAND,
	seestate = S_ALIVEDUSTDEVIL_RUN,
	spawnhealth = 1000,
	speed = 16,
	flags = MF_NOCLIP|MF_BOSS|MF_SPECIAL,
}

states[S_ALIVEDUSTDEVIL_STAND] = {
	sprite = SPR_NULL,
	frame = FF_FULLBRIGHT|A,
	tics = 4,
	action = A_Look,
	nextstate = S_ALIVEDUSTDEVIL_STAND
}

states[S_ALIVEDUSTDEVIL_RUN] = {
	sprite = SPR_NULL,
	frame = FF_FULLBRIGHT|A,
	tics = 1,
	action = A_Chase,
	nextstate = S_ALIVEDUSTDEVIL_RUN
}

addHook("MobjSpawn", function(mobj)
	mobj.scale = $ * 2
end, MT_ALIVEDUSTDEVIL)

addHook("MobjDeath", function(mobj)
	-- SRB2 does some stuff before we can stop it so
	mobj.flags = $ | MF_SPECIAL
	mobj.health = 1000
	return true
end, MT_ALIVEDUSTDEVIL)

addHook("TouchSpecial", function(special, toucher)
	return true
end, MT_ALIVEDUSTDEVIL)

addHook("MobjThinker", function(mobj)
	A_DustDevilThink(mobj)
	
	if (leveltime % 15) == 0 
		P_SupermanLook4Players(mobj)
	end
	
	local range = 10240*FRACUNIT -- higher blockmap range so it doesnt look choppy
	local real_range = 896*FRACUNIT
	
	searchBlockmap("objects", function(refmobj, foundmobj)		
		if R_PointToDist2(foundmobj.x, foundmobj.y, mobj.x, mobj.y) < real_range 
		and abs(foundmobj.z - mobj.z) < 1000*FU and foundmobj.valid then
			if (foundmobj.flags & MF_SPECIAL or foundmobj.type == MT_PLAYER) 
			and not nopull_list[foundmobj.type] then
				local a2a = R_PointToAngle2(foundmobj.x, foundmobj.y, mobj.x, mobj.y)
				local a2a_offset = a2a + ANG30
				
				if foundmobj.type == MT_PLAYER and foundmobj.player
				and foundmobj.player.valid then
					local player = foundmobj.player
					foundmobj.state = S_PLAY_PAIN
					player.panim = PA_PAIN
					
					if (leveltime % 15) == 0 then
						player.pflags = $ & ~PF_THOKKED
						player.pflags = $|PF_JUMPED
					end
					
					if player.powers[pw_shield] & SH_WHIRLWIND then
						return
					end
				else
					L_SpeedCap(foundmobj, 30*FU)
					P_SetObjectMomZ(foundmobj, FU, true)
					P_Thrust(foundmobj, a2a_offset, 2*FU)
				end
				
				P_Thrust(foundmobj, a2a_offset, 3*FU) -- pull
				
				if foundmobj.momz <= 20*FU then
					P_SetObjectMomZ(foundmobj, FU/2, true)
				end
				
				if P_IsObjectOnGround(foundmobj) then
					P_SetObjectMomZ(foundmobj, FU*8)
					L_SpeedCap(foundmobj, 30*FU)
				end
				
				if foundmobj.type == MT_RING then
					local ring = P_SpawnMobj(foundmobj.x, foundmobj.y, foundmobj.z, MT_FLINGRING)
					ring.fuse = 10*TICRATE
					P_RemoveMobj(foundmobj)
					return 
				end
				

				
				if foundmobj.type == MT_PIZZA_ENEMY then
					L_SpeedCap(foundmobj, 45*FU)
				elseif (leveltime % 6) == 0 then
					P_SpawnGhostMobj(foundmobj)
				end
				

			else
				return false
			end
		end
	end, 
	mobj,
	mobj.x-range, mobj.x+range,
	mobj.y-range, mobj.y+range)	
end, MT_ALIVEDUSTDEVIL)
