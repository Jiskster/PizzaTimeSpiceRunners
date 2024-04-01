freeslot("MT_PILLARJOHN", "S_PILLARJOHN", "S_PILLARJOHN_PAIN", "SPR_PILJ", "sfx_jpilr")

mobjinfo[MT_PILLARJOHN] = {
	doomednum = -1,
	spawnstate = S_PILLARJOHN,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 96*FU,
	height = 128*FU,
	flags = MF_SPECIAL,
}

states[S_PILLARJOHN] = {
    sprite = SPR_PILJ,
    frame = FF_ANIMATE|A,
    tics = -1,
    var1 = 11,
    var2 = 3,
    nextstate = S_PILLARJOHN
}

states[S_PILLARJOHN_PAIN] = {
    sprite = SPR_PILJ,
    frame = 12,
    tics = -1,
    nextstate = S_PILLARJOHN_PAIN
}

function PTSR.KnockJohnPillar(john)
	if not john.johnpillarknocked then
		john.state = S_PILLARJOHN_PAIN
		john.flags = $ | MF_NOCLIP | MF_NOCLIPHEIGHT
		john.momx = -cos(john.angle)*8
		john.momy = -sin(john.angle)*8
		john.momz = P_MobjFlip(john)*8*FU
		S_StartSound(nil, sfx_jpilr)
		if consoleplayer and consoleplayer.valid then
			P_FlashPal(consoleplayer, 1, 2)
		end
		john.johnpillarknocked = true
	end
end

addHook("TouchSpecial", function(special, toucher)
	PTSR.PizzaTimeTrigger(toucher)
	PTSR.KnockJohnPillar(special)
	
	return true
end, MT_PILLARJOHN)