local intermission_hud = function(v, player)
	local i_tic = PTSR.gameover_tics
	if not PTSR.gameover then return end
	
	local p_rank = (player.ptsr.rank == "P") or (player.ptsr.deathrank == "P")
	
	local q_rank = v.cachePatch("PTSR_RANK_UNK")
	
	
	--print(PTSR.endscreen_phase_tics)
	--v.fadeScreen(0xFF00, min(fadetween, 31))
	-- Fadings
	if PTSR.endscreen_phase == 1 then -- Fading to black
		local div = min(FU - FixedDiv(PTSR.endscreen_phase_tics*FU, PTSR.results_act1*FU), FU) -- slowly fade to black
		local fadetween = clamp(0, ease.linear(div, 0, 31), 31)
		v.fadeScreen(0xFF00, min(fadetween, 31))
	elseif PTSR.endscreen_phase == 4 then -- Quick white fade in
		local fadewhite_max = 31
		local fadewhite_tics = min(PTSR.results_act4 - PTSR.endscreen_phase_tics, fadewhite_max) -- 2nd fade
		local fadewhite_div = FixedDiv(fadewhite_tics*FU, fadewhite_max*FU)
		local fadewhite_output = ease.linear(fadewhite_div, fadewhite_max, 0) -- black to white
		
		v.drawFill(0,0,v.width(),v.height(),
			fadewhite_output|V_SNAPTOLEFT|V_SNAPTOTOP
		)
	else
		for i=1,2 do
			v.fadeScreen(0xFF00, 31)
		end
	end
	
	if PTSR:inVoteScreen() then
		PTSR.drawIntermissionBackground(v) -- Draw Vote Background
		
		PTSR.drawVoteScreenTimer(v)
		
		PTSR.drawVoteScreenMaps(v, player)
	end
	
	-- Reveal the rank.
	if PTSR.endscreen_phase >= 3 then
		q_rank = PTSR.r2p(v,player.ptsr.deathrank or player.ptsr.rank)
	end
	
	--p_rank
	if p_rank and skins[player.skin].sprites[SPR2_RUN_].numframes then
		PTSR.draw_p_rank_animation(v, player)
	end
	
	local diff = min(PTSR.results_act4 - PTSR.endscreen_phase_tics, 20)
	local div3 = FixedDiv(diff*FU, 20*FU)
	
	-- for game results popping in
	if PTSR.endscreen_phase == 4 then
		local zonenametween = ease.outquint(div3, -100*FU, 10*FU)
		local scoretween = ease.outquint(div3, 500*FU, 100*FU)
		local lapstween = ease.outquint(div3, 500*FU, 80*FU)
		
		local patch = v.getSprite2Patch(player.skin, "XTRA", false, B, 0) -- big ol' css
		local scale = FU*3/2
		
		local patchwidth = patch.width*scale
		local patchheight = patch.height*scale

		local x1,y1 = 160*FU,zonenametween
		local x2,y2 = 300*FU,scoretween
		local x3,y3 = 160*FU,180*FU
		local x4,y4 = 300*FU,lapstween
		local x5,y5 = ease.outquint(div3, -patchwidth, -patchheight/3),(200*FU/2)-(patchheight/2)

		v.drawScaled(x5, y5, scale, patch, V_SNAPTOLEFT)
		
		customhud.CustomFontString(v, x1, y1, G_BuildMapTitle(gamemap), "PTFNT", nil, "center", FRACUNIT/2)
		customhud.CustomFontString(v, x2, y2, "SCORE: "..(player.ptsr.deathscore or player.score), "PTFNT", nil, "right", FRACUNIT/2, SKINCOLOR_BLUE)
		customhud.CustomFontString(v, x4, y4, "LAPS: "..(player.ptsr.deathlaps or player.ptsr.laps), "PTFNT", nil, "right", FRACUNIT/2, SKINCOLOR_BLUE)
		
		--customhud.CustomFontString(v, x3, y3, "STILL WORKING ON RANK SCREEN!", "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_RED)
	end

	-- Rank Drawing
	if PTSR.endscreen_phase >= 2 and PTSR.endscreen_phase <= 4 then
		local shakex = 0
		local shakey = 0
		
		if PTSR.endscreen_phase == 3 then
			local rankshake_max_tics = 20
			local rankshake_max_strength = 10
			local rankshake_diff = min(PTSR.results_act3 - PTSR.endscreen_phase_tics, rankshake_max_tics) -- Rank shaking value
			local rankshake_div = FixedDiv(rankshake_diff*FU, rankshake_max_tics*FU)
			local rankshake = ease.outexpo(rankshake_div, rankshake_max_strength, 0)
			
			shakex = v.RandomRange(-rankshake,rankshake)
			shakey = v.RandomRange(-rankshake,rankshake)
		end
		
		local div2 = FRACUNIT -- for spinning rank (act 2)
		
		local rock = 0 -- how far the rank is away from center
		
		if PTSR.endscreen_phase == 2 then
			local diff = (PTSR.results_act2-PTSR.endscreen_phase_tics) -- goes up
			div2 = min(FixedDiv(diff*FU, PTSR.results_act2*FU), FRACUNIT)
			rock = max(0, PTSR.endscreen_phase_tics)
		end
		
		local sizetween = ease.linear(div2, FRACUNIT/64, FRACUNIT/2)
		local turntween = ease.inexpo(div2, 0, PTSR.results_act2*FU)

		local turnx = sin(turntween*1800)*rock
		local turny = cos(turntween*1800)*rock
		
		local ranktween = 160*FU -- for act 4
		
		if PTSR.endscreen_phase == 4 then
			ranktween = ease.outquint(div3, 160*FU, 280*FU) -- act 4
		end
		
		v.drawScaled(ranktween - turnx + (shakex*FU), 60*FU - turny + (shakey*FU), sizetween, q_rank)
	end
		
	/*
	elseif not PTSR:isVoteOver() then
		local vote_timeleft = (PTSR.results_vote_end - i_tic)/TICRATE
		if #PTSR.vote_maplist ~= CV_PTSR.levelsinvote.value then return end
		
		for i=1, CV_PTSR.levelsinvote.value do
			-- current_ = thing in current loop
			local act_vote = clamp(0, i_tic - PTSR.results_act2_end - (i*4), 35)
			local act_vote_div = clamp(0, FixedDiv(act_vote*FU, 35*FU), 35*FU)
			local act_vote_tween = ease.outexpo(act_vote_div, 500*FU, 200*FU)
			local map_y = 15*FU+((i-1)*30*FU)	
			local current_map = PTSR.vote_maplist[i]
			local current_map_icon = v.cachePatch(G_BuildMapName(current_map.mapnum).."P")
			local current_map_name = mapheaderinfo[current_map.mapnum].lvlttl
			local current_map_act = mapheaderinfo[current_map.mapnum].actnum
			local current_gamemode = current_map.gamemode or 1
			local current_gamemode_info = PTSR.gamemode_list[current_gamemode]
			local current_gamemode_name = current_gamemode_info.name or "Unnamed"
			
			local cursor_patch = v.cachePatch("SLCT1LVL")
			local cursor_patch2 = v.cachePatch("SLCT2LVL")
			local size = FU/4
			local mapoffset = FU*8
			
			v.drawScaled(act_vote_tween, map_y, size, current_map_icon, V_SNAPTORIGHT)
			
			-- Selection Flicker Code
			if player.ptvote_selection == i then
				if (player.ptvote_voted)
					v.drawScaled(act_vote_tween, map_y, size,cursor_patch, V_SNAPTORIGHT)
				else
					if ((leveltime/4)%2 == 0) then 
						v.drawScaled(act_vote_tween, map_y, size,cursor_patch, V_SNAPTORIGHT) 
					else
						v.drawScaled(act_vote_tween, map_y, size,cursor_patch2, V_SNAPTORIGHT) 
					end
				end
			end
			
			-- Map Act
			if current_map_act then
				mapoffset = FU*4
				v.drawString(act_vote_tween+(FU*40), map_y+(FU*9)+mapoffset, "Act "..current_map_act, V_SNAPTORIGHT, "thin-fixed")
			end
			
			-- Map Name
			v.drawString(act_vote_tween+(FU*40), map_y+mapoffset, current_map_name, V_SNAPTORIGHT, "thin-fixed")
			
			if multiplayer and current_gamemode then
				v.drawString(act_vote_tween, map_y, current_gamemode_name, V_SNAPTORIGHT, "small-thin-fixed")
			end
					
			-- Map Votes
			customhud.CustomFontString(v, act_vote_tween-(FU*16), map_y+(FU*4), tostring(PTSR.vote_maplist[i].votes), "PTFNT", V_SNAPTORIGHT, "center", FRACUNIT/2, SKINCOLOR_WHITE)
		end
		
		-- Time Left
		customhud.CustomFontString(v, 160*FU, 10*FU, tostring(vote_timeleft), "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_PINK)
	else
		local chosen_map_icon = v.cachePatch(G_BuildMapName(PTSR.nextmapvoted).."P")
		customhud.CustomFontString(v, 160*FU, 10*FU, G_BuildMapTitle(PTSR.nextmapvoted).." WINS!", "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_YELLOW)
		v.drawScaled(120*FU, 75*FU, FU/2, chosen_map_icon)
	end	
	*/
end

customhud.SetupItem("PTSR_intermission", ptsr_hudmodname, intermission_hud, "game", 1)