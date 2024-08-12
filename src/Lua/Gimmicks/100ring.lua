local killtime = TICRATE/2
local fadetime = TICRATE/4

states[freeslot "S_PTSR_SCORERING"] = {
	sprite = SPR_SCOR,
	frame = A,
	tics = killtime,
	nextstate = S_NULL
}

mobjinfo[freeslot "MT_PTSR_SCORERING"] = {
	spawnstate = S_PTSR_SCORERING,
	dispoffset = 1,
	radius = 1,
	height = 1,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

addHook("MobjSpawn", function(mo)
	mo.spawntime = leveltime
	mo.spritexscale = $*2
	mo.spriteyscale = $*2
end, MT_PTSR_SCORERING)

addHook("MobjThinker", function(mo)
	mo.momz = mo.scale

	local time = leveltime-mo.spawntime

	if time >= killtime-fadetime then
		local time = time-(killtime-fadetime)
		local tweentime = min(FixedDiv(time, fadetime), FU)

		mo.frame = A|(ease.linear(tweentime, 0, 10)*FF_TRANS10)
	end
end, MT_PTSR_SCORERING)

addHook("MobjDeath", function(t,i,s)
	if not PTSR.IsPTSR() then return end

	local x = t["very secure x"] or t.x
	local y = t["very secure y"] or t.y
	local z = t["very secure z"] or t.z

	P_SpawnMobj(x,
		y,
		z,
		MT_PTSR_SCORERING)
end, MT_RING)