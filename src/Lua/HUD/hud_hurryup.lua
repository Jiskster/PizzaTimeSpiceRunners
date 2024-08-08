local function saxaTween(t, first, second, third)
	if t < FU/2 then
		return ease.outcubic(t*2, first, second)
	else
		return ease.incubic((t*2)-FU, second, third)
	end
end

local hurryup_hud = function(v, player)
	if not PTSR.timeleft then return end
	if PTSR.timeleft > 20*TICRATE then return end
	if not multiplayer then return end
	if not PTSR.client_allowhurryupmusic then return end
	
	local x = 320*FRACUNIT
	local y = 100*FRACUNIT
	local timedif = 20*TICRATE-PTSR.timeleft
	local timestring = G_TicsToMTIME(PTSR.timeleft)

	-- fade the screen if close to overtime but not really overtime
	local t = max(3*TICRATE-PTSR.timeleft, 0)
	local tween = ease.linear(FixedDiv(t, 3*TICRATE), 0, 4)
	v.fadeScreen(SKINCOLOR_WHITE, tween)

	if timedif >= 3*TICRATE then return end

	local tw = customhud.CustomFontStringWidth(v, timestring, "PTFNT", FU)
	local sw = (v.width()/v.dupx())*FU

	x = saxaTween(min(FixedDiv(timedif, 3*TICRATE), FU),
			sw+(tw/2),
			sw/2,
			-(tw/2)
		)

	x = $+v.RandomRange(-2*FU, 2*FU)
	y = $+v.RandomRange(-2*FU, 2*FU)

	customhud.CustomFontString(v, x, y, timestring, "PTFNT", V_SNAPTOLEFT, "center", FRACUNIT, SKINCOLOR_WHITE)
end

customhud.SetupItem("PTSR_hurryup", ptsr_hudmodname, hurryup_hud, "game", 0)