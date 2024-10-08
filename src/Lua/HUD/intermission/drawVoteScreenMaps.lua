function PTSR.drawVoteScreenMaps(v, player)
	if PTSR.isVoteOver() then return end

	for i=1,4 do
		local x = 100*FU
		local y = 70*FU
		
		local panel_x = x
		local panel_y = y
		
		local inner_x = x
		local inner_y = y
		
		local x_offset = ((i-1)%2)*(120*FU)
		
		local vote_selection = player.ptsr.vote_selection
		
		local mapscale = FU/2
		local mapvoteinfo = PTSR.vote_maplist[i]
		local mapnum = mapvoteinfo.mapnum
		local mappatch = v.cachePatch(G_BuildMapName(mapnum).."P")
		
		local maprealname = mapheaderinfo[mapnum].lvlttl
		local mapact = mapheaderinfo[mapnum].actnum
		
		local gamemodeinfo = PTSR.gamemode_list[mapvoteinfo.gamemode]
		local gamemodename = gamemodeinfo.name or "Unnamed"
		
		local panelpatch = v.cachePatch("PTSR_MAP_PANEL2")
		local innerpatch = v.cachePatch("PTSR_MAP_INNER")
		
		local innerscale = FU/2
		
		if player.ptsr.vote_selectanim then
			local div = FU - FixedDiv(player.ptsr.vote_selectanim*FU, player.ptsr.vote_selectanim_start*FU)

			innerscale = ease.outquart(div, 0, mapscale) 
		end
		
		local innerflag = V_50TRANS|V_ADD
		
		if player.ptsr.vote_alreadyvoted then
			panelpatch = v.cachePatch("PTSR_MAP_PANEL")
		end
		
		x = $ - FixedMul(mappatch.width*FU, mapscale)/2
		y = $ - FixedMul(mappatch.height*FU, mapscale)/2
		x = $ + x_offset
		
		panel_x = $ - FixedMul(panelpatch.width*FU, mapscale)/2
		panel_y = $ - FixedMul(panelpatch.height*FU, mapscale)/2
		panel_x = $ + x_offset
		
		inner_x = $ - FixedMul(innerpatch.width*FU, innerscale)/2
		inner_y = $ - FixedMul(innerpatch.height*FU, innerscale)/2
		inner_x = $ + x_offset
		
		if i > 2 then
			y = $ + 80*FU
			panel_y = $ + 80*FU
			inner_y = $ + 80*FU
		end
		
		v.drawScaled(x, y, mapscale, mappatch)
		
		if i == vote_selection then
			if player.ptsr.vote_alreadyvoted then
				v.drawScaled(inner_x, inner_y, innerscale, innerpatch, innerflag)
			end
			
			v.drawScaled(panel_x, panel_y, mapscale, panelpatch)
		end
		
		if maprealname then
			v.drawString(x, y, maprealname, 0, "thin-fixed")
		end
		
		if mapact then
			v.drawString(x, y+(8*FU), "Act "..mapact, 0, "thin-fixed")
			v.drawString(x, y+(16*FU), "\x82"..gamemodename, 0, "thin-fixed")
		else
			v.drawString(x, y+(8*FU), "\x82"..gamemodename, 0, "thin-fixed")
		end
	end
end