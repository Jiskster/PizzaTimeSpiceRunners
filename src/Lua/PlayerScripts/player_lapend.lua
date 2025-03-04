// TODO: Make DoLapBonus not call ChatLapStatus, and seperately use them when they're needed.

PTSR.ChatLapStatus = function(player)
	local lapstring = "\x82\*LAP ".. player.ptsr.laps.. " ("..player.name.." "..G_TicsToMTIME(player.ptsr.laptime, true)..")"
	local isonconsole = CV_PTSR.lapbroadcast_type.value == 1
	local isonchat = CV_PTSR.lapbroadcast_type.value == 2

	if isonconsole then
		print(lapstring)
	elseif isonchat then
		chatprint(lapstring, true)
	end
end

PTSR.DoLapBonus = function(player)
	local gm_metadata = PTSR.currentModeMetadata()
	local count = PTSR_COUNT()
	
	PTSR.ChatLapStatus(player)
	
	if player.ptsr.laps ~= nil then
		local escapebonus = true
		
		player.lapbonus = player.ptsr.laps * (gm_metadata.lapbonus or PTSR.lapbonus)
		player.ringbonus = player.ptsr.rings_on_lap * (gm_metadata.ringlapbonus or PTSR.ringlapbonus)
		
		if gm_metadata.core_endurance 
		and count.peppinos then
			if not PTSR.isOvertime() then
				PTSR.difficulty = $ + FixedDiv((FU/10), count.peppinos*FU)
			else
				PTSR.difficulty = $ + FixedDiv((FU/10)*4, count.peppinos*FU)
			end
		end
		
		if PTSR_DoHook("onbonus", player) then
			escapebonus = false
		end
		
		if PTSR_DoHook("onlapbonus", player) then
			player.lapbonus = 0
		end
		
		if PTSR_DoHook("onringbonus", player) then
			player.ringbonus = 0
		end
		
		if escapebonus then
			P_AddPlayerScore(player, player.lapbonus + player.ringbonus ) -- Bonus!
			if isminimalhud then return end
			if player.lapbonus or player.ringbonus then
				CONS_Printf(player, "** Lap "..player.ptsr.laps.." bonuses **")
			end
			
			if player.lapbonus then
				CONS_Printf(player, "* "..player.lapbonus.." point lap bonus!")
			end
			
			if player.ringbonus then
				CONS_Printf(player, "* "..player.ringbonus.." point ring bonus! ("..player.ptsr.rings_on_lap..")")
			end
		end
		
		player.ptsr.rings_on_lap = 0
	end
end