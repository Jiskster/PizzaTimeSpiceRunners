local tooltips_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	local count = PTSR_COUNT()
	--local practicemodetext = "\x84\* PRACTICE MODE *"
	local infinitelapstext = tostring(player.ptsr.laps)
	local lapstext = "\x82\* LAPS: "..player.ptsr.laps.." / "..PTSR.maxlaps.." *"
	
	local pthud_offset = -8*FU
	local div = ( (FU) / (pthud_expectedtime) )*PTSR.pizzatime_tics
	local ese = PTSR.pizzatime_tics < pthud_expectedtime and
	ease.linear(div, pthud_start_pos+pthud_offset, pthud_finish_pos+pthud_offset) or pthud_finish_pos+pthud_offset
	-- y axis tween
	
	-- hi saxa here BAR GO DOWN
	local time_offset = 60
	if not multiplayer and PTSR.timeover_tics >= time_offset then
		local tween = (PTSR.timeover_tics-time_offset)*FU/pthud_expectedtime
		ese = tween < FU and ease.linear(tween, pthud_finish_pos+pthud_offset, (200*FU)+pthud_offset) or (200*FU)+pthud_offset
	end


	if (not player.ptsr.pizzaface) and (player.ptsr.outofgame) and (player.playerstate ~= PST_DEAD) 
	and not (player.ptsr.laps >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value) and not PTSR.gameover then
		if not player.hold_newlap then
			v.drawString(160, 120, "\x85\* Hold FIRE to try a new lap! *", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		else
			local percentage = (FixedDiv(player.hold_newlap*FRACUNIT, PTSR.laphold*FRACUNIT)*100)/FRACUNIT
			v.drawString(160, 120, "\x85\* CHARGING \$percentage\% *", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		end
	end

	if PTSR.pizzatime then
		/*
		if (count.active == 1 and multiplayer) then -- practice mode
			v.drawString(165*FU, ese-(FU*8), practicemodetext , V_SNAPTOBOTTOM, "thin-fixed-center")
		end
		*/
		
		if player.ptsr.pizzaface then
			if player.realmo.pfstuntime then
				v.drawString(160, 100, "You will be unfrozen in: "..player.realmo.pfstuntime/TICRATE.. " seconds.", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
			end
		
			if player.pizzachargecooldown then
				v.drawString(165, 157, "\x85\* COOLING DOWN *", V_SNAPTOBOTTOM, "thin-center")
			elseif player.pizzacharge then
				local percentage = (FixedDiv(player.pizzacharge*FRACUNIT, 35*FRACUNIT)*100)/FRACUNIT
				
				v.drawString(165, 157, "\x85\* CHARGING \$percentage\% *", V_SNAPTOBOTTOM, "thin-center")
			else
				v.drawString(165, 157, "\x85\* HOLD FIRE TO TELEPORT *", V_SNAPTOBOTTOM, "thin-center")
			end
		end
		
		-- Early returns start here, no pizza face code allowed beyond here --
		if player.ptsr.pizzaface then return end
		
		local lapflag_name = "PTSR_LAPFLAG"
		lapflag_name = $ .. "_A" .. tostring((leveltime/2)%12)
		local lapflag_patch = v.cachePatch(lapflag_name)
		v.drawScaled(148*FU, ese-(FU*12), FU/2, lapflag_patch, V_PERPLAYER|V_SNAPTOBOTTOM)
		
		if CV_PTSR.default_maxlaps.value then
			v.drawString(165*FU, ese-(FU*4), lapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-fixed-center")
		else -- infinite laps
			customhud.CustomFontString(v, 165*FU, ese-(FU*6), infinitelapstext, "SMNPT", V_PERPLAYER|V_SNAPTOBOTTOM, "center", FRACUNIT/2, SKINCOLOR_YELLOW)
			--v.drawString(165*FU, ese-(FU*4), infinitelapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-fixed-center")
		end
	end
end

customhud.SetupItem("PTSR_tooltips", ptsr_hudmodname, tooltips_hud, "game", 0)