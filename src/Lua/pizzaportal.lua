local portal_time = 25 -- tics
local minspritescale = FRACUNIT/32
local maxspritescale = FRACUNIT

freeslot("MT_PIZZAPORTAL", "S_PIZZAPORTAL", "SPR_P3PT", "sfx_lapin", "sfx_lapout", "sfx_yuck34")

mobjinfo[MT_PIZZAPORTAL] = {
	doomednum = 1417,
	spawnstate = S_PIZZAPORTAL,
	spawnhealth = 1000,
	deathstate = S_NULL,
	radius = 64*FU,
	height = 144*FU,
	flags = MF_SPECIAL|MF_NOCLIP|MF_NOGRAVITY
}

states[S_PIZZAPORTAL] = {
    sprite = SPR_P3PT,
    frame = A|FF_PAPERSPRITE|FF_FULLBRIGHT,
    tics = -1,
    nextstate = S_PIZZAPORTAL
}

addHook("TouchSpecial", function(special, toucher)
	local tplayer = toucher.player
	if toucher and toucher.valid and tplayer and tplayer.valid then
		local lastlap_perplayer = ((CV_PTSR.lappingtype.value == 2) and (tplayer.lapsdid >= CV_PTSR.maxlaps_perplayer.value))
		if not toucher.pizza_in and not toucher.pizza_out and PTSR.pizzatime and not lastlap_perplayer then -- start lap portal in sequence
			toucher.pizza_in = portal_time
			S_StartSound(toucher, sfx_lapin)
			S_StartSound(special, sfx_yuck34)
		end
	end
	
	return true
end, MT_PIZZAPORTAL)

addHook("MobjThinker", function(mobj)
	local float_offset = sin(leveltime*FRACUNIT*500)*10
	mobj.spriteyoffset = float_offset
	
	if mobj.spawnpoint then
		mobj.angle = FixedAngle(mobj.spawnpoint.angle*FRACUNIT) + ANGLE_90 -- give me the right angle dumbass papersprite
	end
	
	if displayplayer and displayplayer.valid then
		if ((CV_PTSR.lappingtype.value == 2) and (displayplayer.lapsdid >= CV_PTSR.maxlaps_perplayer.value)) or not PTSR.pizzatime then
			mobj.frame = $|FF_TRANS50
		else
			mobj.frame = $ & ~FF_TRANS50
		end
	end
end, MT_PIZZAPORTAL)

-- pizza portal enter animations
-- the easings are the opposites because the counter is going down, ex: out being in and in being out
addHook("MobjThinker", function(mobj)
	if mobj.pizza_in then
		local div = FixedDiv(mobj.pizza_in*FRACUNIT, portal_time*FRACUNIT)
		local ese = ease.outquint(div, minspritescale, maxspritescale)
		mobj.pizza_in = $ - 1

		mobj.spritexscale = ese
		mobj.spriteyscale = ese
		
		L_SpeedCap(mobj, 0)
		if not mobj.pizza_in then -- start lap portal out sequence
			mobj.pizza_out = portal_time
			PTSR.StartNewLap(mobj)
			S_StartSound(mobj, sfx_lapout)
		end
	end
	
	if mobj.pizza_out then
		local div = FixedDiv(mobj.pizza_out*FRACUNIT, portal_time*FRACUNIT)
		local ese = ease.inquint(div, maxspritescale, minspritescale)
		mobj.pizza_out = $ - 1
		
		mobj.spritexscale = ese
		mobj.spriteyscale = ese
		L_SpeedCap(mobj, 0)
	end	
end, MT_PLAYER)

