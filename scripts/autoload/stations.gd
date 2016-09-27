
extends Node

const OVERVIEW = 0
const EQUIPMENT = 1
const TRADE = 2
const BAR = 3
const SHIPYARD = 4
const MAP = 5
const CREW = 6
const services = ["bar","trader","missions","outfitter","shipyard","crew"]


var stations = []
var stations_icon = {}
var stations_prod = {}
var stations_cons = {}
var stations_cargo = {}
var stations_comm = {}
var stations_ballance = {}
var stations_outfits = {}
var stations_produced_outfits = {}
var stations_ships = {}
var stations_produced_ships = {}
var stations_services = {}
var stations_name = {}
var stations_desc = {}
var stations_bar = {}
var stations_image = {}
var stations_price = {}
var stations_icons = {}
var stations_pos = {}
var stations_fr = {}
var stations_visible = {}


var cursor_cross = load("res://images/UI/cursor_cross.png")
var cursor_normal = load("res://images/UI/cursor.png")



func get_station_positions():
	var positions = {}
	for s in stations:
		positions[s] = stations_pos[s].rotated(stations_fr[s]*Time.time)
	return positions


# dock to station
func land(station,dock,ship):
	get_node("/root/Main/"+station).take_off_delay[dock] = 1.0
	
	if (ship!=null):
		var tmr = Timer.new()
		get_node("/root/Main").ships.erase(ship)
		tmr.connect("timeout",ship,"queue_free")
		tmr.set_wait_time(1.0)
		ship.add_child(tmr)
		tmr.start()
		ship.clear_shapes()
		ship.get_node("Anim").play("land")
		ship.destroyed()

func player_land(station,dock):
	var node
	if (get_node("/root/Main").has_node("Player")):
		node = get_node("/root/Main/Player")
	Player.station = station
	Player.dock = dock
	Player.docked = true
	Player.parent = station+"/Position"+str(dock)
	Player.ship_location[Player.ship_selected] = station
	land(station,dock,node)
	
	Player.time_speedup = false
	get_node("TimerLand").start()

func player_landed(autosave=true):
	Time.enable_pause()
	
	var image = null
	if (stations_image[Player.station]!=""):
		image = load("res://images/stations/"+stations_image[Player.station])
	HUD.get_node("Station").menu = OVERVIEW
	HUD.get_node("Station").show_overview()
	for s in services:
		if (s in stations_services[Player.station]):
			HUD.get_node("Station/VBoxContainer/Button_"+s).show()
		else:
			HUD.get_node("Station/VBoxContainer/Button_"+s).hide()
	HUD.get_node("Station/Name/Text").set_text(stations_name[Player.station])
	HUD.get_node("Station/Overview/Text").set_text(stations_desc[Player.station])
	HUD.get_node("Station/Bar/Text").set_text(stations_bar[Player.station])
	HUD.get_node("Station/Overview/Picture").set_texture(image)
	HUD.get_node("Station/Bar/Picture").set_texture(image)
	HUD.get_node("Station").show()
	HUD.get_node("Station/VBoxContainer/Button_overview").grab_focus()
	Input.set_custom_mouse_cursor(cursor_normal,Vector2(1,1))
	
	if (has_node("/root/Main/Player")):
		var ammo = []+get_node("/root/Main/Player").missile_ammo
		var ID = -1
		for i in range(Player.equipment[Player.ship_selected].size()):
			if (Player.equipment[Player.ship_selected][i][Equipment.TYPE]!="" && Equipment.outfits[Player.equipment[Player.ship_selected][i][Equipment.TYPE]]["type"]=="missile"):
				var item = []+Player.equipment[Player.ship_selected][i]
				var iID
				ID += 1
				Equipment.unequip(i)
				Equipment.remove_item([item[Equipment.TYPE],item[Equipment.AMMOUNT]-ammo[ID]])
				iID = Equipment.find_item(item)
				if (iID>=0):
					Equipment.equip(i,iID)
	
	Equipment.store.clear()
	for c in Economy.commodities:
		if (stations_cargo[Player.station].has(c) && stations_cargo[Player.station][c]>0):
			Equipment.store += [[c,stations_comm[Player.station][c]]]
	Equipment.store += stations_outfits[Player.station]
	Equipment.shipyard = stations_ships[Player.station]
	Equipment.update_icons()
	HUD.hide_map()
	HUD.hide_hud()
	Player.ship_crew[Player.ship_selected] = max(Player.ship_crew[Player.ship_selected],Equipment.player_crew)
	
	get_node("/root/Main").delete_objects()
	for s in stations:
		get_node("/root/Main/"+s).clear_all_docks()
	get_node("/root/Menu/Menu/Buttons/Button4").set_disabled(false)
	if (autosave):
		get_node("/root/Menu")._autosave()
	
	Missions.create_random_missions()
	HUD.get_node("Station").update_missions()
	if (get_node("/root/Main").has_method("landed")):
		get_node("/root/Main").landed()
	emit_signal("player_landed",Player.station)
	Missions.landed(Player.station)

# start from a station
func take_off(station,dock,ship,equipment,inventory,script,faction,name,crew):
	var pos = get_node("/root/Main/"+station+"/Position"+str(dock)).get_global_pos()
	var pos2 = get_node("/root/Main/"+station+"/Position"+str(dock)+"/Position").get_global_pos()
	var si = Ships.create_ship(ship,equipment,inventory,script,faction,pos,pos.angle_to_point(pos2),get_node("/root/Main/"+station).get_lv()+(pos2-pos)/5.0,name,crew)
	si.get_node("Anim").play("take_off")
	
	get_node("/root/Main/"+station).docked[dock] = true
	get_node("/root/Main/"+station).take_off_delay[dock] = 10.0
	return si

func player_take_off():
	Time.disable_pause()
	
	if (Player.ship_selected<0):
		HUD.get_node("Station/Warning/Text").set_text(tr("NO_SHIP"))
		HUD.get_node("Station/Warning").popup_centered()
		return
	if (Equipment.player_cargo):
		HUD.get_node("Station/Warning/Text").set_text(tr("NOT_ENOUGH_CARGO_SPACE"))
		HUD.get_node("Station/Warning").popup_centered()
		return
	if (Equipment.player_power):
		HUD.get_node("Station/Warning/Text").set_text(tr("NOT_ENOUGH_POWER"))
		HUD.get_node("Station/Warning").popup_centered()
		return
	if (Equipment.player_thrust):
		HUD.get_node("Station/Warning/Text").set_text(tr("NOT_ENOUGH_ACCELERATION"))
		HUD.get_node("Station/Warning").popup_centered()
		return
	if (Equipment.player_heat):
		HUD.get_node("Station/Warning/Text").set_text(tr("OVERHEATING"))
		HUD.get_node("Station/Warning").popup_centered()
		return
	
	Player.docked = false
	
	for c in Economy.commodities:
		if (stations_cargo[Player.station].has(c) && stations_cargo[Player.station][c]>0):
			var ID = Equipment.find_store([c])
			if (ID>=0):
				stations_comm[Player.station][c] = Equipment.store[ID][1]
	stations_outfits[Player.station].clear()
	for i in range(Equipment.store.size()):
		if (Equipment.outfits[Equipment.store[i][Equipment.TYPE]]["type"]!="commodity"):
			stations_outfits[Player.station].push_back(Equipment.store[i])
	
	if (!has_node("/root/Main/Player")):
		var pos = get_node("/root/Main/"+Player.parent).get_global_pos()
		Ships.create_player(pos,pos.angle_to_point(get_node("/root/Main/"+Player.parent+"/Position").get_global_pos()),get_node("/root/Main/"+Player.station).get_lv()+(get_node("/root/Main/"+Player.parent+"/Position").get_global_pos()-pos)/5.0)
	get_node("/root/Main/Player/Anim").play("take_off")
	
	get_node("/root/Main/"+Player.station).docked[Player.dock] = true
	get_node("/root/Main/"+Player.station).take_off_delay[Player.dock] = 10.0
	HUD.get_node("Station").hide()
	Player.station = null
	HUD.get_node("Station").menu = OVERVIEW
	HUD.hide_map()
	HUD.show_hud()
	HUD._resize()
	Input.set_custom_mouse_cursor(cursor_cross,Vector2(16,16))
	Player.missile_ammo = get_node("/root/Main/Player").missile_ammo
	
	get_node("/root/Menu/Menu/Buttons/Button4").set_disabled(true)
	get_node("/root/Main").update_objects()
	
	emit_signal("player_take_off",Player.station)
	
#	Ships.create_rnd_pirate(Vector2(288000,-1000),Vector2(0,0))
#	Ships.create_rnd_pirate(Vector2(287000,-500),Vector2(0,0))
#	Ships.create_rnd_pirate(Vector2(286000,0),Vector2(0,0))

func reset_outfits():
	for s in stations:
		stations_outfits[s] = []+stations_produced_outfits[s]
		stations_ships[s] = []+stations_produced_ships[s]

func _ready():
	var ti = Timer.new()
	ti.set_name("TimerLand")
	ti.set_wait_time(0.9)
	ti.set_one_shot(true)
	ti.connect("timeout",self,"player_landed")
	add_child(ti)
	
	add_user_signal("player_landed",[{"station":TYPE_STRING}])
	add_user_signal("player_take_off",[{"station":TYPE_STRING}])
