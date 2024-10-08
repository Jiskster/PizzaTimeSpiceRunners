function PTSR.drawVoteScreenChosenMap(v)
	if PTSR.vote_finalpick then
		if PTSR.vote_finalpick.mapnum and PTSR.vote_finalpick.gamemode then
			local x = 160*FU
			local y = 100*FU
			
			local mapnum = PTSR.vote_finalpick.mapnum
			local mappatch = v.cachePatch(G_BuildMapName(mapnum).."P")
			
			local mapscale = FU/2
			
			x = $ - FixedMul(mappatch.width*FU, mapscale)/2
			y = $ - FixedMul(mappatch.height*FU, mapscale)/2
			
			customhud.CustomFontString(v, 160*FU, 20*FU, G_BuildMapTitle(mapnum).. "HAS BEEN CHOSEN!", "PTFNT", V_SNAPTOTOP, "center", FRACUNIT/2, SKINCOLOR_YELLOW)
			v.drawScaled(x, y, mapscale, mappatch)
		end
	end
end