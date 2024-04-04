local titlecard_hud = function(v)
	if not PTSR.IsPTSR() then return end
	if not (PTSR.titlecard_time) then return end
	
	local width = v.width()/v.dupx()*FU
	local height = v.height()/v.dupy()*FU
	
	local ct = PTSR.titlecards[gamemap] or PTSR.titlecards[0]
	local patch = v.patchExists(ct.graphic) and v.cachePatch(ct.graphic) or v.cachePatch("PLCHTC")
	local scale = FixedDiv(height, patch.height*FU)
	-- alpha should start at 10, then end at 0, then go back to 10
	local alpha = max(0, min(min(ct.time - PTSR.titlecard_time, PTSR.titlecard_time), 10))
	alpha = 10 - alpha

	v.drawFill()
	local flags = V_SNAPTOTOP
	if alpha > 1 and alpha < 10 then
		flags = $|(alpha<<V_ALPHAMASK)
	end
	if alpha < 10 then
		v.drawScaled((160*FU) - (patch.width*scale/2), 0, scale, patch, flags)
	end
end

customhud.SetupItem("PTSR_titlecards", ptsr_hudmodname, titlecard_hud, "game", 0)