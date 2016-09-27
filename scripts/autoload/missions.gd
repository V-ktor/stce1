
extends Node

var missions = []
var missions_available = []
var missions_finished = []


func create_random_missions():
	missions_available.clear()
	create_random_transport_missions()

func create_random_transport_missions():
	var num_missions = randi()%6+8
	missions_available.resize(num_missions)
	for i in range(num_missions):
		var data = test_cargo_mission_init()
		missions_available[i] = data

func test_cargo_mission_init():
	var cargo_type = "test"
	var cargo_space = randi()%21+2
	var to = Stations.stations[randi()%(Stations.stations.size())]
	var reward = floor((cargo_space+10)*(100+Stations.stations_pos[Player.station].distance_squared_to(Stations.stations_pos[to])/1e8)*rand_range(0.009,0.011))
	var name = tr("TRANSPORT").capitalize()+" "+str(cargo_space)+Equipment.units["cargo_space"]+" "+tr("OF")+" "+tr(Equipment.outfits[cargo_type]["name"])+" "+tr("TO")+" "+tr(Stations.stations_name[to])+"."
	var desc = tr("TRANSPORT").capitalize()+" "+str(cargo_space)+Equipment.units["cargo_space"]+" "+tr("OF")+" "+tr(Equipment.outfits[cargo_type]["name"])+" "+tr("TO")+" "+tr(Stations.stations_name[to])+"("+to+").\n"+tr("YOU_WILL_BE_PAID")+" "+str(reward)+Equipment.units["price"]+"."
	var requirements = {"free_cargo":cargo_space}
	var data = {"requirements":requirements,"cargo_type":cargo_type,"cargo_space":cargo_space,"destination":to,"reward":reward,"on_accept":"test_cargo_mission_accept","on_land":"test_cargo_mission_on_land","on_abord":"test_cargo_mission_done","name":name,"description":desc}
	return data

func test_cargo_mission_accept(ID):
	var data = missions_available[ID]
	Equipment.add_item([data["cargo_type"],data["cargo_space"]])
	missions.push_back(data)
	missions_available.remove(ID)

func test_cargo_mission_done(ID):
	var data = missions[ID]
	Equipment.remove_item([data["cargo_type"],data["cargo_space"]])
	missions.erase(data)

func test_cargo_mission_on_land(station,ID):
	var data = missions[ID]
	if (station==data["destination"]):
		Player.credits += data["reward"]
		test_cargo_mission_done(ID)



func landed(station):
	for i in range(missions.size()-1,-1,-1):
		var data = missions[i]
		if (data.has("on_land")):
			call(data["on_land"],station,i)

