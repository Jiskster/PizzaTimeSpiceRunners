freeslot("MT_PT_JUGGERNAUTCROWN", "S_PT_JUGGERNAUTCROWN", "SPR_C9W3")

PTSR.juggernaut_crownholder = nil

addHook("NetVars", function(net)
	PTSR.juggernaut_crownholder = net($)
end)

addHook("MapLoad", function()
	PTSR.juggernaut_crownholder = nil
	
	for player in players.iterate do
		if player.mo and player.mo.valid then
			player.mo.hascrown = false
			player.mo.crownref = nil
		end
	end
end)

local function P_StealPlayerScoreButOOG(player, amount) -- oog means outofgame
	local stolen = 0

	for refplayer in players.iterate do
		if player == refplayer or refplayer.ptsr.outofgame then
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

local function JG_GetPlayerCount()
	local player_range = {}
	
	for player in players.iterate do
		if player.mo and player.mo.valid 
		and player.playerstate ~= PST_DEAD  
		and not player.ptsr.outofgame then
			table.insert(player_range, player)
		end
	end
	
	return #player_range
end

mobjinfo[MT_PT_JUGGERNAUTCROWN] = {
	doomednum = -1,
	spawnstate = S_PT_JUGGERNAUTCROWN,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 64*FU,
	height = 64*FU,
	flags = MF_SPECIAL|MF_BOSS
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
				PTSR.juggernaut_crownholder = nil
			
				P_DoPlayerPain(victim.player)
				
				local output_text = victim.player.name.. " lost their crown!"
				chatprint("\x82".. "*" .. output_text)
				
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ":grimacing: ".. output_text.. "\n"
				end
			end
		end
	end
end)

/*
PTSR_AddHook("pfthink", function(pizza)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end
	local count = PTSR_COUNT()
	
	if count.active > 1 then
		if pizza.pizza_target == PTSR.juggernaut_crownholder then
			pizza.pizza_target = nil
		end
	end
end)
*/

PTSR_AddHook("pfplayerfind", function(pizza, player)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end
	local count = PTSR_COUNT()
	
	if count.active > 1 then
		if player.mo and player.mo.valid then
			if PTSR.juggernaut_crownholder == player.mo then
				return false
			end
		end
	else
		pizza.pizza_target = PTSR.juggernaut_crownholder
	end
end)

-- true == override
PTSR_AddHook("pfdamage", function(toucher, pizza)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end
	local count = PTSR_COUNT()
	
	if count.active > 1 then
		if PTSR.juggernaut_crownholder == toucher then
			return true
		else
			return false
		end
	end
end)

/*
PTSR_AddHook("pfteleport", function(pizza)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end

	if PTSR.juggernaut_crownholder then
		pizza.next_pfteleport = PTSR.juggernaut_crownholder
	end
end)
*/

local function JN_FindAndMakeNewJuggernaut()
	local player_range = {}
	
	for player in players.iterate do
		if player.mo and player.mo.valid and player.playerstate ~= PST_DEAD and not player.ptsr.outofgame then
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
	PTSR.juggernaut_crownholder = chosen_player.realmo
	
	S_StartSound(nil, sfx_s24f)
	
	newcrown.flags = $ | (MF_NOCLIP | MF_NOGRAVITY)
	
	local output_text = chosen_player.name.. " has been chosen as a Juggernaut!"
	
	print(output_text)
	
	if DiscordBot then
		DiscordBot.Data.msgsrb2 = $ .. ":crown: " .. output_text.. "\n"
	end
end

PTSR_AddHook("onpizzatime", function()
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end
	
	chatprint("\x82\*Juggernaut! Get that crown!")
	
	JN_FindAndMakeNewJuggernaut()
end)

/*
addHook("PlayerThink", function(player)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end
	
	if player.mo and player.mo.valid then
		if not player.mo.hascrown and PTSR.timeover then
			player.powers[pw_sneakers] = 1
		end
	end
end)
*/

addHook("MobjThinker", function(mobj)
	PTSR.addw2sobject(mobj)

	if mobj.crowntimeout then
		mobj.crowntimeout = $ - 1
	end
	
	-- despawn timer
	if mobj.crownorphan then
		 mobj.crownorphan = $ - 1
		 
		 if not mobj.crownorphan and JG_GetPlayerCount() ~= 0 then
			JN_FindAndMakeNewJuggernaut()
	
			mobj.invalidcrown = true
			P_KillMobj(mobj)
			return
		 end
	end
	
	if mobj.equip_pmo and mobj.equip_pmo.valid then
		local pmo = mobj.equip_pmo
		
		P_MoveOrigin(mobj, pmo.x, pmo.y, pmo.z + 64*FU)
		
		if pmo.player and pmo.player.valid then
			local player = pmo.player
			local normalclock = (leveltime % TICRATE) == 0
			local overtimeclock = (leveltime % 17) == 0
			
			mobj.crownorphan = 10*TICRATE
			
			PTSR.juggernaut_crownholder = pmo
			
			if normalclock and not PTSR.timeover then
				P_StealPlayerScoreButOOG(player, 50)
			elseif overtimeclock and PTSR.timeover then
				P_StealPlayerScoreButOOG(player, 65)
			end
			
			if pmo.player.playerstate == PST_DEAD then
				mobj.equip_pmo = nil
				mobj.flags = $ & ~(MF_NOCLIP | MF_NOGRAVITY)
				mobj.crowntimeout = 0
				pmo.crownref = nil
				pmo.hascrown = false
			end
			
			if player.ptsr.outofgame and JG_GetPlayerCount() > 0 then
				JN_FindAndMakeNewJuggernaut()
		
				mobj.invalidcrown = true
				pmo.crownref = nil
				pmo.hascrown = false
				P_KillMobj(mobj)
				return
			end
		else
			mobj.equip_pmo = nil
			mobj.flags = $ & ~(MF_NOCLIP | MF_NOGRAVITY)
		end
	else
	
	end
	
	if mobj.crowntimeout then
		mobj.frame = $ | (FF_TRANS50 | FF_ADD)
		L_SpeedCap(mobj, FU/2)
	else
		mobj.frame = $ & ~ (FF_TRANS50 | FF_ADD)
	end
	
	if P_CheckDeathPitCollide(mobj) and not mobj.equip_pmo then
		JN_FindAndMakeNewJuggernaut()
		
		mobj.invalidcrown = true
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
			
			player.powers[pw_invulnerability] = $ + 3*TICRATE
			
			local output_text = player.name.. " picked up a crown!"
			chatprint("\x82".. "*"..output_text)
			
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. ":crown: ".. output_text.. "\n"
			end
			
			special.flags = $ | (MF_NOCLIP | MF_NOGRAVITY)
		end
	end
	
	return true
end, MT_PT_JUGGERNAUTCROWN)

addHook("MobjDeath", function(mobj)
	if not mobj.invalidcrown then
		-- SRB2 does some stuff before we can stop it so
		mobj.flags = $ | MF_SPECIAL
		mobj.health = 1000
		
		return true
	end
end, MT_PT_JUGGERNAUTCROWN)