PTSR.keys = {}

states[freeslot "S_PTSR_KEY"] = {
	sprite = freeslot "SPR_PKEY",
	frame = A,
	tics = -1
}

sfxinfo[freeslot "sfx_coltpn"].caption = "Found something!"

local keyNotCaughtFlags = MF_SPECIAL
local keyCaughtFlags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY

mobjinfo[freeslot "MT_PTSR_KEY"] = {
	doomednum = 2112,
	spawnstate = S_PTSR_KEY,

	radius = 32*FU,
	height = 32*FU,

	flags = keyNotCaughtFlags
}

addHook("NetVars", function(n)
	PTSR.keys = n($)
end)

addHook("MapChange", do
	PTSR.keys = {}
end)

addHook("MobjSpawn", function(mo)
	mo.spawn_x = mo.x
	mo.spawn_y = mo.y
	mo.spawn_z = mo.z
end, MT_PTSR_KEY)

addHook("TouchSpecial", function(mo, pmo)
	if not (pmo and pmo.player and pmo.player.ptsr)          then return true end
	if pmo.player.ptsr.keyTo and pmo.player.ptsr.keyTo.valid then return true end
	if mo.attachedPlayer and mo.attachedPlayer.valid         then return true end

	pmo.player.ptsr.keyTo = mo
	mo.attachedPlayer = pmo.player
	S_StartSound(pmo, sfx_coltpn)

	return true
end, MT_PTSR_KEY)

addHook("PostThinkFrame", do
	for k,key in pairs(PTSR.keys) do
		if not (key and key.valid) then table.remove(PTSR.keys, k) continue end

		if key.attachedPlayer then
			if not (key.attachedPlayer.valid 
			and key.attachedPlayer.mo
			and key.attachedPlayer.ptsr
			and key.attachedPlayer.mo.health) then
				if (key.attachedPlayer.valid
				and key.attachedPlayer.ptsr) then
					key.attachedPlayer.ptsr.keyTo = nil
				end

				key.attachedPlayer = nil
				P_SetOrigin(key, key.spawn_x, key.spawn_y, key.spawn_z)
			else
				local p = key.attachedPlayer.mo

				local st = TICRATE*7
				local ut = TICRATE*5

				local angle = FixedMul(360*FU, FixedDiv(leveltime % st, st))
				angle = fixangle($)
	
				local c = cos(angle)
				local s = sin(angle)
				
				local x = p.x+(32*c)
				local y = p.y+(32*s)

				local angle2 = FixedMul(360*FU, FixedDiv(leveltime % ut, ut))
				angle2 = fixangle($)

				local s2 = sin(angle2)

				local z = p.z+(p.height/2)+FixedMul(p.height/2, s2)

				P_MoveOrigin(key, x, y, z)
				key.momx = 0
				key.momy = 0
				key.momz = 0
			end
		end

		key.flags = key.attachedPlayer and keyCaughtFlags or keyNotCaughtFlags
	end
end)

addHook("MapThingSpawn", function(mo, thing)
	PTSR.keys[thing.angle] = mo
	mo.assignedType = thing.angle

	if not PTSR.doors["enter"][thing.angle] then return end

	PTSR.doors["enter"][thing.angle].state = S_PTSR_DOOR_LOCKED
end, MT_PTSR_KEY)