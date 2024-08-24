--heres where the values reset when maps load
local function InitMap()
	PTSR.pizzatime = false -- doesn't matter what gamemode it is, just make it false all the time.
    PTSR.spawn_location = {x = 0, y = 0, z = 0}
    PTSR.endsector = nil
	PTSR.laps = 0
	PTSR.quitting = false
	PTSR.pizzatime_tics = 0 
	PTSR.timeover_tics = 0 
	PTSR.timeleft = 0
	PTSR.timeover = false
	PTSR.showtime = false
	PTSR.deathrings = {}
	PTSR.timeover_tics = 0 -- overtime
	PTSR.intermission_tics = 0
	PTSR.gameover = false
	PTSR.untilend = 0
	PTSR.dustdeviltimer = 0
	PTSR.aipf = nil
	PTSR.difficulty = FRACUNIT
	PTSR.pizzaface_speed_multi = FRACUNIT

	PTSR.vote_maplist = {}
	
	if not multiplayer then
		if consoleplayer then
			consoleplayer.score = 0
			consoleplayer.lives = 3
		end
		mapmusname = mapheaderinfo[gamemap].musname or string.format("MAP%02dM", gamemap)
		COM_BufInsertText(consoleplayer, "devmode 1")
		COM_BufInsertText(consoleplayer, "devmode 0")
	end
	
	/* Unused
	-- titlecards
	if not multiplayer then
		local current_titlecard = PTSR.titlecards[gamemap] or PTSR.titlecards[0]
		PTSR.titlecard_time = current_titlecard.time
	else
		PTSR.titlecard_time = 0
	end
	*/

	for i=1, CV_PTSR.levelsinvote.value do
		table.insert(PTSR.vote_maplist, {votes = 0, mapnum = 1, gamemode = 1})
	end
end

local function InitMap2()
    if not PTSR.IsPTSR() then return end
	PTSR.john = nil
    for map in mapthings.iterate do
        if map.type == 1 then
			local sec = R_PointInSubsector(map.x*FU, map.y*FU).sector

            PTSR.spawn_location.x = map.x*FU
            PTSR.spawn_location.y = map.y*FU
            PTSR.spawn_location.z = sec.floorheight+(map.z*FU)
            PTSR.spawn_location.angle = map.angle*ANG1
        end
		
        if map.type == 501 then
			local sec = R_PointInSubsector(map.x*FU, map.y*FU).sector

            PTSR.end_location.x = map.x*FU
            PTSR.end_location.y = map.y*FU
            PTSR.end_location.z = sec.floorheight+(map.z*FU)
 
            PTSR.end_location.angle = map.angle*ANG1
			local john = P_SpawnMobj(
				PTSR.end_location.x, 
				PTSR.end_location.y, 
				PTSR.end_location.z,
				MT_PILLARJOHN
			)
			john.angle = map.angle*ANG1
			if map.options & MTF_OBJECTFLIP then
				john.flags2 = $ | MF2_OBJECTFLIP
			end
			PTSR.john = john
        end
    end
	-- dont use the playercount function since it will iterate through all players twice
	-- so make a non functioned playercount
	local playercount = 0
	for player in players.iterate() do
	
		playercount = $ + 1	
		-- INCREMENT OVER --
		PTSR.ResetPlayerVars(player)
	end
	-- as saxashitter i am removing thwt fucking signpost
	if not multiplayer then
		for mobj in mobjs.iterate() do
			if mobj.type == MT_SIGN and mobj.valid then
				P_RemoveMobj(mobj)
			end
		end
	end
	if mapheaderinfo[gamemap].ptsr_s_rank_points ~= nil 
	and tonumber(mapheaderinfo[gamemap].ptsr_s_rank_points) then -- custom maxrankpoints
		PTSR.maxrankpoints = tonumber(mapheaderinfo[gamemap].ptsr_s_rank_points)
	else -- default maxrankpoints
		PTSR.maxrankpoints = PTSR.GetRingCount()*150
	end
end

local function InitMap3()
	if PTSR.nextgamemode then
		PTSR.ChangeGamemode(PTSR.nextgamemode)
		
		PTSR.nextgamemode = 1
	end
end

addHook("MapChange", InitMap)
addHook("MapLoad", InitMap)
addHook("MapLoad", InitMap2)
addHook("MapLoad", InitMap3)
