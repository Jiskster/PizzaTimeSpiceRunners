freeslot("S_WEGA", "sfx_wega", "SPR_WEGA")

states[S_WEGA] = {
    sprite = SPR_WEGA,
    frame = FF_FULLBRIGHT|A,
    tics = -1,
    nextstate = S_WEGA
}

PTSR.PFMaskData = {
	{
		name = "Freakza Face",
		state = S_PIZZAFACE,
		scale = FU,
		trails = {SKINCOLOR_RED, SKINCOLOR_GREEN},
		sound = sfx_pizzah,
		emoji = ":pizza:",
		aiselectable = true,
		tagcolor = SKINCOLOR_ORANGE
	},
	{
		name = "C-Ball",
	    state = S_CONEBALL,
		scale = 3*FU/4,
		trails = {SKINCOLOR_WHITE, SKINCOLOR_WHITE},
		sound = sfx_coneba,
		emoji = ":candy:",
		aiselectable = true,
		tagcolor = SKINCOLOR_WHITE,
		special = "coneball"
	},
	{
		name = "Summa",
	    state = S_SUMMADAT_PF,
		scale = FU/2,
		trails = {SKINCOLOR_PEACHY, SKINCOLOR_RED},
		sound = sfx_smdah,
		emoji = ":stuck_out_tongue:",
		tagcolor = SKINCOLOR_ORANGE,
		parrysplit = true,
		aiselectable = true
	},
	{
		name = "Normal",
	    state = S_NORMALFACE_PF,
		scale = FU/2,
		trails = {SKINCOLOR_GREEN, SKINCOLOR_WHITE},
		sound = sfx_nrmlfc,
		emoji = ":green_circle:",
		tagcolor = SKINCOLOR_GREEN,
		aiselectable = true
	},
	{
		name = "Wega",
	    state = S_WEGA,
		scale = FU,
		trails = {SKINCOLOR_PURPLE, SKINCOLOR_BLACK},
		sound = sfx_wega,
		emoji = ":slight_smile:",
		tagcolor = SKINCOLOR_PURPLE,
		momentum = true,
		aiselectable = true
	}
}