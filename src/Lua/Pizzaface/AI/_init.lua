local path = "Pizzaface/AI"
local file_prefix = ""

local files = {
	"Data",
	"Object",
	"Hooks/Thinker",
	"Hooks/MobjSpawn",
	"Hooks/AntiDeath",
	"Hooks/PlayerTouch",
	
	-- Put special pizza face logic below this comment:

}

for i,v in ipairs(files) do
	dofile(path.."/"..file_prefix..v)
end
