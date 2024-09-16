freeslot("MT_PTSR_VFX_BUMP", "S_PTSR_VFX_BUMP", "SPR_VBMP")

mobjinfo[MT_PTSR_VFX_BUMP] = {
	doomednum = -1,
	spawnstate = S_PTSR_VFX_BUMP,

	radius = 16*FU,
	height = 24*FU,

	flags = MF_SLIDEME|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP,
}

states[S_PTSR_VFX_BUMP] = {
	sprite = SPR_VBMP,
	frame = FF_ANIMATE|A,
	tics = I,
	var1 = I,
	var2 = 1,
	nextstate = S_NULL
}
