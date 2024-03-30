local itspizzatime_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	if PTSR.pizzatime and PTSR.pizzatime_tics then
		/*
		if PTSR.pizzatime_tics < 85
			v.draw(0, 0, v.cachePatch("PIZZAPAL"), V_50TRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER)
		end
		*/
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
			v.drawScaled(0, (250*FU) - (PTSR.pizzatime_tics*FU)*3, FU/2, patch)
		else
			v.drawScaled(100*FRACUNIT, (250*FU) - (PTSR.pizzatime_tics*FU)*3, FU/2, patch)
		end
	end
end

customhud.SetupItem("PTSR_itspizzatime", ptsr_hudmodname, itspizzatime_hud, "game", 0)
