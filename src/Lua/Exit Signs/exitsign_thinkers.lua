//LUIG BUD!!!
local isIcy = false
local dist = 1500

addHook("NetVars",function(n)
	isIcy = n($)
end)

local function isIcyF(map)
	if (mapheaderinfo[map] == nil)
		return false;
	end
	
	// https://wiki.srb2.org/wiki/Flats_and_textures/Skies
	if (mapheaderinfo[map].skynum == 17
	or mapheaderinfo[map].skynum == 29
	or mapheaderinfo[map].skynum == 30
	or mapheaderinfo[map].skynum == 107
	or mapheaderinfo[map].skynum == 55)
		return true;
	end

	if (mapheaderinfo[map].musname == "MP_ICE"
	or mapheaderinfo[map].musname == "FHZ"
	or mapheaderinfo[map].musname == "CCZ")
		// ice music
		return true;
	end
	
	//time to bust out the thesaurus!
	local icywords = {
		"frozen",
		"christmas",
		"ice",
		"icy",
		"icicle",
		"blizzard",
		"snow",
		"snowstorm",
		"frost",
		"winter",
		"chilly",
		"frigid",
		"artic",
		"polar",
		"glacial",
		"glacier",
		"wintery",
		"subzero",
		"tundra",
		"snowcap",
		"icecap",
	};

	local stageName = string.lower(mapheaderinfo[map].lvlttl);
	for i = 1,#icywords do
		if (string.find(stageName, icywords[i]) != nil)
			-- Has a very distinctly desert word in its title
			return true;
		end
	end

	return false;

end

addHook("MapLoad",function(mapid)
	isIcy = isIcyF(mapid)
end)
addHook("MapThingSpawn",function(mo,mt)
	//we dont wanna see EXIT pop up from no where
	//looks like an ERROR in a source game!
	mo.flags2 = $|MF2_DONTDRAW
	
	if gametype == GT_PIZZATIMEJISK
		local mul = 14
		if isIcy
			local gus = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_GUSTAVO_EXITSIGN)
			gus.state = S_GUSTAVO_EXIT_WAIT
			gus.icygus = true
			gus.angle = mo.angle
			gus.tracer = mo
			return true
		elseif gamemap == A5
			local gus = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_GUSTAVO_EXITSIGN)
			gus.state = S_GUSTAVO_EXIT_WAIT
			gus.rattygus = true
			gus.angle = mo.angle
			gus.tracer = mo
			return true
		else
			if (P_RandomChance(FU/2))
				local gus = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_GUSTAVO_EXITSIGN)
				gus.state = S_GUSTAVO_EXIT_WAIT
				gus.angle = mo.angle
				gus.tracer = mo
				return true
			else
				local stick = P_SpawnMobjFromMobj(mo,0,0,(mo.height*mul),MT_STICK_EXITSIGN)
				stick.state = S_STICK_EXIT_WAIT
				stick.angle = mo.angle
				stick.tracer = mo
				return true		
			end
		end
	end
	return true
end,MT_PIZZATOWER_EXITSIGN_SPAWN)

addHook("MobjThinker",function(mo)
	if not mo
	or not mo.valid
		return
	end
	
	if not PTJE
		return
	end
	
	local grounded = P_IsObjectOnGround(mo)
	
	mo.angle = mo.tracer.angle
	
	if mo.state == S_GUSTAVO_EXIT_WAIT
	and not mo.alreadyfell
		mo.flags2 = $|MF2_DONTDRAW
		mo.flags = $|MF_NOGRAVITY
		if PTJE.pizzatime
			local px = mo.x
			local py = mo.y
			local br = dist*mo.scale

			searchBlockmap("objects", function(mo, found)
				if found and found.valid
				and found.health
				and found.player
				and not (found.player.pizzaface)
				and (P_CheckSight(mo,found))
					if mo.icygus
						mo.state = S_GUSTAVO_ICE_RALLY
					elseif mo.rattygus
						mo.state = S_GUSTAVO_RAT_FALL
					else
						mo.state = S_GUSTAVO_EXIT_FALL
					end
					mo.alreadyfell = true
				end
			end, mo, px-br, px+br, py-br, py+br)
		end
	else
		mo.flags2 = $ &~MF2_DONTDRAW
		mo.flags = $ &~MF_NOGRAVITY
		if grounded
			if mo.rattygus
				if mo.state ~= S_GUSTAVO_RAT_RALLY
					mo.state = S_GUSTAVO_RAT_RALLY
				end
			elseif not (mo.icygus)
				if mo.state ~= S_GUSTAVO_EXIT_RALLY
					mo.state = S_GUSTAVO_EXIT_RALLY
				end
			end
		else
			if mo.rattygus
				mo.state = S_GUSTAVO_RAT_FALL
			elseif not (mo.icygus)
				mo.state = S_GUSTAVO_EXIT_FALL
			end			
		end
	end
end,MT_GUSTAVO_EXITSIGN)

addHook("MobjThinker",function(mo)
	if not mo
	or not mo.valid
		return
	end
	
	if not PTJE
		return
	end
	
	local grounded = P_IsObjectOnGround(mo)
	
	mo.angle = mo.tracer.angle
	
	if mo.state == S_STICK_EXIT_WAIT
	and not mo.alreadyfell
		mo.flags2 = $|MF2_DONTDRAW
		mo.flags = $|MF_NOGRAVITY
		if PTJE.pizzatime
			local px = mo.x
			local py = mo.y
			local br = dist*mo.scale

			searchBlockmap("objects", function(mo, found)
				if found and found.valid
				and found.health
				and found.player
				and not (found.player.pizzaface)
				and (P_CheckSight(mo,found))
					mo.state = S_STICK_EXIT_FALL
					mo.alreadyfell = true
				end
			end, mo, px-br, px+br, py-br, py+br)
		end
	else
		mo.flags2 = $ &~MF2_DONTDRAW
		mo.flags = $ &~MF_NOGRAVITY
		if grounded
			if mo.state ~= S_STICK_EXIT_RALLY
				mo.state = S_STICK_EXIT_RALLY
			end
		else
			mo.state = S_STICK_EXIT_FALL
		end
	end
end,MT_STICK_EXITSIGN)