rawset(_G, "PTSR_shallowcopy", function(orig)
    if type(orig) != "table" then
		return orig
	end

	local copy = {}

	for k,v in pairs(orig) do
		copy[k] = PTSR_shallowcopy(v)
	end

	return copy
end)

G_AddGametype({
    name = "Spice Runners",
    identifier = "PTSPICER",
    typeoflevel = TOL_PTSR,
    rules = GTR_FRIENDLY|GTR_SPAWNENEMIES|GTR_TIMELIMIT,
    intermissiontype = int_match,
    headercolor = 67,
    description = "Run away from pizzaface, in style!"
})

rawset(_G, "PTSR", { -- variables
	spawn_location = 
	{x = 0, y = 0, z = 0, angle = 0}, -- where the sign is at the start of the map
	
	end_location = 
	{x = 0, y = 0, z = 0, angle = 0}, -- where the sign originally was in the map placement
	
	pizzatime = false,
	laps = 0,
	quitting = false,
	pizzatime_tics = 0,
	titlecard_time = 0,
	
	maxlaps = 5,

	timeleft = 0,
	
	timeover = false,
	
	endsector = nil,
	
	showtime = false,
	
	hudstuff = {
		anim = 0,
		anim_active = false,
		
		rev = false,
		wait_tics = 0,
		
		stop = false,
	},

	intermission_tics = 0,

	gameover = false,
	
	deathrings = {},
	
	timeover_tics = 0,
	
	maxrankpoints = 0,
	
	vote_maplist = {
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1},
		{votes = 0, mapnum = 1}
	},
	
	nextmapvoted = 0,
	
	nextmapvoted_info = {},
	
	dustdeviltimer = 0, -- when this reaches a certain number, every pizza face spawns an alive dust devil
	
	gamemode = 1,
	
	nextgamemode = 1,

	pizzas = {},
})

PTSR.isOvertime = function()
	return PTSR.timeover
end

PTSR.ring_score = 100

PTSR.lapbonus = 444
PTSR.ringlapbonus = 7

PTSR.laphold = 10*TICRATE -- hold fire to lap

PTSR.coremodes = {["1"] = true, ["2"] = true}

PTSR.default_playervars = {
	rank = "D",
	rank_scaleTime = 0,
	
	pizzaface = false,
	pizzamask = nil,
	
	laps = 0,
	laptime = 0,
	
	outofgame = 0,
	
	combo_count = 0,
	combo_active = false,
	combo_timeleft = 0,
	combo_maxtime = 10*TICRATE,
	combo_elapsed = 0, -- timer used for tweening the combo in when starting a combo
	combo_timesfailed = 0,
	combo_times_started = 0,
	
	combo_outro_count = 0, -- i want to keep the old combo visible when exiting
	combo_outro_tics = 0,

	combo_rank = 0, -- hi saxa/mario here look at this oooooo combo ranks
	combo_rank_very = 0,
	
	gotrevivedonce = false,
	justrevived = false,
	
	-- exists to save score when you die, is for rank screen when you die.
	lastscore = nil, 
	lastrank = nil,
	lastlaps = nil,

	lastparryframe = nil,
	cantparry = false, --this is for the pizzaface parry - saxa
	
	hudstuff = PTSR_shallowcopy(PTSR.hudstuff),
	
	-- score lmao
	current_score = 0,
	score_shakeTime = 0,
	score_shakeDrainTime = FU/5,
	score_objects = {},

	door_transitionTime = 0,
	door_transitionFadeTime = 0, // will be double than transitionTime
	door_goto = nil, -- position to teleport when transition is done

	keyTo = nil, -- KEY

	treasure_got = nil,
	treasure_state = S_PLAY_RIDE,
	treasures = 0
}
PTSR.gamemode_list = {}

PTSR.RegisterGamemode = function(name, input_table)
	local table_new = PTSR_shallowcopy(input_table)
	table_new.name = name
	
	table.insert(PTSR.gamemode_list, table_new)
	
	return #PTSR.gamemode_list
end

-- TODO: make every PTSR.gamemode_list[PTSR.gamemode], use this function
-- Im not doing this now because uhh i think it breaks when i use this function idk why
PTSR.currentModeMetadata = function()
	return PTSR.gamemode_list[PTSR.gamemode]
end

PTSR.gm_endurance = PTSR.RegisterGamemode("Endurance", {
	core_endurance = true,
	parry_friendlyfire = false,
	dustdevil = false,
	allowrevive = true,
})

PTSR.gm_versus = PTSR.RegisterGamemode("Versus", {
	parry_friendlyfire = true,
	dustdevil = false,
	allowrevive = false,
	disable_speedcap = true,
	lapbonus = 0,
})

/*
PTSR.gm_elimination = PTSR.RegisterGamemode("Elimination", {
	parry_friendlyfire = false,
	dustdevil = false,
	allowrevive = false,
	elimination_cooldown = 35*TICRATE,
	lapbonus = 0,
	
})
*/

PTSR.gm_juggernaut = PTSR.RegisterGamemode("Juggernaut", {
	parry_friendlyfire = true,
	dustdevil = false,
	allowrevive = false,
})

/*
PTSR.gm_playerpf = PTSR.RegisterGamemode("Player PF", {
	parry_friendlyfire = false,
	dustdevil = false,
	allowrevive = true,
	player_pizzaface = true,
	ring_score = 10,
	enemy_score = 100,
	ringlapbonus = 5,
	lapbonus = 300,
})
*/

PTSR.ChangeGamemode = function(gm)
	local newgamemode = gm or 1
	local gm_metadata = PTSR.gamemode_list[gm]
	
	if newgamemode ~= PTSR.gamemode then -- dont print this if new gamemode is the same
		local output_text = "PTSR Gamemode changed to " .. (gm_metadata.name or "Unnamed Mode")
		print(output_text)
		
		if DiscordBot then
			DiscordBot.Data.msgsrb2 = $ .. ":bar_chart: ".. output_text.. "\n"
		end
	end
	
	PTSR.gamemode = newgamemode
end

addHook("NetVars", function(net)
	local sync_list = {
		"HitlagList",
		"ParryList",
	
		"spawn_location",
		"end_location",
		"pizzatime",
		"maxlaps",
		"quitting",
		"pizzatime_tics",
		"timeleft",
		"timeover",
		"showtime",
		"endsector",
		
		"hudstuff",
		
		"maxrankpoints",

		"gamemode",
		
		"maxtime",
		
		"timeover_tics",
		
		"deathrings",
		
		"john",

		"untilend",

		"intermission_tics",

		"gameover",
		
		"vote_maplist",
		
		"nextmapvoted",
		
		"nextmapvoted_info",
		
		"dustdeviltimer",
		
		"nextgamemode",
		
		"difficulty",
		
		"pizzaface_speed_multi",

		"pizzas",
	}
	
	for i,v in ipairs(sync_list) do
		PTSR[v] = net($)
	end
end)

PTSR.spawn_location_atdefault = (
PTSR.spawn_location.x == 0 and 
PTSR.spawn_location.y == 0 and 
PTSR.spawn_location.z == 0 and 
PTSR.spawn_location.angle == 0
) -- returns true if at the defaults

PTSR.end_location_atdefault = (
PTSR.end_location.x == 0 and 
PTSR.end_location.y == 0 and 
PTSR.end_location.z == 0 and 
PTSR.end_location.angle == 0
) -- returns true if at the defaults

rawset(_G, "PTSR_COUNT", do
	local activeCount = 0
	local inactiveCount = 0
	local pizzaCount = 0
	local peppinoCount = 0

	for player in players.iterate
		if player.valid
			if player.ptsr.pizzaface then
				pizzaCount = $+1
			end
			if player.ptsr.outofgame or player.spectator or player.ptsr.pizzaface or (player.playerstate == PST_DEAD and PTSR.pizzatime)
				inactiveCount = $+1
			else
				peppinoCount = $+1
			end
		end
		
		activeCount = $+1
	end

	return {
		inactive = inactiveCount, -- includes pizza faces
		active = activeCount,
		pizzas = pizzaCount,
		peppinos = peppinoCount,
	}
end)

local RANKMUS = {
	P = "RNK_P",
	S = "RNK_S",
	A = "RNK_A",
	B = "RNK_CB",
	C = "RNK_CB",
	D = "RNK_D"
}

PTSR.RANKMUS = RANKMUS

addHook("ThinkFrame", do
	local gm_metadata = PTSR.currentModeMetadata()
	local count = PTSR_COUNT()

	if PTSR.pizzatime then
		P_StartQuake(FRACUNIT*4, 1)
		PTSR.pizzatime_tics = $ + 1
		
		if not PTSR.gameover then
			if gm_metadata.core_endurance then
				if (PTSR.pizzatime_tics % TICRATE) == 0 then
					if not PTSR.isOvertime() then
						PTSR.difficulty = $ + FRACUNIT/128
					else
						PTSR.difficulty = $ + FRACUNIT/32
					end
				end
				
				PTSR.pizzaface_speed_multi = FixedDiv(FU, FU*2) + FixedDiv(PTSR.difficulty, 2*FU)
			end
		end
		
		if CV_PTSR.timelimit.value then
			if not (PTSR.timeleft) then
				PTSR.timeover_tics = $ + 1
			end
			
			if PTSR.timeleft and (count.inactive ~= count.active) then
				PTSR.timeleft = max(0, $ - 1)
				
				if PTSR.timeleft <= 0 then
					PTSR.timeleft = 0
					if multiplayer then
						PTSR.timeover = true
						
						local timeover_text = "\x8F*Overtime!"
						chatprint(timeover_text)
						
						S_StartSound(nil, P_RandomRange(41,43)) -- lightning
						--S_StartSound(nil, sfx_pizzao)
						
						for i,deathring in ipairs(PTSR.deathrings) do
							if deathring and deathring.valid and deathring.rings_kept then
								deathring.rings_kept = $ * 3
							end
						end
						
						if DiscordBot then
							DiscordBot.Data.msgsrb2 = $ .. ":alarm_clock: Overtime!\n"
						end
					elseif not (PTSR.aipf
					and PTSR.aipf.valid)
						PTSR:SpawnPFAI()
					end
				end
			end
		end

		-- This is explicitly for turning off an inactive game (everyones dead!!!).
		if not PTSR.gameover then
			if (count.inactive == count.active) and PTSR.untilend < 100 then
				PTSR.untilend = $ + 1
				if PTSR.untilend >= 100 then
					PTSR.gameover = true
					print("GAME OVER!")
					if consoleplayer and consoleplayer.valid then
						S_ChangeMusic(RANKMUS[consoleplayer.ptsr.rank], false, player)
						mapmusname = RANKMUS[consoleplayer.ptsr.rank]
					end
					for p in players.iterate do
						if p and p.ptsr and PTSR.PlayerHasCombo(p) then
							PTSR:EndCombo(p)
						end
					end
					PTSR_DoHook("ongameend")
				end
			else
				PTSR.untilend = 0
			end
		else -- intermission thinker
			PTSR.intermission_tics = $ + 1
		end

		if PTSR.timeover then
			PTSR.timeover_tics = $ + 1
		end
	end 
end)

-- we love mobjs too
addHook("MobjSpawn", function(mobj)
	mobj.ptsr = {}
end, MT_PLAYER)

rawset(_G, "GT_PIZZATIMEJISK", GT_PTSPICER)
rawset(_G, "PTJE", PTSR)
rawset(_G, "JISK_COUNT", PTSR_COUNT)