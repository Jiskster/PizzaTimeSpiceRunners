freeslot("MT_PT_JUGGERNAUTCROWN", "S_PT_JUGGERNAUTCROWN", "SPR_C9W3")

PTSR.juggernaut_chosenplayer = nil

addHook("NetVars", function(net)
	PTSR.juggernaut_chosenplayer = net($)
end)

addHook("MapLoad", function()
	PTSR.juggernaut_chosenplayer = nil
end)

local function P_StealPlayerScoreButOOG(player, amount) -- oog means outofgame
	local stolen = 0

	for refplayer in players.iterate do
		if player == refplayer or refplayer.ptsr_outofgame then
			continue 
		end
			
		if refplayer.score >= amount then
			stolen = $ + amount
			refplayer.score = $ - amount
		else
			stolen = $ + refplayer.score
			refplayer.score = 0
		end
	end
	
	P_AddPlayerScore(player, stolen)
end

mobjinfo[MT_PT_JUGGERNAUTCROWN] = {
	doomednum = -1,
	spawnstate = S_PT_JUGGERNAUTCROWN,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 32*FU,
	height = 32*FU,
	flags = MF_SPECIAL
}

states[S_PT_JUGGERNAUTCROWN] = {
    sprite = SPR_C9W3,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_PT_JUGGERNAUTCROWN
}

PTSR_AddHook("onparry", function(pmo, victim)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end

	if victim.hascrown then
		victim.hascrown = false
		
		if victim.crownref and victim.crownref.valid then
			local crown = victim.crownref
			
			victim.crownref.crowntimeout = 2*TICRATE
			victim.crownref.equip_pmo = nil
			victim.crownref.flags = $ & ~(MF_NOCLIP | MF_NOGRAVITY)
			victim.crownref = nil
			
			if victim.player and victim.player.valid then
				P_DoPlayerPain(victim.player)
			end
		end
	end
end)

PTSR_AddHook("onpizzatime", function(pmo, victim)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end

	local player_range = {}
	
	for player in players.iterate do
		if player.mo and player.mo.valid then
			table.insert(player_range, player)
		end
	end
	
	if not #player_range then return end -- if no players then go home
	
	local chosen_player = player_range[P_RandomRange(1, #player_range)]
	
	local newcrown = P_SpawnMobj(chosen_player.realmo.x, 
				chosen_player.realmo.y, 
				chosen_player.realmo.z, 
				MT_PT_JUGGERNAUTCROWN)
				
	newcrown.equip_pmo = chosen_player.realmo
	chosen_player.realmo.hascrown = true
	chosen_player.realmo.crownref = newcrown
	
	S_StartSound(nil, sfx_s24f)
	
	newcrown.flags = $ | (MF_NOCLIP | MF_NOGRAVITY)
	
	print(chosen_player.name.. " has been chosen as a Juggernaut!")
end)

addHook("MobjThinker", function(mobj)
	if mobj.crowntimeout then
		mobj.crowntimeout = $ - 1
	end
	
	if mobj.equip_pmo and mobj.equip_pmo.valid then
		local pmo = mobj.equip_pmo
		
		P_MoveOrigin(mobj, pmo.x, pmo.y, pmo.z + 64*FU)
		
		if pmo.player and pmo.player.valid then
			local player = pmo.player
			local normalclock = (leveltime % TICRATE) == 0
			local overtimeclock = (leveltime % 17) == 0
			
			if normalclock and not PTSR.timeover then
				P_StealPlayerScoreButOOG(player, 25)
			elseif overtimeclock and PTSR.timeover then
				P_StealPlayerScoreButOOG(player, 100)
			end
		else
			mobj.equip_pmo = nil
			mobj.flags = $ & ~(MF_NOCLIP | MF_NOGRAVITY)
		end
	end
	
	if mobj.crowntimeout then
		mobj.frame = $ | (FF_TRANS50 | FF_ADD)
	else
		mobj.frame = $ & ~ (FF_TRANS50 | FF_ADD)
	end
end, MT_PT_JUGGERNAUTCROWN)

addHook("TouchSpecial", function(special, toucher)
	local valid = (special and special.valid) 
					and (toucher and toucher.valid) 
					and (toucher.player and toucher.player.valid)
					
	if valid then
		if not special.equip_pmo and not special.crowntimeout then
			local player = toucher.player
			
			toucher.crownref = special
			toucher.hascrown = true
			
			special.equip_pmo = toucher
			
			S_StartSound(nil, sfx_s24f)
			
			special.flags = $ | (MF_NOCLIP | MF_NOGRAVITY)
		end
	end
	
	return true
end, MT_PT_JUGGERNAUTCROWN)