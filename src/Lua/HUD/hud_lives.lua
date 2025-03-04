local minimal_lives = function(v, p)
	if isminimalhud
		local char_icon = {
			x = 15*FU,
			y = 190*FU,
			flags = V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_HUDTRANS
		}
		if p.mo
			local life_icon = v.getSprite2Patch(p.mo.skin,"LIFE", false, A, 0)
			local pf_icon = v.cachePatch("MINIM_PLAYERPF")
			local skin_color = v.getColormap(p.mo.skin, p.mo.color)
			if p.ptsr.pizzaface --Pizza Face Icon!
				v.drawScaled(char_icon.x+(2*FU), char_icon.y+(2*FU), FU/2, pf_icon, char_icon.flags, v.getColormap(TC_DEFAULT, 0, "FullBlack"))
				v.drawScaled(char_icon.x, char_icon.y, FU/2, pf_icon, char_icon.flags)
			else -- Normal player icon
				v.drawScaled(char_icon.x+(2*FU), char_icon.y+(2*FU), FixedMul(FU, skins[p.mo.skin].highresscale), life_icon, char_icon.flags, v.getColormap(TC_DEFAULT, 0, "FullBlack"))
				v.drawScaled(char_icon.x, char_icon.y, FixedMul(FU, skins[p.mo.skin].highresscale), life_icon, char_icon.flags,skin_color)
			end
		end
		if hud.enabled("lives")
			hud.disable("lives")
		end
	elseif not hud.enabled("lives")
		hud.enable("lives")
	end
end

customhud.SetupItem("PTSR_minimallives", ptsr_hudmodname, minimal_lives, "game", 0)