local RANKMUS = PTSR.RANKMUS

function PTSR.EndGame()
	if not PTSR.gameover then
		PTSR.gameover = true
		print("GAME OVER!")
		
		PTSR.endscreen_phase_tics = PTSR.results_act1
		
		if consoleplayer and consoleplayer.valid then
			S_ChangeMusic(RANKMUS[consoleplayer.ptsr.rank], false, player)
			mapmusname = RANKMUS[consoleplayer.ptsr.rank]
		end
		
		if PTSR.leaderboard and PTSR.leaderboard[1] 
		and PTSR.leaderboard[1].valid then
			local winnerplayer = PTSR.leaderboard[1]
			
			if winnerplayer.ptsr then
				winnerplayer.ptsr.isWinner = true
			end
		end
		
		for p in players.iterate do
			if p and p.ptsr and PTSR.PlayerHasCombo(p) then
				PTSR:EndCombo(p)
			end
		end
		
		PTSR_DoHook("ongameend")
	end
end