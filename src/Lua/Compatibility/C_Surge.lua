-- Remove Ring Attraction from Surge.
addHook("PlayerThink", function(player)
	if not (player.realmo and player.realmo.valid)
	or (gametype ~= GT_PTSPICER) then
		return
	end
	
	local yu = player.stt
	
	if yu then
		if yu.ringattract then
			yu.ringattract = nil
		end
	end
end)