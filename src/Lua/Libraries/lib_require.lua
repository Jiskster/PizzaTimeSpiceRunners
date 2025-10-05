local libs = {}

function PTSR.Require(path)
	path = $:gsub(".lua", "") -- Truncate extension.
	
	if libs[path] then
		return libs[path]
	else
		libs[path] = dofile(path)
		
		return libs[path]
	end
end