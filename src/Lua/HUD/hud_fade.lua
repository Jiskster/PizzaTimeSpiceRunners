local fade_hud = function(v, player)
	--local t_part1 = 324 -- the end tic of the first scene of the music
	--local t_part2 = 388
	
	local i_tic = PTSR.intermission_tics
	if not PTSR.gameover then return end
	
	local div = min(FixedDiv(i_tic*FU, 129*FRACUNIT), FRACUNIT)
	local div2 = min(FixedDiv(i_tic*FU, PTSR.intermission_act1*FRACUNIT),FRACUNIT)
	local div3 -- go down for div3
		
	local c1 = clamp(0, (PTSR.intermission_act1 + 10) - i_tic, 10); 
	local c2 = clamp(0, (PTSR.intermission_act2 + 20) - i_tic, 20); 
	local c3 = clamp(0, (PTSR.intermission_act_end + 20) - i_tic, 20);
	local c4 = clamp(0, (PTSR.intermission_act2 + 31) - i_tic, 31); -- 2nd fade
	local c5 = clamp(0, (PTSR.intermission_act_end + 10) - i_tic, 9); -- 3rd fade
	
	div3 = min(FixedDiv(c2*FU, 20*FRACUNIT),FRACUNIT)
	
	local fadetween = clamp(0, ease.linear(div, 0, 31), 31)
	local sizetween = ease.linear(div2, FRACUNIT/64, FRACUNIT/2)
	local turntween = ease.inexpo(div2, 0, PTSR.intermission_act1*FU)
	local zonenametween = ease.inquint(div3, 10*FU, -100*FU)
	local scoretween = ease.inquint(div3, 100*FU, 500*FU)
	local rock = PTSR.intermission_act1-(turntween/FU)
	rock = max(0, $)
	
	local turnx = sin(turntween*1800)*rock/2
	local turny = cos(turntween*1800)*rock/2
	
	v.fadeScreen(0xFF00, min(fadetween, 31))
	
	if i_tic < PTSR.intermission_act2 then
		v.fadeScreen(0xFF00, min(fadetween, 31))
	else
		v.drawFill(0,0,v.width(),v.height(),
			c4|V_SNAPTOLEFT|V_SNAPTOTOP
		)
	end
	
	if PTSR:inVoteScreen() then
		--thank you luigi for this code :iwantsummadat:
		--drawfill my favorite :kindlygimmesummadat:
		
		v.drawFill(0,0,v.width(),v.height(),
			--even if there is tearing, you wont see the black void
			skincolors[SKINCOLOR_PURPLE].ramp[15]|V_SNAPTOLEFT|V_SNAPTOTOP|c5<<V_ALPHASHIFT
		)
		
		--need the scale before the loops
		local s = FU
		local bgp = v.cachePatch("PTSR_SECRET_BG")
		--this will overflow in 15 minutes + some change
		local timer = FixedDiv(leveltime*FU,2*FU) or 1
		local bgoffx = FixedDiv(timer,2*FU)%(bgp.width*s)
		local bgoffy = FixedDiv(timer,2*FU)%(bgp.height*s)
		for i = 0,(v.width()/bgp.width)+1
			for j = 0,(v.height()/bgp.height)+1
				--Complicated
				local x = 300
				local y = bgp.height*(j-1)
				local f = V_SNAPTORIGHT|V_SNAPTOTOP|c5<<V_ALPHASHIFT
				local c = v.getColormap(nil,pagecolor)
				
				v.drawScaled(((x-bgp.width*(i-1)))*s-bgoffx,(y)*s+bgoffy,s,bgp,f,c)
				v.drawScaled(((x-bgp.width*i))*s-bgoffx,(y)*s+bgoffy,s,bgp,f,c)
			end
		end
	end
	
	local q_rank = v.cachePatch("PTSR_RANK_UNK")
	
	if i_tic > PTSR.intermission_act1 then
		q_rank = PTSR.r2p(v,player.ptsr_rank)
	end
	
	local shakex = i_tic > PTSR.intermission_act1 and v.RandomRange(-c1/2,c1/2) or 0 
	local shakey = i_tic > PTSR.intermission_act1 and v.RandomRange(-c1/2,c1/2) or 0
	
	if i_tic >= PTSR.intermission_act_end then
		zonenametween = ease.inquint(div3, 10*FU, -100*FU)
		scoretween = ease.inquint(div3, 100*FU, 500*FU)
	end
	
	if i_tic < PTSR.intermission_act_end then
		if i_tic >= PTSR.intermission_act2  then
			local x1,y1 = 160*FU,zonenametween
			local x2,y2 = 160*FU,scoretween
			local x3,y3 = 160*FU,180*FU
			customhud.CustomFontString(v, x1, y1, G_BuildMapTitle(gamemap), "PTFNT", nil, "center", FRACUNIT/2)
			customhud.CustomFontString(v, x2, y2, "SCORE: "..(player.pt_endscore or player.score), "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_BLUE)
			
			customhud.CustomFontString(v, x3, y3, "STILL WORKING ON RANK SCREEN!", "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_RED)
		end
	
		v.drawScaled(160*FRACUNIT - turnx + (shakex*FU), 60*FRACUNIT - turny + (shakey*FU), sizetween, q_rank)
	elseif not PTSR:isVoteOver() then
		local vote_timeleft = (PTSR.intermission_vote_end - i_tic)/TICRATE
		if #PTSR.vote_maplist ~= CV_PTSR.levelsinvote.value then return end
		
		for i=1, CV_PTSR.levelsinvote.value do
			-- current_ = thing in current loop
			local act_vote = clamp(0, i_tic - PTSR.intermission_act_end - (i*4), 35)
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
			
			if current_gamemode then
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
	
end

customhud.SetupItem("PTSR_fade", ptsr_hudmodname, fade_hud, "game", 1)