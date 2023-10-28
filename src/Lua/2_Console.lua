rawset(_G, "CV_PTSR", {}) -- for console vars

COM_AddCommand("PTSR_makepizza", function(player, arg)
	if gametype ~= GT_PTSPICER then
		CONS_Printf(player, "Command must be ran in the Pizza Time Deluxe mode.")
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


COM_AddCommand("PTSR_pizzatimenow", function(player)
	if gametype ~= GT_PTSPICER then
		CONS_Printf(player, "Command must be ran in the Pizza Time Deluxe mode.")
		return
	end
	PTSR.PizzaTimeTrigger(player.mo)
end,1)

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

CV_PTSR.maxlaps = CV_RegisterVar({
	name = "PTSR_maxlaps",
	defaultvalue = "16",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.maxlaps_perplayer = CV_RegisterVar({
	name = "PTSR_maxlaps_perplayer",
	defaultvalue = "5",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.lappingtype = CV_RegisterVar({
	name = "PTSR_lappingtype",
	defaultvalue = "2",
	flags = CV_NETVAR,
	PossibleValue = {shared = 1, perplayer = 2}, 
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

CV_PTSR.dynamiclaps = CV_RegisterVar({
	name = "PTSR_dynamiclaps",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff, 
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
	defaultvalue = "5",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

CV_PTSR.pizzatpstuntime = CV_RegisterVar({
	name = "PTSR_pizzatpstuntime",
	defaultvalue = "2",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
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


CV_PTSR.pizzamask = CV_RegisterVar({
	name = "PTSR_pizzamask",
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

rawset(_G, "CV_PTJE", CV_PTSR)