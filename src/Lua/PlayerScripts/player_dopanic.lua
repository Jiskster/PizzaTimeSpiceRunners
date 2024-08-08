PTSR.panicblacklist = {}
PTSR.panicspr2 = {}

PTSR.panicblacklist["takisthefox"] = true

states[freeslot "S_PTSR_PANIC"] = {
	sprite = SPR_PLAY,
	frame = SPR2_CNT1|A,
	tics = 3,
	nextstate = S_PTSR_PANIC
}

-- hi, saxa here, this is the panic sprite stuff for ptsr
-- take the example above to add ur own blacklist
-- to make ur own spr2 available for panic, do this:
-- PTSR.panicspr2["skinhere"] = SPR2_STND
-- where SPR2_STND is ur sprite

addHook("PlayerThink", function(p)
	if not PTSR.IsPTSR() then return end
	if not PTSR.pizzatime then return end
	if not p.mo then return end
	if PTSR.panicblacklist[p.mo.skin] then return end

	if (p.mo.state == S_PLAY_STND
	or p.mo.state == S_PLAY_WAIT)
	and p.rmomx == 0
	and p.rmomy == 0
	and not (p.pflags & (PF_SPINNING)) then
		p.mo.state = S_PTSR_PANIC
	end

	if (p.rmomx ~= 0
	or p.rmomy ~= 0)
	and p.mo.state == S_PTSR_PANIC then
		p.mo.state = S_PLAY_WALK
	end
end)

addHook("PostThinkFrame", do
	for p in players.iterate do
		if not (PTSR.IsPTSR() and p and p.mo) then continue end

		if p.mo.state == S_PTSR_PANIC
		and PTSR.panicspr2[p.mo.skin] then
			-- fucking hate pcall but the sprites stuff is ass
			pcall(function()
				local spr2 = PTSR.panicspr2[p.mo.skin]
				local numframes = skins[p.mo.skin].sprites[spr2].numframes

				p.mo.sprite2 = spr2
				p.mo.frame = (leveltime/3) % numframes
			end)
		end
	end
end)