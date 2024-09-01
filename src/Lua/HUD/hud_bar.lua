local timeafteranimation = 0

local BARXOFF = 5*FU
local BARYOFF = 5*FU
local BARWIDTH = 295*FU
local BARSECTIONWIDTH = 172*FU
local TIMEMODFAC = 4*BARSECTIONWIDTH/FU
local ot_color_table = {
	SKINCOLOR_RED,
	SKINCOLOR_PEPPER,
	SKINCOLOR_SALMON,
	SKINCOLOR_WHITE,
	SKINCOLOR_SALMON,
	SKINCOLOR_PEPPER,
}

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

-- always give scale or die
local function FlashSnakeCustomFontString(v, x, y, str, fontName, flags, align, scale)
	if not (type(str) == "string") then
		warn("No string given in FlashSnakeCustomFontString");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in FlashSnakeCustomFontString");
		return;
	end

	local font = customhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in FlashSnakeCustomFontString");
		return;
	end

	if (type(scale) != "number")
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale != nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale != nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono != nil and scale != nil) then
		mono = $1 * scale;
	end
	
	local nextx = x;

	if (align == "right") then
		nextx = $1 - customhud.CustomFontStringWidth(v, str, fontName, scale);
	elseif (align == "center") then
		nextx = $1 - (customhud.CustomFontStringWidth(v, str, fontName, scale) / 2);
	end

	for i = 1,str:len() do
		local otcolornum = 1+(((leveltime+i)/4)%#ot_color_table)
		local iMul = (i*4)
		local iMulAndLT = leveltime+iMul
		local yAdd = cos(FixedAngle(iMulAndLT*FRACUNIT*10))*4
		local nextByte = str:byte(i,i);
		nextx = customhud.CustomFontChar(v, nextx, y+yAdd, nextByte, fontName, flags, scale, ot_color_table[otcolornum]);
	end
end

local bar_hud = function(v, player)
	if not PTSR.IsPTSR() then return end
	if PTSR.pizzatime then

		local bar_finish = 1475*FRACUNIT/10
		local TLIM = PTSR.maxtime or 0 
		
		local barfill = PTSR.isOvertime() and "BARFILL2" or "BARFILL"
		
		-- "TLIM" is time limit number converted to seconds to minutes
		--example, if CV_PTSR.timelimit.value is 4, it goes to 4*35 to 4*35*60 making it 4 minutes

		local div = ( (FU) / (pthud_expectedtime) )*PTSR.pizzatime_tics
		
		local ese = (PTSR.pizzatime_tics < pthud_expectedtime) and 
		ease.linear(div, pthud_start_pos, pthud_finish_pos) or pthud_finish_pos  -- ese is y axis tween
		
		-- hi saxa here BAR GO DOWN
		local time_offset = 60
		if not multiplayer and PTSR.timeover_tics >= time_offset then
			local tween = (PTSR.timeover_tics-time_offset)*FU/pthud_expectedtime
			ese = tween < FU and ease.linear(tween, pthud_finish_pos, pthud_start_pos) or pthud_start_pos
		end

		local pfEase = min(max(PTSR.pizzatime_tics - CV_PTSR.pizzatimestun.value*TICRATE - 50, 0), 100)
		pfEase = (pfEase*pfEase) * FU / 22
		if not multiplayer then pfEase = 0 end

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
			
			if PTSR.timeleft or not multiplayer then
				customhud.CustomFontString(v, x, ese + y_offset, timestring, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2, SKINCOLOR_WHITE)
			else
				local gm_metadata = PTSR.currentModeMetadata()
				
				local ot_text = gm_metadata.overtime_textontime or "OVERTIME!"
				
				FlashSnakeCustomFontString(v, x, ese + y_offset, ot_text, "PTFNT", (V_SNAPTOBOTTOM), "center", FRACUNIT/2)
			end
			timeafteranimation = $ + 1
		end
	else
		timeafteranimation = 0
	end
end

customhud.SetupItem("PTSR_bar", ptsr_hudmodname, bar_hud, "game", 0)