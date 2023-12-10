addHook("ThinkFrame", do
	if gametype ~= GT_PTSPICER or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if PTSR.gameover and PTSR.intermission_tics == PTSR.intermission_act2 + 5*TICRATE then
		PTSR.vote_maplist = {
		{0,1},
		{0,1},
		{0,1}
		} -- votes, mapnumber
		local temp_maplist = {}
		local temp_selected_maplist = {}
		
		for i=1,1035 do
			if mapheaderinfo[i] and (mapheaderinfo[i].typeoflevel & TOL_PTSR) 
			and not mapheaderinfo[i].hidefromvote then
				table.insert(temp_maplist,i)
			end
		end
		
		for i=1,3 do
			local chosen = P_RandomRange(1,#temp_maplist)
			table.insert(temp_selected_maplist,temp_maplist[chosen])
			table.remove(temp_maplist,chosen)
		end
		
		temp_maplist = {} -- clear leftover maps (idk)
		
		for i=1,#temp_selected_maplist do
			PTSR.vote_maplist[i][2] = temp_selected_maplist[i]
			print(mapheaderinfo[temp_selected_maplist[i]].lvlttl)
		end
		
		S_StartSound(nil,sfx_s3kb3)
		
		S_ChangeMusic("P_INT", true)
		mapmusname = "P_INT"
	end
end)