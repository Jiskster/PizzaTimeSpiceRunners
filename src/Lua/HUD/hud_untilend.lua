-- Draws a timer when the game is about to end.

local untilend_hud = function(v, player)
	if not PTSR.untilend or PTSR.gameover then return end
	local real_timeuntilend = 100 - PTSR.untilend
	local text_timeundilend = "\x88".."Ending in.. "..G_TicsToSeconds(real_timeuntilend).."."..G_TicsToCentiseconds(real_timeuntilend).."s"
	v.drawString(160, 60, text_timeundilend, V_SNAPTOTOP|V_30TRANS|V_ADD, "thin-center")
end

customhud.SetupItem("PTSR_untilend", ptsr_hudmodname, untilend_hud, "game", 0)