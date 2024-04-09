local overtimemulti_hud = function(v, player)
	if not PTSR.timeover or PTSR.gameover then return end
	
	local yum = L_FixedDecimal(FRACUNIT + (PTSR.timeover_tics*CV_PTSR.overtime_speed.value),2)
	
	v.drawString(15, 60, "\x85\Pizza Speed: "..yum.."x", V_SNAPTOLEFT|V_SNAPTOTOP, "thin")
end

customhud.SetupItem("PTSR_overtimemulti", ptsr_hudmodname, overtimemulti_hud, "game", 0)