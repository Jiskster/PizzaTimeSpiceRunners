--Original script by wired-aunt
--Heavily edited version by Jisk.

--Nearly every division operation is replaced with bit shifting where it is possible

PTSR.w2s_mobjs = {}

function PTSR.addw2sobject(mobj)
	local exists = false
	
	for i,v in ipairs(PTSR.w2s_mobjs) do
		if v == mobj then
			exists = true
			break
		end
	end
	
	if not exists then
		table.insert(PTSR.w2s_mobjs, mobj)
	end
end

local string_linebreak = function(view, message, flags)
	--print("string_linebreak( "..message..", "..flags..")")
	local linelist = {}
	local width = 130
	local maxwidth = 170
	local maxlines = 2
	local i = 1
	local line = ""
	while i <= string.len(message) and #linelist < maxlines
		local nextletter = string.sub(message, i, i)
		--print("nextletter: "..nextletter)
		if not (line == "" and nextletter == " ")
			if view.stringWidth(line, flags, "thin") > maxwidth
				if (#linelist == maxlines - 1)
					linelist[#linelist + 1] = line
				else
					linelist[#linelist + 1] = line.."-"
				end
				line = ""
				--print("NEW LINE")
				continue
			elseif view.stringWidth(line, flags, thin) > width and nextletter == " "
				linelist[#linelist + 1] = line
				line = ""
				--print("NEW LINE")
				continue
			else
				line = $ + string.sub(message, i, i)
				--print("	added")
			end
		else
			--print("	invalid space, skipping")
		end
		i = $ + 1
		if i > string.len(message)
			linelist[#linelist + 1] = line
			line = ""
			--print("FINISH, NEW LINE")
		end
	end
	if (#linelist == maxlines)
		linelist[maxlines] = $ .. "..."
	end
	return linelist
end

CV_RegisterVar({
	name = "ptsr_nametags",
	defaultvalue = 1,
	PossibleValue = CV_OnOff
})

hud.add( function(v, player, camera)
	if not CV_FindVar("ptsr_nametags").value
		return
	end
	
	if (not PTSR.IsPTSR()) then return end
	if PTSR.gameover then return end

	if (player.awayviewmobj and player.spectator)
		return
	end

	for _, tmo in pairs(PTSR.w2s_mobjs) do
		if not tmo or not tmo.valid then continue end
		if tmo.player and player == tmo.player then continue end
		if tmo.player and tmo.player.valid then
			if not tmo.player.ptsr.pizzaface then
				continue
			end
		end
		
		if not (tmo.type == MT_PIZZA_ENEMY or tmo.type == MT_PLAYER 
				or tmo.type == MT_PT_DEATHRING or tmo.type == MT_ALIVEDUSTDEVIL
				or tmo.type == MT_PT_JUGGERNAUTCROWN) then
			continue
		end
		
		--WAIT!!!!! check if we're spectating this pf first before doing anything else!
		if (tmo.type == MT_PIZZA_ENEMY)
		and (tmo == player.awayviewmobj)
			continue
		end
		
		--if not tmo.player and not mobjinfo[tmo.type].npc_name then continue end

		--how far away is the other mobj?
		local distance = R_PointToDist(tmo.x, tmo.y) 

		local distlimit = 16000
		if distance > distlimit*FRACUNIT then continue end

		--flipcam adjustment
		local flip = 1
		if displayplayer.mo and displayplayer.mo.valid
			flip = P_MobjFlip(displayplayer.mo)
		end

		local tmoz = tmo.z
		if (flip == -1)
			tmoz = $ + tmo.height
		end
		if spectator
			tmoz = $ - 48*tmo.scale
		end

		if (tmo.type ~= MT_PLAYER) then
			if (tmo.flags2 & MF2_DONTDRAW) then
				continue
			end
		end

		local result = SG_ObjectTracking(v,player,camera,{
			x = tmo.x,
			y = tmo.y,
			z = tmoz
		})
		if not result.onScreen then continue end

		result.y = $+(18*result.scale)

		local name = "NPC"
		local textcolor = SKINCOLOR_GREEN
		local namecolor = SKINCOLOR_ORANGE
		local text_size = FRACUNIT/4
		
		local nodrawstuff = false
		
		if tmo.type == MT_PIZZA_ENEMY or tmo.type == MT_PLAYER then
			local maskdata = nil
			if tmo.type == MT_PLAYER then
				maskdata = PTSR.PFMaskData[tmo.player.ptsr.pizzastyle or 1]
			else
				maskdata = PTSR.PFMaskData[tmo.pizzastyle or 1]
			end
			if not maskdata then
				maskdata = PTSR.PFMaskData[1]
			end
			name = (maskdata.name or "PIZZAFACE"):upper()
			namecolor = (maskdata.tagcolor or SKINCOLOR_ORANGE)
		elseif tmo.type == MT_PT_DEATHRING then
			name = "DEATH RING"
			text_size = FRACUNIT/6
			namecolor = SKINCOLOR_SHAMROCK
		elseif tmo.type == MT_ALIVEDUSTDEVIL then
			name = "TORNADO"
			text_size = FRACUNIT/4
			namecolor = SKINCOLOR_GREY
		elseif tmo.type == MT_PT_JUGGERNAUTCROWN then -- GAMEMODE: JUGGERNAUT exclusive
			nodrawstuff = true
		end

		local namefont = "center"
		local ringfont = "center"
		local charwidth = 5
		local lineheight = 8
		--if distance > 500*FRACUNIT then
			--namefont = "small-thin-fixed-center"
			--ringfont = "small-thin-fixed-center"
			--charwidth = 4
			--lineheight = 4
		--end
		

		local flash = (leveltime/(TICRATE/6))%2 == 0
		if flash and tmo.health == 0 then
			textcolor = SKINCOLOR_RED
		end
	
		--local nameflags = skincolors[tmo.skincolor].chatcolor
		local distedit = max(0, distance - ((distlimit*FU)>>1)) * 2
		local trans = min(9, (((distedit * 10) >> 16) / distlimit)) * V_10TRANS
		
		local dsm = displayplayer.realmo

		-- the z axis exists too yknow
		local dx = tmo.x-dsm.x
		local dy = tmo.y-dsm.y
		local dz = tmo.z-dsm.z
		local obj_dist = (FixedHypot(FixedHypot(dx,dy),dz))/FU
		obj_dist = $/10
		
		if name then
			local gm_metadata = PTSR.currentModeMetadata()

			--luigi budd: regular FU values are too big to easily discern distance
			--from the face, so divide by 10 to help with uh..... telling the distance
			
			if tmo.type == MT_PT_DEATHRING then
				if gm_metadata.allowrevive then
					name = "REVIVE RING"
				else
					name = $ + "["..tostring(tmo.rings_kept).."x]"
				end
			end
			
			if not nodrawstuff then
				customhud.CustomFontString(v, result.x, result.y, name, "PTFNT", trans, namefont, text_size, namecolor)
				customhud.CustomFontString(v, result.x, result.y+(4*FRACUNIT), obj_dist.."fu", "PTFNT", trans, namefont, text_size, SKINCOLOR_WHITE)
			end
		end
		
		-- GAMEMODE: JUGGERNAUT exclusive
		if tmo.type == MT_PT_JUGGERNAUTCROWN and not P_CheckSight(tmo, displayplayer.realmo) then
			local crown_spr = v.getSpritePatch(SPR_C9W3)
			v.drawScaled(result.x, result.y, FU/4, crown_spr)
			v.drawString(result.x, result.y+(12*FRACUNIT), obj_dist.."fu", nil, "thin-fixed-center")
		end
		--v.drawString(hpos, vpos, name, nameflags|trans|V_ALLOWLOWERCASE, namefont)
		--v.drawString(hpos, vpos+(lineheight*FRACUNIT), health, rflags|trans|V_ALLOWLOWERCASE, ringfont)

		if tmo.player and not tmo.player.lastmessagetimer then continue end

		if tmo.player and tmo.player.valid then
			local chat_lifespan = 2*TICRATE
			chat_lifespan = $1 + #tmo.player.lastmessage * TICRATE / 18 or 0

			if tmo.player and tmo.player.lastmessage 
			and leveltime < tmo.player.lastmessagetimer+chat_lifespan then
				local flags = V_GRAYMAP
				local thelines = string_linebreak(v, tmo.player.lastmessage, flags)
				for i = 1, #thelines
					v.drawString(result.x, result.y+(lineheight*(i+1)*FRACUNIT), thelines[i], flags|trans|V_ALLOWLOWERCASE, namefont)
				end
			end
		end
	end
end, "game")

addHook("PlayerMsg", function(player, typenum, target, message)
	if typenum ~= 0 then
		return false --only for normal global messages
	end
	if ignorelist != nil and #ignorelist
		for i = 1, #ignorelist
			if ignorelist[i] == player
				return false
			end
		end
	end

	player.lastmessage = message
	player.lastmessagetimer = leveltime
	return false
end)

local consoleplayer_camera = nil
hud.add(function(v, player, camera)
	consoleplayer_camera = camera
end, "game")

-- clear every frame
addHook("PreThinkFrame", function()
	PTSR.w2s_mobjs = {}
end)

addHook("MapLoad", function()
	for player in players.iterate() do
		player.lastmessage = nil
		player.lastmessagetimer = nil
	end
end)