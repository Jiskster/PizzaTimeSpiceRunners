local hudmodname = "jiskpizzatime"

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

local bar_hud = function(v,player)
	if gametype ~= GT_PTSPICER then return end
	if PTSR.pizzatime then
		local expectedtime = TICRATE*3
		local start = 300*FRACUNIT -- animation position start
		local finish = 175*FRACUNIT -- animation position end
		local bar_finish = 1475*FRACUNIT/10
		local TLIM = CV_PTSR.timelimit.value*TICRATE*60 
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
		if CV_PTSR.timelimit.value then

			
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
						customhud.CustomFontString(v, x, y, timestring, "PTFNT", (V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT), "center", FRACUNIT/2)
					else
						if PTSR.timeleft then
							customhud.CustomFontString(v, x, y, timestring, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2)
						else
							customhud.CustomFontString(v, x, y, "TIME OVER!", "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2)
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

local itspizzatime_hud = function(v,player)
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

local tooltips_hud = function(v,player)
	if gametype ~= GT_PTSPICER then return end
	local exitingCount, playerCount = PTSR_COUNT()
	local practicemodetext = "\x84\* PRACTICE MODE *"
	local dynamiclapstext = "\x82\* DYNAMIC LAPS: "..PTSR.laps.." / "..PTSR.dynamic_maxlaps.." *"
	local lapsandmaxlapstext = "\x82\* LAPS: "..PTSR.laps.." / "..CV_PTSR.maxlaps.value.." *"
	local lapstext = "\x82\* LAPS: "..PTSR.laps.." *"
	local lapsperplayertext = "\x82\* YOUR LAPS: "..player.lapsdid.." / "..CV_PTSR.maxlaps_perplayer.value.." *"


	if (not player.pizzaface) and (player.exiting) and (not PTSR.quitting) and (player.playerstate ~= PST_DEAD) and (exitingCount ~= playerCount) then
		v.drawString(160, 120, "\x85\* Press FIRE to try a new lap! *", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
	end
	if PTSR.pizzatime then

		
		if player.stuntime then
			v.drawString(160, 100, "You will be unfrozen in: "..player.stuntime/TICRATE.. " seconds.", V_TRANSLUCENT|V_SNAPTOBOTTOM|V_PERPLAYER, "thin-center")
		end
		

		if timeafteranimation then
			if timeafteranimation < 10 then
				if (playerCount == 1) then
					v.drawString(165, 157, practicemodetext, V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
				end
				if player.pizzaface then
					if player.pizzachargecooldown then
						v.drawString(165, 157, "\x85\* COOLING DOWN *", V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
					elseif player.pizzacharge then
						local percentage = FixedMul(FixedDiv(1*FRACUNIT, 35*FRACUNIT),35*FRACUNIT)>>FRACBITS
						
						v.drawString(165, 157, "\x85\* CHARGING \$percentage\% *", V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
					else
						v.drawString(165, 157, "\x85\* HOLD FIRE TO TELEPORT *", V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
					end
				end
				-- Early returns start here --
				if player.pizzaface and CV_PTSR.lappingtype.value == 2 then return end
				if CV_PTSR.lappingtype.value == 2 then
					v.drawString(165, 165, lapsperplayertext , V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
					return
				end
				if CV_PTSR.dynamiclaps.value then
					v.drawString(165, 165, dynamiclapstext , V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
					return
				end
				
				if CV_PTSR.maxlaps.value then
					v.drawString(165, 165, lapsandmaxlapstext, V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
					return
				else
					v.drawString(165, 165, lapstext, V_SNAPTOBOTTOM|(10-timeafteranimation)<<V_ALPHASHIFT, "thin-center")
					return
				end
			else
				if (playerCount == 1) then
					v.drawString(165, 157,practicemodetext , V_SNAPTOBOTTOM, "thin-center")
				end
				if player.pizzaface then
					if player.pizzachargecooldown then
						v.drawString(165, 157, "\x85\* COOLING DOWN *", V_SNAPTOBOTTOM, "thin-center")
					elseif player.pizzacharge then
						local percentage = (FixedDiv(player.pizzacharge*FRACUNIT, 35*FRACUNIT)*100)>>FRACBITS
						
						v.drawString(165, 157, "\x85\* CHARGING \$percentage\% *", V_SNAPTOBOTTOM, "thin-center")
					else
						v.drawString(165, 157, "\x85\* HOLD FIRE TO TELEPORT *", V_SNAPTOBOTTOM, "thin-center")
					end
				end
				-- Early returns start here --
				if player.pizzaface and CV_PTSR.lappingtype.value == 2 then return end
				if CV_PTSR.lappingtype.value == 2 then
					v.drawString(165, 165, lapsperplayertext , V_SNAPTOBOTTOM, "thin-center")
					return
				end
				
				if CV_PTSR.dynamiclaps.value then
					v.drawString(165, 165, dynamiclapstext, V_SNAPTOBOTTOM, "thin-center")
					return
				end
				
				if CV_PTSR.maxlaps.value then
					v.drawString(165, 165, lapsandmaxlapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-center")
					return
				else
					v.drawString(165, 165, lapstext, V_PERPLAYER|V_SNAPTOBOTTOM, "thin-center")
					return
				end
			end
		end
	end
end

local lap_hud = function(v,player)
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

local rank_hud = function(v,player)
	if gametype ~= GT_PTSPICER then return end
	if player.pizzaface then return end
	if player.ptje_rank then
		v.drawScaled(15*FRACUNIT,55*FRACUNIT,FRACUNIT/3, PTSR.r2p(v,player.ptje_rank), V_SNAPTOLEFT|V_SNAPTOTOP)
		if player.timeshit then
			v.drawScaled(15*FRACUNIT,55*FRACUNIT,FRACUNIT/3, PTSR.r2p(v, "BROKEN"), V_SNAPTOLEFT|V_SNAPTOTOP|V_20TRANS)
		end
	end
end

local event_hud = function(v,player)
	if gametype ~= GT_PTSPICER then return end
	if not PTSR.currentEvent then return end
	local event = PTSR.currentEvent
	if leveltime > TICRATE*5 then return end
	if event.name == "mirrorPrelude" then
		v.drawNameTag(160,  80, "MAGIC MIRROR NEXT ROUND", V_CENTERNAMETAG, SKINCOLOR_ICY, SKINCOLOR_AQUA)
		v.drawString(160, 120, "everyone will be forced to use", 0, "center")
		v.drawString(160, 130, "the skin of the highest scoring player", 0, "center")
	end
	if event.name == "super" then
		v.drawNameTag(160,  80, "EVERYONE SUPER", V_CENTERNAMETAG, SKINCOLOR_GOLD, SKINCOLOR_RUST)
		v.drawString(160, 120, "go nuts", 0, "center")
	end
	if event.name == "mini" then
		v.drawNameTag(160,  80, "MINI MUSHROOM", V_CENTERNAMETAG, SKINCOLOR_BLUE, SKINCOLOR_WHITE)
		v.drawString(160, 120, "have fun being small", 0, "center")
	end
end

local faceswap_hud = function(v,player)
	if gametype ~= GT_PTSPICER then return end
	if not (player.pizzaface and leveltime) then return end
	if player.stuntime and PTSR.pizzatime_tics < TICRATE*CV_PTSR.pizzatimestun.value+20 then
		v.drawString(160, 150, "Move left and right to swap faces", V_ALLOWLOWERCASE, "small-center")
	end
end

customhud.SetupItem("ptje_bar", hudmodname, bar_hud, "game", 0)
customhud.SetupItem("ptje_itspizzatime", hudmodname, itspizzatime_hud, "game", 0)
customhud.SetupItem("ptje_tooltips", hudmodname, tooltips_hud, "game", 0)
customhud.SetupItem("ptje_lap", hudmodname, lap_hud, "game", 0)
customhud.SetupItem("ptje_rank", hudmodname, rank_hud, "game", 0)
customhud.SetupItem("PTSR_event", hudmodname, event_hud, "game", 0)
customhud.SetupItem("PTSR_faceswap", hudmodname, faceswap_hud, "game", 0)
