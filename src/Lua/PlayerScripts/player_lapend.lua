// TODO: Make DoLapBonus not call ChatLapStatus, and seperately use them when they're needed.

PTSR.ChatLapStatus = function(player)
	local lapstring = "\x82\*LAP ".. player.lapsdid.. " ("..player.name.." "..G_TicsToMTIME(player.laptime, true)..")"
	chatprint(lapstring, true)
	
	
end

PTSR.DoLapBonus = function(player)		
	PTSR.ChatLapStatus(player)
	
	if player.lapsdid ~= nil then
		local escapebonus = true
	
		local lapbonus = (player.lapsdid*777)
		local ringbonus = (player.rings*13)
		
		if PTSR_DoHook("onbonus", toucher) == true then
			escapebonus = false
		end
		
		if PTSR_DoHook("onlapbonus", toucher) == true then
			lapbonus = 0
		end
		
		if PTSR_DoHook("onringbonus", toucher) == true then
			ringbonus = 0
		end
		
		if escapebonus then
			P_AddPlayerScore(player, lapbonus + ringbonus ) -- Bonus!
			if lapbonus or ringbonus then
				CONS_Printf(player, "** Lap "..player.lapsdid.." bonuses **")
			end
			
			if lapbonus then
				CONS_Printf(player, "* "..lapbonus.." point lap bonus!")
			end
			
			if ringbonus then
				CONS_Printf(player, "* "..ringbonus.." point ring bonus!")
			end
		end
	end
end