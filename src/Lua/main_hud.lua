local hudmodname = "spicerunners"

-- rank to patch
PTSR.r2p = function(v,rank) 
	if v.cachePatch("PTSR_RANK_"..rank:upper()) then
		return v.cachePatch("PTSR_RANK_"..rank:upper())
	end
end


/*
local hud_debug = CV_RegisterVar({
	name = "hud_debug",
	defaultvalue = "100",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned, 
})

local hud_debug2 = CV_RegisterVar({
	name = "hud_debug2",
	defaultvalue = "0",
	flags = CV_NETVAR,
	PossibleValue = CV_Unsigned,
})
*/
-- LAPS AND PIZZATIME-MOVEUP HUD --
local timeafteranimation = 0

local BARXOFF = 5*FU
local BARYOFF = 5*FU
local BARWIDTH = 295*FU
local BARSECTIONWIDTH = 172*FU
local TIMEMODFAC = 4*BARSECTIONWIDTH/FU

--[[@param v videolib]]
local function drawBarFill(v, x, y, scale, progress)
	local clampedProg = max(0, min(progress, FU))
	local patch = v.cachePatch("BARFILL")
	local drawwidth = FixedMul(clampedProg, BARWIDTH)
	local barOffset = ((leveltime%TIMEMODFAC)*FU/4)%BARSECTIONWIDTH
	v.drawCropped(
		x+FixedMul(BARXOFF, scale), y+FixedMul(BARYOFF, scale), -- x, y
		scale, scale, -- hscale, vscale
		patch, V_SNAPTOBOTTOM, -- patch, flags
		nil, -- colormap
		barOffset, 0, -- sx, sy
		drawwidth, patch.height*FU)
end

local bar_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	if PTSR.pizzatime then
		local expectedtime = TICRATE*3
		local start = 300*FRACUNIT -- animation position start
		local finish = 175*FRACUNIT -- animation position end
		local bar_finish = 1475*FRACUNIT/10
		local TLIM = PTSR.maxtime or 0 
		-- "TLIM" is time limit number converted to seconds to minutes
		--example, if CV_PTSR.timelimit.value is 4, it goes to 4*35 to 4*35*60 making it 4 minutes
		
		--for the fade in
		local ese = ease.inoutcubic(( (FU) / (expectedtime) )*PTSR.pizzatime_tics, start, finish)

		local pfEase = min(max(PTSR.pizzatime_tics - CV_PTSR.pizzatimestun.value*TICRATE - 50, 0), 100)
		pfEase = (pfEase*pfEase) * FU / 22

		local bar = v.cachePatch("SHOWTIMEBAR") -- the orange border
		local bar2 = v.cachePatch("SHOWTIMEBAR2") -- the purple thing
		
		--1/PTSR.timeleft
		--PTSR.timeleft

		local pizzaface = v.cachePatch('PIZZAFACE_SLEEPING1')
		if animationtable['pizzaface'] // dont wanna risk anything yknow
			pizzaface = v.cachePatch(animationtable['pizzaface'].display_name)
		end

		local john = v.cachePatch('JOHN1')
		if animationtable['john']
			john = v.cachePatch(animationtable['john'].display_name)
		end

		--ease.linear(fixed_t t, [[fixed_t start], fixed_t end])
		if PTSR.maxtime then

			
			--for the bar length calculations
			local progress = FixedDiv(TLIM*FRACUNIT-PTSR.timeleft*FRACUNIT, TLIM*FRACUNIT)
			local johnx = FixedMul(progress, bar_finish)
			

			-- Fix negative errors?
			if johnx < 0 then
				johnx = 0
			end

			local johnscale = (FU/2) -- + (FU/4)

			-- during animation
			if PTSR.pizzatime_tics < expectedtime then 
				--purple bar, +1 fracunit because i want it inside the box 
				-- MAX VALUE FOR HSCALE: FRACUNIT*150
				-- v.drawStretched(91*FRACUNIT, ese + (5*FU)/3, min(themath,bar_finish), (FU/2) - (FU/12), bar2, V_SNAPTOBOTTOM)
				drawBarFill(v, 90*FRACUNIT, ese, (FU/2), progress)
				--brown overlay
				v.drawScaled(90*FRACUNIT, ese, FU/2, bar, V_SNAPTOBOTTOM)
				v.drawScaled((82*FU) + min(johnx,bar_finish), ese + (6*johnscale), johnscale, john, V_SNAPTOBOTTOM)
				v.drawScaled(230*FU, ese - (8*FU) + pfEase, FU/3, pizzaface, V_SNAPTOBOTTOM)
				
			-- after animation
			else 
				// v.drawStretched(91*FRACUNIT, finish + (5*FU)/2, min(themath,bar_finish), (FU/2) - (FU/12), bar2, V_SNAPTOBOTTOM)
				drawBarFill(v, 90*FRACUNIT, finish, (FU/2), progress)
				v.drawScaled(90*FRACUNIT, finish, FU/2, bar, V_SNAPTOBOTTOM)
				v.drawScaled((82*FU) + min(johnx,bar_finish), finish + (6*johnscale), johnscale, john, V_SNAPTOBOTTOM)
				v.drawScaled(230*FU, finish - (8*FU) + pfEase, FU/3, pizzaface, V_SNAPTOBOTTOM)
				--v.drawString(int x, int y, string text, [int flags, [string align]])
				if timeafteranimation then
					local timestring = G_TicsToMTIME(PTSR.timeleft)
					local x = 165*FRACUNIT
					local y = 176*FRACUNIT + FRACUNIT/2
					--drawSuperText(v, 160, 183+120-PTHUD.PizzaTimeTimerY,str,{font = 'PTFNT', flags = V_SNAPTOBOTTOM, align = 'center'})
					if timeafteranimation < 10 then
						--v.drawString(165, y + 5, timestring, V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT , "center")
						customhud.CustomFontString(v, x, y, timestring, "PTFNT", (V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT), "center", FRACUNIT/2, SKINCOLOR_WHITE)
					else
						if PTSR.timeleft then
							customhud.CustomFontString(v, x, y, timestring, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2, SKINCOLOR_WHITE)
						else
							local otcolor = ((leveltime/4)% 2 == 0) and SKINCOLOR_RED or SKINCOLOR_WHITE
							customhud.CustomFontString(v, x, y, "OVERTIME!", "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2, otcolor)
						end
					end
				end
				timeafteranimation = $ + 1
			end
		end
	else
		timeafteranimation = 0
	end
end

local itspizzatime_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	if PTSR.pizzatime and PTSR.pizzatime_tics then
		/*
		if PTSR.pizzatime_tics < 85
			v.draw(0, 0, v.cachePatch("PIZZAPAL"), V_50TRANS|V_SNAPTOTOP|V_SNAPTOLEFT|V_PERPLAYER)
		end
		*/
	end
	if PTSR.pizzatime and PTSR.pizzatime_tics and PTSR.pizzatime_tics < 10*TICRATE then
		local patch = v.cachePatch("ITSPIZZATIME1")
		if CV_PTSR.homework.value then
			patch = v.cachePatch("ITSHWTIME1")
		end
		if leveltime % 3 then
			patch = v.cachePatch("ITSPIZZATIME2")
			if CV_PTSR.homework.value then
				patch = v.cachePatch("ITSHWTIME2")
			end
		end
		if CV_PTSR.homework.value then
			v.drawScaled(0, (250*FU) - (PTSR.pizzatime_tics*FU)*3, FU/2, patch)
		else
			v.drawScaled(100*FRACUNIT, (250*FU) - (PTSR.pizzatime_tics*FU)*3, FU/2, patch)
		end
	end
end

local tooltips_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	local count = PTSR_COUNT()
	local practicemodetext = "\x84\* PRACTICE MODE *"
	local infinitelapstext = "\x82\* LAPS: "..player.lapsdid.." *"
	local lapstext = "\x82\* LAPS: "..player.lapsdid.." / "..PTSR.maxlaps.." *"

	if (not player.pizzaface) and (player.ptsr_outofgame) and (player.playerstate ~= PST_DEAD) 
	and not (player.lapsdid >= PTSR.maxlaps and CV_PTSR.default_maxlaps.value) and not PTSR.gameover then
		if not player.hold_newlap then
			v.drawString(160, 120, "\x85\* Hold FIRE to try a new lap! *", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		else
			local percentage = (FixedDiv(player.hold_newlap*FRACUNIT, PTSR.laphold*FRACUNIT)*100)/FRACUNIT
			v.drawString(160, 120, "\x85\* CHARGING \$percentage\% *", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		end
	end

	if PTSR.pizzatime then
		if player.stuntime then
			v.drawString(160, 100, "You will be unfrozen in: "..player.stuntime/TICRATE.. " seconds.", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		end
		
		if timeafteranimation then
			local addtransflag = (timeafteranimation < 10) and (10-timeafteranimation)<<V_ALPHASHIFT or 0 

			if (count.active == 1) then -- practice mode
				v.drawString(165, 157,practicemodetext , V_SNAPTOBOTTOM|addtransflag, "thin-center")
			end
			
			if player.pizzaface then
				if player.pizzachargecooldown then
					v.drawString(165, 157, "\x85\* COOLING DOWN *", V_SNAPTOBOTTOM|addtransflag, "thin-center")
				elseif player.pizzacharge then
					local percentage = (FixedDiv(player.pizzacharge*FRACUNIT, 35*FRACUNIT)*100)/FRACUNIT
					
					v.drawString(165, 157, "\x85\* CHARGING \$percentage\% *", V_SNAPTOBOTTOM|addtransflag, "thin-center")
				else
					v.drawString(165, 157, "\x85\* HOLD FIRE TO TELEPORT *", V_SNAPTOBOTTOM|addtransflag, "thin-center")
				end
			end
			-- Early returns start here --
			if player.pizzaface then return end
			
			if CV_PTSR.default_maxlaps.value then
				v.drawString(165, 165, lapstext, V_PERPLAYER|V_SNAPTOBOTTOM|addtransflag, "thin-center")
			else -- infinite laps
				v.drawString(165, 165, infinitelapstext, V_PERPLAYER|V_SNAPTOBOTTOM|addtransflag, "thin-center")
			end
		end
	end
end

local lap_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	if not player.laptime then return end
	if player.pizzaface then return end
	if not (consoleplayer and consoleplayer.valid) then return end

	if not player == consoleplayer then return end
	
	local lap2flag = v.cachePatch("LAP2FLAG")
	local hudst = player["PT@hudstuff"]
	
	local cz = {
		x = 120*FU,
		start = -100*FU, 
		finish = 10*FU,
	}
	
	cz.y = ease.linear(FixedDiv(hudst.anim*FRACUNIT, 45*FRACUNIT), cz.start, cz.finish)

	if cz.y ~= nil and hudst.anim_active then
		if player.lapsdid == 2
			v.drawScaled(cz.x,cz.y,FRACUNIT/3, lap2flag, V_SNAPTOTOP)
		elseif player.lapsdid == 3 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP)
		elseif player.lapsdid == 4 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP|V_YELLOWMAP)
		elseif player.lapsdid == 5 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP|V_PURPLEMAP)
		elseif player.lapsdid >= 6 then
			v.drawLevelTitle(cz.x/FU,cz.y/FU, "LAP "..player.lapsdid, V_SNAPTOTOP|V_REDMAP)
		end
	end
end

local rank_hud = function(v, player)
	local rankpos = {
		x = 100*FRACUNIT,
		y = 15*FRACUNIT
	}
	if gametype ~= GT_PTSPICER then return end
	
	if player.pizzaface then return end
	if player.ptsr_rank then
		v.drawScaled(rankpos.x, rankpos.y,FRACUNIT/3, PTSR.r2p(v,player.ptsr_rank), V_SNAPTOLEFT|V_SNAPTOTOP)
		/*
		if player.timeshit then -- no p rank for you noob
			v.drawScaled(rankpos.x, rankpos.y,FRACUNIT/3, PTSR.r2p(v, "BROKEN"), V_SNAPTOLEFT|V_SNAPTOTOP|V_20TRANS)
		end
		*/
	end
end

local faceswap_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	if not (player.pizzaface and leveltime) then return end
	if player.stuntime and PTSR.pizzatime_tics < TICRATE*CV_PTSR.pizzatimestun.value+20 then
		v.drawString(160, 150, "Move left and right to swap faces", V_ALLOWLOWERCASE, "small-center")
	end
end

local gamemode_hud = function(v, player)
	local currentGamemode = PTSR.gamemode_list[PTSR.gamemode]
	
	if gametype ~= GT_PTSPICER then return end
	if not PTSR.pizzatime then return end
	

	v.drawString(320, 0, "\x8A"..currentGamemode, V_SNAPTORIGHT|V_SNAPTOTOP|V_50TRANS|V_ADD, "thin-right")
end

local scoreboard_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end

	local zinger_text = "LEADERBOARD"
	local zinger_x = 160*FRACUNIT
	local zinger_y = 10*FRACUNIT
	local player_sep = 17*FRACUNIT -- separation of player infos 

	local player_list = {}
	for _player in players.iterate do
		if not _player.spectator and not _player.pizzaface then
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
		v.drawScaled(_xcoord - 16*FRACUNIT, _ycoord, FRACUNIT/4, 
		PTSR.r2p(v,_player.ptsr_rank), commonflags)

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
		v.drawString( _xcoord +16*FRACUNIT+(scoreandpingwidth*FU), _ycoord+8*FRACUNIT,  "laps: ".._player.lapsdid, (commonflags), "thin-fixed")
		--v.drawString(int x, int y, string text, [int flags, [string align]])
	
		-- [Finish Flag] --
		if (_player.ptsr_outofgame)
			v.drawScaled(_xcoord - 6*FRACUNIT,_ycoord+11*FRACUNIT,FU/2,
				v.getSpritePatch(SPR_FNSF,A,0),
				(commonflags)|V_FLIP
			)		
		end
		
	end 

	customhud.CustomFontString(v, zinger_x, zinger_y, zinger_text, "PTFNT", (V_SNAPTOTOP), "center", FRACUNIT/4, SKINCOLOR_BLUE)
end

local score_hud = function(v, player)
	v.drawScaled(24*FU, 15*FU, FU/3, v.cachePatch("_SCOREOFPIZZA"), (V_SNAPTOLEFT|V_SNAPTOTOP))
	customhud.CustomFontString(v, 58*FU, 11*FU, tostring(player.score), "SCRPT", (V_SNAPTOLEFT|V_SNAPTOTOP), "center", FRACUNIT/3)
end

local overtimemulti_hud = function(v, player)
	if not PTSR.timeover then return end
	
	local yum = L_FixedDecimal(FRACUNIT + (PTSR.timeover_tics*25))
	
	v.drawString(10, 135, "\x85\PF Speed: "..yum.."x", V_SNAPTOLEFT|V_SNAPTOBOTTOM, "thin")
end

local untilend_hud = function(v, player)
	if not PTSR.untilend or PTSR.gameover then return end
	local real_timeuntilend = 100 - PTSR.untilend
	local text_timeundilend = "\x88".."Ending in.. "..G_TicsToSeconds(real_timeuntilend).."."..G_TicsToCentiseconds(real_timeuntilend).."s"
	v.drawString(160, 60, text_timeundilend, V_SNAPTOTOP|V_30TRANS|V_ADD, "thin-center")
end

local fade_hud = function(v, player)
	if not PTSR.gameover then return end

	local div = min(FixedDiv(PTSR.intermission_tics*FU, 129*FRACUNIT), FRACUNIT)
	local fadetween = ease.linear(div, 0, 31)
	v.fadeScreen(0xFF00, min(fadetween, 31))
end
--local yum = FRACUNIT + (PTSR.timeover_tics*48)

customhud.SetupItem("PTSR_bar", hudmodname, bar_hud, "game", 0)
customhud.SetupItem("PTSR_itspizzatime", hudmodname, itspizzatime_hud, "game", 0)
customhud.SetupItem("PTSR_tooltips", hudmodname, tooltips_hud, "game", 0)
customhud.SetupItem("PTSR_lap", hudmodname, lap_hud, "game", 0)
customhud.SetupItem("PTSR_rank", hudmodname, rank_hud, "game", 0)
--customhud.SetupItem("PTSR_event", hudmodname, event_hud, "game", 0)
customhud.SetupItem("PTSR_faceswap", hudmodname, faceswap_hud, "game", 0)
customhud.SetupItem("PTSR_gamemode", hudmodname, gamemode_hud, "game", 0) -- show gamemode type
customhud.SetupItem("PTSR_overtimemulti", hudmodname, overtimemulti_hud, "game", 0)
customhud.SetupItem("PTSR_untilend", hudmodname, untilend_hud, "game", 0)
customhud.SetupItem("PTSR_fade", hudmodname, fade_hud, "game", 0)
customhud.SetupItem("rankings", hudmodname, scoreboard_hud, "scores", 0) -- override vanilla rankings hud
customhud.SetupItem("score", hudmodname, score_hud, "game", 0) -- override score hud
customhud.SetupItem("time", hudmodname, nil, "game", 0) -- override time hud (NOTHING)


--PTSR.gamemode[#PTSR.gamemode_list]