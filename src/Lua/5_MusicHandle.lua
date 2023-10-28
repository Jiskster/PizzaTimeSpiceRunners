addHook("ThinkFrame", function()
	if gametype ~= GT_PTSPICER then return end
	if CV_PTSR.nomusic.value then return end
	
	if not consoleplayer then return end
	
	local laps = consoleplayer.lapsdid
	if PTSR.pizzatime then
		if laps <= 1 and mapmusname ~= "PIZTIM" then
			P_PlayJingleMusic(player, "PIZTIM", nil, true, JT_OTHER)
			mapmusname = "PIZTIM"
		elseif laps == 2 and mapmusname ~= "DEAOLI" then
			P_PlayJingleMusic(player, "DEAOLI", nil, true, JT_OTHER)
			mapmusname = "DEAOLI"
		elseif laps == 3 and mapmusname ~= "PIJORE" then
			P_PlayJingleMusic(player, "PIJORE", nil, true, JT_OTHER)
			mapmusname = "PIJORE"
		elseif laps == 4 and mapmusname ~= "GLUWAY" then
			P_PlayJingleMusic(player, "GLUWAY", nil, true, JT_OTHER)
			mapmusname = "GLUWAY"
		elseif laps >= 5 and mapmusname ~= "PASTVI" then
			P_PlayJingleMusic(player, "PASTVI", nil, true, JT_OTHER)
			mapmusname = "PASTVI"
		end
	end
end)