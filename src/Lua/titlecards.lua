PTSR.titlecards = {
	[1] = {
		music = "GF1TIL",
		graphic = "GFZ1TC",
		time = 3*TICRATE
	},
	[2] = {
		music = "GF2TIL",
		graphic = "GFZ2TC",
		time = 3*TICRATE
	},
	-- placeholder
	[0] = {
		music = "GF2TIL",
		graphic = "PLCHTC",
		time = 3*TICRATE
	}
}

function PTSR.AddTitlecard(mapnum, music, graphic, time)
	if not (mapnum) then return end
	music = music or "GF2TIL"
	graphic = graphic or "PLCHTC"
	time = time or 3*TICRATE
	
	PTSR.titlecards[mapnum] = {
		music = music,
		graphic = graphic,
		time = time
	}
end

addHook('ThinkFrame', do
	if not PTSR.IsPTSR() then return end
	if not (PTSR.titlecard_time) then return end
	
	local ct = PTSR.titlecards[gamemap] or PTSR.titlecards[0]
	
	if S_MusicName() ~= ct.music then
		S_ChangeMusic(ct.music, false, consoleplayer)
	end
	for p in players.iterate do
		p.realtime = 0
		p.pflags = $|PF_FULLSTASIS
	end
	
	PTSR.titlecard_time = $-1
	if not (PTSR.titlecard_time) then
		S_ChangeMusic(mapmusname, true, consoleplayer)
	end
end)