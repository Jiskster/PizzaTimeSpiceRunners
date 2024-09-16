PTSR.intermission_act1 = 324 -- last drum beat of the music
PTSR.intermission_act2 = 388 -- cymbals (tschhh..)
PTSR.intermission_act_end = PTSR.intermission_act2 + 5*TICRATE
PTSR.intermission_vote_end = PTSR.intermission_act_end + CV_PTSR.voteseconds.value*TICRATE


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
	if not PTSR.IsPTSR() or gamestate ~= GS_LEVEL then return end --stop the trolling
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
	local levelsinvote = CV_PTSR.levelsinvote.value

	if not PTSR.IsPTSR() or gamestate ~= GS_LEVEL then return end --stop the trolling
	
	if PTSR.gameover and PTSR.intermission_tics == PTSR.intermission_act_end then
		PTSR.vote_maplist = {}  -- votes, mapnumber
		
		for i=1,levelsinvote do
			table.insert(PTSR.vote_maplist, {votes = 0, mapnum = 1, gamemode = 1})
		end
		
		local temp_maplist = {}
		local temp_selected_maplist = {}
		
		for i=1,1035 do
			if mapheaderinfo[i] and (mapheaderinfo[i].typeoflevel & TOL_PTSR) 
			and not mapheaderinfo[i].ptsr_hidden then
				table.insert(temp_maplist,i)
			end
		end
		
		for i=1,levelsinvote do
			local chosen = P_RandomRange(1,#temp_maplist)
			table.insert(temp_selected_maplist,temp_maplist[chosen])
			table.remove(temp_maplist,chosen)
		end
		
		for i=1,#temp_selected_maplist do
			-- assign gamemodes
			local newgamemode = 1
			local coremodes = {} -- EX: {1,2}
			if multiplayer then
				for i,v in pairs(PTSR.coremodes) do
					if v == true then
						table.insert(coremodes, i)
					end
				end
				
				local gamemode_fromcoremodes = P_RandomRange(1,#coremodes) -- coremode range
				newgamemode = coremodes[gamemode_fromcoremodes] 
			
				if P_RandomChance(FU/3) then
					if #PTSR.gamemode_list > #coremodes then
						newgamemode = P_RandomRange(#coremodes + 1, #PTSR.gamemode_list)
					end
				end
				
				if not multiplayer then
					newgamemode = 1
				end
			end
			
			-- set mapvote var
			PTSR.vote_maplist[i].mapnum = temp_selected_maplist[i]
			PTSR.vote_maplist[i].gamemode = tonumber(newgamemode)

			print(G_BuildMapTitle(temp_selected_maplist[i]))
		end
		
		for player in players.iterate do 
			player.ptvote_selection = P_RandomRange(1,levelsinvote)
		end
		
		S_StartSound(nil,sfx_s3kb3)
		
		S_ChangeMusic("P_INT", true)
		mapmusname = "P_INT"
	end
	
	if PTSR.intermission_tics == PTSR.intermission_vote_end then
		local sorted_votes = PTSR_shallowcopy(PTSR.vote_maplist) -- table
		local raw_votes = {} -- just the votes numbers
		
		table.sort(sorted_votes,function(a,b) return a.votes > b.votes end)
		
		for i=1,#sorted_votes do
			raw_votes[i] = sorted_votes[i].votes
		end
		
		if allequals(unpack(raw_votes))
			local chosenmap = P_RandomRange(1,levelsinvote)
			
			print("\x82"..G_BuildMapTitle(sorted_votes[chosenmap].mapnum).. " was picked as the next map with a tie with all maps!")
			PTSR.nextmapvoted = sorted_votes[chosenmap].mapnum 
			
			PTSR.nextmapvoted_info = sorted_votes[chosenmap]
		elseif sorted_votes[1].votes == sorted_votes[2].votes then
			local chosenmap = P_RandomRange(1,2)
			
			print("\x82"..G_BuildMapTitle(sorted_votes[chosenmap].mapnum).. " was picked as the next map with a two way tie!")
			PTSR.nextmapvoted = sorted_votes[chosenmap].mapnum
			
			PTSR.nextmapvoted_info = sorted_votes[chosenmap]
		else
			print("\x82"..G_BuildMapTitle(sorted_votes[1].mapnum).. " was picked as the next map!")
			PTSR.nextmapvoted = sorted_votes[1].mapnum
			
			PTSR.nextmapvoted_info = sorted_votes[1]
		end
		
		for i,v in ipairs(sorted_votes) do
			print(i..": "..G_BuildMapTitle(v.mapnum).. "["..v.votes.."]")
		end
		
		S_StartSound(nil, sfx_s3kb3)
		
		PTSR.nextgamemode = tonumber(PTSR.nextmapvoted_info.gamemode)
	end
	
	if PTSR.intermission_tics == PTSR.intermission_vote_end + 5*TICRATE then
		COM_BufInsertText(server, "map "..PTSR.nextmapvoted)
	end
end)

addHook("PreThinkFrame", function()
	for player in players.iterate do
		local cmd = player.cmd
		
		player.hold_newlap = $ or 0
		
		if player.ptsr.outofgame and not (player.ptsr.laps >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value) then 
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
					
						if player.ptvote_selection + 1 > CV_PTSR.levelsinvote.value then
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
							player.ptvote_selection = CV_PTSR.levelsinvote.value
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
				player.ptvote_selection = clamp(1,$,CV_PTSR.levelsinvote.value)
			else
				player.ptvote_selection = 1
			end
		end
		
		if PTSR:inVoteScreen() or player.ptsr.outofgame then
			cmd.buttons = 0
			cmd.forwardmove = 0
			cmd.sidemove = 0	
		end
	end
end)