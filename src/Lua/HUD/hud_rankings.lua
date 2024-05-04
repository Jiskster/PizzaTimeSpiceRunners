local scoreboard_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if not multiplayer then return end

	local zinger_text = "LEADERBOARD"
	local zinger_x = 160*FRACUNIT
	local zinger_y = 10*FRACUNIT
	local player_sep = 17*FRACUNIT -- separation of player infos 

	local player_list = {}
	for _player in players.iterate do
		if not _player.spectator and not _player.ptsr.pizzaface then
			table.insert(player_list, _player)
		end
	end

	table.sort(player_list, function(a,b) return a.score > b.score end)

	for i=1,#player_list do
		if i > 20 then continue end
		
		local _player = player_list[i]
		local _skinname = skins[_player.realmo.skin].name
		local _colormap = v.getColormap(_skinname, _player.skincolor)
		local _skinpatch = v.getSprite2Patch(_player.realmo.skin, SPR2_XTRA)
		local commonflags = (V_SNAPTOLEFT|V_SNAPTOTOP)
		local playernameflags = (_player == consoleplayer) and V_YELLOWMAP or V_GRAYMAP
		playernameflags = $|V_ALLOWLOWERCASE
		local aliveflag = (_player.playerstate ~= PST_LIVE or _player.quittime > 0) and V_50TRANS or 0
		
		local playerpingcolor
		
		if _player.ping < 105 then
			playerpingcolor = V_GREENMAP
		elseif _player.ping < 200 then
			playerpingcolor = V_YELLOWMAP
		elseif _player.ping < INT32_MAX then
			playerpingcolor = V_REDMAP
		end
		
		local _xcoord = 22*FRACUNIT
		local _ycoord = 15*FRACUNIT + (i*player_sep)

		if i > 10 then
			_xcoord = $ + 160*FRACUNIT
			_ycoord = $ - (10*player_sep)
			commonflags = $ & ~V_SNAPTOLEFT
			commonflags = $ | V_SNAPTORIGHT
		end
		-- [Player Icon] --
		v.drawScaled(_xcoord, _ycoord, FRACUNIT/2,
		_skinpatch, (commonflags)|aliveflag, _colormap)

		-- [Player Rank] --
		v.drawScaled(_xcoord - 16*FRACUNIT + 8*FRACUNIT, _ycoord + 8*FRACUNIT, FRACUNIT/4, 
		PTSR.r2p(v,_player.ptsr.rank), commonflags)

		/*
		if _player.timeshit then -- no p rank for you noob, but on score hud
			v.drawScaled(_xcoord - 16*FRACUNIT, _ycoord, FRACUNIT/4, 
			PTSR.r2p(v, "BROKEN"), commonflags|V_20TRANS)
		end
		*/
		
		local scorewidth = v.stringWidth(tostring(_player.score), (commonflags|playernameflags))
		local scoreandpingwidth = v.stringWidth(tostring(_player.score)..tostring(_player.ping), (commonflags))
		
		-- [ Bar Things] --
		v.drawFill(0, 25, 640, 1, V_SNAPTOTOP+V_SNAPTOLEFT) -- bar 
		--v.drawFill(160, 25, 1, 640, V_SNAPTOTOP)

		-- [Player Name] --
		v.drawString( _xcoord + 16*FRACUNIT, _ycoord,  _player.name, (commonflags|playernameflags|aliveflag), "thin-fixed")
		
		-- [Player Score] --
		v.drawString(_xcoord + 16*FRACUNIT, _ycoord + 8*FRACUNIT, tostring(_player.score), (commonflags), "thin-fixed")

		v.drawString( _xcoord +8*FRACUNIT+(scorewidth*FU), _ycoord+8*FRACUNIT,  _player.ping.."ms", (commonflags|playerpingcolor), "thin-fixed")
		v.drawString( _xcoord +16*FRACUNIT+(scoreandpingwidth*FU), _ycoord+8*FRACUNIT,  "laps: ".._player.ptsr.laps, (commonflags), "thin-fixed")
		--v.drawString(int x, int y, string text, [int flags, [string align]])
	
		-- show crown in leaderboard
		-- GAMEMODE: JUGGERNAUT exclusive
		if _player.realmo.hascrown then
			local crown_spr = v.getSpritePatch(SPR_C9W3)
			
			v.drawScaled(_xcoord, _ycoord+(4*FU), FRACUNIT/4,
			crown_spr, (commonflags)|aliveflag)
		end
		
		-- [Finish Flag] --
		if (_player.ptsr.outofgame)
			v.drawScaled(_xcoord - 6*FRACUNIT,_ycoord+11*FRACUNIT,FU/2,
				v.getSpritePatch(SPR_FNSF,A,0),
				(commonflags)|V_FLIP
			)		
		end
	end 

	customhud.CustomFontString(v, zinger_x, zinger_y, zinger_text, "PTFNT", (V_SNAPTOTOP), "center", FRACUNIT/4, SKINCOLOR_BLUE)
end

customhud.SetupItem("rankings", ptsr_hudmodname, scoreboard_hud, "scores", 1) -- override vanilla rankings hud