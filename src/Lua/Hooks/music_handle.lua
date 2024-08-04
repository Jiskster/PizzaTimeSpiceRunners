PTSR.MusicList = {
	Laps = {
		[1] = "PIZTIM",
		[2] = "DEAOLI",
		[3] = "PIJORE",
		[4] = "GLUWAY",
		[5] = "PASTVI",
	}
}

-- split a string
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

local ps_auto = "client/SpiceRunners/ps_autoload.txt"-- auto pizza script path

local ps_auto_file = io.openlocal(ps_auto, "r")

if ps_auto_file then
	local line_count = 0
	
	for line in ps_auto_file:lines() do
		line_count = $ + 1
		
		if line:len() <= 1 then continue end
		
		if line:sub(1,1) == "#" then
			local space = line:find(" ")
			
			local command 
			if space then
				print("sp! "..space)
				command = line:sub(2,space-1)
			else
				command = line:sub(2,line:len())
			end
			
			print(command)
			
			if command == "CLEAR_LAP_MUSIC" then
				PTSR.MusicList.Laps = {}
				print("cleared deh music")
			elseif command == "LAPMUS" then
				print(command.. " at line ".. line_count) 
			end
		end
	end
	ps_auto_file:close()
else
	ps_auto_file = io.openlocal(ps_auto, "w")
	ps_auto_file:close()
end



local IS_PANIC = false

addHook("ThinkFrame", function()
	if not PTSR.IsPTSR() then return end
	if CV_PTSR.nomusic.value then return end
	if PTSR.gameover then return end
	if not consoleplayer then return end
	
	local laps = consoleplayer.ptsr.laps
	
	if PTSR.pizzatime then
		if PTSR.timeover and leveltime then
			local mus = CV_PTSR.overtime_music.value
			local mus_str = "OVRTME"
			local gm_metadata = PTSR.currentModeMetadata()
			
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
	
		if PTSR.MusicList.Laps[laps] and mapmusname ~= PTSR.MusicList.Laps[laps] then
			local newmus = PTSR.MusicList.Laps[laps]
			if S_MusicExists(newmus) then
				S_ChangeMusic(newmus, true, player)
				mapmusname = newmus
			else
				S_StopMusic(player)
			end
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
			S_SetMusicPosition(length-(PTSR.timeleft/TICRATE*1000))
			IS_PANIC = true
		end
	end
end)