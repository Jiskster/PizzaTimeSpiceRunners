-- split a string
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

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

--this is really simple, no other way to make this
rawset(_G, "P_FlyTo", function(mo, fx, fy, fz, sped, addques)
    if mo.valid
        local flyto = P_AproxDistance(P_AproxDistance(fx - mo.x, fy - mo.y), fz - mo.z)
        if flyto < 1
            flyto = 1
        end
		
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

rawset(_G, "L_DoBrakes", function(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
	mo.momz = FixedMul($,factor)
end)

rawset(_G, "L_SpeedCap", function(mo,limit,factor)
	local spd_xy = R_PointToDist2(0,0,mo.momx,mo.momy)
	local spd, ang =
		R_PointToDist2(0,0,spd_xy,mo.momz),
		R_PointToAngle2(0,0,mo.momx,mo.momy)
	if spd > limit
		if factor == nil
			factor = FixedDiv(limit,spd)
		end
		L_DoBrakes(mo,factor)
		return factor
	end
end)

rawset(_G, "L_FixedDecimal", function(str,maxdecimal)
	if str == nil or tostring(str) == nil
		return "<invalid FixedDecimal>"
	end
	local number = tonumber(str)
	maxdecimal = ($ != nil) and $ or 3
	if tonumber(str) == 0 return '0' end
	local polarity = abs(number)/number
	local str_polarity = (polarity < 0) and '-' or ''
	local str_whole = tostring(abs(number/FRACUNIT))
	if maxdecimal == 0
		return str_polarity..str_whole
	end
	local decimal = number%FRACUNIT
	decimal = FRACUNIT + $
	decimal = FixedMul($,FRACUNIT*10^maxdecimal)
	decimal = $>>FRACBITS
	local str_decimal = string.sub(decimal,2)
	return str_polarity..str_whole..'.'..str_decimal
end)

-- clamp
rawset(_G, "clamp", function(low, value, high)
	if value < low then
		value = low
	elseif value > high then
		value = high
	end
	
	return value
end)

-- inverse clamp
rawset(_G, "iclamp", function(low, value, high)
	if value < low then
		value = low
	elseif value > high then
		value = high
	end
	
	return high-value
end)

rawset(_G, "prtable", function(text, t, prefix, cycles)
    prefix = $ or ""
    cycles = $ or {}

    print(prefix..text.." = {")

    for k, v in pairs(t)
        if type(v) == "table"
            if cycles[v]
                print(prefix.."    "..tostring(k).." = "..tostring(v))
            else
                cycles[v] = true
                prtable(k, v, prefix.."    ", cycles)
            end
        elseif type(v) == "string"
            print(prefix.."    "..tostring(k)..' = "'..v..'"')
        else
			if type(v) == "userdata" and v.valid and v.name
				v = v.name
			end
            print(prefix.."    "..tostring(k).." = "..tostring(v))
        end
    end

    print(prefix.."}")
end)

rawset(_G, "L_ThrustXYZ", function(mo,xyangle,zangle,speed,relative)
	local xythrust = P_ReturnThrustX(nil,zangle,speed)
	local zthrust = P_ReturnThrustY(nil,zangle,speed)
	if relative then
		P_Thrust(mo,xyangle,xythrust)		
		mo.momz = $+zthrust	
	else
		P_InstaThrust(mo,xyangle,xythrust)		
		mo.momz = zthrust	
	end
	return xythrust/FRACUNIT, zthrust/FRACUNIT
end)