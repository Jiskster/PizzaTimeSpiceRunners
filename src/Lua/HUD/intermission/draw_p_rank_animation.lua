PTSR.draw_p_rank_animation = function(v, player)
	local i_tic = PTSR.endscreen_tics

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