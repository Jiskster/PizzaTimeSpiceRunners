local doors = {
	["enter"] = {},
	["exit"] = {}
}

states[freeslot "S_PTSR_DOOR"] = {
	sprite = freeslot "SPR_PDOR",
	frame = A,
	tics = -1
}

mobjinfo[freeslot "MT_PTSR_DOOR"] = {
	doomednum = 2111,

	width = 32*FU,
	height = 60*FU,

	spawnstate = S_PTSR_DOOR,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}

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

	doors[type][angle] = mo
	if doors[oppositeType][angle] then
		local mo2 = doors[oppositeType][angle]

		mo.opposite_door = mo2
		mo2.opposite_door = mo
	end
end

addHook("MapChange", do
	doors = {
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
	assignDoors(doors[oppositeType][thing.angle], oppositeType, thing.angle)
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

		if not mo.colliding[p] then
			op.colliding[p] = true

			p.ptsr.door_transitionTime = TICRATE/4
			p.ptsr.door_transitionFadeTime = TICRATE/2
			p.ptsr.door_goto = op
		end
	end

	mo.colliding = colliding
end, MT_PTSR_DOOR)