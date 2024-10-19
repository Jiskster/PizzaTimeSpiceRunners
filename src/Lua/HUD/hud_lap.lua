PTSR.LapColors = {
	[2] = SKINCOLOR_PURPLE,
	[3] = SKINCOLOR_RED,
	[4] = SKINCOLOR_GREEN,
	[5] = SKINCOLOR_BLUE,
}

local function getPatchesFromNum(v, font, num)
	local patches = {}
	local str = tostring(num)

	for i = 1,#str do
		local byte = str:sub(i):byte()
		local patch = v.cachePatch(string.format("%s%03d", font, byte))
		if not patch then continue end

		table.insert(patches, patch)
	end

	return patches
end

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
		local color = SKINCOLOR_PURPLE
		
		if PTSR.LapColors[player.ptsr.laps] then
			color = v.getColormap(nil, PTSR.LapColors[player.ptsr.laps])
		else -- pseudo rng lap colors
			local colornum = ((player.ptsr.laps*INT8_MAX)%#skincolors)+1
			
			if skincolors[colornum] then
				color = v.getColormap(nil, colornum)
			else
				color = v.getColormap(nil, SKINCOLOR_PURPLE) -- default
			end
		end
		
		v.drawScaled(cz.x, cz.y, FU/3, v.cachePatch"LAPFLAG", V_SNAPTOTOP, color)
		local patches = getPatchesFromNum(v, "PTLAP", player.ptsr.laps)

		local fx = 0
		local scale = FU/3

		for _,patch in ipairs(patches) do
			local x = cz.x + (165*scale)
			local fy = (91-patch.height)*scale
			
			v.drawScaled(x+fx,cz.y+fy,scale,patch,V_SNAPTOTOP, color)
			fx = $+(patch.width*scale)
		end
	end
end


customhud.SetupItem("PTSR_lap", ptsr_hudmodname, lap_hud, "game", 0)