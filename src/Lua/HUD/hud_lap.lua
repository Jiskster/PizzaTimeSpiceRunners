local lap_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	if not player.laptime then return end
	if player.pizzaface then return end
	if not (consoleplayer and consoleplayer.valid) then return end

	if not player == consoleplayer then return end
	
	local lap2flag = v.cachePatch("LAP2FLAG")
	local hudst = player["PT@hudstuff"]
	
	local cz = {
		x = 120*FU,
		start = -100*FU, 
		finish = 10*FU,
	}
	
	cz.y = ease.linear(FixedDiv(hudst.anim*FRACUNIT, 45*FRACUNIT), cz.start, cz.finish)

	if cz.y ~= nil and hudst.anim_active then
		if player.lapsdid == 2
			v.drawScaled(cz.x,cz.y,FRACUNIT/3, lap2flag, V_SNAPTOTOP)
		elseif player.lapsdid == 3 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP)
		elseif player.lapsdid == 4 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP|V_YELLOWMAP)
		elseif player.lapsdid == 5 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP|V_PURPLEMAP)
		elseif player.lapsdid >= 6 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP|V_REDMAP)
		end
	end
end


customhud.SetupItem("PTSR_lap", ptsr_hudmodname, lap_hud, "game", 0)