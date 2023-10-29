rawset(_G, "GetInternalFontWidth", function(str, font)

	-- No string
	if not (str) then return 0 end

	local width = 0

	for i=1,#str do
		-- (Using patch width by the way)
		if (font == "STCFN") then -- default font
			width = $1+8
		elseif (font == "TNYFN") then
			width = $1+7
		elseif (font == "LTFNT") then
			width = $1+20
		elseif (font == "TTL") then
			width = $1+29
		elseif (font == "CRFNT" or font == "NTFNT") then -- TODO: Credit font centers wrongly
			width = $1+16
		elseif (font == "NTFNO") then
			width = $1+20
		else
			width = $1+27
		end
	end
	return width
end)

rawset(_G, "drawSuperText", function(v, x, y, str, parms)

	-- Scaling
	local scale = (parms and parms.scale) or 1*FRACUNIT
	local hscale = (parms and parms.hscale) or 0
	local vscale = (parms and parms.vscale) or 0
	local yscale = (8*(FRACUNIT-scale))
	-- Spacing
	local xspacing = (parms and parms.xspace) or 0 -- Default: 8
	local yspacing = (parms and parms.yspace) or 4
	-- Text Font
	local font = (parms and parms.font) or "STCFN"
	local uppercs = (parms and parms.uppercase) or false
	local align = (parms and parms.align) or nil
	local flags = (parms and parms.flags) or 0
	local fixed = (parms and parms.fixed) or false

	if font == 'PTFNT'
		scale = $ - FRACUNIT/2 - FRACUNIT/4
	end
	
	-- Split our string into new lines from line-breaks
	local lines = {}

	for ls in str:gmatch("[^\r\n]+") do
		table.insert(lines, ls)
	end

	-- For each line, set some stuff up
	for seg=1,#lines do
		
		local line = lines[seg]
		-- Fixed Position
		local fx = x << FRACBITS
		local fy = y << FRACBITS
		if fixed
			fx = x
			fy = y
		end
		-- Offset position
		local off_x = 0
		local off_y = 0
		-- Current character & font patch (we assign later later instead of local each char)
		local char
		local charpatch

		-- Alignment options
		if (align) then
			-- TODO: not working correctly for CRFNT
			if (align == "center") then
				if not fixed
					fx = $1-FixedMul( (GetInternalFontWidth(line, font)/2), scale) << FRACBITS -- accs for scale
				else
					fx = $1-FixedMul( (GetInternalFontWidth(line, font)/2), scale)
				end
				-- 	fx = $1-FixedMul( (v.stringWidth(line, 0, "normal")/2), scale) << FRACBITS
			elseif (align == "right") then
				if not fixed
					fx = $1-FixedMul( (GetInternalFontWidth(line, font)), scale) << FRACBITS
				else
					fx = $1-FixedMul( (GetInternalFontWidth(line, font)), scale)
				end
				-- fx = $1-FixedMul( (v.stringWidth(line, 0, "normal")), scale) << FRACBITS
			end
		end

		-- Go over each character in the line
		for strpos=1,#line do
			local drawable = true
			-- get our character step by step
			char = line:sub(strpos, strpos)

			-- TODO: custom skincolors will make a mess of this since the charlimit is 255
			-- Set text color, inputs, and more through special characters
			-- Referencing skincolors https://wiki.srb2.org/wiki/List_of_skin_colors

			-- TODO: effects?
			-- if (char:byte() == 161) then
			-- 	continue
			-- end
			-- print(strpos<<27)
			-- off_x = (cos(v.RandomRange(ANG1, ANG10)*leveltime))
			-- off_y = (sin(v.RandomRange(ANG1, ANG10)*leveltime))
			-- local step = strpos%3+1
			-- print(step)
			-- off_x = cos(ANG10*leveltime)*step
			-- off_y = sin(ANG10*leveltime)*step

			-- Skip and replace non-existent space graphics
			if not char:byte() or char:byte() == 32 then
				fx = $1+2*scale
				drawable = false
			end

			-- Unavoidable non V_ALLOWLOWERCASE flag toggle (exclude specials above 210)
			if (uppercs or (font == "CRFNT" or font == "NTFNT" or font == 'PTFNT'))
			and not (char:byte() >= 210) then
				char = tostring(char):upper()
			end

			-- transform the char to byte to a font patch
			charpatch = v.cachePatch( string.format("%s%03d", font, string.byte(char)) )

			-- Draw char patch
			if drawable
				v.drawStretched(
					fx+off_x, fy+off_y+yscale,
					scale+hscale, scale+vscale, charpatch, flags)
				-- Sets the space between each character using font width
			end
			fx = $1+(xspacing+charpatch.width)*scale
			--fy = $1+yspacing*scale
		end

		-- Break new lines by spacing and patch width for semi-accurate spacing
		y = $1+(yspacing+charpatch.height)*scale >> FRACBITS 
	end	

end)

rawset(_G, "L_ZCollide", function(mo1,mo2)
	if mo1.z > mo2.height+mo2.z then return false end
	if mo2.z > mo1.height+mo1.z then return false end
	return true
end)

rawset(_G, "G_TicsToMTIME", function(tics, hascents)
	if tics == nil then return "??:??" end
	local minutes = tostring(G_TicsToMinutes(tics))
	local seconds = tostring(G_TicsToSeconds(tics))
	local cents = tostring(G_TicsToCentiseconds(tics))		

    if minutes:len() < 2 then
        minutes = $
    end

    if seconds:len() < 2 then
		seconds = "0"..$
    end
	
	if cents:len() < 2 then
        cents = $
    end
	
	if not hascents then
		return minutes..":"..seconds
	else
		return minutes..":"..seconds.."."..cents
	end
end)

rawset(_G, "P_FlyTo", function(mo, fx, fy, fz, sped, addques) --A very useful command honestly.
    if mo.valid
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - mo.z)
        if flyto < 1
            flyto = 1
        end
        --local anglesucc = R_PointToAngle2(mo.x, mo.y, fx, fy)
        
        if addques
            mo.momx = $ + FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = $ + FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = $ + FixedMul(FixedDiv(fz - mo.z, flyto), sped)
        else
            mo.momx = FixedMul(FixedDiv(fx - mo.x, flyto), sped)
            mo.momy = FixedMul(FixedDiv(fy - mo.y, flyto), sped)
            mo.momz = FixedMul(FixedDiv(fz - mo.z, flyto), sped)
        end    
    end    
end)