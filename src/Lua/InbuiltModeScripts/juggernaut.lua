freeslot("MT_PT_JUGGERNAUTCROWN", "S_PT_JUGGERNAUTCROWN", "SPR_C9W3")

PTSR.juggernaut_chosenplayer = nil

addHook("NetVars", function(net)
	PTSR.juggernaut_chosenplayer = net($)
end)

addHook("MapLoad", function()
	PTSR.juggernaut_chosenplayer = nil
end)

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
    sprite = SPR_PZAT,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_PT_JUGGERNAUTCROWN
}

PTSR_AddHook("onparry", function(pmo, victim)
	print(victim.type)
end)

PTSR_AddHook("onpizzatime", function(pmo, victim)
	if PTSR.gamemode ~= PTSR.gm_juggernaut then return end
	

	print("Picking random player as Juggernaut.")
end)