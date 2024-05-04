local lap_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if not player.ptsr.laptime then return end
	if player.ptsr.pizzaface then return end
	if not (consoleplayer and consoleplayer.valid) then return end

	if not player == consoleplayer then return end
	
	local lap2flag = v.cachePatch("LAP2FLAG")
	local hudst = player.hudstuff
	
	local shakex = v.RandomRange(-FU/2,FU/2)
	local shakey = v.RandomRange(-FU/2,FU/2)
	
	local cz = {
		x = 120*FU,
		start = -100*FU, 
		finish = 10*FU,
	}
	
	cz.y = ease.linear(FixedDiv(hudst.anim*FRACUNIT, 45*FRACUNIT), cz.start, cz.finish)

	cz.x = $ + shakex
	cz.y = $ + shakey

	if cz.y ~= nil and hudst.anim_active then
		if player.ptsr.laps == 2
			v.drawScaled(cz.x,cz.y,FRACUNIT/3, lap2flag, V_SNAPTOTOP)
		elseif player.ptsr.laps == 3 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.ptsr.laps, V_SNAPTOTOP)
		elseif player.ptsr.laps == 4 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.ptsr.laps, V_SNAPTOTOP|V_YELLOWMAP)
		elseif player.ptsr.laps == 5 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.ptsr.laps, V_SNAPTOTOP|V_PURPLEMAP)
		elseif player.ptsr.laps >= 6 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.ptsr.laps, V_SNAPTOTOP|V_REDMAP)
		end
	end
end


customhud.SetupItem("PTSR_lap", ptsr_hudmodname, lap_hud, "game", 0)