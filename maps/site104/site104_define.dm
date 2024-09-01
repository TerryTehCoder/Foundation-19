/datum/map/site104
	name = "Site 104"
	full_name = "Foundation Site 104"
	path = "site104"
	flags = MAP_HAS_BRANCH | MAP_HAS_RANK
	station_levels = list(1,2,3,4,5,6,7)
	contact_levels = list(1,2,3,4,5,6,7)
	player_levels = list(1,2,3,4,5,6,7)
	admin_levels = list(8,9,10)
	empty_levels = list()
	accessible_z_levels = list("1"=1,"2"=1,"3"=1,"4"=1,"5"=1,"6"=1,"7"=1)
	base_turf_by_z = list(
		"1" = /turf/simulated/floor/beach/water/ocean,
		"2" = /turf/simulated/floor/plating,
		"3" = /turf/simulated/floor/plating,
		"4" = /turf/simulated/floor/plating,
		"2" = /turf/simulated/floor/plating,
		"3" = /turf/simulated/floor/plating,
		"5" = /turf/simulated/floor/plating,
		"6" = /turf/simulated/floor/plating,
		"7" = /turf/simulated/floor/plating
	)
	overmap_size = 35
	overmap_event_areas = 0
	usable_email_tlds = list("site104.foundation", "security.site104.foundation", "science.site104.foundation", "utility.site104.foundation")
	config_path = "config/site104_config.txt"

	allowed_spawns = list("Cryogenic Storage", "D-Cells", "Light Containment Zone")
	default_spawn = "Cryogenic Storage"

	station_name  = "Foundation Site 104"
	station_short = "Site 104"
	dock_name     = "Central Command Depo"
	boss_name     = "Foundation Marine Overwatch"
	boss_short    = "Marine Overwatch"
	company_name  = "SCP Foundation"
	company_short = "Foundation"

	map_admin_faxes = list(
		"Foundation Central Office",
		"UIU Central Office",
		"GOC Central Office",
		"Horizon Initiative Central Office ",
		"Marshall, Carter, and Dark Central Office",
		"Goldbaker-Reinz Central Office"
	)

	//These should probably be moved into the evac controller...
	shuttle_docked_message = "The outbound ship is now boarding at the Ship-Depo. It will depart in approximately %ETD%."
	shuttle_leaving_dock = "The outbound ship for off-duty personnel is now departing, and will reach its first stop in %ETA%."
	shuttle_called_message = "The work shift is now ending. The next outbound ship for off-duty personnel will begin boarding in %ETA%."
	shuttle_recall_message = "The work shift has been extended. Please return to your post."
	emergency_shuttle_docked_message = "The emergency ship is now boarding at the Ship-Depo. Evacuation is mandatory for all Foundation personnel. It will depart in %ETD%."
	emergency_shuttle_leaving_dock = "The emergency ship is departing for Extraction Site 24-A and will arrive in %ETA%. Please cooperate with Responders upon arrival."
	emergency_shuttle_called_message = "An emergency evacuation has been ordered for this facility. All authorized evacuees must proceed to the outbound Ship-Depo within %ETA%."
	emergency_shuttle_recall_message = "The emergency evacuation has been cancelled. Return to your post."

	evac_controller_type = /datum/evacuation_controller/shuttle //The evacuation controller that the map uses, this MUST be defined else the train will not function.

	default_law_type = /datum/ai_laws/foundation
	use_overmap = 0
	num_exoplanets = 0
	planet_size = list(129,129)
	apc_test_exempt_areas = list( //Note to self, this needs to be updated to Site-104 locations (which do not currently exist).
		/area/space = NO_APC
	)

	away_site_budget = 3

	id_hud_icons = 'maps/site104/icons/assignment_hud.dmi'

	lobby_tracks = list(
		/decl/audio/track/dieinthedark,
		/decl/audio/track/perdition,
		/decl/audio/track/ajoura,
		/decl/audio/track/days,
		/decl/audio/track/hie,
		/decl/audio/track/chaos,
		/decl/audio/track/bookburners,
		/decl/audio/track/dread,
		/decl/audio/track/animosity,
		/decl/audio/track/animosity_v2,
		/decl/audio/track/main_astowo,
		/decl/audio/track/final_flash,
		/decl/audio/track/duplicity_and_disillusion,
		/decl/audio/track/battle_for_ganzir,
		/decl/audio/track/purge_protocol,
		/decl/audio/track/uiu_spawn_theme,
		/decl/audio/track/surface_area,
	)

	available_cultural_info = list(
		TAG_HOMEWORLD = list(HOME_SYSTEM_EARTH),
		TAG_FACTION = list(FACTION_SCP_FOUNDATION),
		TAG_CULTURE = list(
			CULTURE_HUMAN_EARTH,
			CULTURE_HUMAN_ARABIC,
			CULTURE_HUMAN_BRITISH,
			CULTURE_HUMAN_CHINESE,
			CULTURE_HUMAN_EASTSLAVIC,
			CULTURE_HUMAN_FRENCH,
			CULTURE_HUMAN_GERMAN,
			CULTURE_HUMAN_GOIDELIC,
			CULTURE_HUMAN_ITALIAN,
			CULTURE_HUMAN_JAPANESE,
			CULTURE_HUMAN_LATINAMERICAN),
		TAG_RELIGION = list(
			RELIGION_OTHER,
			RELIGION_JUDAISM,
			RELIGION_HINDUISM,
			RELIGION_BUDDHISM,
			RELIGION_ISLAM,
			RELIGION_CHRISTIANITY,
			RELIGION_AGNOSTICISM,
			RELIGION_ATHEISM,
		),
	)

	default_cultural_info = list(
		TAG_HOMEWORLD = HOME_SYSTEM_EARTH,
		TAG_FACTION =   FACTION_SCP_FOUNDATION,
		TAG_CULTURE =   CULTURE_HUMAN_EARTH,
		TAG_RELIGION =  RELIGION_AGNOSTICISM
	)

/datum/map/site104/get_map_info()
	. = list()
	. +=  "You're aboard Site-104, a Foundation facility located a few miles off the Prime Meridian of the Atlantic Ocean using the frame of a decommissioned Oil Rig. While the facility isn't as large as Site-53, its tight corridors and external catwalks will keep you wondering what that noise you just heard was. Through both record manipulation and outright clever political play this area of the region is largely unoccupied, with only the cold nip of the wind and the ocean waves to keep you company, and sometimes a few tourists who's curiosity is a little too strong for their own good..."
	return jointext(., "<br>")

/*
/datum/map/torch/setup_map()
	..()
	system_name = generate_system_name()
	minor_announcement = new(new_sound = sound('sounds/AI/torch/commandreport.ogg', volume = 45))
*/
