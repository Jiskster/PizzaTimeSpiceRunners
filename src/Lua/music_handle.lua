addHook("ThinkFrame", function()
	if gametype ~= GT_PTSPICER then return end
	if CV_PTSR.nomusic.value then return end
	if PTSR.gameover then return end
	
	if not consoleplayer then return end
	
	local laps = consoleplayer.lapsdid
	if PTSR.pizzatime then
		if PTSR.timeover and leveltime then
			local mus = CV_PTSR.overtime_music.value
			local mus_table = {[1] = "OVRTME", [2] = "OVRTM2"}
			local mus_str = mus_table[mus]
			
			if mapmusname ~= mus_str then
				S_ChangeMusic(mus_str, true, player)
				mapmusname = mus_str
			end
			
			P_SetupLevelSky(34)
			P_SetSkyboxMobj(nil)
			return
		end
	
		if laps <= 1 and mapmusname ~= "PIZTIM" then
			S_ChangeMusic("PIZTIM", true, player)
			mapmusname = "PIZTIM"
		elseif laps == 2 and mapmusname ~= "DEAOLI" then
			S_ChangeMusic("DEAOLI", true, player)
			mapmusname = "DEAOLI"
		elseif laps == 3 and mapmusname ~= "PIJORE" then
			S_ChangeMusic("PIJORE", true, player)
			mapmusname = "PIJORE"
		elseif laps == 4 and mapmusname ~= "GLUWAY" then
			S_ChangeMusic("GLUWAY", true, player)
			mapmusname = "GLUWAY"
		elseif laps >= 5 and mapmusname ~= "PASTVI" then
			S_ChangeMusic("PASTVI", true, player)
			mapmusname = "PASTVI"
		end
	end
end)