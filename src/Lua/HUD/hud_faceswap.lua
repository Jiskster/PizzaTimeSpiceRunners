local faceswap_hud = function(v, player)
	if gametype ~= GT_PTSPICER then return end
	if not (player.pizzaface and leveltime) then return end
	if player.stuntime and PTSR.pizzatime_tics < TICRATE*CV_PTSR.pizzatimestun.value+20 then
		v.drawString(160, 150, "Move left and right to swap faces", V_ALLOWLOWERCASE, "small-center")
	end
end

customhud.SetupItem("PTSR_faceswap", ptsr_hudmodname, faceswap_hud, "game", 0)