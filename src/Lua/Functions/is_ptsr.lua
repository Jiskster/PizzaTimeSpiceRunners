function PTSR.IsPTSR()
	return (not multiplayer and gamestate == GS_LEVEL) or gametype == GT_PTSPICER
end