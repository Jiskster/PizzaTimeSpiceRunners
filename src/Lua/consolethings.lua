rawset(_G, "CV_PTSR", {}) -- for console vars

COM_AddCommand("ptsr_makepizza", function(player, arg)
	if not PTSR.IsPTSR() then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	if tonumber(arg) == nil then
		CONS_Printf(player, "arg1 must be a number.")
		return
	end
	if not arg then
		CONS_Printf(player, "makepizza <playernum>")
		return
	end
	
	if players[tonumber(arg)] then
		local targetplayer = players[tonumber(arg)]
		if targetplayer and targetplayer.valid and not targetplayer.ptsr.pizzaface then
			targetplayer.ptsr.pizzaface = true
			chatprint("\x85*"..targetplayer.name.." has become a pizza!")
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. "**".. targetplayer.name .. "** has magically become a pizza!\n"
			end
		end
	else
		CONS_Printf(player, "Player does not exist")
	end
end,1)

COM_AddCommand("ptsr_panicblacklist", function(p, skin, bool)
	if not (skin
	and skins[skin]) then
		CONS_Printf(p, "You must input a valid skin to add/remove to the blacklist.")
		return
	end

	if not bool then
		PTSR.panicblacklist[skin] = not PTSR.panicblacklist[skin]
		local text1 = PTSR.panicblacklist[skin] and "Added " or "Removed "
		local text2 = PTSR.panicblacklist[skin] and " into " or " from "
		CONS_Printf(p, text1..skin..text2.."the blacklist.")
	else
		if bool == "true"
		or bool == "add"
		or bool == "yes" then
			PTSR.panicblacklist[skin] = true
			CONS_Printf(p, "Added "..skin.." into the blacklist.")
		else
			PTSR.panicblacklist[skin] = false
			CONS_Printf(p, "Removed "..skin.." from the blacklist.")
		end
	end
end)

COM_AddCommand("ptsr_pizzatimenow", function(player)
	if not PTSR.IsPTSR() then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	PTSR.PizzaTimeTrigger(player.mo)
end,1)

local forcePT = false

COM_AddCommand("ptsr_debug_forcept", function(player)
	if not PTSR.IsPTSR() then
		forcePT = true
	end
end,1)

CV_PTSR.nuhuh = CV_RegisterVar({
	name = "ptsr_debug_nuhuh",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

addHook("PostThinkFrame", function ()
	if forcePT then
		COM_BufInsertText(server, "map " + G_BuildMapName(gamemap) + " -gametype 8 -f")
		forcePT = false
	end
end)

COM_AddCommand("ptsr_setnextgamemode", function(player, arg)
	if not PTSR.IsPTSR() then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	if tonumber(arg) == nil then
		CONS_Printf(player, "arg1 must be a number.")
		return
	end

	if not arg then
		CONS_Printf(player, "PTSR_setgamemode <gamemode_num>")
		return
	end

	PTSR.nextgamemode = PTSR.gamemode_list[tonumber(arg)] and tonumber(arg) or 1
	print("An admin forced next gamemode to: ".. PTSR.gamemode_list[PTSR.nextgamemode].name)
end,1)

COM_AddCommand("ptsr_spawnpfai", function(player, randomplayer, pftype)
	if not PTSR.IsPTSR() then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	local newpizaface = PTSR:SpawnPFAI(pftype)
	
	if (randomplayer and not randomplayer == "false") then
		PTSR:RNGPizzaTP(newpizaface, true)
	end
	
	CONS_Printf(player, "Spawned an AI Pizzaface")
end,1)


COM_AddCommand("ptsr_printcoords", function(player)
	if not PTSR.IsPTSR() then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	CONS_Printf(player, "X: "..player.mo.x/FU.."\n"
				.."Y: "..player.mo.y/FU.."\n"
				.."Z: "..player.mo.z/FU)
end)

COM_AddCommand("ptsr_printangle", function(player)
	if not PTSR.IsPTSR() then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	CONS_Printf(player, "Angle: "..AngleFixed(player.mo.angle)/FU)
end)

COM_AddCommand("ptsr_timeto1", function(player)
	if not PTSR.IsPTSR() then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	PTSR.timeleft = 1
end, 1)
// ADDED FOR TESTING PURPOSES

CV_PTSR.x_positioning = CV_RegisterVar({
	name = "PTSR_x_positioning",
	defaultvalue = "0",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})

CV_PTSR.y_positioning = CV_RegisterVar({
	name = "PTSR_y_positioning",
	defaultvalue = "0",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned
})

CV_PTSR.forcelap = CV_RegisterVar({
	name = "PTSR_forcelap",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.default_maxlaps = CV_RegisterVar({
	name = "PTSR_default_maxlaps",
	defaultvalue = "0",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.pizzatimestun = CV_RegisterVar({ -- in seconds
	name = "PTSR_pizzatimestun",
	defaultvalue = "10",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 60}, 
})

CV_PTSR.fakelapstun = CV_RegisterVar({
	name = "PTSR_fakelapstun",
	defaultvalue = "3",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.tpinv = CV_RegisterVar({
	name = "PTSR_tpinv",
	defaultvalue = "3", -- IN SECONDS
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.showdeaths = CV_RegisterVar({
	name = "PTSR_showdeaths",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.pizzalaugh = CV_RegisterVar({ -- Whenever the pizzaface laugh plays when pizzatime starts.
	name = "PTSR_pizzalaugh",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.homework = CV_RegisterVar({
	name = "PTSR_homework",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.collisionsystem = CV_RegisterVar({
	name = "PTSR_collisionsystem",
	defaultvalue = "1",
	flags = CV_NETVAR,
	PossibleValue = {line = 1},  -- , locationcheck = 2
})

CV_PTSR.timelimit = CV_RegisterVar({
	name = "PTSR_timelimit",
	defaultvalue = "4", -- in minutes
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.pizzachoosetype = CV_RegisterVar({
	name = "PTSR_pizzachoosetype",
	defaultvalue = "3",
	flags = CV_NETVAR,
	PossibleValue = {firsttrigger = 1, random = 2, allbutfirst = 3}, 
})

CV_PTSR.pizzacount = CV_RegisterVar({
	name = "PTSR_pizzacount",
	defaultvalue = "1",
	flags = CV_NETVAR,
	PossibleValue = CV_Natural, 
})

CV_PTSR.pizzatpcooldown = CV_RegisterVar({
	name = "PTSR_pizzatpcooldown",
	defaultvalue = "175", -- 5 Seconds
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 525}, 
})

CV_PTSR.pizzatpstuntime = CV_RegisterVar({
	name = "PTSR_pizzatpstuntime",
	defaultvalue = "70",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 525}, 
})

CV_PTSR.nomusic = CV_RegisterVar({
	name = "PTSR_nomusic",
	defaultvalue = "off",
	PossibleValue = CV_OnOff, 
})

CV_PTSR.scoreonkill = CV_RegisterVar({
	name = "PTSR_scoreonkill",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.killwhilerunning = CV_RegisterVar({
	name = "PTSR_killwhilerunning",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.screams = CV_RegisterVar({
	name = "PTSR_screams",
	defaultvalue = "off",
	flags = CV_SAVE,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.aitpstuntime = CV_RegisterVar({
	name = "PTSR_aitpstuntime",
	defaultvalue = "50",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 525}, 
})

CV_PTSR.aispeed = CV_RegisterVar({
	name = "PTSR_aispeed",
	defaultvalue = "30",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 500*FRACUNIT}, 
})

CV_PTSR.aileash = CV_RegisterVar({
	name = "PTSR_aileash",
	defaultvalue = "5200",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})

CV_PTSR.airubberband = CV_RegisterVar({
	name = "PTSR_airubberband",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.parrycooldown = CV_RegisterVar({
	name = "PTSR_parrycooldown",
	defaultvalue = "30",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 525}, 
})

CV_PTSR.pfparrycooldown = CV_RegisterVar({
	name = "PTSR_pfparrycooldown",
	defaultvalue = "105", -- 3 seconds
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 525}, 
})

CV_PTSR.parrystuntime = CV_RegisterVar({
	name = "PTSR_parrystuntime",
	defaultvalue = "45",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 525}, 
})

CV_PTSR.parryknockback_xy = CV_RegisterVar({
	name = "PTSR_parryknockback_xy",
	defaultvalue = "25",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})

CV_PTSR.parryknockback_z = CV_RegisterVar({
	name = "PTSR_parryknockback_z",
	defaultvalue = "15",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})

CV_PTSR.parry_radius = CV_RegisterVar({
	name = "PTSR_parry_radius",
	defaultvalue = "300",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})

CV_PTSR.parry_height = CV_RegisterVar({
	name = "PTSR_parry_height",
	defaultvalue = "200",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})

CV_PTSR.parry_friendlyfire = CV_RegisterVar({
	name = "PTSR_parry_friendlyfire",
	defaultvalue = "off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
})

CV_PTSR.parry_safeframes = CV_RegisterVar({
	name = "PTSR_parry_safeframes",
	defaultvalue = "5",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 350}, 
})

CV_PTSR.nopizza = CV_RegisterVar({
	name = "PTSR_nopizza",
	defaultvalue = "off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.flashframedeath = CV_RegisterVar({
	name = "PTSR_flashframedeath",
	defaultvalue = "On",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.dustdeviltimerend = CV_RegisterVar({
	name = "PTSR_dustdeviltimerend",
	defaultvalue = "3150", -- 1:30 min by default
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.overtime_speed = CV_RegisterVar({
	name = "PTSR_overtime_speed",
	defaultvalue = "0.00045",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})


/* TODO: Make these save with an i/o system
CV_PTSR.pizzastyle = CV_RegisterVar({
	name = "PTSR_pizzastyle",
	defaultvalue = "pizzaface",
	flags = CV_SAVE|CV_CALL,
	PossibleValue = {pizzaface = 1, coneball = 2, eggman = 3}, 
	func = function (cv)
		local name = ({
			[1] = "Pizzaface",
			[2] = "Coneball",
			[3] = "Eggman",
			[4] = "Summa"
		})[cv.value]
		if consoleplayer then
			CONS_Printf(consoleplayer, "You will now appear as " .. name .. " when you're the villian of Pizza Time.")
		else
			print("You will now appear as " .. name .. " when you're the villian of Pizza Time.")
		end
	end 
})
*/

CV_PTSR.combotime = CV_RegisterVar({
	name = "PTSR_combotime",
	defaultvalue = "15",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 60}, 
})

CV_PTSR.overtime_music = CV_RegisterVar({
	name = "PTSR_overtime_music",
	defaultvalue = "on",
	flags = 0,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.levelsinvote = CV_RegisterVar({
	name = "PTSR_levelsinvote",
	defaultvalue = "6",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 1, MAX = 6}
})

CV_PTSR.voteseconds = CV_RegisterVar({
	name = "PTSR_voteseconds",
	defaultvalue = "20",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

local luaOnly = "iamlua" .. P_RandomFixed()

COM_AddCommand("_PTSR_pizzastyle_sync", function(player, blah, set)
	if blah ~= luaOnly then
		CONS_Printf(player, "Don't run this manually! Instead, set `PTSR_pizzastyle`")
		return
	end
	
	player.ptsr.pizzastyle = tonumber(set)
end)

CV_PTSR.oldmusic = CV_RegisterVar({
	name = "PTSR_oldmusic",
	defaultvalue = "off",
	flags = CV_SAVE|CV_CALL,
	PossibleValue = CV_OnOff, 
	func = function (cv)
		if not consoleplayer then return end
		if cv.value then
			CONS_Printf(consoleplayer, "Lap 4 will now play Glucose Getaway by RodMod.")
		else
			CONS_Printf(consoleplayer, "Lap 4 will now play Pasta La Vista by Oofator.")
		end
	end
})

CV_PTSR.lapbroadcast_type = CV_RegisterVar({
	name = "PTSR_lapbroadcast_type",
	defaultvalue = "console",
	flags = 0,
	PossibleValue = {console = 1, chat = 2},
})

CV_PTSR.allowgamemodes = CV_RegisterVar({
	name = "PTSR_allowgamemodes",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

rawset(_G, "CV_PTJE", CV_PTSR)