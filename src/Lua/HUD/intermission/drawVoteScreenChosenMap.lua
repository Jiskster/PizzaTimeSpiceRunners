function PTSR.drawVoteScreenChosenMap(v)
	if PTSR.vote_finalpick then
		if PTSR.vote_finalpick.mapnum and PTSR.vote_finalpick.gamemode then
			local x = 160*FU
			local y = 100*FU
			
			local text1_y = 20*FU
			local text2_y = text1_y + 16*FU
			
			local mapnum = PTSR.vote_finalpick.mapnum
			local mappatch = v.cachePatch(G_BuildMapName(mapnum).."P")
			local player_name = PTSR.vote_finalpick.voter_info.name
			
			local mapscale = FU/2
			
			x = $ - FixedMul(mappatch.width*FU, mapscale)/2
			y = $ - FixedMul(mappatch.height*FU, mapscale)/2
			
			customhud.CustomFontString(v, 160*FU, text1_y, G_BuildMapTitle(mapnum), "PTFNT", V_SNAPTOTOP, "center", FRACUNIT/2, SKINCOLOR_YELLOW)
			customhud.CustomFontString(v, 160*FU, text2_y, "VOTE WINNER: "..player_name, "PTFNT", V_SNAPTOTOP, "center", FRACUNIT/2, SKINCOLOR_GREEN)
			
			v.drawScaled(x, y, mapscale, mappatch)
		end
	end
end