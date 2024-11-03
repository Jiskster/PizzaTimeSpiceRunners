PTSR.results_act1 = 3*TICRATE + 24 -- Fading to black
PTSR.results_act2 = 5*TICRATE + 23 -- Spinning Rank (Anticipation..)
PTSR.results_act3 = 1*TICRATE + 29 -- Shaking Rank (Last note held)
PTSR.results_act4 = 5*TICRATE -- cymbals (tschhh..) and moment of silence....
--PTSR.results_vote_end = PTSR.results_act2_end + CV_PTSR.voteseconds.value*TICRATE


function PTSR.inVoteScreen()
	return (PTSR.vote_screen == true)
end

function PTSR.isVoteOver()
	return (PTSR.vote_screen == true) and (not PTSR.vote_timeleft)
end

function PTSR.InitVoteScreen()
	local levelsinvote = 4
	
	PTSR.vote_maplist = {}  -- votes, mapnumber
	
	for i=1,levelsinvote do
		table.insert(PTSR.vote_maplist, {votes = 0, mapnum = 1, gamemode = 1})
	end
	
	local temp_maplist = {} -- maps that have ptsr TOL_ and not hidden
	local temp_selected_maplist = {} -- few maps
	
	-- get every map that is ptsr and not hidden
	for i=1,1035 do
		if mapheaderinfo[i] and (mapheaderinfo[i].typeoflevel & TOL_PTSR) 
		and not mapheaderinfo[i].ptsr_hidden then
			table.insert(temp_maplist,i)
		end
	end
	
	-- choose a select few maps.
	for i=1,levelsinvote do
		local chosen = P_RandomRange(1,#temp_maplist)
		table.insert(temp_selected_maplist,temp_maplist[chosen])
		table.remove(temp_maplist,chosen)
	end
	
	for i=1,#temp_selected_maplist do
		PTSR.vote_maplist[i].mapnum = temp_selected_maplist[i]
		PTSR.vote_maplist[i].gamemode = P_RandomRange(1,#PTSR.gamemode_list)
	end

	for player in players.iterate do 
		player.ptsr.vote_selection = P_RandomRange(1,levelsinvote)
	end
	
	S_StartSound(nil,sfx_s3kb3)
	
	S_ChangeMusic("P_INT", true)
	mapmusname = "P_INT"
	
	PTSR.vote_timeleft = CV_PTSR.voteseconds.value*TICRATE
	PTSR.vote_screen = true
end

local function RegisterVoteScreenInput(player, cmd)
	if (cmd.buttons & BT_JUMP) then
		if not player.ptsr.vote_pressed then
			if not player.ptsr.vote_alreadyvoted then
				S_StartSound(nil, sfx_s1a1, player)
				player.ptsr.vote_selectanim = player.ptsr.vote_selectanim_start
				player.ptsr.vote_mapstats = {
					mapnum = PTSR.vote_maplist[player.ptsr.vote_selection].mapnum,
					gamemode = PTSR.vote_maplist[player.ptsr.vote_selection].gamemode,
				}
				player.ptsr.vote_alreadyvoted = true
			end
			
			player.ptsr.vote_pressed = true
		end
	else
		player.ptsr.vote_pressed = false
	end
	
	if (cmd.buttons & BT_SPIN) then
		if not player.ptsr.vote_unpressed then
			if player.ptsr.vote_alreadyvoted then
				S_StartSound(nil, sfx_s3k72, player) 
				player.ptsr.vote_mapstats = {}
				player.ptsr.vote_alreadyvoted = false
			end
			
			player.ptsr.vote_unpressed = true
		end
	else
		player.ptsr.vote_unpressed = false
	end
	
	if not player.ptsr.vote_alreadyvoted then 
		if (cmd.forwardmove > 40) then
			if not player.ptsr.vote_up then
				S_StartSound(nil, sfx_s3kb7, player)
			
				if player.ptsr.vote_selection - 2 > 0 then
					player.ptsr.vote_selection = max(1, $ - 2)
				end
			
				player.ptsr.vote_up = true
			end
		else
			player.ptsr.vote_up = false
		end
		
		if (cmd.forwardmove < -40) then
			if not player.ptsr.vote_down then
				S_StartSound(nil, sfx_s3kb7, player)
			
				if player.ptsr.vote_selection + 2 <= 4 then
					player.ptsr.vote_selection = min($ + 2, 4)
				end
			
				player.ptsr.vote_down = true
			end
		else
			player.ptsr.vote_down = false
		end
		
		if (cmd.sidemove < -40) then
			if not player.ptsr.vote_left then
				S_StartSound(nil, sfx_s3kb7, player)
			
				if player.ptsr.vote_selection - 1 > 0 then
					player.ptsr.vote_selection = max(1, $ - 1)
				end
			
				player.ptsr.vote_left = true
			end
		else
			player.ptsr.vote_left = false
		end
		
		if (cmd.sidemove > 40) then
			if not player.ptsr.vote_right then
				S_StartSound(nil, sfx_s3kb7, player)
			
				if player.ptsr.vote_selection + 1 <= 4 then
					player.ptsr.vote_selection = min($ + 1, 4)
				end
			
				player.ptsr.vote_right = true
			end
		else
			player.ptsr.vote_right = false
		end
	end
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
	if not PTSR.IsPTSR() or gamestate ~= GS_LEVEL then return end --stop the trolling

	if PTSR.inVoteScreen() then
		if not PTSR.isVoteOver() then
			PTSR.vote_timeleft = $ - 1

			if not PTSR.vote_timeleft then
				for player in players.iterate do
					if not player.ptsr then continue end
					
					if player.ptsr.vote_alreadyvoted 
					and player.ptsr.vote_mapstats["mapnum"] ~= nil
					and player.ptsr.vote_mapstats["gamemode"] ~= nil then
						local vote_multi = 1
						
						if player.ptsr.isWinner then
							vote_multi = $ + 1
						end
						
						for i=1,vote_multi do
							table.insert(PTSR.vote_roulettelist, {
								mapnum = player.ptsr.vote_mapstats["mapnum"],
								gamemode = player.ptsr.vote_mapstats["gamemode"],
								voter_info = {
									name = player.name,
									skin = skins[player.skin].name,
									skincolor = player.skincolor,
								}
							})
						end
					end
				end
				
				if #PTSR.vote_roulettelist then -- setup roulette
					PTSR.vote_roulette_ticspeed = P_RandomRange(1,2)
					PTSR.vote_roulette_ticsleft = PTSR.vote_roulette_ticspeed
					PTSR.vote_roulette_turnsleft = P_RandomRange(60,75)
					PTSR.vote_routette_ticspeed_turnsleft = PTSR.vote_routette_ticspeed_turnsleft_start
				else -- no votes? go random bro
					S_StartSound(nil, sfx_s3kb3)
				
					PTSR.vote_roulette_tictilmapswitch = 5*TICRATE
					PTSR.vote_finalpick = PTSR.vote_maplist[P_RandomRange(1,#PTSR.vote_maplist)]
					
					PTSR.nextgamemode = 1
					
					print("\x82"..G_BuildMapTitle(PTSR.vote_finalpick.mapnum).. " was picked as the next map!")
				end
			end
		else
			if PTSR.vote_roulette_ticsleft 
			and PTSR.vote_roulette_turnsleft 
			and (not PTSR.vote_finalpick) and 
			(not PTSR.vote_roulette_tictilmapswitch) then
				PTSR.vote_roulette_ticsleft = $ - 1
			
				if not PTSR.vote_roulette_ticsleft then -- when next selection/when tumbler sound
					if PTSR.vote_routette_ticspeed_turnsleft then
						PTSR.vote_routette_ticspeed_turnsleft = $ - 1
						
						if not PTSR.vote_routette_ticspeed_turnsleft then
							PTSR.vote_roulette_ticspeed = $ + P_RandomRange(2,4) -- lower selection speed
							PTSR.vote_routette_ticspeed_turnsleft = PTSR.vote_routette_ticspeed_turnsleft_start
						end
					end
					
					PTSR.vote_roulette_turnsleft = $ - 1
					
					if PTSR.vote_roulette_turnsleft then -- keep on going
						S_StartSound(nil, sfx_s3kb7)
						PTSR.vote_roulette_ticsleft = PTSR.vote_roulette_ticspeed
						PTSR.vote_routette_selection = ((($+1)-1)%#PTSR.vote_roulettelist)+1
					else -- its over bro
						S_StartSound(nil, sfx_s3kb3)
						
						PTSR.vote_roulette_tictilmapswitch = 5*TICRATE
						PTSR.vote_finalpick = PTSR.vote_roulettelist[PTSR.vote_routette_selection]
						
						PTSR.nextgamemode = PTSR.vote_finalpick.gamemode
						
						print("\x82"..G_BuildMapTitle(PTSR.vote_finalpick.mapnum).. " was picked as the next map!")
					end
				end
			end
		end
		
		if PTSR.vote_roulette_tictilmapswitch and PTSR.vote_finalpick then
			PTSR.vote_roulette_tictilmapswitch = $ - 1
			
			if not PTSR.vote_roulette_tictilmapswitch then
				if isserver then
					COM_BufInsertText(server, "map "..PTSR.vote_finalpick.mapnum.." -f")
				end
			end
		end
	end
end)

addHook("PreThinkFrame", function()
	if not PTSR.IsPTSR() then return end
	if not (PTSR.inVoteScreen()) then return end
	
	for player in players.iterate do
		local cmd = player.cmd
		
		if player.ptsr.vote_selectanim then
			player.ptsr.vote_selectanim = max(0, $ - 1)
		end
		
		if not PTSR.isVoteOver() then
			RegisterVoteScreenInput(player, cmd)
		end
		
		cmd.buttons = 0
		cmd.forwardmove = 0
		cmd.sidemove = 0	
	end
end)