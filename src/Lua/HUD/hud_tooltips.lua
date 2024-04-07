local tooltips_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	local count = PTSR_COUNT()
	local practicemodetext = "\x84\* PRACTICE MODE *"
	local infinitelapstext = "\x82\* LAPS: "..player.lapsdid.." *"
	local lapstext = "\x82\* LAPS: "..player.lapsdid.." / "..PTSR.maxlaps.." *"
	
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


	if (not player.pizzaface) and (player.ptsr_outofgame) and (player.playerstate ~= PST_DEAD) 
	and not (player.lapsdid >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value) and not PTSR.gameover then
		if not player.hold_newlap then
			v.drawString(160, 120, "\x85\* Hold FIRE to try a new lap! *", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		else
			local percentage = (FixedDiv(player.hold_newlap*FRACUNIT, PTSR.laphold*FRACUNIT)*100)/FRACUNIT
			v.drawString(160, 120, "\x85\* CHARGING \$percentage\% *", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		end
	end

	if PTSR.pizzatime then
		if (count.active == 1 and multiplayer) then -- practice mode
			v.drawString(165*FU, ese-(FU*8), practicemodetext , V_SNAPTOBOTTOM, "thin-fixed-center")
		end
		
		if player.pizzaface then
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
		if player.pizzaface then return end
		
		if CV_PTSR.default_maxlaps.value then
			v.drawString(165*FU, ese, lapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-fixed-center")
		else -- infinite laps
			v.drawString(165*FU, ese, infinitelapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-fixed-center")
		end
	end
end

customhud.SetupItem("PTSR_tooltips", ptsr_hudmodname, tooltips_hud, "game", 0)