
extends Node

var missions = []
var missions_available = []
var missions_finished = []


func create_random_missions():
	missions_available.clear()
	create_random_bounty_missions()
	create_random_escort_missions()
	create_random_transport_missions()
	create_random_passenger_missions()

func create_random_bounty_missions():
	var num_basic_bounty_missions = randi()%3
	var num_alive_bounty_missions = randi()%2
	var index = missions_available.size()
	var num_missions = num_basic_bounty_missions+num_alive_bounty_missions
	missions_available.resize(missions_available.size()+num_missions)
	for i in range(index,index+num_basic_bounty_missions):
		var data = basic_bounty_mission_init()
		missions_available[i] = data
	index += num_basic_bounty_missions
	for i in range(index,index+num_alive_bounty_missions):
		var data = alive_bounty_mission_init()
		missions_available[i] = data
	index += num_alive_bounty_missions
	

func create_random_escort_missions():
	var num_basic_escort_missions = randi()%3
	var num_medium_escort_missions = randi()%3
	var num_small_fleet_escort_missions = randi()%2
	var index = missions_available.size()
	var num_missions = num_basic_escort_missions+num_medium_escort_missions+num_small_fleet_escort_missions
	missions_available.resize(missions_available.size()+num_missions)
	for i in range(index,index+num_basic_escort_missions):
		var data = basic_escort_mission_init()
		missions_available[i] = data
	index += num_basic_escort_missions
	for i in range(index,index+num_medium_escort_missions):
		var data = medium_escort_mission_init()
		missions_available[i] = data
	index += num_medium_escort_missions
	for i in range(index,index+num_small_fleet_escort_missions):
		var data = small_fleet_escort_mission_init()
		missions_available[i] = data
	index += num_small_fleet_escort_missions
	

func create_random_transport_missions():
	var num_basic_transport_missions = randi()%4+3
	var num_large_transport_missions = randi()%3+2
	var num_basic_rush_missions = randi()%3+2
	var index = missions_available.size()
	var num_missions = num_basic_transport_missions+num_large_transport_missions+num_basic_rush_missions
	missions_available.resize(missions_available.size()+num_missions)
	for i in range(index,index+num_basic_transport_missions):
		var data = basic_transport_mission_init()
		missions_available[i] = data
	index += num_basic_transport_missions
	for i in range(index,index+num_large_transport_missions):
		var data = large_transport_mission_init()
		missions_available[i] = data
	index += num_large_transport_missions
	for i in range(index,index+num_basic_rush_missions):
		var data = basic_rush_mission_init()
		missions_available[i] = data
	index += num_basic_rush_missions
	

func create_random_passenger_missions():
	var num_basic_passenger_missions = randi()%4+1
	var num_cargo_passenger_missions = randi()%3
	var num_rush_passenger_missions = randi()%3
	var num_missions = num_basic_passenger_missions+num_cargo_passenger_missions+num_rush_passenger_missions
	var index = missions_available.size()
	missions_available.resize(missions_available.size()+num_missions)
	for i in range(index,index+num_basic_passenger_missions):
		var data = basic_passenger_mission_init()
		missions_available[i] = data
	index += num_basic_passenger_missions
	for i in range(index,index+num_cargo_passenger_missions):
		var data = cargo_passenger_mission_init()
		missions_available[i] = data
	index += num_cargo_passenger_missions
	for i in range(index,index+num_rush_passenger_missions):
		var data = rush_passenger_mission_init()
		missions_available[i] = data
	index += num_rush_passenger_missions
	

func landed(station):
	for i in range(missions.size()-1,-1,-1):
		var data = missions[i]
		if (data.has("on_land")):
			call(data["on_land"],station,i)
	for i in range(missions.size()-1,-1,-1):
		if (missions[i]==null):
			missions.remove(i)

func take_off(station):
	for i in range(missions.size()-1,-1,-1):
		var data = missions[i]
		if (data.has("on_take_off")):
			call(data["on_take_off"],station,i)
	for i in range(missions.size()-1,-1,-1):
		if (missions[i]==null):
			missions.remove(i)

func _ready():
	var script = GDScript.new()
	var code = get_script().get_source_code()
	
	var dir = Directory.new()
	var error = dir.open("res://scripts/missions")
	if (error==OK):
		var file_name
		dir.list_dir_begin()
		file_name = dir.get_next()
		while (file_name!=""):
			if (!dir.current_is_dir()):
				var file = File.new()
				var error = file.open("res://scripts/missions/"+file_name,File.READ)
				if (error==OK):
					code += file.get_as_text()
			file_name = dir.get_next()
		dir.list_dir_end()
	
	script.set_source_code(code)
	script.reload()
	set_script(script)
