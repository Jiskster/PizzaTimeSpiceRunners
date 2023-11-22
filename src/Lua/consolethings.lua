rawset(_G, "CV_PTSR", {}) -- for console vars

COM_AddCommand("ptsr_makepizza", function(player, arg)
	if gametype ~= GT_PTSPICER then
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
		if targetplayer and targetplayer.valid and not targetplayer.pizzaface then
			targetplayer.pizzaface = true
			chatprint("\x85*"..targetplayer.name.." has become a pizza!")
			if DiscordBot then
				DiscordBot.Data.msgsrb2 = $ .. "[" .. chosen_player .. "] **" .. players[chosen_player].name .. "** has magically become a pizza!\n"
			end
			PTSR_add_announcement(5*TICRATE,"\x85*"..targetplayer.name.." has become a pizza!")
		end
	else
		CONS_Printf(player, "Player does not exist")
	end
end,1)


COM_AddCommand("ptsr_pizzatimenow", function(player)
	if gametype ~= GT_PTSPICER then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	PTSR.PizzaTimeTrigger(player.mo)
end,1)

COM_AddCommand("ptsr_setgamemode", function(player, arg)
	if gametype ~= GT_PTSPICER then
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

	PTSR.gamemode = PTSR.gamemode_list[tonumber(arg)] and tonumber(arg) or 1
	print("Changed Gamemode to: ".. PTSR.gamemode_list[PTSR.gamemode])
end,1)

COM_AddCommand("ptsr_spawnpfai", function(player, randomplayer, pftype)
	if gametype ~= GT_PTSPICER then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	local newpizaface = PTSR:SpawnPFAI()
	
	if pftype ~= nil and pftype == "summa" then
		newpizaface.laughsound = sfx_smdah
		newpizaface.state = S_SUMMADAT_PF
	end
	
	if (randomplayer and not randomplayer == "false") then
		PTSR:RNGPizzaTP(newpizaface, true)
	end
	
	CONS_Printf(player, "Spawned an AI Pizzaface")
end,1)


COM_AddCommand("ptsr_printcoords", function(player)
	if gametype ~= GT_PTSPICER then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	CONS_Printf(player, "X: "..player.mo.x/FU.."\n"
				.."Y: "..player.mo.y/FU.."\n"
				.."Z: "..player.mo.z/FU)
end)

COM_AddCommand("ptsr_printangle", function(player)
	if gametype ~= GT_PTSPICER then
		CONS_Printf(player, "Command must be ran in the Pizza Time Spice Runners mode.")
		return
	end
	
	CONS_Printf(player, "Angle: "..AngleFixed(player.mo.angle)/FU)
end)
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
	defaultvalue = "5",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.pizzatimestun = CV_RegisterVar({
	name = "PTSR_pizzatimestun",
	defaultvalue = "10",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
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


CV_PTSR.aimode = CV_RegisterVar({
	name = "PTSR_aimode",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

CV_PTSR.aistuntime = CV_RegisterVar({
	name = "PTSR_aistuntime",
	defaultvalue = "350",
	flags = CV_NETVAR,
	PossibleValue = {MIN = 0, MAX = 525}, 
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

CV_PTSR.parrycooldown = CV_RegisterVar({
	name = "PTSR_parrycooldown",
	defaultvalue = "90",
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
	defaultvalue = "175",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})

CV_PTSR.parry_height = CV_RegisterVar({
	name = "PTSR_parry_height",
	defaultvalue = "185",
	flags = CV_NETVAR|CV_FLOAT,
	PossibleValue = {MIN = 0, MAX = 25000*FRACUNIT}, 
})

CV_PTSR.parry_friendlyfire = CV_RegisterVar({
	name = "PTSR_parry_friendlyfire",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
})


CV_PTSR.pizzastyle = CV_RegisterVar({
	name = "PTSR_pizzastyle",
	defaultvalue = "pizzaface",
	flags = CV_SAVE|CV_CALL,
	PossibleValue = {pizzaface = 1, coneball = 2, eggman = 3}, 
	func = function (cv)
		local name = ({
			[1] = "Pizzaface",
			[2] = "Coneball",
			[3] = "Eggman"
		})[cv.value]
		if consoleplayer then
			CONS_Printf(consoleplayer, "You will now appear as " .. name .. " when you're the villian of Pizza Time.")
		else
			print("You will now appear as " .. name .. " when you're the villian of Pizza Time.")
		end
	end 
})

local luaOnly = "iamlua" .. P_RandomFixed()

COM_AddCommand("_PTSR_pizzastyle_sync", function(player, blah, set)
	if blah ~= luaOnly then
		CONS_Printf(player, "Don't run this manually! Instead, set `PTSR_pizzastyle`")
		return
	end
	
	player.PTSR_pizzastyle = tonumber(set)
end)

addHook("ThinkFrame", function ()
	if not consoleplayer then return end
	
	if consoleplayer.PTSR_pizzastyle ~= CV_PTSR.pizzastyle.value then
		COM_BufInsertText(consoleplayer, "_PTSR_pizzastyle_sync " .. luaOnly .. " " .. CV_PTSR.pizzastyle.value)
	end
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

CV_PTSR.allowgamemodes = CV_RegisterVar({
	name = "PTSR_allowgamemodes",
	defaultvalue = "on",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
})

rawset(_G, "CV_PTJE", CV_PTSR)