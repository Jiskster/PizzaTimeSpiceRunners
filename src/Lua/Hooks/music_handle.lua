local IS_PANIC = false
addHook("ThinkFrame", function()
	if not PTSR.IsPTSR() then return end
	if CV_PTSR.nomusic.value then return end
	if PTSR.gameover then return end
	
	if not consoleplayer then return end
	
	local laps = consoleplayer.lapsdid
	if PTSR.pizzatime then
		if PTSR.timeover and leveltime then
			local mus = CV_PTSR.overtime_music.value
			local mus_str = "OVRTME"
			local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
			
			if mus then
				if gm_metadata.overtime_music then
					S_ChangeMusic(gm_metadata.overtime_music, true, player)
					mapmusname = gm_metadata.overtime_music
				elseif mapmusname ~= mus_str then
					S_ChangeMusic(mus_str, true, player)
					mapmusname = mus_str
				end
			end
			
			P_SetupLevelSky(34)
			P_SetSkyboxMobj(nil)
			if mus then
				return
			end
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
		
		if S_MusicName() ~= "PIZTIM" then
			IS_PANIC = false
		end
		
		local length = S_GetMusicLength()

		if not multiplayer
		and S_MusicName() == "PIZTIM"
		and PTSR.timeleft <= 56*TICRATE
		and not IS_PANIC then
			S_ChangeMusic("PIZTIM", false, consoleplayer)
			S_SetMusicPosition(length-(56*1000))
			IS_PANIC = true
		end
	end
end)