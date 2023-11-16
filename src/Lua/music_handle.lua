addHook("ThinkFrame", function()
	if gametype ~= GT_PTSPICER then return end
	if CV_PTSR.nomusic.value then return end
	
	if not consoleplayer then return end
	
	local laps = consoleplayer.lapsdid
	if PTSR.pizzatime then
		if PTSR.timeover and leveltime then
			if mapmusname ~= "OVRTME" then
				S_ChangeMusic("OVRTME", true, player)
				mapmusname = "OVRTME"
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