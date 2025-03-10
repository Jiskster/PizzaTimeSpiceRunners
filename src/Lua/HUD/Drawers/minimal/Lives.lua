local minimal_lives = function(v, player)
	local char_icon = {
		x = 15*FU,
		y = 190*FU,
		flags = V_SNAPTOBOTTOM|V_SNAPTOLEFT|V_HUDTRANS
	}
	
	if player.mo then
		local life_icon = v.getSprite2Patch(player.mo.skin,"LIFE", false, A, 0)
		local pf_icon = v.cachePatch("MINIM_PLAYERPF")
		local skin_color = v.getColormap(player.mo.skin, player.mo.color)
		if player.ptsr.pizzaface --Pizza Face Icon!
			v.drawScaled(char_icon.x+(2*FU), char_icon.y+(2*FU), FU/2, pf_icon, char_icon.flags, v.getColormap(TC_DEFAULT, 0, "FullBlack"))
			v.drawScaled(char_icon.x, char_icon.y, FU/2, pf_icon, char_icon.flags)
		elseif life_icon -- Normal player icon
			v.drawScaled(char_icon.x+(2*FU), char_icon.y+(2*FU), FixedMul(FU, skins[player.mo.skin].highresscale), life_icon, char_icon.flags, v.getColormap(TC_DEFAULT, 0, "FullBlack"))
			v.drawScaled(char_icon.x, char_icon.y, FixedMul(FU, skins[player.mo.skin].highresscale), life_icon, char_icon.flags,skin_color)
		end
	end
end

return "Lives", minimal_lives, "game", "minimal"