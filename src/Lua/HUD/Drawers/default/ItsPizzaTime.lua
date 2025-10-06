local itspizzatime_hud = function(v, player)
	if not PTSR.IsPTSR() then return end

	local t = min(FixedDiv(PTSR.pizzatime_tics*FU, 1*TICRATE*FU), FU)
	
	if t then
		v.fadeScreen(SKINCOLOR_WHITE, ease.linear(t, 10, 0))
	end
	
	if PTSR.pizzatime and PTSR.pizzatime_tics and PTSR.pizzatime_tics < 10*TICRATE then
		local patch = v.cachePatch("ITSPIZZATIME1")
		if CV_PTSR.homework.value then
			patch = v.cachePatch("ITSHWTIME1")
		end
		if leveltime % 3 then
			patch = v.cachePatch("ITSPIZZATIME2")
			if CV_PTSR.homework.value then
				patch = v.cachePatch("ITSHWTIME2")
			end
		end
		if CV_PTSR.homework.value then
			v.drawScaled(0, (250*FU) - (PTSR.pizzatime_tics*FU)*3, (FU/3)*3/2, patch)
		else
			v.drawScaled(100*FRACUNIT, (250*FU) - (PTSR.pizzatime_tics*FU)*3, (FU/3)*3/2, patch)
		end
	end
end

return "ItsPizzaTime", itspizzatime_hud
