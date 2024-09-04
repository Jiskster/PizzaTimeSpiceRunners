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


-- simple midgame joining blocker, variable init & more
addHook("PlayerSpawn", function(player)
	player.ptsr = $ or PTSR_shallowcopy(PTSR.default_playervars)
	player.ptsr.laps = $ or 0
	player.ptsr.laptime = $ or 0 
	
	if player.realmo and player.realmo.valid then
		if player.ptsr.pizzaface then
			return
		end
		
		if PTSR.pizzatime and leveltime then
			if not player.ptsr.justrevived then
				player.spectator = true -- default behavior
			else
				player.ptsr.deathscore = nil
				player.ptsr.deathrank = nil
				player.ptsr.deathlaps = nil
			
				player.ptsr.justrevived = false
				
				if player.ptsr.revivelocation then
					local revloc = player.ptsr.revivelocation 
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
				
				player.powers[pw_invulnerability] = 5*TICRATE
			end
		end
	end
end)

addHook("PlayerSpawn", function(player)
	player.hudstuff = PTSR_shallowcopy(PTSR.hudstuff)
end)

addHook("PlayerThink", function(player)
	if not PTSR.IsPTSR() then return end
	local gm_metadata = PTSR.currentModeMetadata()

	if not multiplayer then
		if player.exiting then
			player.exiting = 4
		end
		player.deadtimer = 10
	end

	if multiplayer and player.deadtimer > 5*TICRATE and PTSR.pizzatime and not player.spectator then
		player.playerstate = PST_REBORN
	end

	if PTSR.pizzatime and PTSR.timeover and not gm_metadata.disableovertimeshoes then
		player.powers[pw_sneakers] = 1
	end
end)

addHook("PlayerThink", function(player)
	local hudst = player.hudstuff
	
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
	local hudst = player.hudstuff
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
		if player.ptsr.laptime ~= nil and PTSR.pizzatime and not player.ptsr.outofgame 
		and not player.mo.pizza_in and not player.mo.pizza_out then
			player.ptsr.laptime = $ + 1
		end
		
		-- elfilin support: KILL THE DAMN PLAYER WHEN TRYING TO RIDE A PIZZAFACE
		-- ridingplayer isnt a player_t this is so clickbait!!!
		if player.elfilin and player.elfilin.ridingplayer 
		and player.mo and player.mo.valid and
		player.elfilin.ridingplayer.valid and
		player.elfilin.ridingplayer.player.ptsr.pizzaface and player.playerstate == PST_LIVE then
			--P_KillMobj(player.mo,player.elfilin.ridingplayer)
			player.elfilin.ridingplayer = 0
		end
	end
end)

for i = 1,5 do
	sfxinfo[freeslot("sfx_rup"..i)].caption = "Ranked up!"
	sfxinfo[freeslot("sfx_rad"..i)].caption = "Ranked down!"
end
local ranksTable = {
	["D"] = 1,
	["C"] = 2,
	["B"] = 3,
	["A"] = 4,
	["S"] = 5,
	["P"] = 6
}
local rankSounds = {
	{
		up = sfx_rup1,
		down = sfx_rad1
	},
	{
		up = sfx_rup2,
		down = sfx_rad2
	},
	{
		up = sfx_rup3,
		down = sfx_rad3
	},
	{
		up = sfx_rup4,
		down = sfx_rad4
	},
	{
		up = sfx_rup5,
		down = sfx_rad5
	}
}

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

	--player.ptsr.rank = "P"
	-- boy what the hellllll o ma god way ayyaay

	local _lastrank = player.ptsr.rank

	if not PTSR.gameover then
		if player.ptsr.current_score < pec then
			-- this is real p rank
			-- cry like a wittle babyy!
			player.ptsr.rank = "D"
		elseif player.ptsr.current_score <= pec*2 then
			player.ptsr.rank = "C"	
		elseif player.ptsr.current_score <= pec*4 then
			player.ptsr.rank = "B"
		elseif player.ptsr.current_score <= PTSR.maxrankpoints then
			player.ptsr.rank = "A"
		elseif player.ptsr.current_score <= pec*16 then
			if player.ptsr.combo_timesfailed == 0 
			and player.ptsr.combo_times_started == 1 then -- never gave up, one chance
				player.ptsr.rank = "P"
			else
				player.ptsr.rank = "S"
			end
		end
	end

	player.ptsr.rank_scaleTime = max(0, $-(FU/6))

	if leveltime
	and _lastrank ~= player.ptsr.rank then
		local lastRankNum = ranksTable[_lastrank]
		local rankNum = ranksTable[player.ptsr.rank]

		local type = "down"
		if rankNum >= lastRankNum then
			type = "up"
		end

		S_StartSoundAtVolume(nil,
			rankSounds[min(lastRankNum, rankNum)][type],
			255/2,
			player)

		player.ptsr.rank_scaleTime = FU
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
	
	if not PTSR.IsPTSR() then return end
	
	if PTSR.pizzatime
		PTSR.leaderboard = {}
		
		for p in players.iterate
			
			if (PTSR.pizzatime)
				local outofgame = p.spectator or p.ptsr.pizzaface or (p.playerstate == PST_DEAD and PTSR.pizzatime)
				if not outofgame
					table.insert(PTSR.leaderboard,p)
				end
			end
			
		end
		
		table.sort(PTSR.leaderboard, function(a,b)
			local p1 = a
			local p2 = b
			
			if ranktonum[a.ptsr.rank] ~= ranktonum[b.ptsr.rank]
				if ranktonum[a.ptsr.rank] > ranktonum[b.ptsr.rank]
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

-- Main Speed Cap (Makes the game playable and fun for fast characters)

addHook("PostThinkFrame", function()
	if not PTSR.IsPTSR() then return end
	
	local gm_metadata = PTSR.currentModeMetadata()
	
	if gm_metadata.disable_speedcap then return end
	
	for player in players.iterate do
		if not (player.pflags & PF_SPINNING) then
			if player.mo and player.mo.valid then
				if PTSR.ParryList[player.mo] and
				PTSR.HitlagList[player.mo] then
					continue
				end
				
				if gm_metadata and gm_metadata.speedcap then
					PTSR.SpeedCap_XY(player.mo, gm_metadata.speedcap)
				else
					PTSR.SpeedCap_XY(player.mo, 75*FU)
				end
			end
		end
	end
end)