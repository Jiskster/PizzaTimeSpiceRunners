addHook("PlayerThink", function(p)
	if not PTSR.IsPTSR() then 
		return end;
		
	if not (p and p.ptsr) then 
		return end;

	p.ptsr.score_shakeTime = max(0, $-p.ptsr.score_shakeDrainTime)
end)