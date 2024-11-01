/obj/machinery/bluespacerelay
	name = "Emergency Bluespace Relay"
	desc = "This sends messages through bluespace! Wow!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bspacerelay"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 15000
	construct_state = /decl/machine_construction/default/panel_closed
	uncreated_component_parts = null
	machine_name = "emergency bluespace relay"
	machine_desc = "Used to instantly send messages across vast distances. An emergency relay is required to directly contact Expeditionary Command through crisis channels."

/obj/machinery/bluespacerelay/on_update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "[initial(icon_state)]_off"
	else
		icon_state = initial(icon_state)

/obj/machinery/bluespacerelay/dish
	name = "Long Distance Satellite Relay"
	desc = "A massive scooped radar dish that allows the site to contact regional command instantly through vast distances."
	machine_desc = "Used to instantly send messages across vast distances. A Satellite-Relay is required to directly contact Regional Command through crisis channels."
	icon = 'icons/teststructures_large.dmi'
	icon_state = "satellite-relay"
	idle_power_usage = 0 //It's a satellite dish, it doesn't really need power, plus it's outside so hard to regulate.
