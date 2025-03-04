rawset(_G, "ptsr_hudmodname", "spicerunners")
-- time expected to reach to the final tween position, when pizza time starts
rawset(_G, "pthud_expectedtime", TICRATE*3)
-- pt animation position start
rawset(_G, "pthud_start_pos", 225*FRACUNIT)
-- pt animation position end
rawset(_G, "pthud_finish_pos", 175*FRACUNIT)
-- ptsr minimal hud (local enable)
if not isminimalhud then rawset(_G, "isminimalhud",{}) end

-- rank to patch
PTSR.r2p = function(v,rank) 
	if v.cachePatch("PTSR_RANK_"..rank:upper()) then
		return v.cachePatch("PTSR_RANK_"..rank:upper())
	end
end

PTSR.r2p_minimal = function(v,rank) 
	if v.cachePatch("MNIM_RANK_"..rank:upper()) then
		return v.cachePatch("MNIM_RANK_"..rank:upper())
	end
end

-- rank to fill
PTSR.r2f = function(v,rank) 
	if v.cachePatch("PTSR_FRANK_"..rank:upper()) then
		return v.cachePatch("PTSR_FRANK_"..rank:upper())
	end
end

PTSR.r2f_minimal = function(v,rank) 
	if v.cachePatch("MNIM_FRANK_"..rank:upper()) then
		return v.cachePatch("MNIM_FRANK_"..rank:upper())
	end
end

addHook("HUD", function(v,p,c)
	if PTSR.IsPTSR() then
		hud.disable("textspectator") -- sonic team junior
	end
end)