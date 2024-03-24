local hudmodname = "spicerunners"

-- time expected to reach to the final tween position, when pizza time starts
local pthud_expectedtime = TICRATE*3 
-- pt animation position start
local pthud_start_pos = 225*FRACUNIT 
-- pt animation position end
local pthud_finish_pos = 175*FRACUNIT

-- rank to patch
PTSR.r2p = function(v,rank) 
	if v.cachePatch("PTSR_RANK_"..rank:upper()) then
		return v.cachePatch("PTSR_RANK_"..rank:upper())
	end
end

-- rank to fill
PTSR.r2f = function(v,rank) 
	if v.cachePatch("PTSR_FRANK_"..rank:upper()) then
		return v.cachePatch("PTSR_FRANK_"..rank:upper())
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
local function drawBarFill(v, x, y, scale, progress, patch)
	local clampedProg = max(0, min(progress, FU))
	local patch = v.cachePatch(patch)
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
		local bar_finish = 1475*FRACUNIT/10
		local TLIM = PTSR.maxtime or 0 
		
		local barfill = PTSR.isOvertime() and "BARFILL2" or "BARFILL"
		
		-- "TLIM" is time limit number converted to seconds to minutes
		--example, if CV_PTSR.timelimit.value is 4, it goes to 4*35 to 4*35*60 making it 4 minutes

		local div = ( (FU) / (pthud_expectedtime) )*PTSR.pizzatime_tics
		
		local ese = (PTSR.pizzatime_tics < pthud_expectedtime) and 
		ease.linear(div, pthud_start_pos, pthud_finish_pos) or pthud_finish_pos  -- ese is y axis tween
		

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
		
		local john
		
		if not PTSR.isOvertime() then
			john = v.cachePatch('JOHN1')
			if animationtable['john']
				john = v.cachePatch(animationtable['john'].display_name)
			end
		else
			john = v.cachePatch('REDJOHN1')
			if animationtable['redjohn']
				john = v.cachePatch(animationtable['redjohn'].display_name)
			end
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
			--purple bar, +1 fracunit because i want it inside the box 
			-- MAX VALUE FOR HSCALE: FRACUNIT*150
			-- v.drawStretched(91*FRACUNIT, ese + (5*FU)/3, min(themath,bar_finish), (FU/2) - (FU/12), bar2, V_SNAPTOBOTTOM)
			
			drawBarFill(v, 90*FRACUNIT, ese, (FU/2), progress, barfill)
			--brown overlay
			v.drawScaled(90*FRACUNIT, ese, FU/2, bar, V_SNAPTOBOTTOM)
			v.drawScaled((82*FU) + min(johnx,bar_finish), ese + (6*johnscale), johnscale, john, V_SNAPTOBOTTOM)
			v.drawScaled(230*FU, ese - (8*FU) + pfEase, FU/3, pizzaface, V_SNAPTOBOTTOM)
			
			local timestring = G_TicsToMTIME(PTSR.timeleft)
			local x = 165*FRACUNIT
			local y = 176*FRACUNIT + FRACUNIT/2
			local y_offset = (3*FRACUNIT)/2
			
			if PTSR.timeleft then
				customhud.CustomFontString(v, x, ese + y_offset, timestring, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2, SKINCOLOR_WHITE)
			else
				local gm_metadata = PTSR.gamemode_list[PTSR.gamemode]
				local otcolor = ((leveltime/4)% 2 == 0) and SKINCOLOR_RED or SKINCOLOR_WHITE
				local ot_text = gm_metadata.overtime_textontime or "OVERTIME!"
				
				customhud.CustomFontString(v, x, ese + y_offset, ot_text, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2, otcolor)
			end
			
			timeafteranimation = $ + 1
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
	
	local pthud_offset = -8*FU
	local div = ( (FU) / (pthud_expectedtime) )*PTSR.pizzatime_tics
	local ese = PTSR.pizzatime_tics < pthud_expectedtime and
	ease.linear(div, pthud_start_pos+pthud_offset, pthud_finish_pos+pthud_offset) or pthud_finish_pos+pthud_offset
	-- y axis tween


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
		
		if (count.active == 1) then -- practice mode
			v.drawString(165*FU, ese-(FU*8), practicemodetext , V_SNAPTOBOTTOM, "thin-fixed-center")
		end
		
		if player.pizzaface then
			if player.pizzachargecooldown then
				v.drawString(165*FU, 157, "\x85\* COOLING DOWN *", V_SNAPTOBOTTOM, "thin-center")
			elseif player.pizzacharge then
				local percentage = (FixedDiv(player.pizzacharge*FRACUNIT, 35*FRACUNIT)*100)/FRACUNIT
				
				v.drawString(165*FU, 157, "\x85\* CHARGING \$percentage\% *", V_SNAPTOBOTTOM, "thin-center")
			else
				v.drawString(165*FU, 157, "\x85\* HOLD FIRE TO TELEPORT *", V_SNAPTOBOTTOM, "thin-center")
			end
		end
		
		-- Early returns start here, no pizza face code allowed beyond here --
		if player.pizzaface then return end
		
		if CV_PTSR.default_maxlaps.value then
			v.drawString(165*FU, ese, lapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-fixed-center")
		else -- infinite laps
			v.drawString(165*FU, ese, infinitelapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-fixed-center")
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
		x = 110*FRACUNIT,
		y = 20*FRACUNIT
	}
	if gametype ~= GT_PTSPICER then return end
	
	if player.pizzaface then return end

	--get the percent to next rank
	local per = (PTSR.maxrankpoints)/8
	local percent = per
	local score = 0
	local rank = player.ptsr_rank
	
	if (rank == "D")
		score = player.score
	elseif (rank == "C")
		score = player.score-(per)
	elseif (rank == "B")
		score = player.score-(per*2)
		percent = $*2
	elseif (rank == "A")
		score = player.score-(per*4)
		percent = $*4
	elseif (rank == "S")
		score = player.score-(PTSR.maxrankpoints)
		percent = $*8
	end
	--

	if player.ptsr_rank then
		v.drawScaled(rankpos.x, rankpos.y,FRACUNIT/3, PTSR.r2p(v,player.ptsr_rank), V_SNAPTOLEFT|V_SNAPTOTOP)		
		--luigi budd: the fill
		if per
		and (player.ptsr_rank ~= "P")
			
			local patch = PTSR.r2f(v,player.ptsr_rank)
			local max = percent
			local erm = FixedDiv(score,max)
			
			local scale2 = patch.height*FU-(FixedMul(erm,patch.height*FU))
			
 			if scale2 < 0 then scale2 = FU end
			
			v.drawCropped(rankpos.x,rankpos.y+(scale2/3),
				FU/3,FU/3,
				patch,
				V_SNAPTOLEFT|V_SNAPTOTOP, 
				nil,
				0,scale2,
				patch.width*FU,patch.height*FU
			)
			
		end
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
	local currentGamemode = PTSR.gamemode_list[PTSR.gamemode].name or "Unnamed"
	
	if gametype ~= GT_PTSPICER then return end
	
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
		v.drawScaled(_xcoord - 16*FRACUNIT + 8*FRACUNIT, _ycoord + 8*FRACUNIT, FRACUNIT/4, 
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
	if not PTSR.timeover or PTSR.gameover then return end
	
	local yum = L_FixedDecimal(FRACUNIT + (PTSR.timeover_tics*25),2)
	
	v.drawString(15, 60, "\x85\Pizza Speed: "..yum.."x", V_SNAPTOLEFT|V_SNAPTOTOP, "thin")
end

local untilend_hud = function(v, player)
	if not PTSR.untilend or PTSR.gameover then return end
	local real_timeuntilend = 100 - PTSR.untilend
	local text_timeundilend = "\x88".."Ending in.. "..G_TicsToSeconds(real_timeuntilend).."."..G_TicsToCentiseconds(real_timeuntilend).."s"
	v.drawString(160, 60, text_timeundilend, V_SNAPTOTOP|V_30TRANS|V_ADD, "thin-center")
end

local fade_hud = function(v, player)
	--local t_part1 = 324 -- the end tic of the first scene of the music
	--local t_part2 = 388
	
	local i_tic = PTSR.intermission_tics
	if not PTSR.gameover then return end
	
	local div = min(FixedDiv(i_tic*FU, 129*FRACUNIT), FRACUNIT)
	local div2 = min(FixedDiv(i_tic*FU, PTSR.intermission_act1*FRACUNIT),FRACUNIT)
	local div3 -- go down for div3
		
	local c1 = clamp(0, (PTSR.intermission_act1 + 10) - i_tic, 10); 
	local c2 = clamp(0, (PTSR.intermission_act2 + 20) - i_tic, 20); 
	local c3 = clamp(0, (PTSR.intermission_act_end + 20) - i_tic, 20);
	local c4 = clamp(0, (PTSR.intermission_act2 + 31) - i_tic, 31); -- 2nd fade
	local c5 = clamp(0, (PTSR.intermission_act_end + 10) - i_tic, 9); -- 3rd fade
	
	div3 = min(FixedDiv(c2*FU, 20*FRACUNIT),FRACUNIT)
	
	local fadetween = clamp(0, ease.linear(div, 0, 31), 31)
	local sizetween = ease.linear(div2, FRACUNIT/64, FRACUNIT/2)
	local turntween = ease.inexpo(div2, 0, PTSR.intermission_act1*FU)
	local zonenametween = ease.inquint(div3, 10*FU, -100*FU)
	local scoretween = ease.inquint(div3, 100*FU, 500*FU)
	local rock = PTSR.intermission_act1-(turntween/FU)
	rock = max(0, $)
	
	local turnx = sin(turntween*1800)*rock/2
	local turny = cos(turntween*1800)*rock/2
	
	v.fadeScreen(0xFF00, min(fadetween, 31))
	
	if i_tic < PTSR.intermission_act2 then
		v.fadeScreen(0xFF00, min(fadetween, 31))
	else
		v.drawFill(0,0,v.width(),v.height(),
			c4|V_SNAPTOLEFT|V_SNAPTOTOP
		)
	end
	
	if PTSR:inVoteScreen() then
		--thank you luigi for this code :iwantsummadat:
		--drawfill my favorite :kindlygimmesummadat:
		
		v.drawFill(0,0,v.width(),v.height(),
			--even if there is tearing, you wont see the black void
			skincolors[SKINCOLOR_PURPLE].ramp[15]|V_SNAPTOLEFT|V_SNAPTOTOP|c5<<V_ALPHASHIFT
		)
		
		--need the scale before the loops
		local s = FU
		local bgp = v.cachePatch("PTSR_SECRET_BG")
		--this will overflow in 15 minutes + some change
		local timer = FixedDiv(leveltime*FU,2*FU) or 1
		local bgoffx = FixedDiv(timer,2*FU)%(bgp.width*s)
		local bgoffy = FixedDiv(timer,2*FU)%(bgp.height*s)
		for i = 0,(v.width()/bgp.width)+1
			for j = 0,(v.height()/bgp.height)+1
				--Complicated
				local x = 300
				local y = bgp.height*(j-1)
				local f = V_SNAPTORIGHT|V_SNAPTOTOP|c5<<V_ALPHASHIFT
				local c = v.getColormap(nil,pagecolor)
				
				v.drawScaled(((x-bgp.width*(i-1)))*s-bgoffx,(y)*s+bgoffy,s,bgp,f,c)
				v.drawScaled(((x-bgp.width*i))*s-bgoffx,(y)*s+bgoffy,s,bgp,f,c)
			end
		end
	end
	
	local q_rank = v.cachePatch("PTSR_RANK_UNK")
	
	if i_tic > PTSR.intermission_act1 then
		q_rank = PTSR.r2p(v,player.ptsr_rank)
	end
	
	local shakex = i_tic > PTSR.intermission_act1 and v.RandomRange(-c1/2,c1/2) or 0 
	local shakey = i_tic > PTSR.intermission_act1 and v.RandomRange(-c1/2,c1/2) or 0
	
	if i_tic >= PTSR.intermission_act_end then
		zonenametween = ease.inquint(div3, 10*FU, -100*FU)
		scoretween = ease.inquint(div3, 100*FU, 500*FU)
	end
	
	if i_tic < PTSR.intermission_act_end then
		if i_tic >= PTSR.intermission_act2  then
			local x1,y1 = 160*FU,zonenametween
			local x2,y2 = 160*FU,scoretween
			local x3,y3 = 160*FU,180*FU
			customhud.CustomFontString(v, x1, y1, G_BuildMapTitle(gamemap), "PTFNT", nil, "center", FRACUNIT/2)
			customhud.CustomFontString(v, x2, y2, "SCORE: "..(player.pt_endscore or player.score), "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_BLUE)
			
			customhud.CustomFontString(v, x3, y3, "STILL WORKING ON RANK SCREEN!", "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_RED)
		end
	
		v.drawScaled(160*FRACUNIT - turnx + (shakex*FU), 60*FRACUNIT - turny + (shakey*FU), sizetween, q_rank)
	elseif not PTSR:isVoteOver() then
		local vote_timeleft = (PTSR.intermission_vote_end - i_tic)/TICRATE
		if #PTSR.vote_maplist ~= CV_PTSR.levelsinvote.value then return end
		
		for i=1, CV_PTSR.levelsinvote.value do
			-- current_ = thing in current loop
			local act_vote = clamp(0, i_tic - PTSR.intermission_act_end - (i*4), 35)
			local act_vote_div = clamp(0, FixedDiv(act_vote*FU, 35*FU), 35*FU)
			local act_vote_tween = ease.outexpo(act_vote_div, 500*FU, 200*FU)
			local map_y = 15*FU+((i-1)*30*FU)	
			local current_map = PTSR.vote_maplist[i]
			local current_map_icon = v.cachePatch(G_BuildMapName(current_map.mapnum).."P")
			local current_map_name = mapheaderinfo[current_map.mapnum].lvlttl
			local current_map_act = mapheaderinfo[current_map.mapnum].actnum
			local current_gamemode = current_map.gamemode or 1
			local current_gamemode_info = PTSR.gamemode_list[current_gamemode]
			local current_gamemode_name = current_gamemode_info.name or "Unnamed"
			
			local cursor_patch = v.cachePatch("SLCT1LVL")
			local cursor_patch2 = v.cachePatch("SLCT2LVL")
			local size = FU/4
			local mapoffset = FU*8
			
			v.drawScaled(act_vote_tween, map_y, size, current_map_icon, V_SNAPTORIGHT)
			
			-- Selection Flicker Code
			if player.ptvote_selection == i then
				if (player.ptvote_voted)
					v.drawScaled(act_vote_tween, map_y, size,cursor_patch, V_SNAPTORIGHT)
				else
					if ((leveltime/4)%2 == 0) then 
						v.drawScaled(act_vote_tween, map_y, size,cursor_patch, V_SNAPTORIGHT) 
					else
						v.drawScaled(act_vote_tween, map_y, size,cursor_patch2, V_SNAPTORIGHT) 
					end
				end
			end
			
			-- Map Act
			if current_map_act then
				mapoffset = FU*4
				v.drawString(act_vote_tween+(FU*40), map_y+(FU*9)+mapoffset, "Act "..current_map_act, V_SNAPTORIGHT, "thin-fixed")
			end
			
			-- Map Name
			v.drawString(act_vote_tween+(FU*40), map_y+mapoffset, current_map_name, V_SNAPTORIGHT, "thin-fixed")
			
			if current_gamemode then
				v.drawString(act_vote_tween, map_y, current_gamemode_name, V_SNAPTORIGHT, "small-thin-fixed")
			end
					
			-- Map Votes
			customhud.CustomFontString(v, act_vote_tween-(FU*16), map_y+(FU*4), tostring(PTSR.vote_maplist[i].votes), "PTFNT", V_SNAPTORIGHT, "center", FRACUNIT/2, SKINCOLOR_WHITE)
		end
		
		-- Time Left
		customhud.CustomFontString(v, 160*FU, 10*FU, tostring(vote_timeleft), "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_PINK)
	else
		local chosen_map_icon = v.cachePatch(G_BuildMapName(PTSR.nextmapvoted).."P")
		customhud.CustomFontString(v, 160*FU, 10*FU, G_BuildMapTitle(PTSR.nextmapvoted).." WINS!", "PTFNT", nil, "center", FRACUNIT/2, SKINCOLOR_YELLOW)
		v.drawScaled(120*FU, 75*FU, FU/2, chosen_map_icon)
	end	
	
end

--leaderboard goes after & over the voting screen
local placecolor = {
	[1] = V_YELLOWMAP,
	[2] = 0,
	[3] = V_BROWNMAP
}
local rankcolor = {
	["P"] = "\x89",
	["S"] = "\x82",
	["A"] = "\x85",
	["B"] = "\x88",
	["C"] = "\x83",
	["D"] = "\x86",
}

local leaderboard_hud = function(v,p)
	if not PTSR.gameover then return end
	
	if PTSR:inVoteScreen()
	and #PTSR.leaderboard > 0
		local ldr = PTSR.leaderboard
		local lifepatch
		
		for i = 1,3
			if ldr[i] and ldr[i].valid
				local act_vote = clamp(0, PTSR.intermission_tics - PTSR.intermission_act_end - (i*4), 35)
				local tweendiv = clamp(0, FixedDiv(act_vote*FU, 35*FU), 35*FU)
				local tweenx = ease.outexpo(tweendiv, -400*FU, 95*FU)
				local y = 15*FU+((i-1)*60*FU)+25*FU
				local scale = FU*2
				
				lifepatch = v.getSprite2Patch(ldr[i].skin,
					SPR2_LIFE,
					false,
					A,0,0
				)
				v.drawScaled(tweenx-(lifepatch.width*scale/2),
					y,
					scale,
					lifepatch,
					V_SNAPTOLEFT,
					v.getColormap(nil,ldr[i].skincolor)
				)
				
				local placepatch = v.cachePatch("LDRB_"..i)
				v.drawScaled(tweenx-30*FU,
					y-20*FU,
					FU/2,
					placepatch,
					V_SNAPTOLEFT,
					v.getColormap(nil,ldr[i].skincolor)
				)
				
				v.drawString(tweenx-(lifepatch.width*scale/2),
					y+10*FU,
					ldr[i].name,
					V_SNAPTOLEFT|V_ALLOWLOWERCASE|placecolor[i],
					"thin-fixed-center"
				)
				v.drawString(tweenx-(lifepatch.width*scale/2),
					y+18*FU,
					rankcolor[ldr[i].ptsr_rank]..ldr[i].ptsr_rank.."\x80 - "..ldr[i].score,
					V_SNAPTOLEFT|V_ALLOWLOWERCASE,
					"thin-fixed-center"
				)
			end
		end
	end
end

--local yum = FRACUNIT + (PTSR.timeover_tics*48)

local overtime_hud = function(v, player)
	if not PTSR.timeover then return end
	local left_tween 
	local right_tween 
	
	local text_its = v.cachePatch("OT_ITS")
	local text_overtime = v.cachePatch("OT_OVERTIME")
	
	local anim_len = 5*TICRATE/3 -- 1.6__ secs
	local anim_delay = 1*TICRATE
	local anim_lastframe = (anim_len*2)+(anim_delay)
	local left_end = 0 -- end pos of left
	local right_end = 110 -- end pos of right
	
	local shake_dist = 2
	local shakex_1 = v.RandomRange(-shake_dist, shake_dist)
	local shakey_1 = v.RandomRange(-shake_dist, shake_dist)
	local shakex_2 = v.RandomRange(-shake_dist, shake_dist)
	local shakey_2 = v.RandomRange(-shake_dist, shake_dist)
	
	local div = min(FixedDiv(PTSR.timeover_tics*FU, anim_len*FU), FU)
	local div_end = min(FixedDiv((PTSR.timeover_tics - anim_delay - anim_len)*FU, (anim_len)*FU), FU)

	if PTSR.timeover_tics <= anim_len + anim_delay then -- come in
		left_tween = ease.outquint(div, left_end-400, left_end)
		right_tween = ease.outquint(div, right_end+400, right_end)
	else -- come out
		left_tween = ease.inquint(div_end, left_end, left_end-400)
		right_tween = ease.inquint(div_end, right_end, right_end+400)
	end
	
	if PTSR.timeover_tics <= anim_lastframe then -- draw
		v.drawScaled(
			(left_tween+shakex_1)*FU,
			(80+shakey_1)*FU,
			FU/2,
			text_its
		)
		
		v.drawScaled(
			(right_tween+shakex_2)*FU,
			(80+shakey_2)*FU,
			FU/2,
			text_overtime
		)
		
		/* Beta Text (Broken positions)
			v.drawLevelTitle(left_tween+shakex_1, 100+shakey_1, "It's ", V_REDMAP)
			v.drawLevelTitle(right_tween+shakex_2, 100+shakey_2, "Overtime!", V_REDMAP)
		*/
	end
end

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
customhud.SetupItem("PTSR_fade", hudmodname, fade_hud, "game", 1)
customhud.SetupItem("PTSR_overtime", hudmodname, overtime_hud, "game", 0)
customhud.SetupItem("PTSR_leaderboard", hudmodname, leaderboard_hud, "game", 2)
customhud.SetupItem("rankings", hudmodname, scoreboard_hud, "scores", 1) -- override vanilla rankings hud
customhud.SetupItem("score", hudmodname, score_hud, "game", 0) -- override score hud
customhud.SetupItem("time", hudmodname, nil, "game", 0) -- override time hud (NOTHING)


--PTSR.gamemode[#PTSR.gamemode_list]