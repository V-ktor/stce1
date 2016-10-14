
extends CanvasLayer

const OVERVIEW = 0
const EQUIPMENT = 1
const TRADE = 2
const BAR = 3
const SHIPYARD = 4
const MAP = 5
const CREW = 6

var map = false
var map_scale = 1.0
var map_zoom = 1.0
var map_center = Vector2(0,0)

var cursor_cross = load("res://images/ui/cursor_cross.png")
var cursor_normal = load("res://images/ui/cursor.png")

func show_map():
	map = true
	set_process(true)
	get_node("Map/Map/Draw").update()
	get_node("Map").show()
	for c in get_node("Map/Map").get_children():
		c.show()
	get_node("Map/Map/Station0").hide()

func hide_map():
	map = false
	set_process(false)
	get_node("Map").hide()
	for c in get_node("Map/Map").get_children():
		c.hide()

func show_hud():
	get_node("Ships").show()
	get_node("Status").show()
	get_node("Weapons").show()

func hide_hud():
	get_node("Ships").hide()
	get_node("Status").hide()
	get_node("Weapons").hide()

func update_weapon_groups():
	for c in get_node("Station/Weapons/ScrollContainer/VBoxContainer").get_children():
		c.set_name("deleted")
		c.queue_free()
	
	for i in range(Player.weapon_group[0].size()):
		var bi = get_node("Station/Weapons/Weapon0").duplicate()
		bi.set_name("Weapon"+str(i))
		bi.get_node("Name").set_text(tr(Equipment.outfits[Equipment.player_weapons[i]]["name"]))
		bi.get_node("Icon").set_texture(Equipment.outfits[Equipment.player_weapons[i]]["icon"])
		for j in range(Player.weapon_group.size()):
			bi.get_node("HBoxContainer/Button"+str(j+1)).set_pressed(Player.weapon_group[j][i])
			bi.get_node("HBoxContainer/Button"+str(j+1)).connect("toggled",self,"weapon_toggled",[j,i])
		get_node("Station/Weapons/ScrollContainer/VBoxContainer").add_child(bi)
		bi.show()

func weapon_toggled(activated,group,weapon):
	Player.weapon_group[group][weapon] = activated


func _resize():
	var scale = OS.get_video_mode_size().y/800.0
	var zoom = 3.0/min(OS.get_video_mode_size().x/1000.0,OS.get_video_mode_size().y/600.0)
	map_scale = 0.00065/zoom
	
	if (has_node("Status/Ship/Outlines")):
		get_node("Status/Ship").set_size(Vector2(get_node("Status/Ship/Outlines").get_texture().get_width(),get_node("Status/Ship/Outlines").get_texture().get_height())*scale)
		get_node("Status/Ship/Outlines").set_scale(scale*Vector2(1,1))
	
	get_node("Map/Map").set_rect(Rect2(Vector2(0,0),get_node("Map").get_rect().size))
	
	get_node("Station")._resize()
	get_node("Station").update_icons()

func _input(event):
	if (event.type==InputEvent.MOUSE_BUTTON):
		var camera = null
		if (map):
			camera = get_node("/root/Main/Camera")
		if (event.is_action_pressed("LMB") && map && (get_node("Station").is_hidden() || (event.pos.x>225 && event.pos.y>50 && event.pos.x<OS.get_video_mode_size().x-180 && event.pos.y<OS.get_video_mode_size().y-48))):
			if (map_zoom>1.0):
				map_center = Vector2(0,0)
				map_zoom = 1.0
				get_node("Map/Map/Draw").update()
			else:
				map_center = map_center-20.0/map_zoom*(camera.get_global_mouse_pos()-camera.get_global_pos())/camera.get_zoom()-map_center/map_zoom
				map_zoom = 20.0
				get_node("Map/Map/Draw").update()
	elif (event.type==InputEvent.KEY):
		if (event.is_action_pressed("show_map") && get_node("Station").is_hidden()):
			if (event.is_pressed() && !map):
				if (get_node("/root/Main").has_node("Player")):
					map_zoom = 20.0
					map_center = -map_zoom*map_scale*get_node("/root/Main/Player").get_global_pos()
				show_map()
				Input.set_custom_mouse_cursor(cursor_normal,Vector2(1,1))
			else:
				hide_map()
				Input.set_custom_mouse_cursor(cursor_cross,Vector2(16,16))
		
		Equipment.buy_ammount = (1+4*Input.is_action_pressed("multiplier_5"))*(1+9*Input.is_action_pressed("multiplier_10"))*(1+99*Input.is_action_pressed("multiplier_100"))

func _process(delta):
	if (!map):
		return
	
	# draw map
	var center = OS.get_video_mode_size()/2.0+map_center
	var pos = Vector2(0,0)
	var radar_range = 0
	get_node("Map/Map/Sun").set_pos(get_node("/root/Main/Sun").get_global_pos()*map_scale*map_zoom+center)
	get_node("Map/Map/Sun").set_scale(map_scale*map_zoom*250*Vector2(1,1))
	if (has_node("/root/Main/Player")):
		pos = get_node("/root/Main/Player").get_global_pos()
		radar_range = get_node("/root/Main/Player").radar
		if (get_node("/root/Main/Player").nav.size()>0 && get_node("/root/Main/Player").ap):
			get_node("Map/Map/Nav").show()
			get_node("Map/Map/Nav").set_pos(get_node("/root/Main/Player").nav[0].get_global_pos()*map_scale*map_zoom+center)
		else:
			HUD.get_node("Map/Map/Nav").hide()
	for i in range(get_node("/root/Main").num_planets):
		get_node("Map/Map/Planet"+str(i+1)).set_pos((get_node("/root/Main/Planet"+str(i+1)+"/Planet").get_global_pos())*map_scale*map_zoom+center)
		get_node("Map/Map/Planet"+str(i+1)).set_scale(map_scale*100*Vector2(1,1))
		get_node("Map/Map/Planet"+str(i+1)).set_rot(get_node("/root/Main/Planet"+str(i+1)).get_rot())
	var c = get_node("Station").commodity
	for s in Stations.stations:
		if (pos.distance_squared_to(get_node("/root/Main/"+s).get_global_pos())<radar_range*radar_range || Stations.stations_visible[s]):
			Stations.stations_icons[s].set_pos(get_node("/root/Main/"+s).get_global_pos()*map_scale*map_zoom+center)
			Stations.stations_icons[s].set_scale(map_scale*1000*Vector2(1,1))
			Stations.stations_icons[s].show()
			Stations.stations_visible[s] = true
			if (get_node("Station").menu==MAP && Stations.stations_cargo[s].has(c) && Stations.stations_cargo[s][c]>0):
				var f = 0.5*(Economy.prices[c]-Stations.stations_price[s][c])/Economy.price_range[c]+0.5
				Stations.stations_icons[s].get_node("BG").set_modulate(Color(1,0.5,0,1).linear_interpolate(Color(0,1,0.5,1),f))
			else:
				Stations.stations_icons[s].get_node("BG").set_modulate(Color(1,1,1,0))
		else:
			Stations.stations_icons[s].hide()
	if (radar_range<=0):
		return
	for ship in get_node("/root/Main").ships+get_node("/root/Main").objects:
		if (true || pos.distance_squared_to(ship.get_global_pos())<(radar_range-ship.stealth)*(radar_range-ship.stealth)):
			ship.icon.set_pos(ship.get_global_pos()*map_scale*map_zoom+center)
			ship.icon.set_rot(ship.get_rot())
			ship.icon.show()
			if (Factions.is_enemy(Factions.PLAYER,ship.faction)):
				Player.time_speedup = false
		else:
			ship.icon.hide()

func _ready():
	set_process_input(true)
	get_tree().connect("screen_resized",self,"_resize")
	
	get_node("Tooltip/VBoxContainer/Line4/Slots").set_scroll_active(false)
	Input.set_custom_mouse_cursor(cursor_normal,Vector2(1,1))
	hide_map()
	hide_hud()
