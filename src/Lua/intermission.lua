function PTSR:inVoteScreen()
	return PTSR.intermission_tics > PTSR.intermission_act_end
end

function PTSR:isVoteOver()
	return PTSR.intermission_tics > PTSR.intermission_vote_end
end

local function allequals(...)
	local args = {...}
	local success = true
	
	for i,v in ipairs(args)
		
		for ii,vv in ipairs(args)
			if v ~= vv then
				success = false
				break 2
			end
		end
	end
	
	return success
end

addHook("ThinkFrame", do
	if gametype ~= GT_PTSPICER or gamestate ~= GS_LEVEL then return end --stop the trolling
	if PTSR.gameover then
		P_SwitchWeather(0)
		for sector in sectors.iterate do
			S_StopSound(sector)
		end
	end
end)

addHook("MobjThinker", function(mobj)
	if PTSR.gameover and leveltime then
		mobj.flags = $ | MF_NOTHINK
		return true
	end
end)

addHook("ThinkFrame", do
	if gametype ~= GT_PTSPICER or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if PTSR.gameover and PTSR.intermission_tics == PTSR.intermission_act_end then
		PTSR.vote_maplist = {
			{votes = 0, mapnum = 1},
			{votes = 0, mapnum = 1},
			{votes = 0, mapnum = 1}
		}  -- votes, mapnumber
		
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
			PTSR.vote_maplist[i].mapnum = temp_selected_maplist[i]
			print(G_BuildMapTitle(temp_selected_maplist[i]))
		end
		
		for player in players.iterate do 
			player.ptvote_selection = P_RandomRange(1,3)
		end
		
		S_StartSound(nil,sfx_s3kb3)
		
		S_ChangeMusic("P_INT", true)
		mapmusname = "P_INT"
		
		
	end
	
	if PTSR.intermission_tics == PTSR.intermission_vote_end then
		local sorted_votes = PTSR_shallowcopy(PTSR.vote_maplist)

		table.sort(sorted_votes,function(a,b) return a.votes > b.votes end)
		
		if allequals(sorted_votes[1].votes,sorted_votes[2].votes,sorted_votes[3].votes)
			local chosenmap = P_RandomRange(1,3)
			
			print("\x82"..G_BuildMapTitle(sorted_votes[chosenmap].mapnum).. " was picked as the next map with a three way tie!")
			PTSR.nextmapvoted = sorted_votes[chosenmap].mapnum
		elseif sorted_votes[1].votes == sorted_votes[2].votes then
			local chosenmap = P_RandomRange(1,2)
			
			print("\x82"..G_BuildMapTitle(sorted_votes[chosenmap].mapnum).. " was picked as the next map with a two way tie!")
			PTSR.nextmapvoted = sorted_votes[chosenmap].mapnum
		else
			print("\x82"..G_BuildMapTitle(sorted_votes[1].mapnum).. " was picked as the next map!")
			PTSR.nextmapvoted = sorted_votes[1].mapnum
		end
		
		for i,v in ipairs(sorted_votes) do
			print(i..": "..G_BuildMapTitle(v.mapnum).. "["..v.votes.."]")
		end
		
		S_StartSound(nil, sfx_s3kb3)
	end
	
	if PTSR.intermission_tics == PTSR.intermission_vote_end + 5*TICRATE then
		COM_BufInsertText(server, "map "..PTSR.nextmapvoted)
	end
end)

addHook("PreThinkFrame", function()
	for player in players.iterate do
		local cmd = player.cmd
		
		if player.ptsr_outofgame and not (player.lapsdid >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value) then 
			if (player.cmd.buttons & BT_ATTACK) and not PTSR.gameover then
				player.hold_newlap = $ + 1
			else
				player.hold_newlap = 0
			end
		end
		
		if PTSR:inVoteScreen() and not PTSR:isVoteOver() then
		
			-- Selection Increment
			if not player.ptvote_voted then
				if cmd.forwardmove < -40 or cmd.sidemove > 40 then
					if not player.ptvote_down then
						S_StartSound(nil, sfx_s3kb7, player)
					
						if player.ptvote_selection + 1 > 3 then
							player.ptvote_selection = 1
						else
							player.ptvote_selection = $ + 1 
						end
						
						player.ptvote_down = true
					end
				else
					player.ptvote_down = false
				end
				
				-- Selection Decrement
				if cmd.forwardmove > 40 or cmd.sidemove < -40 then
					if not player.ptvote_up then
						S_StartSound(nil, sfx_s3kb7, player)
						
						if player.ptvote_selection - 1 < 1 then
							player.ptvote_selection = 3
						else
							player.ptvote_selection = $ - 1 
						end
						
						player.ptvote_up = true
					end
				else
					player.ptvote_up = false
				end
			end
			
			if cmd.buttons & BT_JUMP and not player.ptvote_voted then
				if not player.ptvote_votepressed then
					S_StartSound(nil, sfx_s1a1, player)  

					PTSR.vote_maplist[player.ptvote_selection].votes = $ + 1
					player.ptvote_voted = true
					player.ptvote_votepressed = true
				end
			else
				player.ptvote_votepressed = false
			end
			
			if cmd.buttons & BT_SPIN and player.ptvote_voted then
				if not player.ptvote_unvotepressed then
					S_StartSound(nil, sfx_s3k72, player) 

					PTSR.vote_maplist[player.ptvote_selection].votes = $ - 1
					player.ptvote_voted = false
					player.ptvote_unvotepressed = true
				end
			else
				player.ptvote_unvotepressed = false
			end
			
			if player.ptvote_selection then
				player.ptvote_selection = clamp(1,$,3)
			else
				player.ptvote_selection = 1
			end
		end
		
		if PTSR:inVoteScreen() or player.ptsr_outofgame then
			cmd.buttons = 0
			cmd.forwardmove = 0
			cmd.sidemove = 0	
		end
	end
end)