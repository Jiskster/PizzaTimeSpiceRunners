function PTSR.DoBrakes_XY(mo,factor)
	mo.momx = FixedMul($,factor)
	mo.momy = FixedMul($,factor)
	mo.momz = FixedMul($,factor)
end

function PTSR.SpeedCap_XY(mo,limit,factor)
	local spd_xy = R_PointToDist2(0,0,mo.momx,mo.momy)
	local spd, ang =
		R_PointToDist2(0,0,spd_xy,mo.momz),
		R_PointToAngle2(0,0,mo.momx,mo.momy)
	if spd > limit
		if factor == nil
			factor = FixedDiv(limit,spd)
		end
		PTSR.DoBrakes_XY(mo,factor)
		return factor
	end
end