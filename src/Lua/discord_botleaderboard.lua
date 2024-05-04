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
				local ping = player.ping
				local statms = ''
				local iconskin = "{"..skins[player.skin].name.."} "
				local admin = ':black_small_square: '
				if (ping < 32) then statms = ':ping_blue: '
				elseif (ping < 95) then statms = ':ping_green: '
				elseif (ping < 195) then statms = ':ping_yellow: '
				elseif (ping < 256) then statms = ':ping_red: ' end
				local rank = ':unknown: '
				if player.ptsr.pizzaface and leveltime then
					rank = PTSR.PFMaskData[player.ptsr.pizzastyle or 1].emoji or ":pizza: "
				elseif player.spectator or player.playerstate == PST_DEAD
					rank = ':dead: '
				elseif player.ptsr.rank
					rank = '['..player.ptsr.rank:upper()..']'
				end
				--if player.mo and ((player.pflags & PF_FINISHED) or player.ptsr.outofgame) then pffinished = ":completed: " end
				if IsPlayerAdmin(player) then admin = ":remote_admin: " end
				if player.playtime == nil then player.playtime = 0 end
				local seconds = G_TicsToSeconds(player.playtime)
				if string.len(seconds) == 1 then seconds = "0"..tostring(seconds) end
				local pptime = G_TicsToMinutes(player.playtime, true)..":"..seconds
				local line = statms..iconskin..rank..admin.."["..#player.."] `"..pname.."`: Score - "..player.score
				if not player.ptsr.pizzaface and player.ptsr.rank and player.ptsr.laps then
					line = $ .. "; Laps - "..player.ptsr.laps -- .." / "..PTSR.maxlaps
					line = $ .. "; Rings -"..player.rings
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