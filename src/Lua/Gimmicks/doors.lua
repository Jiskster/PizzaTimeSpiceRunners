PTSR.doors = {
	["enter"] = {},
	["exit"] = {}
}

states[freeslot "S_PTSR_DOOR"] = {
	sprite = freeslot "SPR_PDOR",
	frame = A,
	tics = -1
}

states[freeslot "S_PTSR_DOOR_LOCKED"] = {
	sprite = freeslot "SPR_PDKE",
	frame = A,
	tics = -1
}

states[freeslot "S_PTSR_DOOR_UNLOCKED"] = {
	sprite = SPR_PDKE,
	frame = B,
	tics = -1
}

mobjinfo[freeslot "MT_PTSR_DOOR"] = {
	--$Name Door
	--$Sprite PDORA0
	--$Category Spice Runners
	--$AngleText ID
	doomednum = 2111,

	radius = 20*FU,
	height = 60*FU,

	spawnstate = S_PTSR_DOOR,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
}

sfxinfo[freeslot "sfx_edoor"].caption = "Entering door"
sfxinfo[freeslot "sfx_keyul"].caption = "Unlock door"
sfxinfo[freeslot "sfx_cheers"].caption = "YAY!"

local function getPlayers(mo)
	local players = {}

	local width = FixedMul(mo.radius, mo.scale)
	local height = FixedMul(mo.height, mo.scale)

	searchBlockmap("objects",
		function(mo, pmo)
			if pmo.z > mo.z+height then return end
			if mo.z > pmo.z+FixedMul(pmo.height, pmo.scale) then return end

			if not (pmo.type == MT_PLAYER
			and pmo.player
			and pmo.player.ptsr) then return end

			players[pmo.player] = true
		end, mo)

	return players
end

local function assignDoors(mo, type, angle)
	if not (mo and mo.valid) then return end

	local oppositeType = type == "enter" and "exit" or "enter"

	PTSR.doors[type][angle] = mo
	mo.assignedType = angle

	if PTSR.doors[oppositeType][angle] then
		local mo2 = PTSR.doors[oppositeType][angle]

		if mo2 and mo.valid then
			mo.opposite_door = mo2
			mo2.opposite_door = mo
		end
	end

	if type == "enter"
	and PTSR.keys[angle] then
		mo.state = S_PTSR_DOOR_LOCKED
		-- LOCK IT GET THE KEY BITCH
	end
end

addHook("NetVars", function(n)
	PTSR.doors = n($)
end)

addHook("MapChange", do
	PTSR.doors = {
		["enter"] = {},
		["exit"] = {}
	}
end)

addHook("MobjSpawn", function(mo)
	mo.colliding = {}
end, MT_PTSR_DOOR)

addHook("MapThingSpawn", function(mo, thing)
	local type = thing.extrainfo == 0 and "enter" or "exit"
	local oppositeType = thing.extrainfo == 0 and "exit" or "enter"

	assignDoors(mo, type, thing.angle)
	assignDoors(PTSR.doors[oppositeType][thing.angle], oppositeType, thing.angle)
end, MT_PTSR_DOOR)

addHook("MobjThinker", function(mo)
	if not mo.opposite_door then return end
	if not mo.opposite_door.valid then return end

	local op = mo.opposite_door

	local colliding = getPlayers(mo)

	for p,v in pairs(colliding) do
		if not (p
		and p.valid
		and p.mo
		and p.mo.valid
		and p.mo.health
		and p.ptsr
		and not p.ptsr.door_goto) then continue end

		if mo.state == S_PTSR_DOOR_LOCKED then
			if not (p.ptsr.keyTo
			and p.ptsr.keyTo.valid
			and p.ptsr.keyTo.assignedType == mo.assignedType) then
				continue
			end

			P_RemoveMobj(p.ptsr.keyTo)
			p.ptsr.keyTo = nil

			mo.state = S_PTSR_DOOR_UNLOCKED
			S_StartSound(p.mo, sfx_cheers)
			S_StartSound(mo, sfx_keyul)
		end

		if not mo.colliding[p] then
			op.colliding[p] = true

			p.ptsr.door_transitionTime = TICRATE/4
			p.ptsr.door_transitionFadeTime = TICRATE/2
			p.ptsr.door_goto = op

			S_StartSound(mo, sfx_edoor)
			S_StartSound(nil, sfx_edoor, p)
		end
	end

	mo.colliding = colliding
end, MT_PTSR_DOOR)