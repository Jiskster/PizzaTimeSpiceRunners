rawset(_G, "ptsr_hudmodname", "spicerunners")
-- time expected to reach to the final tween position, when pizza time starts
rawset(_G, "pthud_expectedtime", TICRATE*3)
-- pt animation position start
rawset(_G, "pthud_start_pos", 225*FRACUNIT)
-- pt animation position end
rawset(_G, "pthud_finish_pos", 175*FRACUNIT)

-- rank to patch
PTSR.r2p = function(v,rank) 
	if v.cachePatch("PTSR_RANK_"..rank:upper()) then
		return v.cachePatch("PTSR_RANK_"..rank:upper())
	end
end

-- rank to fill
PTSR.r2f = function(v,rank) 
	if v.cachePatch("PTSR_FRANK_"..rank:upper()) then
		return v.cachePatch("PTSR_FRANK_"..rank:upper())
	end
end




