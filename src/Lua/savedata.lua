local _rchars_ = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
local commandtoken = P_RandomKey(FRACUNIT)
local serverid
local totalscore_leaderboard = {
	/*
	{
		username = "Jiskster_rdWqGyxX"
		displayname = "Jisk" -- prevname from json or player.nam
		totalscore = 2424,
	}
	*/
}

local ts_lb_path = "PTSRDATA/totalscore_leaderboard.sav2"

if isserver then
	
	local file = io.openlocal(ts_lb_path, "r")
	
	if file then
		local content = file:read("*a")

		if content:len() > 2 then
			totalscore_leaderboard = json.decode(content)
		end
	end
end


-- have table
-- add to table if nobody here
-- save to table as json in file on quit

PTSR.autologin = CV_RegisterVar({
	name = "PTSR_autologin",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
})

PTSR.showloginprint = CV_RegisterVar({
	name = "PTSR_showloginprint",
	defaultvalue = "Off",
	PossibleValue = CV_OnOff,
	flags = 0,
})

addHook("NetVars", function(net)
    commandtoken = net($)
	serverid = net($)
	totalscore_leaderboard = net($)
end)

local function stringfile(str)
	return string.gsub(str, "%W", function(d)
		return tonumber(d) and d or "" 
	end)
end

local function genRNGUsername(pname)
    if type(pname) == "string" then
        local extra = ""
        local extranum = 8

        for i=1,extranum do
            local nc = P_RandomKey(#_rchars_)+1
            local chartoget = _rchars_:sub(nc,nc)
            extra = $ + chartoget
        end

        return stringfile(pname).."_"..extra
    end

    return
end

local function GenerateRandomChars(input_extranum)
    local extra = ""
    local extranum = input_extranum == nil and 25 or input_extranum

    for i=1,extranum do
        local nc = P_RandomKey(#_rchars_)+1
        local chartoget = _rchars_:sub(nc,nc)
        extra = $ + chartoget
    end
    return extra
end

local function usernameLoggedIn(username)
	for player in players.iterate do
		if player.registered_user == username then
			return player
		end
	end
	
	return false
end

local function isRegisteredUser(player)
	return player.registered_user and player.registered
end

local function gsFileSave(gsfile, player)
	if gsfile then
		gsfile:write(json.encode({
			totalscore = bigint.unserialize(player.ptsr_totalscore or bigint.new(0)),
			prevname = player.name
		}))
		
		gsfile:close()
	end
end

local function savePlayerData(player)
	if isRegisteredUser(player) and player.ptsr_totalscore ~= nil then
		local gspath = "PTSRDATA/"..player.registered_user.."/gamesave.sav2"
		local gsfile = io.openlocal(gspath, "w+")
		
		gsFileSave(gsfile, player)
	end
end

-- only use on GameQuit
local function saveTSLeaderBoardData()
	local file = io.openlocal(ts_lb_path, "w+")

	if file then
		local encoded = json.encode(totalscore_leaderboard)

		file:write(encoded)
	end
end

local function GetServerIDFromFile()
	if isserver then
		local server_id_path = "PTSRDATA/serverid.sav2"
		local serveridfile = io.openlocal(server_id_path, "r")
		
		if serveridfile then
			local content = tostring(serveridfile:read("*a"))
			
			serveridfile:close()
			
			return content
		end
	end
	
	return false
end

local function SetFileServerID(input_serverid)
	if isserver then
		local server_id_path = "PTSRDATA/serverid.sav2"
		local serveridfile = io.openlocal(server_id_path, "w")
		
		if serveridfile then
			local content = tostring(serveridfile:read("*a"))
			
			serveridfile:write(input_serverid)
			
			serveridfile:close()
			
			return content
		end
	end
	
	return false
end

local function FindUsernameOnLeaderboard(username)
	for i,v in ipairs(totalscore_leaderboard) do
		if v.username == username then
			return v
		end
	end

	return false
end

local function UpdateTotalScoreLeaderboard()
	for player in players.iterate do
        if player.registered and player.registered_user then
			local userlb = FindUsernameOnLeaderboard(player.registered_user) -- table
			
            if userlb then
                userlb.displayname = player.name
                userlb.totalscore = player.ptsr_totalscore
            else
                table.insert(totalscore_leaderboard, {
                    username = player.registered_user,
                    displayname = player.name,
                    totalscore = player.ptsr_totalscore
                })
            end
        end
    end
end

COM_AddCommand("PTSR_registeraccount", function(player, tplayer)
	if not multiplayer then return end
	
	if player ~= server and tplayer then
		if player == consoleplayer then
			print("illegal parameter")
		end
		return 
	end	
	
	local target_player = player
	
	if tplayer and players[tonumber(tplayer)] and players[tonumber(tplayer)].valid then
		target_player = players[tonumber(tplayer)] 
	end
	
    if (target_player.valid) and ((gamestate == GS_LEVEL) or (gamestate == GS_INTERMISSION)) then
        if not (target_player.registered) then
		
			
            local gen_username = genRNGUsername(target_player.name)
            local gen_password = GenerateRandomChars()
			
			
            if (isserver) or (isdedicatedserver) then -- Server
                local server_passpath = "PTSRDATA/"..gen_username.."/password.sav2"
                local server_gspath = "PTSRDATA/"..gen_username.."/gamesave.sav2"
				
                local passfile = io.openlocal(server_passpath, "w+")
                local gsfile = io.openlocal(server_gspath, "w+")
				
				if passfile then
					passfile:write(gen_password)
					passfile:close()
				end
				
				
				gsFileSave(gsfile, target_player)
            end

            if (target_player == consoleplayer) then -- Client
                local clientpath = "client/PTSR/"..serverid.."/account.sav2"
                local file = io.openlocal(clientpath, "w+")

                local clientpath_content = ('PTSR_loginaccount '.. '"'.. gen_username ..'" '.. '"'.. gen_password ..'"')
				if file then
					file:write(clientpath_content)
					file:close()
				end
            end
			
			target_player.registered_user = gen_username
			target_player.registered = true
			
			if (PTSR.showloginprint.value) or (isserver) then
				print(target_player.name.." created an account ("..gen_username..")")
			end
			
			target_player.login_timeout = nil
        end
    end
end)

COM_AddCommand("PTSR_loginaccount", function(player, username, password)
	if not multiplayer then return end
	
    if (player.valid) and ((gamestate == GS_LEVEL) or (gamestate == GS_INTERMISSION)) then
        if (not (player.registered) or not (player.registered_user)) and (username and password) then
			if usernameLoggedIn(username) then
				local playeronaccount = usernameLoggedIn(username) 
				if player == consoleplayer and playeronaccount and playeronaccount.valid and playeronaccount ~= server then
					print("Someone is already logged in this account, kicking the online user. Please try again. ".."("..playeronaccount.name..")")
				end
				
				if playeronaccount and playeronaccount.valid then
					COM_BufInsertText(server, "kick "..#playeronaccount.." Someone else logged in.")
				end
				
				return
			end
			
            if (isserver) or (isdedicatedserver) then
				local passpath = "PTSRDATA/"..username.."/password.sav2"
				local passfile = io.openlocal(passpath)
				
				if passfile then
					local passcontent = passfile:read("*a")
					if passcontent and (passcontent == password) then
						COM_BufInsertText(server, "PTSR_importdata "..#player.." "..username.." "..commandtoken)
					end
					passfile:close()
				else
					print(player.name.." tried to login as an invalid account. Registering the user.")
					COM_BufInsertText(server, "PTSR_registeraccount "..#player)
				end
			end
        end
    end
end)

COM_AddCommand("PTSR_importdata", function(player, playernum, username, token) -- make data server side
	if not multiplayer then return end
	
    if playernum ~= nil and username ~= nil and token ~= nil and ((gamestate == GS_LEVEL) or (gamestate == GS_INTERMISSION)) then
        if (tonumber(token) == commandtoken) and players[tonumber(playernum)] and players[tonumber(playernum)].valid then
			local target_player = players[tonumber(playernum)]
			
            if ((isserver) or (isdedicatedserver)) then
                local gspath = "PTSRDATA/"..username.."/gamesave.sav2"
                local gsfile = io.openlocal(gspath, "r")

                if gsfile then
                    local gsread = gsfile:read("*a")
                    if gsread then
						local command_format = string.format('PTSR_jsonimport %s "%s" %s', playernum, gsread:gsub('"',"'"), commandtoken)
						COM_BufInsertText(player, command_format)
                    end
					
					gsfile:close()
                end
			end
        end
    end
	
	if playernum and username and player == server then
		local target_player = players[tonumber(playernum)]
		
		target_player.registered_user = username
		target_player.registered = true
		
		if (PTSR.showloginprint.value) or (isserver) then
			print(target_player.name.." logged in as "..username)
		end
		
		target_player.login_timeout = nil
	end
end, 1)

COM_AddCommand("PTSR_jsonimport", function(player, playernum, jsondata, token)
	if not multiplayer then return end
	
	if player == server and jsondata ~= nil and token ~= nil and 
	playernum ~= nil and (tonumber(token) == commandtoken) then
		if players[tonumber(playernum)] then
			local target_player = players[tonumber(playernum)]
			local decoded_data = json.decode(jsondata:gsub("'",'"'))
			
			if decoded_data.totalscore ~= nil then
				player.ptsr_totalscore = bigint.new(decoded_data.totalscore)
			end
		end
	end
end, 1)

addHook("PlayerQuit", function(player)
	if not multiplayer then return end
	
	if (isserver) then
		savePlayerData(player)
	end
end)

addHook("GameQuit", function(quitting)
	if not multiplayer then return end
	
    if (isserver) then
        for player in players.iterate do 
            savePlayerData(player)
        end

		saveTSLeaderBoardData()
    end
end)

PTSR_AddHook("ongameend", function()
	UpdateTotalScoreLeaderboard()
end)

COM_AddCommand("PTSR_setserverid", function(player, input_serverid, token)
	if (player ~= server) then return end
	if (tonumber(token) ~= commandtoken) then return end
	
	serverid = input_serverid
	
	if isserver then
		print("Set serverid to: "..serverid)
	end
end, 1)

addHook("PlayerCmd", function(player,cmd) -- auto login / register
	if not multiplayer then return end
	
	if (cmd.buttons or cmd.forwardmove) and (not (player.registered) 
	and not (player.registered_user)) and PTSR.autologin.value and serverid then
		local clientpath = "client/PTSR/"..serverid.."/account.sav2"
        local file = io.openlocal(clientpath, "r")
		if file then
			COM_BufInsertText(player, file:read("*a"))
			file:close()
		elseif (leveltime % 3) == 0 then
			COM_BufInsertText(player, "PTSR_registeraccount")
		end
	end
end)

addHook("PlayerThink", function(player)
	if not multiplayer then return end

	if (leveltime % 35) == 0 then
		local guh = totalscore_leaderboard
		local encoded = json.encode(guh)

		print(encoded)
	end
	
	if player and player.valid then
		local cmd = player.cmd
		
		if (cmd.buttons or cmd.forwardmove) and (not (player.registered) 
		and not (player.registered_user)) and PTSR.autologin.value and serverid then
			player.login_timeout = $ or 0
			player.login_timeout = $ + 1
			
			if player.login_timeout > 4 * TICRATE then
				COM_BufInsertText(server, "kick " .. #player.. " NetXCMD timeout.")
			end
		end
	end
end)

addHook("MapLoad", function()
	if not serverid then
		local new_serverid = GetServerIDFromFile() or GenerateRandomChars(32)
		SetFileServerID(new_serverid)
		COM_BufInsertText(server, "PTSR_setserverid ".. new_serverid.. " ".. commandtoken)
	end
end)
