//
//The Lua for Minimal Hud's I/O functionality
//Entire lua code made by SMS Alfredo
//

local GKSMINIM_PATH = "client/SpiceRunners/"
local GKSMINIM_SAVE_PATHS = {
	"minimalhud.txt"}
	
local GKSMINIM_SAVE_COMMANDS = {
	"ptsr_minimalhud"}

//Table/string conversion functions

local tabletostring = function(table)
	local chars = ""
	for id, value in pairs(table)
		chars = $..tostring(id).." "..tostring(value).." "
	end
	return chars
end

local stringtotable = function(chars)
	local table = {}
	local id
	for value in string.gmatch(chars, "[^%s]+") do
		if id == nil
			id = tonumber(value)
			if id == nil
				id = value
			end
		else
			table[id] = value
			id = nil
		end
	end
	return table
end

//Command to receive Mario's IO saves using a compressed string
COM_AddCommand("ptsr_gksminimalhud_io", function(player, arg)
	//Say we've used this command
	if player.ptsrminimdidio then return end
	player.ptsrminimdidio = true
	
	//Convert save to table
	local save = arg and stringtotable(arg)
	
	//Iterate through table and apply field values
	if save
		for id, field in ipairs(GKSMINIM_SAVE_COMMANDS)
			local value = save[id]
			if value != nil
				_G[field](player, value) //Execute command
			end
		end
	end
end)

//Apply the I/O for the netgame commands when spawning
addHook("PlayerSpawn", function(player)
	if player != consoleplayer or player.ptsrminimdidio or not io then return end
	
	//Go through all the I/O files, putting their values in a table
	local save = {}
	local hasvalues = false
	for id, field in ipairs(GKSMINIM_SAVE_COMMANDS)
		local file = io.openlocal(GKSMINIM_PATH + GKSMINIM_SAVE_PATHS[id])
		if file
			local value = file:read("*l")
			if value != nil
				hasvalues = $ or save[id]
			end
			file:close()
		end
	end
end)