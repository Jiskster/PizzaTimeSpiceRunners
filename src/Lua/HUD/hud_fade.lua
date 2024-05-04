local fade_hud = function(v, player)
	--local t_part1 = 324 -- the end tic of the first scene of the music
	--local t_part2 = 388
	
	local i_tic = PTSR.intermission_tics
	if not PTSR.gameover then return end
	
	local p_rank = (player.ptsr.rank == "P") or (player.ptsr.deathrank == "P")
	
	local div = min(FixedDiv(i_tic*FU, 129*FRACUNIT), FRACUNIT)
	local div2 = min(FixedDiv(i_tic*FU, PTSR.intermission_act1*FRACUNIT),FRACUNIT)
	local div3 -- go down for div3
		
	local c1 = clamp(0, (PTSR.intermission_act1 + 10) - i_tic, 10); 
	local c2 = clamp(0, (PTSR.intermission_act2 + 20) - i_tic, 20); 
	local c3 = clamp(0, (PTSR.intermission_act_end + 20) - i_tic, 20);
	local c4 = clamp(0, (PTSR.intermission_act2 + 31) - i_tic, 31); -- 2nd fade
	local c5 = clamp(0, (PTSR.intermission_act_end + 10) - i_tic, 9); -- 3rd fade
	
	div3 = min(FixedDiv(c2*FU, 20*FRACUNIT),FRACUNIT)
	
	local q_rank = v.cachePatch("PTSR_RANK_UNK")
	
	local fadetween = clamp(0, ease.linear(div, 0, 31), 31)
	local sizetween = ease.linear(div2, FRACUNIT/64, FRACUNIT/2)
	local turntween = ease.inexpo(div2, 0, PTSR.intermission_act1*FU)
	local zonenametween = ease.inquint(div3, 10*FU, -100*FU)
	local scoretween = ease.inquint(div3, 100*FU, 500*FU)
	local lapstween = ease.inquint(div3, 80*FU, 500*FU)
	local ranktween = ease.inquint(div3, 280*FU, 160*FU)
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
	
	if i_tic > PTSR.intermission_act1 then
		q_rank = PTSR.r2p(v,player.ptsr.deathrank or player.ptsr.rank)
	end
	
	local shakex = i_tic > PTSR.intermission_act1 and v.RandomRange(-c1/2,c1/2) or 0 
	local shakey = i_tic > PTSR.intermission_act1 and v.RandomRange(-c1/2,c1/2) or 0
	
	if p_rank then
		local s_width = v.width()/v.dupx()*FU
		local s_height = v.height()/v.dupy()*FU
		local runfr = leveltime % skins[player.skin].sprites[SPR2_RUN_].numframes
		local runspr = v.getSprite2Patch(player.skin, "RUN_", false, runfr, 3)
		
		local portal_up = 100
		local portal_up_end = 150
		
		local portal_down = 247
		local portal_down_end = 247+50
		
		local p_ri = 230
		local p_da = 245
		
		local p_ri_2 = 250
		local p_da_2 = 265
		
		local portaltime = max(0, min((i_tic-portal_up)*FU/(portal_up_end-portal_up), FU))
		local firsttime = max(0, min((i_tic-p_ri)*FU/(p_da-p_ri), FU))
		local secondtime = max(0, min((i_tic-p_ri_2)*FU/(p_da_2-p_ri_2), FU))

		local portal = v.cachePatch("PPORTAL"..tostring(leveltime % 3))
		local portal_scale = FU/3
		local p_width = portal.width*portal_scale
		local p_height = portal.height*portal_scale
		
		local portaltween = (i_tic >= portal_up and i_tic < portal_up_end)
		and ease.outquint(portaltime, -p_height*FU, (s_height-(10*FU)-p_height))
		or (s_height-(10*FU)-p_height)

		if i_tic >= portal_down then
			portaltime = max(0, min((i_tic-portal_down)*FU/(portal_down_end-portal_down), FU))

			portaltween = (i_tic >= portal_down and i_tic < portal_down_end)
			and ease.inquint(portaltime,
				(s_height-(10*FU)-p_height),
				-p_height*FU)
			or -p_height*FU
		end

		local firsttween = (i_tic >= p_ri and i_tic < p_da)
		and ease.linear(firsttime, 320*FU, 160*FU)
		or 160*FU

		local secondtween = (i_tic >= p_ri_2 and i_tic < p_da_2)
		and ease.linear(secondtime, s_width, -runspr.width*(FU*2))
		or -runspr.width*(FU*2)
		
		if i_tic >= portal_up and i_tic < portal_down_end then
			v.drawScaled(140*FU, portaltween, portal_scale, portal, V_SNAPTORIGHT|V_SNAPTOTOP)
		end
		
		if firsttime and i_tic < p_da then
			v.drawScaled(firsttween, 170*FU, FU/2, runspr, V_SNAPTOBOTTOM|V_SNAPTORIGHT, v.getColormap(nil,player.skincolor))
		end
		if secondtime and i_tic < p_da_2 then
			local scale = FU*2+(FU/2)
			local height = runspr.height*scale
			v.drawScaled(secondtween, 100*FU+(height/2), scale, runspr, V_SNAPTOLEFT, v.getColormap(nil,player.skincolor))
		end
	end
	
	if i_tic >= PTSR.intermission_act_end then
		zonenametween = ease.inquint(div3, 10*FU, -100*FU)
		scoretween = ease.inquint(div3, 100*FU, 500*FU)
	end
	
	if i_tic < PTSR.intermission_act_end then
		if i_tic >= PTSR.intermission_act2  then
			local patch = v.getSprite2Patch(player.skin, "XTRA", false, B, 0)
			local scale = FU*3/2
			
			local patchwidth = patch.width*scale
			local patchheight = patch.height*scale

			local x1,y1 = 160*FU,zonenametween
			local x2,y2 = 300*FU,scoretween
			local x3,y3 = 160*FU,180*FU
			local x4,y4 = 300*FU,lapstween
			local x5,y5 = ease.inquint(div3, -patchheight/3, -patchwidth),(200*FU/2)-(patchheight/2)
			v.drawScaled(x5, y5, scale, patch, V_SNAPTOLEFT, v.getColormap(nil,player.skincolor))
			
			customhud.CustomFontString(v, x1, y1, G_BuildMapTitle(gamemap), "PTFNT", nil, "center", FRACUNIT/2)
			customhud.CustomFontString(v, x2, y2, "SCORE: "..(player.ptsr.deathscore or player.score), "PTFNT", nil, "right", FRACUNIT/2, SKINCOLOR_BLUE)
			customhud.CustomFontString(v, x4, y4, "LAPS: "..(player.ptsr.deathlaps or player.ptsr.laps), "PTFNT", nil, "right", FRACUNIT/2, SKINCOLOR_BLUE)
			
			customhud.CustomFontString(v, x3, y3, "STILL WORKING ON RANK SCREEN!", "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_RED)
		end
	
		v.drawScaled(ranktween - turnx + (shakex*FU), 60*FRACUNIT - turny + (shakey*FU), sizetween, q_rank)
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
	
end

customhud.SetupItem("PTSR_fade", ptsr_hudmodname, fade_hud, "game", 1)