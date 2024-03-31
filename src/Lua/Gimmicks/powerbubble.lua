freeslot("MT_PT_BUBBLE", "S_PT_BUBBLE", "SPR_PBBL", "sfx_bblpop")
freeslot("MT_PT_BUBBLEEFFECT", "S_PT_BUBBLE2") -- effect
freeslot("MT_PT_BUBBLEPOWER", "S_PT_BUBBLE3") -- display power

mobjinfo[MT_PT_BUBBLE] = {
	doomednum = -1,
	spawnstate = S_PT_BUBBLE,
	spawnhealth = 1000,
	deathstate = S_SPRK1,
	deathsound = sfx_bblpop,
	radius = 64*FU,
	height = 32*FU,
	dispoffset = 0,
	flags = MF_SLIDEME|MF_SPECIAL|MF_NOGRAVITY|MF_NOCLIPHEIGHT
}

mobjinfo[MT_PT_BUBBLEEFFECT] = {
	doomednum = -1,
	spawnstate = S_PT_BUBBLE2,
	spawnhealth = 1000,
	radius = 16*FU,
	height = 24*FU,
	dispoffset = 1,
	flags = MF_SLIDEME|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
}

mobjinfo[MT_PT_BUBBLEPOWER] = {
	doomednum = -1,
	spawnstate = S_PT_BUBBLE3,
	spawnhealth = 1000,
	radius = 16*FU,
	height = 24*FU,
	dispoffset = 2,
	flags = MF_SLIDEME|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOCLIP
}

states[S_PT_BUBBLE] = {
    sprite = SPR_PBBL,
    frame = A|FF_ANIMATE|FF_FULLBRIGHT,
    tics = -1,
	var1 = 3,
	var2 = 2,
    nextstate = S_PT_BUBBLE,
}

states[S_PT_BUBBLE2] = {
    sprite = SPR_THOK,
    frame = A|FF_FULLBRIGHT,
    tics = -1,
	--frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	--var1 = 3,
	--var2 = 1,
    nextstate = S_PT_BUBBLE2,
}

states[S_PT_BUBBLE3] = {
    sprite = SPR_THOK,
    frame = A|FF_FULLBRIGHT,
    tics = -1,
	--frame = A|FF_ANIMATE|FF_FULLBRIGHT,
	--var1 = 3,
	--var2 = 1,
    nextstate = S_PT_BUBBLE3,
}

function A_PT_BubbleFloatAnim(actor)
	local maxangle = 0xFFFFFFFE
	local angles = 16
	local thrust_factor = 30*FRACUNIT
	
	for i = 0, angles do
		local div = FixedAngle((360*FRACUNIT)/angles)*i
		
		for ii = 0, angles do
			local div2 = FixedAngle((360*FRACUNIT)/angles)*ii
			
			local b_mo = P_SpawnMobj(actor.x , actor.y, actor.z, MT_PT_BUBBLEEFFECT)
			b_mo.divrem3 = P_RandomRange(FU/3, FU/6)
			b_mo.color = SKINCOLOR_AZURE
			
			L_ThrustXYZ(b_mo, div, div2, thrust_factor)
		end
	end
end

addHook("TouchSpecial", function(special, toucher)
	if special.displaypower and special.displaypower.valid then
		P_SpawnGhostMobj(special.displaypower)
		P_RemoveMobj(special.displaypower)
	end
	A_PT_BubbleFloatAnim(special)
end, MT_PT_BUBBLE)

addHook("MapThingSpawn", function(mobj)
	local monitor_range = {400,452} -- range of thingnum
	
	if mobj.info.doomednum >= monitor_range[1] and mobj.info.doomednum <= monitor_range[2] then
		local bubble = P_SpawnMobj(mobj.x, mobj.y, mobj.z, MT_PT_BUBBLE)
		bubble.displaypower = P_SpawnMobj(bubble.x, bubble.y, bubble.z+24*FU, MT_PT_BUBBLEPOWER)
		bubble.displaypower.sprite = SPR_TVRI
		bubble.displaypower.frame = C
		
		P_RemoveMobj(mobj)
		return true
	end
end)

addHook("MobjSpawn", function(mobj)
	mobj.spritexscale = $ / 4
	mobj.spriteyscale = $ / 4
	
	mobj.fuse = 10
end, MT_PT_BUBBLEEFFECT)

addHook("MobjThinker", function(mobj)
	if mobj and mobj.valid and mobj.divrem3 then
		mobj.momx = FixedMul($, FU - mobj.divrem3)
		mobj.momy = FixedMul($, FU - mobj.divrem3)
		mobj.momz = FixedMul($, FU - mobj.divrem3)
		
		mobj.frame = $ | ((10-mobj.fuse)<<FF_TRANSSHIFT)
	end
end, MT_PT_BUBBLEEFFECT)