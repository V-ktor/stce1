
extends Panel
# station menu displayed when docked

const OVERVIEW = 0
const EQUIPMENT = 1
const TRADE = 2
const BAR = 3
const SHIPYARD = 4
const MAP = 5
const CREW = 6
const MISSIONS = 7

var commodity = "food"
var menu = OVERVIEW
var inventory_rows = 0
var inventory_cols = 0
var equipment_rows = 0
var equipment_cols = 0
var store_rows = 0
var store_cols = 0
var mission_selected = -1

var item = load("res://scenes/hud/item.tscn")


func show_overview():
	menu = OVERVIEW
	get_node("Overview").show()
	get_node("Bar").hide()
	get_node("Trade").hide()
	get_node("Inventory").hide()
	get_node("Equipment").hide()
	get_node("Shipyard").hide()
	get_node("Hangar").hide()
	get_node("Crew").hide()
	get_node("Missions").hide()
	get_node("Map").hide()
	HUD.hide_map()

func show_bar():
	menu = BAR
	get_node("Overview").hide()
	get_node("Bar").show()
	get_node("Trade").hide()
	get_node("Inventory").hide()
	get_node("Equipment").hide()
	get_node("Shipyard").hide()
	get_node("Hangar").hide()
	get_node("Crew").hide()
	get_node("Missions").hide()
	get_node("Map").hide()
	HUD.hide_map()

func show_trade():
	menu = TRADE
	get_node("Overview").hide()
	get_node("Bar").hide()
	get_node("Trade").show()
	get_node("Inventory").show()
	get_node("Equipment").hide()
	get_node("Shipyard").hide()
	get_node("Hangar").hide()
	get_node("Crew").hide()
	get_node("Missions").hide()
	get_node("Map").hide()
	HUD.hide_map()
	Equipment.equipment_offset = 0
	Equipment.store_offset = 0
	Equipment.update_icons()

func show_equipment():
	menu = EQUIPMENT
	get_node("Overview").hide()
	get_node("Bar").hide()
	get_node("Trade").hide()
	get_node("Inventory").show()
	get_node("Equipment").show()
	get_node("Shipyard").hide()
	get_node("Hangar").hide()
	get_node("Crew").hide()
	get_node("Missions").hide()
	get_node("Map").hide()
	HUD.hide_map()
	Equipment.equipment_offset = 0
	Equipment.store_offset = 0
	Equipment.update_icons()

func show_shipyard():
	menu = SHIPYARD
	get_node("Overview").hide()
	get_node("Bar").hide()
	get_node("Trade").hide()
	get_node("Inventory").hide()
	get_node("Equipment").hide()
	get_node("Shipyard").show()
	get_node("Hangar").show()
	get_node("Crew").hide()
	get_node("Missions").hide()
	get_node("Map").hide()
	HUD.hide_map()
	Equipment.equipment_offset = 0
	Equipment.store_offset = 0
	Equipment.update_icons()

func show_crew():
	menu = CREW
	get_node("Overview").hide()
	get_node("Bar").hide()
	get_node("Trade").hide()
	get_node("Inventory").hide()
	get_node("Equipment").hide()
	get_node("Shipyard").hide()
	get_node("Hangar").show()
	get_node("Crew").show()
	get_node("Missions").hide()
	get_node("Map").hide()
	HUD.hide_map()

func show_map():
	menu = MAP
	get_node("Overview").hide()
	get_node("Bar").hide()
	get_node("Trade").hide()
	get_node("Inventory").hide()
	get_node("Equipment").hide()
	get_node("Shipyard").hide()
	get_node("Hangar").hide()
	get_node("Crew").hide()
	get_node("Missions").hide()
	get_node("Map").show()
	HUD.show_map()
	get_node("../Map").hide()

func show_missions():
	menu = MISSIONS
	get_node("Overview").hide()
	get_node("Bar").hide()
	get_node("Trade").hide()
	get_node("Inventory").hide()
	get_node("Equipment").hide()
	get_node("Shipyard").hide()
	get_node("Hangar").hide()
	get_node("Crew").hide()
	get_node("Missions").show()
	get_node("Map").hide()
	HUD.show_map()
	get_node("../Map").hide()
	deselect_mission()

func select_commodity(type):
	commodity = type

func store_offset(offset):
	var ofs = Equipment.store_offset
	Equipment.store_offset = clamp(ofs+offset,0,max(ceil(Equipment.store.size()/Equipment.store_cols-Equipment.store_rows),0))
	if (Equipment.store_offset!=ofs):
		Equipment.update_icons()

func inventory_offset(offset):
	var ofs = Equipment.inventory_offset
	Equipment.inventory_offset = clamp(ofs+offset,0,max(ceil(Equipment.inventory.size()/Equipment.inventory_cols-Equipment.inventory_rows),0))
	if (Equipment.inventory_offset!=ofs):
		Equipment.update_icons()

func equipment_offset(offset):
	var ofs = Equipment.equipment_offset
	Equipment.equipment_offset = clamp(ofs+offset,0,max(ceil(Equipment.equipment.size()/Equipment.equipment_cols-Equipment.equipment_rows),0))
	if (Equipment.equipment_offset!=ofs):
		Equipment.update_icons()

func shipyard_offset(offset):
	var ofs = Equipment.store_offset
	Equipment.store_offset = clamp(ofs+offset,0,max(ceil(Equipment.shipyard.size()/Equipment.store_cols-Equipment.store_rows),0))
	if (Equipment.store_offset!=ofs):
		Equipment.update_icons()

func hangar_offset(offset):
	var ofs = Equipment.inventory_offset
	Equipment.inventory_offset = clamp(ofs+offset,0,max(ceil(Equipment.equipment.size()/Equipment.inventory_cols-Equipment.inventory_rows),0))
	if (Equipment.inventory_offset!=ofs):
		Equipment.update_icons()

func toggle_commodities_filter(pressed):
	Equipment.store_filter["commodity"] = pressed
	Equipment.update_icons()

func toggle_weapon_filter(pressed):
	Equipment.store_filter["weapon"] = pressed
	Equipment.store_filter["turret"] = pressed
	Equipment.update_icons()

func toggle_missile_filter(pressed):
	Equipment.store_filter["missile"] = pressed
	Equipment.update_icons()

func toggle_reactor_filter(pressed):
	Equipment.store_filter["reactor"] = pressed
	Equipment.update_icons()

func toggle_engine_filter(pressed):
	Equipment.store_filter["engine"] = pressed
	Equipment.update_icons()

func toggle_internal_filter(pressed):
	Equipment.store_filter["internal"] = pressed
	Equipment.update_icons()

func toggle_external_filter(pressed):
	Equipment.store_filter["external"] = pressed
	Equipment.update_icons()

func hire_crew():
	Equipment.hire_crew()

func fire_crew():
	Equipment.fire_crew()

func take_off():
	Stations.player_take_off()

func accept_mission():
	Missions.call(Missions.missions_available[mission_selected]["on_accept"],mission_selected)
	update_missions()
	deselect_mission()
	Equipment.update_icons()

func abord_mission():
	Missions.call(Missions.missions_available[mission_selected]["on_abord"],mission_selected)
	update_missions()
	deselect_mission()

func deselect_mission():
	mission_selected = -1
	get_node("Missions/ButtonAccept").set_disabled(true)
	get_node("Missions/ButtonAbord").set_disabled(true)
	get_node("Missions/Text").clear()
	HUD.map_center = Vector2(0,0)
	HUD.map_zoom = 1.0
	HUD.get_node("Map/Map/Draw").update()

func select_mission_available(ID):
	var disabled = false
	var req = Missions.missions_available[ID]["requirements"]
	for k in req.keys():
		if (k=="free_cargo"):
			if (Player.free_cargo_space<req[k]):
				disabled = true
				break
		elif (k=="free_bunks"):
			if (Player.free_bunks<req[k]):
				disabled = true
				break
	mission_selected = ID
	get_node("Missions/ButtonAccept").set_disabled(disabled)
	get_node("Missions/ButtonAbord").set_disabled(true)
	get_node("Missions/Text").clear()
	get_node("Missions/Text").add_text(Missions.missions_available[ID]["description"])
	HUD.map_zoom = 20.0
	HUD.map_center = -HUD.map_scale*HUD.map_zoom*Stations.stations_current_pos[Missions.missions_available[ID]["destination"]]
	HUD.get_node("Map/Map/Draw").update()

func select_mission(ID):
	mission_selected = ID
	get_node("Missions/ButtonAccept").set_disabled(true)
	get_node("Missions/ButtonAbord").set_disabled(false)
	get_node("Missions/Text").clear()
	get_node("Missions/Text").add_text(Missions.missions[ID]["description"])
	HUD.map_zoom = 20.0
	HUD.map_center = -HUD.map_scale*HUD.map_zoom*Stations.stations_current_pos[Missions.missions[ID]["destination"]]
	HUD.get_node("Map/Map/Draw").update()

func update_missions():
	deselect_mission()
	for i in range(Missions.missions_available.size()):
		if (!has_node("Missions/ScrollContainer/VBoxContainer/Available/Mission"+str(i+1))):
			var bi = get_node("Missions/ScrollContainer/VBoxContainer/Available/Mission0").duplicate()
			bi.get_node("Text").set_text(Missions.missions_available[i]["title"])
			bi.get_node("Button").connect("pressed",self,"select_mission_available",[i])
			bi.set_name("Mission"+str(i+1))
			get_node("Missions/ScrollContainer/VBoxContainer/Available").add_child(bi)
			bi.show()
		else:
			var bi = get_node("Missions/ScrollContainer/VBoxContainer/Available/Mission"+str(i+1))
			bi.get_node("Text").set_text(Missions.missions_available[i]["title"])
	for i in range(Missions.missions_available.size(),get_node("Missions/ScrollContainer/VBoxContainer/Available").get_child_count()-1):
		get_node("Missions/ScrollContainer/VBoxContainer/Available/Mission"+str(i+1)).queue_free()
	
	for i in range(Missions.missions.size()):
		if (!has_node("Missions/ScrollContainer/VBoxContainer/Accepted/Mission"+str(i+1))):
			var bi = get_node("Missions/ScrollContainer/VBoxContainer/Available/Mission0").duplicate()
			bi.get_node("Text").set_text(Missions.missions[i]["title"])
			bi.get_node("Button").connect("pressed",self,"select_mission",[i])
			bi.set_name("Mission"+str(i+1))
			get_node("Missions/ScrollContainer/VBoxContainer/Accepted").add_child(bi)
			bi.show()
		else:
			var bi = get_node("Missions/ScrollContainer/VBoxContainer/Accepted/Mission"+str(i+1))
			bi.get_node("Text").set_text(Missions.missions[i]["title"])
	for i in range(Missions.missions.size(),get_node("Missions/ScrollContainer/VBoxContainer/Accepted").get_child_count()):
		get_node("Missions/ScrollContainer/VBoxContainer/Accepted/Mission"+str(i+1)).queue_free()

func _resize():
	var ms = (OS.get_video_mode_size().x/800.0+OS.get_video_mode_size().y/600.0)/2.0
	var item_size = 128
	if (ms<1.5):
		item_size = 64
	elif (ms<2.0):
		item_size = 96
	inventory_rows = floor((OS.get_video_mode_size().y/2.0-82)/item_size)
	inventory_cols = floor((OS.get_video_mode_size().x-351)/item_size)
	get_node("Inventory/GridContainer").set_columns(inventory_cols)
	for c in get_node("Inventory/GridContainer").get_children():
		c.set_name(" ")
		c.queue_free()
	for i in range(inventory_rows*inventory_cols):
		var ii = item.instance()
		ii.type = ii.INVENTORY
		ii.ID = i
		ii.set_custom_minimum_size(item_size*Vector2(1,1))
		ii.set_name("Item"+str(i))
		get_node("Inventory/GridContainer").add_child(ii)
	
	equipment_rows = floor((OS.get_video_mode_size().y/2.0-58)/item_size)
	equipment_cols = floor((OS.get_video_mode_size().x-607)/item_size)
	get_node("Equipment/GridContainer").set_columns(equipment_cols)
	for c in get_node("Equipment/GridContainer").get_children():
		c.set_name(" ")
		c.queue_free()
	for i in range(equipment_rows*equipment_cols):
		var ii = item.instance()
		ii.type = ii.EQUIPMENT
		ii.ID = i+1
		ii.set_custom_minimum_size(item_size*Vector2(1,1))
		ii.set_name("Item"+str(i+1))
		get_node("Equipment/GridContainer").add_child(ii)
	
	store_rows = floor((OS.get_video_mode_size().y/2.0-82)/item_size)
	store_cols = floor((OS.get_video_mode_size().x-351)/item_size)
	get_node("Trade/GridContainer").set_columns(store_cols)
	for c in get_node("Trade/GridContainer").get_children():
		c.set_name(" ")
		c.queue_free()
	for i in range(store_rows*store_cols):
		var ii = item.instance()
		ii.type = ii.STORE
		ii.ID = i
		ii.set_custom_minimum_size(item_size*Vector2(1,1))
		ii.set_name("Item"+str(i))
		get_node("Trade/GridContainer").add_child(ii)
	
	get_node("Shipyard/Ships").set_columns(store_cols)
	for c in get_node("Shipyard/Ships").get_children():
		c.set_name(" ")
		c.queue_free()
	for i in range(store_rows*store_cols):
		var ii = item.instance()
		ii.type = ii.SHIP
		ii.ID = i
		ii.set_custom_minimum_size(item_size*Vector2(1,1))
		ii.set_name("Item"+str(i))
		get_node("Shipyard/Ships").add_child(ii)
	
	for c in get_node("Hangar/Hangar").get_children():
		c.set_name(" ")
		c.queue_free()
	for i in range(inventory_rows*inventory_cols):
		var ii = item.instance()
		ii.type = ii.HANGAR
		ii.ID = i
		ii.set_custom_minimum_size(item_size*Vector2(1,1))
		ii.set_name("Item"+str(i))
		get_node("Hangar/Hangar").add_child(ii)
