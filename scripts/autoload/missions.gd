
extends Node

var missions = []
var missions_available = []
var missions_finished = []


func test_cargo_mission_init():
	var cargo_type = "test"
	var cargo_space = randi()%21+2
	var to = Stations.stations[randi()%(Stations.stations.size())]
	var reward = floor((cargo_space+10)*(100+Stations.stations_pos[Player.station].distance_squared_to(Stations.stations_pos[to])/1e8)*rand_range(0.009,0.011))
	var requirements = {"free_cargo":cargo_space}
	var data = {"requirements":requirements,"cargo_type":cargo_type,"cargo_space":cargo_space,"destination":to,"reward":reward,"on_land":"test_cargo_mission_on_land"}
	return data

func test_cargo_mission_accept(ID):
	var data = missions_available[ID]
	Equipment.add_item([data["cargo_type"],data["cargo_space"]])
	missions.push_back(data)
	missions_available.remove(ID)

func test_cargo_mission_done(data):
	Equipment.remove_item([data["cargo_type"],data["cargo_space"]])
	missions.erase(data)

func test_cargo_mission_on_land(station,data):
	if (station==data["destination"]):
		Player.credits += data["reward"]
		test_cargo_mission_done(data)



func landed(station):
	for m in missions:
		if (m.has("on_land")):
			call(m["on_land"],station,m)

