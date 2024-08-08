local function barfill(v, x, y, scale, progress, flags)
	local bar = v.cachePatch("HEATMET"..(leveltime/2) % 12)

	local trueprog = 0
	local fill = v.cachePatch("HEATMETF"..(leveltime/2) % 12)
	local ox = x+(2*FU)
	local oy = y+(4*FU)

	while trueprog < progress do
		if trueprog+(fill.width*FU) <= progress then
			v.drawScaled(ox+FixedMul(trueprog, scale), oy, scale, fill, flags)
			trueprog = $+(fill.width*FU)
		else
			v.drawCropped(ox+FixedMul(trueprog, scale), oy,
				scale, scale,
				fill,
				flags or 0,
				nil,
				0,0,
				progress-trueprog,
				fill.height*FU
			)
			trueprog = progress
		end
	end

	v.drawScaled(x, y, scale, bar, flags)
end

local overtimemulti_hud = function(v, player)
	if not PTSR.timeover or PTSR.gameover then return end
	
	local speed = (PTSR.timeover_tics*CV_PTSR.overtime_speed.value)
	local speedtext = L_FixedDecimal(FRACUNIT + speed,2)
	
	local totics = PTSR.timeover_tics
	local t = min(FixedDiv(totics, 5*TICRATE), FU)

	local tw = v.stringWidth("PF SPEED: "..speedtext.."X", V_SNAPTOLEFT|V_SNAPTOTOP, "thin")*FU

	local y = 58*FU
	local x = ease.outcubic(t, -tw, 16*FU)

	local limit = 180*FU
	local prog = min(FixedMul(limit, FixedDiv(speed, FU*2)), limit)

	-- barfill(v, x, y, FU/3, prog, V_SNAPTOBOTTOM)
	v.drawString(x, y, "PIZZA SPEED: "..speedtext.."X", V_SNAPTOTOP|V_SNAPTOLEFT|V_REDMAP|V_20TRANS, "thin-fixed")
end

customhud.SetupItem("PTSR_overtimemulti", ptsr_hudmodname, overtimemulti_hud, "game", 0)