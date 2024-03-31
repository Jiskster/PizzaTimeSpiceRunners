freeslot("MT_PT_BUBBLE", "S_PT_BUBBLE", "SPR_PBBL", "sfx_bblpop")

mobjinfo[MT_PT_BUBBLE] = {
	doomednum = -1,
	spawnstate = S_PT_BUBBLE,
	spawnhealth = 1000,
	deathstate = S_SPRK1,
	deathsound = sfx_bblpop,
	radius = 16*FU,
	height = 24*FU,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

states[S_PT_BUBBLE] = {
    sprite = SPR_PBBL,
    frame = A|FF_ANIMATE|FF_FULLBRIGHT,
    tics = -1,
	var1 = 3,
	var2 = 3,
    nextstate = S_PT_BUBBLE,
}

addHook("TouchSpecial", function(special, toucher)
	print("oogh")
end, MT_PT_BUBBLE)

addHook("MapThingSpawn", function(mobj)
	local monitor_range = {400,452} -- range of thingnum
	
	if mobj.info.doomednum >= monitor_range[1] and mobj.info.doomednum <= monitor_range[2] then
		P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_PT_BUBBLE)
		P_RemoveMobj(mobj)
		return true
	end
end)