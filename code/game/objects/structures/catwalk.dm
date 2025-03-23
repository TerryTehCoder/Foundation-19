/obj/structure/catwalk
	name = "catwalk"
	desc = "Cats really don't like these things."
	icon = 'icons/obj/catwalks.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	layer = CATWALK_LAYER
	plane = DEFAULT_PLANE
	footstep_type = /decl/footsteps/catwalk
	obj_flags = OBJ_FLAG_NOFALL
	var/hatch_open = FALSE
	var/obj/item/stack/tile/mono/plated_tile

/obj/structure/catwalk/Initialize()
	. = ..()
	DELETE_IF_DUPLICATE_OF(/obj/structure/catwalk)
	update_connections(1)
	update_icon()


/obj/structure/catwalk/Destroy()
	redraw_nearby_catwalks()
	return ..()

/obj/structure/catwalk/proc/redraw_nearby_catwalks()
	for(var/direction in GLOB.alldirs)
		var/obj/structure/catwalk/L = locate() in get_step(src, direction)
		if(L)
			L.update_connections()
			L.update_icon() //so siding get updated properly


/obj/structure/catwalk/on_update_icon()
	update_connections()
	cut_overlays()
	icon_state = ""
	var/image/I
	if(!hatch_open)
		for(var/i = 1 to 4)
			I = image('icons/obj/catwalks.dmi', "catwalk[connections[i]]", dir = 1<<(i-1))
			add_overlay(I)
	if(plated_tile)
		I = image('icons/obj/catwalks.dmi', "plated")
		I.color = plated_tile.color
		add_overlay(I)

/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(1)
			new /obj/item/stack/material/rods(src.loc)
			qdel(src)
		if(2)
			new /obj/item/stack/material/rods(src.loc)
			qdel(src)

/obj/structure/catwalk/attack_hand(mob/user)
	if(user.pulling)
		do_pull_click(user, src)
	..()

/obj/structure/catwalk/attack_robot(mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/catwalk/proc/deconstruct(mob/user)
	playsound(src, 'sounds/items/Welder.ogg', 100, 1)
	to_chat(user, SPAN_NOTICE("Slicing \the [src] joints ..."))
	new /obj/item/stack/material/rods(src.loc)
	new /obj/item/stack/material/rods(src.loc)
	//Lattice would delete itself, but let's save ourselves a new obj
	if(isspaceturf(loc) || istype(src.loc, /turf/simulated/open))
		new /obj/structure/lattice/(src.loc)
	if(plated_tile)
		new plated_tile.build_type(src.loc)
	qdel(src)

/obj/structure/catwalk/attackby(obj/item/C as obj, mob/user as mob)
	if(isWelder(C))
		var/obj/item/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			deconstruct(user)
		return
	if(istype(C, /obj/item/gun/energy/plasmacutter))
		var/obj/item/gun/energy/plasmacutter/cutter = C
		if(!cutter.slice(user))
			return
		deconstruct(user)
		return
	if(isCrowbar(C) && plated_tile)
		if(user.a_intent != I_HELP)
			return
		hatch_open = !hatch_open
		if(hatch_open)
			playsound(src, 'sounds/items/Crowbar.ogg', 100, 2)
			to_chat(user, SPAN_NOTICE("You pry open \the [src]'s maintenance hatch."))
		else
			playsound(src, 'sounds/items/Deconstruct.ogg', 100, 2)
			to_chat(user, SPAN_NOTICE("You shut \the [src]'s maintenance hatch."))
		update_icon()
		return
	if(istype(C, /obj/item/stack/tile/mono) && !plated_tile)
		var/obj/item/stack/tile/floor/ST = C
		if(!ST.in_use)
			to_chat(user, SPAN_NOTICE("Placing tile..."))
			ST.in_use = 1
			if (!do_after(user, 1 SECOND, bonus_percentage = 50))
				ST.in_use = 0
				return
			to_chat(user, SPAN_NOTICE("You plate \the [src]"))
			name = "plated catwalk"
			ST.in_use = 0
			src.add_fingerprint(user)
			if(ST.use(1))
				var/list/decls = decls_repository.get_decls_of_subtype(/decl/flooring)
				for(var/flooring_type in decls)
					var/decl/flooring/F = decls[flooring_type]
					if(!F.build_type)
						continue
					if(ispath(C.type, F.build_type))
						plated_tile = F
						break
				update_icon()

/obj/structure/catwalk/refresh_neighbors()
	return

/obj/effect/catwalk_plated
	name = "plated catwalk spawner"
	icon = 'icons/obj/catwalks.dmi'
	icon_state = "catwalk_plated"
	density = TRUE
	anchored = TRUE
	var/activated = FALSE
	layer = CATWALK_LAYER
	var/plating_type = /decl/flooring/tiling/mono



/obj/effect/catwalk_plated/Initialize(mapload)
	. = ..()
	var/auto_activate = mapload || (GAME_STATE < RUNLEVEL_GAME)
	if(auto_activate)
		activate()
		return INITIALIZE_HINT_QDEL


/obj/effect/catwalk_plated/CanPass()
	return 0

/obj/effect/catwalk_plated/attack_hand()
	attack_generic()

/obj/effect/catwalk_plated/attack_ghost()
	attack_generic()

/obj/effect/catwalk_plated/attack_generic()
	activate()

/obj/effect/catwalk_plated/proc/activate()
	if(activated) return

	if(locate(/obj/structure/catwalk) in loc)
		warning("Frame Spawner: A catwalk already exists at [loc.x]-[loc.y]-[loc.z]")
	else
		var/obj/structure/catwalk/C = new /obj/structure/catwalk(loc)
		C.plated_tile += new plating_type
		C.name = "plated catwalk"
		C.update_icon()

	activated = 1
	for(var/turf/T in orange(src, 1))
		for(var/obj/effect/wallframe_spawn/other in T)
			if(!other.activated) other.activate()

//I have no idea how the original author got the dark/white plate coverings but if you're wondering how I did it.. I sacrificed a friday night.
/proc/generate_colored_catwalks()
	var/icon/base_icon = icon('icons/obj/catwalks.dmi', "catwalk")
	if (!base_icon)
		warning("Base icon for 'catwalk_plated' not found")
		return

	var/icon/plated_icon = icon('icons/obj/catwalks.dmi', "plated")
	if (!plated_icon)
		warning("Plated icon not found!")
		return

	// Define the list of colors with associated names, you can amend this list if you want to make more to iterate through.
	var/list/colors = list(
		"keter" = COLOR_KETER_RED,
		"safe" = COLOR_SAFE_GREEN,
		"euclid" = COLOR_EUCLID_YELLOW
	)

	// Loop through each color and generate a colored icon state
	for (var/name in colors)
		var/color = colors[name]

		// Create a new icon for the "plated" icon (In order to add color)
		var/icon/colored_plated_icon = new /icon(plated_icon)

		// Applying the color itself
		colored_plated_icon.Blend(color, ICON_MULTIPLY)

		//Establishes the path designated by the user
		var/cache_path = input("Enter the path where you want to save the catwalk DMI files:")

		if (!cache_path)
			warning("No directory specified. Cancelling")
			return

		//What we're saving it under
		var/file_path = "[cache_path]catwalks_[name].dmi"

		//Copying it over to the directory, hopefully in tact!
		fcopy(colored_plated_icon, file_path)


/client/verb/generate_catwalk_icons()
	set name = "Generate Catwalk Icons"
	set desc = "Generates colored catwalk icons and saves them to the catwalks.dmi"
	set category = "Admin"

	generate_colored_catwalks()

/obj/effect/catwalk_plated/dark
	icon_state = "catwalk_plateddark"
	plating_type = /decl/flooring/tiling/mono/dark

/obj/effect/catwalk_plated/white
	icon_state = "catwalk_platedwhite"
	plating_type = /decl/flooring/tiling/mono/white

//Coloration, like the above two, is handeled by the plating type, different icons have visually different details on the plating.

/obj/effect/catwalk_plated/keter
	icon_state = "catwalk_platedketer"
	plating_type = /decl/flooring/tiling/mono/keter

/obj/effect/catwalk_plated/safe
	icon_state = "catwalk_platedsafe"
	plating_type = /decl/flooring/tiling/mono/safe

/obj/effect/catwalk_plated/euclid
	icon_state = "catwalk_platedeuclid"
	plating_type = /decl/flooring/tiling/mono/euclid
