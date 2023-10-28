local oldFunc = nil

local function registerIt(successValue) 
	if oldFunc then return successValue end
	if not DiscordBot then return false end
	oldFunc = DiscordBot.Functions.statsofserver
	
	DiscordBot.Functions.statsofserver = function()
		if gametype ~= GT_PTSPICER then return oldFunc() end
	
		local playerstats = ''
		for player in players.iterate do
			if player
				local pname = string.gsub(player.name, "`", "")
				local ping = 0
				local statms = ''
				local iconskin = ":"..skins[player.skin].name..":"
				local admin = ':black_small_square:'
				if player.cmd.latency then ping = player.cmd.latency * 13 end
				if (ping < 32) then statms = ':ping_blue:'
				elseif (ping < 64) then statms = ':ping_green:'
				elseif (ping < 128) then statms = ':ping_yellow:'
				elseif (ping < 256) then statms = ':ping_red:' end
				local rank = ':unknown:'
				if player.pizzaface and leveltime then
					rank = pfmaskData[player.PTSR_pizzastyle or 1].emoji or ":pizza:"
				elseif player.spectator or player.playerstate == PST_DEAD
					rank = ':dead:'
				elseif player.ptje_rank
					rank = ':'..player.ptje_rank:lower()..'rank:'
				end
				if player.mo and (player.pflags & PF_FINISHED) then pffinished = ":completed:" end
				if IsPlayerAdmin(player) then admin = ":remote_admin:" end
				if player.playtime == nil then player.playtime = 0 end
				local seconds = G_TicsToSeconds(player.playtime)
				if string.len(seconds) == 1 then seconds = "0"..tostring(seconds) end
				local pptime = G_TicsToMinutes(player.playtime, true)..":"..seconds
				local line = statms..iconskin..rank..admin.."["..#player.."] `"..pname.."`: Score - "..player.score
				if not player.pizzaface and player.ptje_rank and player.lapsdid then
					line = $ .. "; Laps - "..player.lapsdid.." / "..CV_PTSR.maxlaps_perplayer.value
				end
				playerstats = $ + line.."\n"
			end
		end
		if playerstats == ''
			playerstats = "There's no one here."
		end
		return playerstats
	end
	
	return successValue
end

if not registerIt(true) then
	addHook("MapLoad", registerIt)
end