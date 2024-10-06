/* Okay it's "Technically" a turf.. but lets be honest it's a structure in form.
Eugh! I hate figuring out where files go!

I get around the visuals underneath structures issue for Multi_Z by just making the structure a open turf child, which is.. janky
But I think it works.

You could /Probably/ do something with Overlays here but I'm not super familiar with them so I just bake the floor design into the hatch sprite.
*/

/turf/simulated/open/roofhatch
	name = "Roof Hatch"
	desc = "A hatch built into the roof, I wonder where it leads."
	icon = 'icons/teststructures_small.dmi'
	icon_state = "roofhatch_closed"
	var/isclosed = TRUE
	z_flags = ZM_MIMIC_DEFAULTS | ZM_MIMIC_NO_AO | ZM_ALLOW_ATMOS

/turf/simulated/open/roofhatch/Entered(atom/movable/mover, atom/oldloc) //We don't want to reference the parent.
	if(isclosed)
		return
	else
		mover.fall(oldloc)

/turf/simulated/open/roofhatch/attackby(obj/item/C, mob/user)
	. = ..()
	if(isclosed)
		isclosed = FALSE
		icon_state = "roofhatch_opened"
	else
		isclosed = TRUE
		icon_state = "roofhatch_closed"
