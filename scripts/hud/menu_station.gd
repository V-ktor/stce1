
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
var inventory_offset = 0
var inventory_rows = 0
var inventory_cols = 0
var equipment_offset = 0
var equipment_rows = 0
var equipment_cols = 0
var store_offset = 0
var store_rows = 0
var store_cols = 0
var store_filter = {"ship":true,"weapon":true,"turret":true,"missile":true,
"reactor":true,"engine":true,"internal":true,"external":true,"commodity":true}
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
	equipment_offset = 0
	store_offset = 0
	update_icons()

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
	equipment_offset = 0
	store_offset = 0
	update_icons()

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
	equipment_offset = 0
	store_offset = 0
	update_icons()

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
	var ofs = store_offset
	store_offset = clamp(ofs+offset,0,max(ceil(Equipment.store.size()/store_cols-store_rows),0))
	if (store_offset!=ofs):
		update_icons()

func inventory_offset(offset):
	var ofs = inventory_offset
	inventory_offset = clamp(ofs+offset,0,max(ceil(Player.inventory.size()/inventory_cols-inventory_rows),0))
	if (inventory_offset!=ofs):
		update_icons()

func equipment_offset(offset):
	var ofs = equipment_offset
	equipment_offset = clamp(ofs+offset,0,max(ceil(Player.equipment[Player.ship_selected].size()/equipment_cols-equipment_rows),0))
	if (equipment_offset!=ofs):
		update_icons()

func shipyard_offset(offset):
	var ofs = store_offset
	store_offset = clamp(ofs+offset,0,max(ceil(Equipment.shipyard.size()/store_cols-store_rows),0))
	if (store_offset!=ofs):
		update_icons()

func hangar_offset(offset):
	var ofs = inventory_offset
	inventory_offset = clamp(ofs+offset,0,max(ceil(Player.equipment.size()/inventory_cols-inventory_rows),0))
	if (inventory_offset!=ofs):
		update_icons()

func toggle_commodities_filter(pressed):
	store_filter["commodity"] = pressed
	update_icons()

func toggle_weapon_filter(pressed):
	store_filter["weapon"] = pressed
	store_filter["turret"] = pressed
	update_icons()

func toggle_missile_filter(pressed):
	store_filter["missile"] = pressed
	update_icons()

func toggle_reactor_filter(pressed):
	store_filter["reactor"] = pressed
	update_icons()

func toggle_engine_filter(pressed):
	store_filter["engine"] = pressed
	update_icons()

func toggle_internal_filter(pressed):
	store_filter["internal"] = pressed
	update_icons()

func toggle_external_filter(pressed):
	store_filter["external"] = pressed
	update_icons()

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
	update_icons()

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
		elif (k=="num_weapons"):
			if (Player.weapon_group[0].size()<req[k]):
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

func update_icons():
	# update inventory/equipment/store icons
	var ofs
	ofs = inventory_offset*inventory_cols
	for i in range(inventory_rows*inventory_cols):
		var item = get_node("Inventory/GridContainer/Item"+str(i))
		if (Player.inventory.size()>i+ofs):
			var type = Player.inventory[i+ofs][Equipment.TYPE]
			item.get_node("Number").set_text(str(Player.inventory[i+ofs][Equipment.AMMOUNT]))
			item.icon = type
			if (type!=""):
				var b = Equipment.outfits[type]["type"]
				item.get_node("Icon").set_texture(Equipment.outfits[type]["icon"])
				item.add_style_override("panel",Equipment.bg[b])
				if (b!="commodity"):
					item.get_node("Size").add_style_override("panel",Equipment.icon_size[Equipment.outfits[type]["size"]])
					item.get_node("Size").show()
				item.show()
			else:
				item.hide()
		else:
			item.hide()
	
	ofs = equipment_offset*equipment_cols
	for i in range(1,equipment_rows*equipment_cols+1):
		var item = get_node("Equipment/GridContainer/Item"+str(i))
		if (Player.ship_selected>=0 && Player.equipment[Player.ship_selected].size()>i+ofs):
			var type = Player.equipment[Player.ship_selected][i+ofs][Equipment.TYPE]
			if (Player.equipment[Player.ship_selected][i+ofs][Equipment.AMMOUNT]>1):
				item.get_node("Number").set_text(str(Player.equipment[Player.ship_selected][i+ofs][Equipment.AMMOUNT]))
			else:
				item.get_node("Number").set_text("")
			item.icon = type
			if (type!=""):
				item.get_node("Icon").set_texture(Equipment.outfits[type]["icon"])
			else:
				item.get_node("Icon").set_texture(null)
			var size = Equipment.outfits[Player.equipment[Player.ship_selected][0][Equipment.TYPE]]["slots"][i-1].split("_")[1]
			item.get_node("Size").add_style_override("panel",Equipment.icon_size[size])
			item.get_node("Size").show()
			if (Equipment.outfits[Player.equipment[Player.ship_selected][0][0]]["slots"].size()+1>i):
				var b = Equipment.outfits[Player.equipment[Player.ship_selected][0][0]]["slots"][i-1].split("_")[0]
				item.add_style_override("panel",Equipment.bg[b])
				item.show()
			else:
				item.hide()
		else:
			item.hide()
	
	var k = 0
	ofs = store_offset*store_cols
	for i in range(ofs,Equipment.store.size()):
		var item = get_node("Trade/GridContainer/Item"+str(k))
		var type = Equipment.store[i][Equipment.TYPE]
		item.icon = type
		item.get_node("Number").set_text(str(Equipment.store[i][Equipment.AMMOUNT]))
		if (type!=""):
			var b = Equipment.outfits[type]["type"]
			item.get_node("Icon").set_texture(Equipment.outfits[type]["icon"])
#			if (b>=0):
			item.add_style_override("panel",Equipment.bg[b])
			if (b!="commodity"):
					item.get_node("Size").add_style_override("panel",Equipment.icon_size[Equipment.outfits[type]["size"]])
					item.get_node("Size").show()
			if (store_filter[b]):
				item.show()
				item.ID = i
				k += 1
				if (k>=store_rows*store_cols):
					break
	for i in range(k,store_rows*store_cols):
		var item = get_node("Trade/GridContainer/Item"+str(i))
		item.hide()
		item.ID = i
	get_node("Equipment/Texture").set_size(get_node("Equipment/Texture").get_size().y*Vector2(1,1))
	if (Player.ship_selected>=0):
		get_node("Equipment/Texture").set_texture(Equipment.outfits[Player.equipment[Player.ship_selected][0][0]]["preview"])
	else:
		get_node("Equipment/Texture").set_texture(null)
	
	var k = 0
	ofs = store_offset*store_cols
	for i in range(ofs,Equipment.shipyard.size()):
		var item = get_node("Shipyard/Ships/Item"+str(k))
		var type = Equipment.shipyard[i][Equipment.TYPE]
		item.icon = type
		item.get_node("Number").set_text(str(Equipment.shipyard[i][Equipment.AMMOUNT]))
		if (type!=""):
			item.get_node("Icon").set_texture(Equipment.outfits[type]["icon"])
			item.add_style_override("panel",Equipment.bg["ship"])
			item.show()
			item.ID = i
			k += 1
			if (k>=store_rows*store_cols):
				break
	for i in range(k,store_rows*store_cols):
		var item = get_node("Shipyard/Ships/Item"+str(i))
		item.hide()
		item.ID = i
	
	var k = 0
	if (Player.equipment.size()>0):
		ofs = inventory_offset*inventory_cols
		for i in range(ofs,Player.equipment.size()):
			var item = get_node("Hangar/Hangar/Item"+str(k))
			var type = Player.equipment[i][0][Equipment.TYPE]
			item.icon = type
			item.get_node("Number").set_text("")
			if (Player.ship_location[i]==Player.station):
				item.set_opacity(1.0)
			else:
				item.set_opacity(0.75)
			if (type!=""):
				item.get_node("Icon").set_texture(Equipment.outfits[type]["icon"])
				item.add_style_override("panel",Equipment.bg["ship"])
				item.show()
				item.ID = i
				k += 1
				if (k>=store_rows*store_cols):
					break
	for i in range(k,inventory_rows*inventory_cols):
		var item = get_node("Hangar/Hangar/Item"+str(i))
		item.hide()
		item.ID = i
	if (Player.ship_selected>=0):
		get_node("Hangar/Hangar/Item"+str(Player.ship_selected)+"/Selected").show()
	
	Equipment.update_stats()
	
	get_node("Inventory/Credits").set_text(str(Player.credits)+Equipment.units["price"])
	get_node("Crew/Text").clear()
	if (Player.ship_selected>=0):
		get_node("Crew/Text").add_text(tr("CREW")+": "+str(Player.ship_crew[Player.ship_selected])+" / "+str(Equipment.player_bunks)+"\n"+tr("min_crew")+": "+str(Equipment.player_crew)+"\n"+tr("PASSENGERS")+": "+str(Player.passengers)+"\n"+tr("FREE_BUNKS")+": "+str(Equipment.player_bunks-Player.ship_crew[Player.ship_selected]))

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
