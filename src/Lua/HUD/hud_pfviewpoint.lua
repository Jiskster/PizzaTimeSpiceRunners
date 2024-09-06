local pfviewpoint_hud = function(v, p)
	if not PTSR.IsPTSR() then return end
	if not (p.spectator) then return end

    local me = p.realmo

    if not (me and me.valid) then return end

    if not (me.pfviewpoint)
        v.drawString(160,30,
            "Press TOSSFLAG to",
            V_SNAPTOTOP|V_20TRANS,
            "thin-center"
        )
          v.drawString(160,38,
            "spectate Pizzaface!",
            V_SNAPTOTOP|V_20TRANS,
            "thin-center"
        )
      
    else
        local maskdata = PTSR.PFMaskData[PTSR.pizzas[me.pfindex].pizzastyle or 1]

        v.drawString(160,30,
            "VIEWPOINT:",
            V_SNAPTOTOP|V_YELLOWMAP,
            "thin-center"
        )
        v.drawString(160,38,
            maskdata.name,
            V_SNAPTOTOP|V_ALLOWLOWERCASE,
            "thin-center"
        )
        v.drawString(160,46,
            "Press any button to stop",
            V_SNAPTOTOP|V_20TRANS,
            "thin-center"
        )
      
    end
end

customhud.SetupItem("PTSR_pfviewpoint", ptsr_hudmodname, pfviewpoint_hud, "game", 0)