local RANKMUS = PTSR.RANKMUS

function PTSR.EndGame()
	if not PTSR.gameover then
		PTSR.gameover = true
		print("GAME OVER!")
		
		if consoleplayer and consoleplayer.valid then
			S_ChangeMusic(RANKMUS[consoleplayer.ptsr.rank], false, player)
			mapmusname = RANKMUS[consoleplayer.ptsr.rank]
		end
		
		for p in players.iterate do
			if p and p.ptsr and PTSR.PlayerHasCombo(p) then
				PTSR:EndCombo(p)
			end
		end
		
		PTSR_DoHook("ongameend")
	end
end