local FixedMul = FixedMul
local FixedDiv = FixedDiv
local FU = FU
local FixedAngle = FixedAngle
local FRACUNIT = FRACUNIT
local V_SNAPTOBOTTOM = V_SNAPTOBOTTOM
local TICRATE = TICRATE
local min = min
local max = max
local linear = ease.linear
local PTSR = PTSR
local customhud = customhud

local timeafteranimation = 0

local ot_color_table = {
	SKINCOLOR_RED,
	SKINCOLOR_PEPPER,
	SKINCOLOR_SALMON,
	SKINCOLOR_WHITE,
	SKINCOLOR_SALMON,
	SKINCOLOR_PEPPER,
}

--[[@param v videolib]]
/*local function drawBarFill(v, x, y, scale, progress, patch)
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
end*/

local function drawBar(v, x, y, scale, properties)
	local prog = properties and properties.offset or 0
	local length = properties and properties.length or 0
	local bar = v.cachePatch(properties and properties.bar or "SHOWTIMEBAR")
	local fill = v.cachePatch(properties and properties.fill or "BARFILL")
	local ox = properties and properties.fill_xoffset or 0
	local oy = properties and properties.fill_yoffset or 0
	local ow = properties and properties.fill_widthoffset or 0
	local flags = properties and properties.flags or 0
	local color = properties and properties.color

	prog = -fill.width*$

	ox = FixedMul($, scale)
	oy = FixedMul($, scale)

	length = bar.width*$
	length = max(0, ($-ox)+ow)

	while prog < length do
		if prog+(fill.width*FU) < length then
			if prog < 0 then
				v.drawCropped(
					x+ox, y+oy,
					scale, scale,
					fill,
					flags,
					color,
					-prog,
					0,
					(fill.width*FU)-prog,fill.height*FU
				)
			else
				v.drawScaled(x+FixedMul(prog, scale)+ox,
					y+oy,
					scale,
					fill,
					flags,
					color)
			end
			prog = $+(fill.width*FU)
		else
			if prog > 0 then
				v.drawCropped(
					x+FixedMul(prog, scale)+ox, y+oy,
					scale, scale,
					fill,
					flags,
					color,
					0, 0,
					length-prog,
					fill.height*FU
				)
			else
				v.drawCropped(
					x+ox, y+oy,
					scale, scale,
					fill,
					flags,
					color,
					-prog, 0,
					length,
					fill.height*FU
				)
			end
			prog = length
		end
	end
	v.drawScaled(x,y,scale,bar,flags)
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
	if not PTSR.IsPTSR() then 
		return end;
	
	if not PTSR.pizzatime then
		timeafteranimation = 0
		return
	end
	
	local bar_finish = 1475*FRACUNIT/10
	local TLIM = PTSR.maxtime or 0 
	
	local barfill = PTSR.isOvertime() and "BARFILL2" or "BARFILL"
	
	-- "TLIM" is time limit number converted to seconds to minutes
	--example, if CV_PTSR.timelimit.value is 4, it goes to 4*35 to 4*35*60 making it 4 minutes

	local div = ( (FU) / (pthud_expectedtime) )*PTSR.pizzatime_tics
	
	local ese = (PTSR.pizzatime_tics < pthud_expectedtime) and 
	linear(div, pthud_start_pos, pthud_finish_pos) or pthud_finish_pos  -- ese is y axis tween
	
	-- hi saxa here BAR GO DOWN
	local time_offset = 60
	if not multiplayer and PTSR.timeover_tics >= time_offset then
		local tween = (PTSR.timeover_tics-time_offset)*FU/pthud_expectedtime
		ese = tween < FU and linear(tween, pthud_finish_pos, pthud_start_pos) or pthud_start_pos
	end

	local pfEase = min(max(PTSR.pizzatime_tics - CV_PTSR.pizzatimestun.value*TICRATE - 50, 0), 100)
	pfEase = (pfEase*pfEase) * FU / 22
	if not multiplayer then pfEase = 0 end

	local bar = v.cachePatch("SHOWTIMEBAR") -- the orange border
	local bar2 = v.cachePatch("SHOWTIMEBAR2") -- the purple thing

	local pizzaface = v.cachePatch(PTSR.getHudStateFrame("PIZZAFACE_SLEEPING"))
	
	if PTSR.showtime then -- WAKE THE FUCK UP PIZZA FACE!!
		pizzaface = v.cachePatch(PTSR.getHudStateFrame("PIZZAFACE_SHOWTIME"))
	end
	
	local john
	
	if not PTSR.isOvertime() then
		john = v.cachePatch(PTSR.getHudStateFrame("JOHN"))
	else
		john = v.cachePatch(PTSR.getHudStateFrame("REDJOHN"))
	end

	--ease.linear(fixed_t t, [[fixed_t start], fixed_t end])
	if PTSR.maxtime then
		--for the bar length calculations
		local progress = FixedDiv(TLIM*FRACUNIT-PTSR.timeleft*FRACUNIT, TLIM*FRACUNIT)
		local johnx = FixedMul(progress, bar_finish)

		-- Fix negative errors?
		johnx = max(0, $)

		local johnscale = (FU/2) -- + (FU/4)

		-- the bar itself
		drawBar(v, 90*FU, ese, FU/2, {
			offset = FixedDiv(leveltime % (45*TICRATE), 45*TICRATE),
			length = progress,
			fill_xoffset = 5*FU,
			fill_yoffset = 5*FU,
			fill_widthoffset = -5*FU,
			fill = PTSR.timeleft and "BARFILL" or "BARFILL2",
			flags = V_PERPLAYER|V_SNAPTOBOTTOM
		})
		
		 -- angry john...
		v.drawScaled(
			(82*FU) + min(johnx,bar_finish), 
			ese + (6*johnscale), 
			johnscale, 
			john, 
			V_PERPLAYER|V_SNAPTOBOTTOM
		)
		
		-- sleepy pf...
		v.drawScaled(230*FU,
			ese - (8*FU) + pfEase,
			FU/3,
			pizzaface, 
			V_PERPLAYER|V_SNAPTOBOTTOM
		) 
		
		local timestring = G_TicsToMTIME(PTSR.timeleft)
		local x = 165*FRACUNIT
		local y = 176*FRACUNIT + FRACUNIT/2
		local y_offset = (3*FRACUNIT)/2
		
		if PTSR.timeleft or not multiplayer then
			customhud.CustomFontString(v, x, ese + y_offset, timestring, "PTFNT", (V_PERPLAYER|V_SNAPTOBOTTOM), "center", FRACUNIT/2, SKINCOLOR_WHITE)
		else
			local gm_metadata = PTSR.currentModeMetadata()
			
			local ot_text = gm_metadata.overtime_textontime or "OVERTIME!"
			
			FlashSnakeCustomFontString(v, x, ese + y_offset, ot_text, "PTFNT", (V_PERPLAYER|V_SNAPTOBOTTOM), "center", FRACUNIT/2) -- OVERTIME!
		end
		
		timeafteranimation = $ + 1
	end
end

return "Bar", bar_hud