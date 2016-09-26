
extends CanvasLayer
# main menu

const LOAD = 0
const SAVE = 1
# show these actions in the options section
const actions = [
"shoot","launch_missile","missile_cycle_up","missile_cycle_down",
"thrust","reverse_thrust","land","board","show_map","time_speedup",
"zoom_in","zoom_out",
"weapon_group_1","weapon_group_2","weapon_group_3","weapon_group_4"]
# equipment when starting a new game
const start_equipment = [
#[["d01",1],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0],["",0]],
[["rpf",1],["paa",1],["paa",1],["",0],["",0],["rbs",1],["",0],["",0],["ebm",1],["ebm",1],["",0],["",0]],
[["fr2",1],["chg",1],["chg",1],["",0],["rbs",1],["",0],["ebs",1],["ebs",1],["",0]],
[["tr1",1],["cgt",1],["",0],["",0],["rbs",1],["",0],["ebs",1],["ebs",1],["",0],["",0]]]
const start_credits = [200,3000,1250]
const start_location = "Planet3/Station01"
const start_dock = 1

var mode = LOAD
var level_path = "res://scenes/level.tscn"

var res = Vector2(800,600)
var fullscreen = false
var sound = true
var sound_volume = 1.0
var music = true
var music_volume = 1.0
var difficulty = 1.0
var settings = {
"resolution_x":800,
"resolution_y":600,
"fullscreen":false,
"music":true,
"music_volume":1.0,
"sound":true,
"sound_volume":1.0,
"difficulty":1.0}
var key_binds = {}
var first = "First"
var last = "Last"
var ship = 0
var save_files = []
var autosave_files = []
var file_selected = ""
var action_selected = ""
var new_event

var thread = Thread.new()


# start game

func set_first(text):
	first = text

func set_last(text):
	last = text

func select_ship(ID):
	ship = ID

func load_level(level_path):
	get_node("Loading/Anim").play("fade_in")
	if (get_node("/root").has_node("Main")):
		get_node("/root/Main").delete_objects()
		get_node("/root/Main").queue_free()
	for c in HUD.get_node("Ships").get_children():
		c.queue_free()
	var level = load(level_path)
	call_deferred("load_done")
	return level

func load_done():
	var li = thread.wait_to_finish()
	get_node("Loading/Anim").play("fade_out")
	if (li==null):
		print("Can't load level!")
		return
	if (!li.can_instance()):
		print("Can't load level!")
		return
	li = li.instance()
	if (li==null):
		print("Can't load level!")
		return
	
	get_node("/root").add_child(li)
	
	Stations.player_land(Player.station,Player.dock)
	Stations.player_landed(false)
	Stations.get_node("TimerLand").stop()
	Equipment.swap_ship(Player.ship_selected)
	
	get_node("Menu/Buttons/Button1").set_disabled(false)
	get_node("Menu/Buttons/Button4").set_disabled(false)

func new_game():
	Player.first = first
	Player.last = last
	Player.inventory = []
	Player.credits = start_credits[ship]
	Player.equipment = [[]+start_equipment[ship]]
	Player.ship_location = [start_location]
	Player.ship_name = ["Player"]
	Player.ship_crew = [1]
	Player.ship_selected = 0
	Player.station = start_location
	Player.dock = start_dock
	Time.time = 0.0
	
	thread.start(self,"load_level",level_path)
	hide_menu()
	get_node("New").hide()

func _load():
	var file = File.new()
	if (!file.file_exists("user://saves/"+file_selected)):
		get_node("Files/Error").popup()
		get_node("Files/Error/Text").set_text("File "+file_selected+" not found!")
		return
	
	var error = file.open("user://saves/"+file_selected,File.READ)
	if (error==OK):
		while (!file.eof_reached()):
			var currentline = {}
			currentline.parse_json(file.get_line())
			if (currentline.has("first")):
				Player.first = currentline["first"]
				Player.last = currentline["last"]
			if (currentline.has("inventory")):
				Player.inventory = currentline["inventory"]
			if (currentline.has("credits")):
				Player.credits = currentline["credits"]
			if (currentline.has("equipment")):
				Player.equipment = currentline["equipment"]
			if (currentline.has("ship_location")):
				Player.ship_location = currentline["ship_location"]
			if (currentline.has("crew")):
				Player.ship_crew = currentline["crew"]
			if (currentline.has("ship_name")):
				Player.ship_name = currentline["ship_name"]
			if (currentline.has("ship_selected")):
				Player.ship_selected = currentline["ship_selected"]
			if (currentline.has("station")):
				Player.station = currentline["station"]
			if (currentline.has("dock")):
				Player.dock = currentline["dock"]
			if (currentline.has("time")):
				Time.time = currentline["time"]
				Economy.get_node("TimerEconomyUpdate").set_wait_time(60.0-fmod(Time.time,60.0))
			if (currentline.has("variables")):
				Player.variables = currentline["variables"]
			if (currentline.has("stations")):
				Stations.stations = currentline["stations"]
				Stations.stations_prod = currentline["stations_prod"]
				Stations.stations_cons = currentline["stations_cons"]
				Stations.stations_cargo = currentline["stations_cargo"]
				Stations.stations_comm = currentline["stations_comm"]
				Stations.stations_ballance = currentline["stations_ballance"]
				Stations.stations_outfits = currentline["stations_outfits"]
				Stations.stations_produced_outfits = currentline["stations_produced_outfits"]
				Stations.stations_ships = currentline["stations_ships"]
				Stations.stations_produced_ships = currentline["stations_produced_ships"]
				Stations.stations_services = currentline["stations_services"]
				Stations.stations_name = currentline["stations_name"]
				Stations.stations_desc = currentline["stations_desc"]
				Stations.stations_bar = currentline["stations_bar"]
				Stations.stations_image = currentline["stations_image"]
				Stations.stations_icon = currentline["stations_icon"]
				Stations.stations_pos = currentline["stations_pos"]
				Stations.stations_visible = currentline["station_visible"]
				for s in Stations.stations:
					var pos = Stations.stations_pos[s].split(", ")
					Stations.stations_pos[s] = Vector2(pos[0].substr(1,pos[0].length()),pos[0].substr(0,pos[0].length()-1))
				Stations.stations_fr = currentline["stations_fr"]
			if (currentline.has("missions")):
				Missions.missions = currentline["missions"]
				Missions.missions_finished = currentline["missions_finished"]
#			if (currentline.has("")):
#				Player. = currentline[""]
			
			
	else:
		get_node("Files/Error").popup()
		get_node("Files/Error/Text").set_text("Failed to open file "+file_selected+"!")
		return
	
	thread.start(self,"load_level",level_path)
	hide_menu()

func _save():
	if (!Player.docked):
		return
	
	var file = File.new()
	var error = file.open("user://saves/"+file_selected,File.WRITE)
	if (error!=OK):
		get_node("Files/Error").popup()
		get_node("Files/Error/Text").set_text("Error writing to file "+file_selected+"!")
		return
	
	file.store_line({"first":Player.first,"last":Player.last}.to_json())
	file.store_line({"time":Time.time}.to_json())
	file.store_line(OS.get_datetime().to_json())
	file.store_line({"inventory":Player.inventory}.to_json())
	file.store_line({"credits":Player.credits}.to_json())
	file.store_line({"equipment":Player.equipment}.to_json())
	file.store_line({"ship_location":Player.ship_location}.to_json())
	file.store_line({"crew":Player.ship_crew}.to_json())
	file.store_line({"ship_name":Player.ship_name}.to_json())
	file.store_line({"ship_selected":Player.ship_selected}.to_json())
	file.store_line({"station":Player.station}.to_json())
	file.store_line({"dock":Player.dock}.to_json())
	file.store_line({"variables":Player.variables}.to_json())
	file.store_line({"stations":Stations.stations,"stations_prod":Stations.stations_prod,"stations_cons":Stations.stations_cons,"stations_cargo":Stations.stations_cargo,"stations_comm":Stations.stations_comm,"stations_ballance":Stations.stations_ballance,"stations_outfits":Stations.stations_outfits,"stations_produced_outfits":Stations.stations_produced_outfits,"stations_ships":Stations.stations_ships,"stations_produced_ships":Stations.stations_produced_ships,"stations_services":Stations.stations_services,"stations_name":Stations.stations_name,"stations_desc":Stations.stations_desc,"stations_bar":Stations.stations_bar,"stations_image":Stations.stations_image,"stations_icon":Stations.stations_icon,"stations_pos":Stations.stations_pos,"stations_fr":Stations.stations_fr,"station_visible":Stations.stations_visible}.to_json())
	file.store_line({"missions":Missions.missions,"missions_finished":Missions.missions_finished}.to_json())
	
	file.close()

func _autosave():
	var date = OS.get_date()
	var time = OS.get_time()
	var dir = Directory.new()
	var filename = "autosaves/"+Player.first+"-"+Player.last+"_"
	var file_ID = 4
	_create_save_dir()
	if (dir.file_exists("user://saves/"+filename+"3.sav")):
		dir.remove("user://saves/"+filename+"3.sav")
	for i in range(2,0,-1):
		if (dir.file_exists("user://saves/"+filename+str(i)+".sav")):
			dir.rename("user://saves/"+filename+str(i)+".sav","user://saves/"+filename+str(i+1)+".sav")
	file_selected = filename+"1.sav"
	
	_save()

func load_or_save():
	if (mode==LOAD):
		_load()
	elif (mode==SAVE):
		_save()
	get_node("Files").hide()


# load and save

func _create_save_dir():
	var dir = Directory.new()
	if (!dir.dir_exists("user://saves/autosaves")):
		dir.make_dir_recursive("user://saves/autosaves")

func get_save_files():
	_create_save_dir()
	var dir = Directory.new()
	var error = dir.open("user://saves")
	if (error!=OK):
		print("Error opening save directory("+str(error)+")!")
		get_node("Files/Error/Text").set_text("Can't make save directory!")
		get_node("Files/Error").popup()
		return
	
	save_files.clear()
	autosave_files.clear()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name!=""):
		if (!dir.current_is_dir()):
			save_files.push_back(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	error = dir.open("user://saves/autosaves")
	autosave_files.clear()
	if (error!=OK):
		print("Error opening autosave directory("+str(error)+")!")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while (file_name!=""):
		if (!dir.current_is_dir()):
			autosave_files.push_back(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func set_selected_file(file):
	file_selected = file

func set_file_and_confirm(file):
	file_selected = file
	load_or_save()

func select_file(ID):
	file_selected = save_files[ID]
	get_node("Files/LineEdit").set_text(file_selected)

func select_autosave(ID):
	file_selected = "autosaves/"+autosave_files[ID]
	get_node("Files/LineEdit").set_text(file_selected)

func update_files():
	get_save_files()
	
	for i in range(save_files.size()):
		var data = save_files[i].replace(".sav","").split("_")
		var bi
		if (get_node("Files/ScrollContainer/VBoxContainer").has_node("File"+str(i))):
			bi = get_node("Files/ScrollContainer/VBoxContainer/File"+str(i))
		else:
			bi = get_node("Files/ScrollContainer/VBoxContainer/File").duplicate()
			bi.set_name("File"+str(i))
			bi.connect("pressed",self,"select_file",[i])
			get_node("Files/ScrollContainer/VBoxContainer").add_child(bi)
			bi.show()
		
		var file = File.new()
		var error = file.open("user://saves/"+save_files[i],File.READ)
		if (error==OK):
			var currentline = {}
			currentline.parse_json(file.get_line())
			bi.get_node("HBoxContainer/Name").set_text(currentline["first"]+" "+currentline["last"])
			currentline.parse_json(file.get_line())
			bi.get_node("HBoxContainer/Time").set_text("day "+str(1+floor(currentline["time"]/60.0/24.0)))
			currentline.parse_json(file.get_line())
			bi.get_node("HBoxContainer/Date").set_text(str(currentline["hour"])+":"+str(currentline["minute"])+", "+str(currentline["day"])+"."+str(currentline["month"])+"."+str(currentline["year"]))
		
#		bi.get_node("HBoxContainer/Name").set_text(data[0].replace("-"," "))
#		if (data.size()>1):
#			bi.get_node("HBoxContainer/Time").set_text(data[1]+" days")
#		if (data.size()>3):
#			bi.get_node("HBoxContainer/Date").set_text(data[2].replace("-",".")+", "+data[3].replace("-",":"))
		bi.raise()
	
	for i in range(autosave_files.size()):
		var data = autosave_files[i].replace(".sav","").replace("autosave/","").split("_")
		var bi
		if (get_node("Files/ScrollContainer/VBoxContainer").has_node("FileA"+str(i))):
			bi = get_node("Files/ScrollContainer/VBoxContainer/FileA"+str(i))
		else:
			bi = get_node("Files/ScrollContainer/VBoxContainer/FileA").duplicate()
			bi.set_name("FileA"+str(i))
			bi.connect("pressed",self,"select_autosave",[i])
			get_node("Files/ScrollContainer/VBoxContainer").add_child(bi)
			bi.show()
		bi.get_node("HBoxContainer/Name").set_text(data[0].replace("-"," "))
		if (data.size()>1):
			bi.get_node("HBoxContainer/Autosave").set_text(tr("AUTOSAVE")+" "+data[1].replace(".sav",""))
		bi.raise()



# options

func set_res_x(value):
	res.x = value

func set_res_y(value):
	res.y = value

func set_fullscreen(pressed):
	fullscreen = pressed

func enable_sounds(pressed):
	sound = pressed

func set_sound_volume(value):
	sound_volume = value/100.0

func enable_music(pressed):
	music = pressed

func set_music_volume(value):
	music_volume = value/100.0

func set_difficulty(value):
	difficulty = value/100.0

func options_cancel():
	get_node("Options").hide()
	res = Vector2(settings["resolution_x"],settings["resolution_y"])
	fullscreen = settings["fullscreen"]
	sound = settings["sound"]
	sound_volume = settings["sound_volume"]
	music = settings["music"]
	music_volume = settings["music_volume"]
	difficulty = settings["difficulty"]
	Player.difficulty = difficulty
	get_node("Options/ScrollContainer/VBoxContainer/Resolution/HBoxContainer/SpinBoxX").set_value(res.x)
	get_node("Options/ScrollContainer/VBoxContainer/Resolution/HBoxContainer/SpinBoxY").set_value(res.y)
	get_node("Options/ScrollContainer/VBoxContainer/Fullscreen/HBoxContainer/CheckBox").set_pressed(fullscreen)
	get_node("Options/ScrollContainer/VBoxContainer/Sound/HBoxContainer/CheckBox").set_pressed(sound)
	get_node("Options/ScrollContainer/VBoxContainer/Sound/HBoxContainer/SpinBoxV").set_value(sound_volume*100)
	get_node("Options/ScrollContainer/VBoxContainer/Music/HBoxContainer/CheckBox").set_pressed(music)
	get_node("Options/ScrollContainer/VBoxContainer/Music/HBoxContainer/SpinBoxV").set_value(music_volume*100)
	get_node("Options/ScrollContainer/VBoxContainer/Difficulty/HBoxContainer/SpinBoxD").set_value(difficulty*100)
	
	OS.set_window_size(res)
	OS.set_video_mode(res,fullscreen,true)
	OS.set_window_fullscreen(fullscreen)
	AudioServer.set_fx_global_volume_scale(sound_volume*sound)
	AudioServer.set_stream_global_volume_scale(music_volume*music)
	
	for action in actions:
		if (key_binds.has(action)):
			for i in range(key_binds[action].size()):
				var ev = InputEvent()
				ev.type = key_binds[action][i]["type"]
				if (ev.type==InputEvent.KEY):
					ev.scancode = key_binds[action][i]["scancode"]
				elif (ev.type==InputEvent.MOUSE_BUTTON):
					ev.button_index = key_binds[action][i]["button_index"]
				InputMap.action_add_event(action,ev)

func options_confirm():
	get_node("Options").hide()
	settings["resolution_x"] = res.x
	settings["resolution_y"] = res.y
	settings["fullscreen"] = fullscreen
	settings["sound"] = sound
	settings["sound_volume"] = sound_volume
	settings["music"] = music
	settings["music_volume"] = music_volume
	settings["difficulty"] = difficulty
	Player.difficulty = difficulty
	
	key_binds.clear()
	for action in actions:
		key_binds[action] = []
		for event in InputMap.get_action_list(action):
			if (event.type==InputEvent.KEY):
				key_binds[action].push_back({"type":event.type,"scancode":event.scancode})
			elif (event.type==InputEvent.MOUSE_BUTTON):
				key_binds[action].push_back({"type":event.type,"button_index":event.button_index})
	
	OS.set_window_size(res)
	OS.set_video_mode(res,fullscreen,true)
	OS.set_window_fullscreen(fullscreen)
	AudioServer.set_fx_global_volume_scale(sound_volume*sound)
	AudioServer.set_stream_global_volume_scale(music_volume*music)
	
	save_settings()

func save_settings():
	var file = File.new()
	var error = file.open("user://settings.cfg",File.WRITE)
	
	file.store_line(settings.to_json())
	file.store_line(key_binds.to_json())
	
	file.close()

func load_settings():
	var file = File.new()
	if (!file.file_exists("user://settings.cfg")):
		print("No config file found!")
		default_settings()
		options_cancel()
		update_key_binds()
		return 
	var error = file.open("user://settings.cfg",File.READ)
	
	if (error==OK):
		while (!file.eof_reached()):
			var currentline = {}
			currentline.parse_json(file.get_line())
			for s in settings.keys():
				if (currentline.has(s)):
					settings[s] = float(currentline[s])
			for action in actions:
				if (currentline.has(action)):
					key_binds[action] = currentline[action]
	else:
		default_settings()
	
	options_cancel()
	update_key_binds()

func default_settings():
	settings["resolution_x"] = OS.get_screen_size().x
	settings["resolution_y"] = OS.get_screen_size().y
	settings["fullscreen"] = true

func update_key_binds():
	for action in actions:
		if (!has_node("Options/ScrollContainer/VBoxContainer/"+action)):
			var pi = get_node("Options/ScrollContainer/VBoxContainer/KeyBind").duplicate()
			pi.set_name(action)
			pi.get_node("HBoxContainer/Label").set_text(tr(action))
			pi.get_node("HBoxContainer/ButtonAdd").connect("pressed",self,"show_add_key",[action])
			get_node("Options/ScrollContainer/VBoxContainer").add_child(pi)
			pi.show()
		
		var keys = InputMap.get_action_list(action)
		for event in keys:
			if (event.type==InputEvent.KEY && !has_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer/Label_"+str(event.scancode))):
				var li = get_node("Options/Label0").duplicate()
				var bi = get_node("Options/Button0").duplicate()
				li.set_text(str(event.scancode))
				bi.connect("pressed",self,"remove_key",[action,event])
				li.set_name("Label_"+str(event.scancode))
				bi.set_name("Button_"+str(event.scancode))
				get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer").add_child(li)
				get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer").add_child(bi)
				li.show()
				bi.show()
			elif (event.type==InputEvent.MOUSE_BUTTON && !has_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer/Label_"+str(event.button_index))):
				var li = get_node("Options/Label0").duplicate()
				var bi = get_node("Options/Button0").duplicate()
				li.set_text(str(event.button_index))
				bi.connect("pressed",self,"remove_key",[action,event])
				li.set_name("Label_"+str(event.button_index))
				bi.set_name("Button_"+str(event.button_index))
				get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer").add_child(li)
				get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer").add_child(bi)
				li.show()
				bi.show()

func add_key(action,event):
	InputMap.action_add_event(action,event)
	if (!has_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer/Label_"+str(event.scancode))):
		var li = get_node("Options/Label0").duplicate()
		var bi = get_node("Options/Button0").duplicate()
		li.set_text(str(event.scancode))
		bi.connect("pressed",self,"remove_key",[action,event])
		li.set_name("Label_"+str(event.scancode))
		bi.set_name("Button_"+str(event.scancode))
		get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer").add_child(li)
		get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer").add_child(bi)
		li.show()
		bi.show()

func remove_key(action,event):
	InputMap.action_erase_event(action,event)
	if (has_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer/Label_"+str(event.scancode))):
		get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer/Label_"+str(event.scancode)).queue_free()
		get_node("Options/ScrollContainer/VBoxContainer/"+action+"/HBoxContainer/HBoxContainer/Button_"+str(event.scancode)).queue_free()

func add_new_key():
	add_key(action_selected,new_event)

# menu functions

func quit():
	if (get_node("Quit").is_visible()):
		_quit()
	else:
		get_node("Quit").popup_centered()

func _quit():
	save_settings()
	get_tree().quit()

func show_menu():
	get_node("Menu/Anim").play("show")
	get_node("BG").show()

func hide_menu():
	get_node("Menu/Anim").play("hide")
	get_node("BG").hide()

func show_load():
	update_files()
	get_node("Files").set_title(tr("LOAD"))
	get_node("Files/Button").set_text(tr("LOAD"))
	mode = LOAD
	get_node("Files").set_pos(Vector2(112,184))
	get_node("Files").popup()

func show_save():
	var date = OS.get_date()
	var time = OS.get_time()
	update_files()
	file_selected = Player.first+"-"+Player.last+"_"+str(date["day"])+"-"+str(date["month"])+"-"+str(date["year"])+"_"+str(time["hour"])+"-"+str(time["minute"])+".sav"
	get_node("Files").set_title(tr("SAVE"))
	get_node("Files/Button").set_text(tr("SAVE"))
	get_node("Files/LineEdit").set_text(file_selected)
	mode = SAVE
	get_node("Files").set_pos(Vector2(112,184))
	get_node("Files").popup()

func show_options():
	get_node("Options").set_pos(Vector2(112,184))
	get_node("Options").popup()

func show_new():
	get_node("New").set_pos(Vector2(112,184))
	get_node("New").popup()

func hide_new():
	get_node("New").hide()

func toggle_options_video(pressed):
	if (pressed):
		get_node("Options/ScrollContainer/VBoxContainer/Resolution").show()
		get_node("Options/ScrollContainer/VBoxContainer/Fullscreen").show()
	else:
		get_node("Options/ScrollContainer/VBoxContainer/Resolution").hide()
		get_node("Options/ScrollContainer/VBoxContainer/Fullscreen").hide()

func toggle_options_sound(pressed):
	if (pressed):
		get_node("Options/ScrollContainer/VBoxContainer/Sound").show()
		get_node("Options/ScrollContainer/VBoxContainer/Music").show()
	else:
		get_node("Options/ScrollContainer/VBoxContainer/Sound").hide()
		get_node("Options/ScrollContainer/VBoxContainer/Music").hide()

func toggle_options_game(pressed):
	if (pressed):
		get_node("Options/ScrollContainer/VBoxContainer/Difficulty").show()
	else:
		get_node("Options/ScrollContainer/VBoxContainer/Difficulty").hide()

func toggle_options_keys(pressed):
	if (pressed):
		for action in actions:
			get_node("Options/ScrollContainer/VBoxContainer/"+action).show()
	else:
		for action in actions:
			get_node("Options/ScrollContainer/VBoxContainer/"+action).hide()

func show_add_key(action):
	action_selected = action
	get_node("Options/AddKey/LabelAction").set_text(action)
	get_node("Options/AddKey/LabelKey").set_text(tr("PRESS_KEY"))
	get_node("Options/AddKey").show()


func _resize():
	res = OS.get_video_mode_size()
	settings["resolution_x"] = res.x
	settings["resolution_y"] = res.y
	get_node("Options/ScrollContainer/VBoxContainer/Resolution/HBoxContainer/SpinBoxX").set_value(res.x)
	get_node("Options/ScrollContainer/VBoxContainer/Resolution/HBoxContainer/SpinBoxY").set_value(res.y)
	if (get_node("Options").is_visible()):
		get_node("Options").popup()

func _input(event):
	if (event.type==InputEvent.KEY):
		if (event.is_action_pressed("escape")):
			if (get_node("Menu").is_visible()):
				if (get_node("Files").is_visible()):
					get_node("Files").hide()
				elif (get_node("Options").is_visible()):
					get_node("Options").hide()
				elif (get_node("New").is_visible()):
					get_node("New").hide()
				elif (!get_node("/root").has_node("Main")):
					quit()
				else:
					if (get_node("Quit").is_visible()):
						get_node("Quit").hide()
					else:
						hide_menu()
						if (Player.docked || HUD.map):
							Input.set_custom_mouse_cursor(HUD.cursor_normal,Vector2(1,1))
						else:
							Input.set_custom_mouse_cursor(HUD.cursor_cross,Vector2(16,16))
			else:
				show_menu()
				if (get_node("/root").has_node("Main")):
					Input.set_custom_mouse_cursor(HUD.cursor_normal,Vector2(1,1))
		else:
			new_event = event
			get_node("Options/AddKey/LabelKey").set_text(str(event.scancode))

func _ready():
	get_tree().connect("screen_resized", self, "_resize")
	set_process_input(true)
	show_menu()
	
	load_settings()