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

customhud.SetupItem("PTSR_bar", ptsr_hudmodname, bar_hud, "game", 0)