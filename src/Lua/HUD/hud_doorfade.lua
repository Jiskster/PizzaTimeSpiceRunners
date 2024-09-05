addHook("HUD", function(v,p)
	if not PTSR.IsPTSR() then return end
	if not (p and p.ptsr and p.ptsr.door_transitionFadeTime) then return end

	local fadeTime = p.ptsr.door_transitionFadeTime

	if fadeTime > TICRATE/4 then
		fadeTime = $-(TICRATE/4)

		local t = max(0, min(FixedDiv(fadeTime, TICRATE/4), FU))
		local strength = ease.linear(t, 31, 0)
		v.fadeScreen(0xFF00, strength)
	else
		local t = max(0, min(FixedDiv(fadeTime, TICRATE/4), FU))
		local strength = ease.linear(t, 0, 31)
		v.fadeScreen(0xFF00, strength)
	end
end)