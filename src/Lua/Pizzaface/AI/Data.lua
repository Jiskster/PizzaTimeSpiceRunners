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
		name = "Glueball (100% glue nothing else)",
	    state = S_CONEBALL,
		scale = 3*FU/4,
		trails = {SKINCOLOR_WHITE, SKINCOLOR_WHITE},
		sound = sfx_coneba,
		emoji = ":candy:",
		aiselectable = true,
		tagcolor = SKINCOLOR_MAGENTA,
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
		parrysplit = true
	},
	{
		name = "Normal",
	    state = S_NORMALFACE_PF,
		scale = FU/2,
		trails = {SKINCOLOR_GREEN, SKINCOLOR_WHITE},
		sound = sfx_nrmlfc,
		emoji = ":green_circle:",
		tagcolor = SKINCOLOR_GREEN
	},
	{
		name = "Gooch",
	    state = S_GOOCH_PF,
		scale = FU,
		trails = {SKINCOLOR_RED, SKINCOLOR_GREEN},
		sound = sfx_pizzah,
		emoji = ":slight_smile:",
		tagcolor = SKINCOLOR_RED,
		momentum = true,
		aiselectable = true
	}
}