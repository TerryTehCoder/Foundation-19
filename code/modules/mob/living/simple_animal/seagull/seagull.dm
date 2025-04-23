/mob/living/simple_animal/seagull
	name = "Seagull"
	desc = "A white and grey seabird. Prone to causing a nuisance when food is involved."
	icon = 'icons/mob/simple_animal/seagull.dmi'
	icon_state = "seagull"
	icon_living = "seagull"
	icon_dead = "seagull_dead"
	pass_flags = PASS_FLAG_TABLE
	mob_size = MOB_SMALL
	density = FALSE
	cold_resist = 0.3 //Fluffy Feathers keep them warm in the winter.
	death_sounds = list('sounds/simple_mob/seagull/Seagull_Death1.ogg', 'sounds/simple_mob/seagull/Seagull_Death2.ogg')

	speak_emote = list("skaaws")

	natural_weapon = /obj/item/natural_weapon/seagull_claws

	response_help  = "pets"
	response_disarm = "gently moves aside"
	response_harm   = "swats"
	universal_speak = TRUE
	pass_flags = PASS_FLAG_TABLE
	can_pry = FALSE // There is no world in which a seagull should be able to pry open an airlock.

	say_list_type = /datum/say_list/seagull

	//Current Signal listeners

	var/list/listening_mobs = list()
	var/list/listening_items = list()

	// Interest Mechanics which handle how curious the seagull is about food and you.

	var/interest_level = 0
	////Used for interest emotes in handle_interest().
	var/static/list/seagull_emote_table = list(
		"low" = list("The seagull eyes M lazily", "The seagull tilts its head at M"),
		"medium" = list("The seagull squawks at M", "The seagull flaps its wings at M"),
		"high" = list("The seagull screeches at M", "The seagull hops excitedly at M", "The seagull flutters its wings at M")
	)

	// Interest words, used for speech recognition and interest gain.
	var/static/list/seagull_interest_words = list(
    "food" = 3, "fries" = 4, "french fries" = 5, "pizza" = 4, "snack" = 2, "snacks" = 2,
    "alka-seltzer" = -5, "alkaseltzer" = -5, "chocolate" = 2, "candy" = 2, "soda" = 1,
    "drink" = 1, "drinks" = 1, "chips" = 3, "lunch" = 3, "bread" = 4,
    "cheese" = 2, "burger" = 4, "hotdog" = 3, "garbage" = 2, "bin" = 1, "scrap" = 1,
    "leftovers" = 3, "crumb" = 2, "crumbs" = 2, "treat" = 2, "treats" = 2, "cake" = 3,
    "pie" = 3, "sandwich" = 4, "fish" = 5, "dumb bird" = 1, "stupid bird" = 1, "ugly bird" = 1,
    "fucking bird" = 1, "shoo" = -2, "fuck off" = -2, "leave me alone" = -1, "leave" = -1, "go away" = -1,
    "keel-aw" = 3, "caw" = 3, "skaaaw" = 3, "kee-yaw" = 3
)

	var/last_emote_time = 0 //Time since the last emote, self explanatory. Compared against worldtime for cooldown.

/obj/item/natural_weapon/seagull_claws
	name = "claws"
	gender = PLURAL
	attack_verb = list("clawed")
	sharp = TRUE
	force = 8

/datum/say_list/seagull
	speak = list("Keel-aw.", "Caw?", "Caw!", "CAW.", "Skaaaw!", "Kee-yaw!")
	emote_hear = list("caws", "ruffles its feathers", "hops nervously", "flutters its wings", "gives an indignant squawk")
	emote_see = list("hops", "stares intently", "tilts its head", "squawks excitedly!", "pecks at the ground")

/mob/living/simple_animal/seagull/admin
	name = "Tough Seagull"
	desc = "A particularly large seagull that looks like it means business."
	can_pry = TRUE // This seagull is a tough guy, don't mess with it.
	can_escape = TRUE // This seagull can escape from netting.
	thick_armor = TRUE // Thick feathers prevent injections, but not bullets.
	taser_kill = FALSE // Its tough body can withstand even the strongest of shocks.
	maxHealth = 30 // What has this gull been eating??
	health = 30
	pry_desc = "prying open the airlock with its beak" // Terrifying.

//Resistances

	heat_resist = 0.5
	cold_resist = 0.7
	shock_resist = 0.5
	poison_resist = 0.5

	natural_weapon = /obj/item/natural_weapon/adminseagull_claws

/obj/item/natural_weapon/adminseagull_claws
	name = "sharp claws"
	gender = PLURAL
	attack_verb = list("clawed")
	sharp = TRUE
	force = 12

/mob/living/simple_animal/seagull/Initialize()
	..()
	if (src.client)
		return // No point in listening for signals if the seagull has a client already somehow.
	else
		// Listen for nearby mob moves and mob speech
		for (var/mob/living/M in view(7, src)) //7 is an arbitrary number, and can be bigger or smaller.
			RegisterSignal(M, COMSIG_MOVED, PROC_REF(on_mob_moved))
			RegisterSignal(M, COMSIG_MOB_HEARD_SPEECH, PROC_REF(on_mob_speech))

		// Listen for item drops
		for (var/obj/item/I in view(7, src))
			RegisterSignal(I, COMSIG_DROPPED_ITEM, PROC_REF(on_item_dropped))
		setup_seagull_bias() //Picking the random crewman that the seagulls will be biased towards.

/*This is not as scary as it looks, we're just registering signals for nearby mobs and items to listen
for movement and speech, and unregistering them if they move out of range. We did the same registering
above on init of the mob*/

/mob/living/simple_animal/seagull/proc/update_signal_listeners() //Handles signal updating, gets called in Life()
	for(var/mob/living/M in view(src, 7))
		if(!M.client) //No point in signal registering a clientless mob since it's unlikely to drop anything.
			continue
		if(!src.listening_mobs.Find(M) && !istype(M, /mob/living/simple_animal/seagull)) //Is the mob not already in the list of listeners?
			RegisterSignal(M, COMSIG_MOVED, PROC_REF(on_mob_moved))
			RegisterSignal(M, COMSIG_MOB_HEARD_SPEECH, PROC_REF(on_mob_speech))
			listening_mobs += M //Adding the mob to the list of listeners.

	for(var/obj/item/I in view(src, 7))
		if(!src.listening_items.Find(I)) //Is the item not already in the list of listeners?
			RegisterSignal(I, COMSIG_DROPPED_ITEM, PROC_REF(on_item_dropped))
			listening_items += I //Adding the item to the list of listeners.

	for(var/mob/living/M in listening_mobs.Copy())
		if(get_dist(src, M) > 7 || !M) //Has the mob moved out of the range of interest?
			UnregisterSignal(M, COMSIG_MOVED, PROC_REF(on_mob_moved))
			UnregisterSignal(M, COMSIG_MOB_HEARD_SPEECH, PROC_REF(on_mob_speech))
			listening_mobs -= M //Removing the mob from the list of listeners.

	for(var/obj/item/I in listening_items.Copy())
		if(get_dist(src, I) > 7 || !I) //Has the item moved out of the range of interest?
			UnregisterSignal(I, COMSIG_DROPPED_ITEM, PROC_REF(on_item_dropped))
			listening_items -= I //Removing the item from the list of listeners.

//Our actual interest handeling proc, called by signal procs below.

/mob/living/simple_animal/seagull/proc/handle_interest(atom/T, interest_gain)
	add_interest(interest_gain) //We still want to add interest, even if we don't Do anything with it. (Ex. Emoting, moving, etc.)

	if(world.time < last_emote_time + 30)
		return //Spamming emotes can cause complications so we throttle it to every 30 deciseconds minimum.
	last_emote_time = world.time

	var/list/emote_list

	if (interest_level <= 30)
		emote_list = seagull_emote_table["low"]
	else if (interest_level <= 60)
		emote_list = seagull_emote_table["medium"]
	else
		emote_list = seagull_emote_table["high"]

	var/emote

	if (T == src || !T)
		return //If the seagull is interested in itself (somehow), or if the target is null, we don't want to do anything.

	if (ismob(T))
		var/mob/living/M = T //This is cursed but should be okay I think?? Searching for string M in our emote associative list and replacing it with the mob or item name.
		var/name_to_use = M.real_name
		if (!name_to_use) //if real_name is null or doesn't exist
			name_to_use = "someone"
		emote = replacetext(pick(emote_list), "M", "[name_to_use]")
	else if (isitem(T))
		var/obj/item/I = T
		emote = replacetext(pick(emote_list), "M", "[the_name(I)]")
	else
		emote = replacetext(pick(emote_list), "M", "something") //If somehow the seagull is interested in something that isn't a mob or item, we just use "something".

	src.visible_message(SPAN_NOTICE(emote)) //We have our message like "eyes M lazily" and now we can send it to the world.

/mob/living/simple_animal/seagull/proc/on_mob_moved(mob/living/M)
	if (in_range(M, 5) && (is_food(M.l_hand) || is_food(M.r_hand)))
		handle_interest(M, 1)
		DoMove(get_dir(src, M), M)

/mob/living/simple_animal/seagull/proc/on_item_dropped(obj/item/I)
	if (in_range(I, 5) && (is_food(I)))
		handle_interest(I, 3)
		DoMove(get_dir(src, I), I)

/mob/living/simple_animal/seagull/proc/on_mob_speech(mob/living/M, message)
	var/lower_msg = lowertext(message)
	var/total_interest = 0

	for(var/word in seagull_interest_words)
		if (findtext(lower_msg, word))
			total_interest += seagull_interest_words[word]
			message_admins("Matched word: [word], Interest: [seagull_interest_words[word]]") //Debug, remove later.

/* ^^ - Counting up all of the interesting words in the message, and then adding them all at once
to the interest handeler, rather than doing it individually, though that Would probably be funny. - ^^*/

		if(total_interest)
			message_admins("Total interest for message '[message]': [total_interest]") //Debug, remove later.
			handle_interest(M, total_interest)

//Utilities, such as food classification, movement checks, and interest addition, etc.

/mob/living/simple_animal/seagull/proc/is_food(obj/item/I)
	// Checking if the item is food, very simple but I don't know how Daedulus handles this, so I want it to be easy to fix later.
	return istype(I, /obj/item/reagent_containers/food)

/mob/living/simple_animal/seagull/DoMove(direction, mob/mover) //Sanity check to make sure there's no client when the A.I forces movement.
	if (src.client)
		return
	. = ..()
	return .

/mob/living/simple_animal/seagull/proc/add_interest(amount)
	src.interest_level += amount
	src.interest_level = clamp(src.interest_level, -100, 100)

/mob/living/simple_animal/seagull/Life()
	..()
	update_signal_listeners()

/mob/living/simple_animal/seagull/proc/setup_seagull_bias()
	if(!(GLOB.player_list.len))
		return //No players, no bias, seagulls are sad.

	var/mob/living/chosen_one = pick(GLOB.player_list)
	if(!chosen_one.client)
		return //Sanity check, no point in biasing a clientless mob.
	var/random_interest = rand(-15, 15)

	if(random_interest == 0)
		random_interest = 1 //We don't want the seagulls to be completely neutral, that would be boring.

	seagull_interest_words[lowertext(chosen_one.real_name)] = random_interest
	if(chosen_one && chosen_one.client)
		message_admins("The seagulls have developed a bias toward [chosen_one.real_name] ([chosen_one.client.ckey]) this round: [random_interest]")
	else //How the hell did this happen? Clientless seagull biasing???
		message_admins("The seagulls have developed a bias toward [chosen_one.real_name] this round: [random_interest]")

/proc/the_name(atom/A) // Returns a string with the name of the atom prefixed with "the" and lowercased. Does this exist already? I don't know, maybe, if it does you can yell at me later.
	if(!A) //Sanity check
		return "something"

	var/n = A.name
	if(!n) //Sanity check
		return "something"

	// Don't add 'the' if it's likely a proper name (starts with a capital)
	if(n == uppertext(n) || istype(A, /mob/living/carbon/human))
		return n

	// Already starts with 'the'? Leave it
	if(lowertext(copytext(n, 1, 4)) == "the ")
		return n


	n = lowertext(copytext(n, 1, 2)) + copytext(n, 2)

	return "the [n]"
