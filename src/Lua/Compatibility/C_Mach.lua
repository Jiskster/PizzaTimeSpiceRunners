-- Mach, get a better modding environment.

local oldMT = userdataMetatable("mobj_t")
local oldIndex = oldMT.__index

oldMT.__index = function(mobj, field)
    if field ~= "mach_ringAttract" 
	or not (skins["mach"] or GT_PTSPICER) then
        return oldIndex(mobj, field)
    else
        if (mobj.type == MT_FLINGRING
        or mobj.type == MT_FLINGCOIN) 
        and not mobj.fuse then
            mobj.fuse = 12
        end

        mobj.target = nil
        return false
    end
end