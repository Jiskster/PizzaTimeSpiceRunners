PTSR.ESLOCATIONS = {loaded = false}; -- "Escape Spawner Locations"
local locations = PTSR.ESLOCATIONS;

freeslot(
"MT_ESCAPESPAWNER_ANIM",
"S_ESCAPESPAWNER_ANIM",
"SPR_SPWE",
"sfx_espawn"
)

sfxinfo[sfx_espawn].caption = "Escape Spawn!"

mobjinfo[MT_ESCAPESPAWNER_ANIM] = {
	doomednum = -1,
	spawnstate = S_ESCAPESPAWNER_ANIM,

	radius = 16*FU,
	height = 24*FU,

	flags = MF_SLIDEME|MF_NOGRAVITY|MF_NOCLIPHEIGHT|MF_NOBLOCKMAP,
}

states[S_ESCAPESPAWNER_ANIM] = {
	sprite = SPR_SPWE,
	frame = FF_ANIMATE|A,
	tics = T,
	var1 = T,
	var2 = 1,
	nextstate = S_NULL
}

-- If a mobj type is on this list, they are given the norespawn flag.
local nonrespawn_list = {
	[MT_RING] = true,
	[MT_COIN] = true
}

-- Arealock: The distance where an object is forced back to its spawn.
PTSR.EscapeSpawnList = {
	-- [MT_ ...]{ }
	[MT_BLUECRAWLA] = {arealock = 512*FU},
	[MT_REDCRAWLA] = {arealock = 512*FU},
	[MT_RING] = true,
	[MT_COIN] = true,
}

addHook("ThinkFrame", function()
	if not (locations.loaded) then return end
	if not leveltime then return end -- man srb2 sucks
	if not PTSR.pizzatime then return end
	if not PTSR.IsPTSR() then return end
	
	for i,v in ipairs(locations) do
		if not (v.child and v.child.valid) then
			-- Clean up invalid type, or left over players.
			for k,a in pairs(v.lap_list) do
				if userdataType(k) ~= "player_t"
				or not (k and k.valid) then
					v.laplist[k] = nil
					break
				end
			end
			
			for player in players.iterate do
				if (player.mo and player.mo.valid) then
					local dist = R_PointToDist2(player.mo.x, player.mo.y, v.x, v.y)
					
					if dist < 4096*FU then
						local vMobj = P_SpawnMobj(v.x, v.y, v.z, MT_RAY) -- Spawn a ray to check position (Because P_CheckSight only takes mobj_t)
						vMobj.fuse = 1
						
						if v.lap_list[player] == nil then
							v.lap_list[player] = max(player.ptsr.laps - 1, 0)
						end
						
						if (vMobj and vMobj.valid) and P_CheckSight(vMobj, player.mo) then							
							if (v.lap_list[player] < player.ptsr.laps) then
								v.lap_list[player] = player.ptsr.laps
								v.child = P_SpawnMobj(v.x, v.y, v.z, v.type)
								v.child.angle = v.angle
								P_SpawnMobj(v.x, v.y, v.z, MT_ESCAPESPAWNER_ANIM)
								S_StartSound(v.child, sfx_espawn)
								
								if v.flipped == true then
									v.child.eflags = $|MFE_VERTICALFLIP
								end
							end
						end
					end
				end
			end
		else
			local dist = R_PointToDist2(v.child.x, v.child.y, v.x, v.y)
			
			if PTSR.EscapeSpawnList[v.type] and type(PTSR.EscapeSpawnList[v.type]) == "table" and 
			PTSR.EscapeSpawnList[v.type].arealock then
				if dist > PTSR.EscapeSpawnList[v.type].arealock then
					P_SetOrigin(v.child, v.x, v.y, v.z)
					v.child.angle = v.angle
					P_SpawnMobj(v.x, v.y, v.z, MT_ESCAPESPAWNER_ANIM)
					S_StartSound(v.child, sfx_espawn)
				end
			end
		end
	end
end)

addHook("NetVars", function(net)
	locations = net($)
end)

addHook("MapLoad", function()
	if not PTSR.IsPTSR() then 
		return 
	end
	
	locations = {loaded = false}
	
	for thing in mapthings.iterate do
		if thing and thing.valid then
			local mobj = thing.mobj
			
			if mobj and mobj.valid then
				if nonrespawn_list[mobj.type] then
					mobj.flags2 = $|MF2_DONTRESPAWN
				end
				
				if PTSR.EscapeSpawnList[mobj.type] then
					table.insert(locations, {
						child = mobj,
						x = mobj.x,
						y = mobj.y,
						z = mobj.z,
						flipped = (thing.options & MTF_OBJECTFLIP) == MTF_OBJECTFLIP,
						lap_list = {}, -- [player_t] = latestlap
						type = mobj.type,
						angle = mobj.angle,
					})
				end
			end
		end
	end
	
	locations.loaded = true
end)