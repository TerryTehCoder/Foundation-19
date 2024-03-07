/obj/item/clothing/proc/can_attach_accessory(obj/item/clothing/accessory/A, mob/user)
	if (!length(valid_accessory_slots))
		if (user)
			to_chat(user, SPAN_WARNING("\The [src] can't take any attachments."))
		return FALSE

	if (!istype(A) || !(A.slot in valid_accessory_slots))
		if (user)
			to_chat(user, SPAN_WARNING("\The [A] can't attach to \the [src]."))
		return FALSE

	if (accessories.len && restricted_accessory_slots && (A.slot in restricted_accessory_slots))
		for (var/obj/item/clothing/accessory/AC in accessories)
			if (AC.slot == A.slot)
				if (user)
					to_chat(user, SPAN_WARNING("\The [src] can't attach more accessories of that type."))
				return FALSE

	var/bulky = A.get_bulky_coverage()
	if (bulky)
		if (bulky & get_bulky_coverage())
			if (user)
				to_chat(user, SPAN_WARNING("\The [src] is already too bulky to attach \the [A]."))
			return FALSE

		if (ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if (src != H.l_hand && src != H.r_hand)
				for (var/obj/item/clothing/C in H.get_equipped_items())
					if ((C != src) && (C.get_bulky_coverage() & bulky))
						if (user)
							to_chat(user, SPAN_WARNING("\The [A] is too bulky to wear with \the [C]."))
						return FALSE
	return TRUE

/obj/item/clothing/attackby(obj/item/I, mob/user)
	if (istype(I, /obj/item/clothing/accessory))
		if (can_attach_accessory(I, user) && user.unEquip(I))
			attach_accessory(user, I)
		return
	if (length(accessories))
		for (var/obj/item/clothing/accessory/A in accessories)
			A.attackby(I, user)
		return
	..()

/obj/item/clothing/attack_hand(mob/user)
	//only forward to the attached accessory if the clothing is equipped (not in a storage)
	if(accessories.len && src.loc == user)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.attack_hand(user)
		return
	return ..()

/obj/item/clothing/MouseDrop(obj/over_object)
	if(!(ishuman(usr) || issmall(usr)))
		return

	if(!over_object || over_object == src)
		return

	//makes sure that the clothing is equipped so that we can't drag it into our hand from miles away.
	if (!(src.loc == usr))
		return

	if (usr.incapacitated())
		return

	if (!usr.unEquip(src))
		return

	switch(over_object.name)
		if("r_hand")
			usr.put_in_r_hand(src)
		if("l_hand")
			usr.put_in_l_hand(src)
	src.add_fingerprint(usr)

/obj/item/clothing/examine(mob/user)
	. = ..()
	for(var/obj/item/clothing/accessory/A in accessories)
		to_chat(user, "[icon2html(A, user)] \A [A] is attached to it.")
	switch(ironed_state)
		if(WRINKLES_WRINKLY)
			to_chat(user, SPAN_BAD("It's wrinkly."))
		if(WRINKLES_NONE)
			to_chat(user, SPAN_NOTICE("It's completely wrinkle-free!"))
	switch(smell_state)
		if(SMELL_CLEAN)
			to_chat(user, SPAN_NOTICE("It smells clean!"))
		if(SMELL_STINKY)
			to_chat(user, SPAN_BAD("It's quite stinky!"))


/obj/item/clothing/proc/update_accessory_slowdown()
	slowdown_accessory = 0
	for(var/obj/item/clothing/accessory/A in accessories)
		slowdown_accessory += A.slowdown

/**
 *  Attach accessory A to src
 *
 *  user is the user doing the attaching. Can be null, such as when attaching
 *  items on spawn
 */
/obj/item/clothing/proc/attach_accessory(mob/user, obj/item/clothing/accessory/A)
	accessories += A
	A.on_attached(src, user)
	if(A.removable)
		src.verbs |= TYPE_PROC_REF(/obj/item/clothing, removetie_verb)
	update_accessory_slowdown()
	update_clothing_icon()

/obj/item/clothing/proc/remove_accessory(mob/user, obj/item/clothing/accessory/A)
	if(!A || !(A in accessories))
		return

	A.on_removed(user)
	accessories -= A
	update_accessory_slowdown()
	update_clothing_icon()

/obj/item/clothing/proc/removetie_verb()
	set name = "Remove Accessory"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return
	if(!accessories.len) return
	var/obj/item/clothing/accessory/A
	var/list/removables = list()
	for(var/obj/item/clothing/accessory/ass in accessories)
		if(ass.removable)
			removables |= ass
	if(accessories.len > 1)
		A = input("Select an accessory to remove from [src]") as null|anything in removables
	else
		A = accessories[1]
	src.remove_accessory(usr,A)
	removables -= A
	if(!removables.len)
		src.verbs -= TYPE_PROC_REF(/obj/item/clothing, removetie_verb)

/obj/item/clothing/emp_act(severity)
	if(accessories.len)
		for(var/obj/item/clothing/accessory/A in accessories)
			A.emp_act(severity)
	..()
