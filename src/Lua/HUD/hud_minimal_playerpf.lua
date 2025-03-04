local minimal_playerpf = function(v, p)
	if not PTSR.IsPTSR() then return end
	if not isminimalhud then return end
	if PTSR.pizzatime then
		if p.ptsr.pizzaface then
			local tooltips_pos = {
				x=12,
				y=55
			}
			local buttons_padding = {
				x = 21,
				y = 18
			}
			local tooltips_stringflag = "thin"
			local tooltips_flags = V_SNAPTOLEFT
			
			v.drawString(2,2,"Kill Players", V_SNAPTOTOP|V_SNAPTOLEFT|V_REDMAP|V_HUDTRANSHALF)
			
			if p.realmo.pfstuntime then
				local stun_graphic = v.cachePatch("MINIM_STUN")
				local stun = {
					x= 160,
					y= 179,
					flags = V_SNAPTOBOTTOM|V_PERPLAYER,
					string_flags = "thin-center"
				}
				v.draw(stun.x, stun.y, stun_graphic, stun.flags)
				v.drawString(stun.x, stun.y-4, p.realmo.pfstuntime/TICRATE, stun.flags|V_YELLOWMAP, stun.string_flags)
			end
			
			local graphic_c1 = v.cachePatch("MINIM_BTNC1")
			local graphic_c2 = v.cachePatch("MINIM_BTNC2")
			local graphic_fire = v.cachePatch("MINIM_BTNFIRE")
			
			--Buttons draw
			v.draw(tooltips_pos.x, tooltips_pos.y, graphic_fire, tooltips_flags)
			v.draw(tooltips_pos.x, tooltips_pos.y+buttons_padding.y, graphic_c1, tooltips_flags)
			v.draw(tooltips_pos.x, tooltips_pos.y+(buttons_padding.y*2), graphic_c2, tooltips_flags)
		
			if p.pizzachargecooldown then
				v.drawString(tooltips_pos.x+(buttons_padding.x-3), tooltips_pos.y+4, "COOLING DOWN", tooltips_flags|V_GRAYMAP, tooltips_stringflag)
			elseif p.pizzacharge then
				local percentage = (FixedDiv(p.pizzacharge*FRACUNIT, 35*FRACUNIT)*100)/FRACUNIT
				
				v.drawString(tooltips_pos.x+(buttons_padding.x-3), tooltips_pos.y+4, "CHARGING \$percentage\%", tooltips_flags|V_YELLOWMAP, tooltips_stringflag)
			else
				v.drawString(tooltips_pos.x+(buttons_padding.x-3), tooltips_pos.y+4, "TELEPORT", tooltips_flags|V_REDMAP, tooltips_stringflag)
			end

			v.drawString(tooltips_pos.x+(buttons_padding.x-3), tooltips_pos.y+buttons_padding.y+4, "DASH", tooltips_flags|V_REDMAP, tooltips_stringflag)
			if not p.ptsr.pizzachase then
				if not (p.ptsr.pizzachase_cooldown) then
					v.drawString(tooltips_pos.x+(buttons_padding.x-3), tooltips_pos.y+(buttons_padding.y*2)+4, "CHASEDOWN", tooltips_flags|V_REDMAP, tooltips_stringflag)
				else
					v.drawString(tooltips_pos.x+(buttons_padding.x-3), tooltips_pos.y+(buttons_padding.y*2)+4, "COOLING DOWN", tooltips_flags|V_GRAYMAP, tooltips_stringflag)
				end
			end
		end
	end
end

customhud.SetupItem("PTSR_minimalplayerPF", ptsr_hudmodname, minimal_playerpf, "game", 0)