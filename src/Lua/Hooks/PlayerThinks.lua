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
			if not player.ptsr_justrevived then
				player.spectator = true -- default behavior
			else
				player.ptsr_justrevived = false
				
				if player.ptsr_revivelocation then
					local revloc = player.ptsr_revivelocation 
					P_SetOrigin(player.realmo, revloc.x, revloc.y, revloc.z)
				end
				
				if player["ptsr_revive_await_rings"] then
					player.rings = player["ptsr_revive_await_rings"]
					player["ptsr_revive_await_rings"] = nil
				end
				
				if player["ptsr_revive_await_score"] then
					player.score = player["ptsr_revive_await_score"]
					player["ptsr_revive_await_score"] = nil
				end
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

addHook("PlayerThink", function(player)
	local pmo = player.mo
	local hudst = player["PT@hudstuff"]
	local maxholdtime = PTSR.laphold -- HOLDFORLAP

	if player.mo and player.mo.valid then
		if player.hold_newlap == nil then
			player.hold_newlap = 0
		end

		if player.hold_newlap and not PTSR.gameover then
		 	if player.hold_newlap >= PTSR.laphold then
				if not PTSR_DoHook("onlap", pmo) then
					PTSR.StartNewLap(player.mo)
					hudst.anim_active = true
					hudst.anim = 1
				end
				player.hold_newlap = 0
			end
		end 
		
		-- increment laptime
		if player.laptime ~= nil and PTSR.pizzatime and not player.ptsr_outofgame 
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
	-- a 8th of the max rank points, multiply later
	-- idk what pec is supposed to mean but i guess it means a fraction of the maxrank points
	local pec = (PTSR.maxrankpoints)/8
	
	/*
	print("rank debug")
	local previ = 0
	for i = 1,13
		if dont[i] == true then continue end
		
		local num = max(pec*i-player.score,0)
		
		local cc = ''
		if num == 0 then cc = "\x83" end
		local pad = ' '
		if i == 13 then pad = '' end
		
		print(i..pad..": "..rank[i]..": "
			..cc..num..
			" (+"..(pec*previ).." from last rank)"
		)
		previ = i
	end
	*/

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
	elseif player.score <= PTSR.maxrankpoints then
		player.ptsr_rank = "A"
	elseif player.score <= pec*16 then
		player.ptsr_rank = "S"
	else		
		player.ptsr_rank = "P"
	end
end)

--leaderboard stuff -luigi budd
local ranktonum = {
	["P"] = 6,
	["S"] = 5,
	["A"] = 4,
	["B"] = 3,
	["C"] = 2,
	["D"] = 1,
}

addHook('ThinkFrame', function()
	if gamestate ~= GS_LEVEL
		return
	end
	
	if gametype ~= GT_PTSPICER then return end
	
	if PTSR.pizzatime
		PTSR.leaderboard = {}
		
		for p in players.iterate
			
			if (PTSR.pizzatime)
				local outofgame = p.spectator or p.pizzaface or (p.playerstate == PST_DEAD and PTSR.pizzatime)
				if not outofgame
					table.insert(PTSR.leaderboard,p)
				end
			end
			
		end
		table.sort(PTSR.leaderboard, function(a,b)
			local p1 = a
			local p2 = b
			if ranktonum[a.ptsr_rank] ~= ranktonum[b.ptsr_rank]
				if ranktonum[a.ptsr_rank] > ranktonum[b.ptsr_rank]
					return true
				end
			else
				if p1.score > p2.score then
					return true
				end
			end
		end)
		
	end
end)

addHook("PlayerThink", function(player)
	local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
	
	if player.mo and player.mo.valid then
		if gm_metadata and gm_metadata.speedcap then
			L_SpeedCap(player.mo, gm_metadata.speedcap)
		end
	end
end)