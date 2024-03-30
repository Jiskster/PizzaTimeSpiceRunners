local score_hud = function(v, player)
	v.drawScaled(24*FU, 15*FU, FU/3, v.cachePatch("_SCOREOFPIZZA"), (V_SNAPTOLEFT|V_SNAPTOTOP))
	customhud.CustomFontString(v, 58*FU, 11*FU, tostring(player.score), "SCRPT", (V_SNAPTOLEFT|V_SNAPTOTOP), "center", FRACUNIT/3)
end

customhud.SetupItem("score", ptsr_hudmodname, score_hud, "game", 0) -- override score hud
