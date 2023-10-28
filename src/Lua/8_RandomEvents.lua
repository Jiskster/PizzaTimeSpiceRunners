-- mirror of chaos and stuff

PTSR.currentEvent = nil

local frozen = true

addHook("MapLoad", function ()
	if gametype ~= GT_PTSPICER then return end

	if PTSR.currentEvent then
		if PTSR.currentEvent.name == "mirror" then
			if PTSR.currentEvent.activated then
				CV_Set(CV_FindVar("forceskin"), -1)
				PTSR.currentEvent = nil
			else
				if DiscordBot then
					DiscordBot.Data.msgsrb2 = $ .. ":mirror: The Chaos Mirror activates!\nChosen skin: " .. skins[PTSR.currentEvent.skin].realname.."!\n"
				end
				PTSR.currentEvent.activated = true
				for player in players.iterate do
					player.preMirrorSkin = player.skin
					R_SetPlayerSkin(player, PTSR.currentEvent.skin)
				end
				CV_Set(CV_FindVar("forceskin"), PTSR.currentEvent.skin)
			end
		else
			PTSR.currentEvent = nil
		end
	else
		if P_RandomChance(FRACUNIT/16) then
			PTSR.currentEvent = {name = ({"super", "mini"})[P_RandomRange(1,2)]}
			if DiscordBot then
				if PTSR.currentEvent.name == "mirrorPrelude" then
					DiscordBot.Data.msgsrb2 = $ .. ":mirror: The Chaos Mirror glows...\nThe highest scoring player this round will force their character upon all next round!\n"
				elseif PTSR.currentEvent.name == "super" then
					DiscordBot.Data.msgsrb2 = $ .. ":superhero: Everyone is super now!\n"
				elseif PTSR.currentEvent.name == "super" then
					DiscordBot.Data.msgsrb2 = $ .. ":small_red_triangle_down: Everyone is mini now!\n"
				end
			end
		end
	end
	if PTSR.currentEvent then
		print(PTSR.currentEvent.name .. " event")
	else
		print("no event")
	end
end)

addHook("IntermissionThinker", function ()
	if gametype ~= GT_PTSPICER then return end
	if PTSR.currentEvent then
		local event = PTSR.currentEvent
		if event.name == "mirrorPrelude" then
			local maxplayer = nil
			local maxscore = -4
			for player in players.iterate do
				if player and player.pstate ~= PST_DEAD then
					if player.score > maxscore then
						maxplayer = player
						maxscore = player.score
					end
				end
			end
			if maxplayer then
				PTSR.currentEvent = {name = "mirror", skin = maxplayer.skin, activated = false}
			else
				PTSR.currentEvent = nil
			end
		elseif event.name == "mirror" and event.activated then
			CV_Set(CV_FindVar("forceskin"), -1)
			for player in players.iterate do
				R_SetPlayerSkin(player, player.preMirrorSkin)
			end
		end
	end
end)

--[[@param p player_t]]
addHook("PlayerThink", function (p)
	if p.PTSR_wasmini then
		p.mo.scale = FU
		p.PTSR_wasmini = false
	end
	if gametype ~= GT_PTSPICER then return end
	if not PTSR.currentEvent then return end
	if p.pstate == PST_DEAD or p.spectator or not p.realmo then return end
	if PTSR.currentEvent.name == "super" then
		p.rings = 9999
		if not p.powers[pw_super] and not p.exiting then p.powers[pw_super] = 2 end
		p.charflags = $ | SF_SUPER
	end
	if PTSR.currentEvent.name == "mini" then
		p.mo.scale = FU/3
		if p.pizzaface then
			p.mo.scale = $ * 2
		end
		p.PTSR_wasmini = true
	end
end)

addHook("ThinkFrame", function ()
	if gametype ~= GT_PTSPICER then return end
	if PTSR.currentEvent and PTSR.currentEvent.name == "super" then
		emeralds = 127
	else
		emeralds = 0
	end
end)