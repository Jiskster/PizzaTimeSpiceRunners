--LUIG BUD!!!
--this code is old and sucks booty

/*
	--TODO
	-make gus and stick into seperate objects and make 1 spawner obbject
	 on mapthingspawn, choose one or the other. GUS AND STICK NUM = -1!!!
*/

freeslot("MT_PIZZATOWER_EXITSIGN_SPAWN")
freeslot("SPR_GSSE")
freeslot("S_EXITSPAWN_PLACEHOLDER")

states[S_EXITSPAWN_PLACEHOLDER] = {
	sprite = SPR_GSSE,
	frame = A,
	tics = -1,
}
mobjinfo[MT_PIZZATOWER_EXITSIGN_SPAWN] = {
	--$Name Exit Sign
	--$Sprite GSSEA0
	--$Category Spice Runners
	doomednum = 1263, --1-26-[202]3
	spawnstate = S_EXITSPAWN_PLACEHOLDER,
	spawnhealth = 1000, --gus cannot die lol
	radius = 14*FU,
	height = 26*FU,
	flags = MF_NOCLIPTHING
}

freeslot("MT_GUSTAVO_EXITSIGN")
freeslot("S_GUSTAVO_EXIT_WAIT")
freeslot("S_GUSTAVO_EXIT_FALL")
freeslot("SPR_GESF")
freeslot("S_GUSTAVO_EXIT_RALLY")
freeslot("SPR_GESR")
freeslot("S_GUSTAVO_ICE_RALLY")
freeslot("SPR_GESI")
freeslot("S_GUSTAVO_RAT_FALL")
freeslot("SPR_GERF")
freeslot("S_GUSTAVO_RAT_RALLY")
freeslot("SPR_GERR")

states[S_GUSTAVO_EXIT_WAIT] = {
	sprite = SPR_RING,
	frame = A,
	tics = -1,
}
states[S_GUSTAVO_EXIT_FALL] = {
	sprite = SPR_GESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_GUSTAVO_EXIT_RALLY] = {
	sprite = SPR_GESR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 9-1,
	var2 = 2,
	tics = -1,
}

states[S_GUSTAVO_ICE_RALLY] = {
	sprite = SPR_GESI,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 1,
	tics = -1,
}

states[S_GUSTAVO_EXIT_FALL] = {
	sprite = SPR_GESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_GUSTAVO_RAT_FALL] = {
	sprite = SPR_GERF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	tics = -1,
}
states[S_GUSTAVO_RAT_RALLY] = {
	sprite = SPR_GERR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 9-1,
	var2 = 2,
	tics = -1,
}

mobjinfo[MT_GUSTAVO_EXITSIGN] = {
	doomednum = -1,
	spawnstate = S_GUSTAVO_EXIT_WAIT,
	spawnhealth = 1000, --gus cannot die lol
	radius = 14*FU,
	height = 26*FU,
	flags = MF_NOCLIPTHING
}

freeslot("MT_STICK_EXITSIGN")
freeslot("S_STICK_EXIT_WAIT")
freeslot("S_STICK_EXIT_FALL")
freeslot("SPR_SESF")
freeslot("S_STICK_EXIT_RALLY")
freeslot("SPR_SESR")

states[S_STICK_EXIT_WAIT] = {
	sprite = SPR_RING,
	frame = A,
	tics = -1,
}
states[S_STICK_EXIT_FALL] = {
	sprite = SPR_SESF,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 3-1,
	var2 = 2,
	tics = -1,
}
states[S_STICK_EXIT_RALLY] = {
	sprite = SPR_SESR,
	frame = A|FF_PAPERSPRITE|FF_ANIMATE,
	var1 = 6-1,
	var2 = 2,
	tics = -1,
}

mobjinfo[MT_STICK_EXITSIGN] = {
	doomednum = -1,
	spawnstate = S_STICK_EXIT_WAIT,
	spawnhealth = 1000, --gus cannot die lol
	radius = 10*FU,
	height = 32*FU,
	flags = MF_NOCLIPTHING
}