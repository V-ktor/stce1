
const basic_cargo = [
"water","apples","aluminium","copper","titanium","petroleum","antibiotics",
"medical_supplies","semiconductors","microchips","plutonium","thorium","waste"
]


# basic cargo missions
const str_transport_title = [
"TRANSPORT_<ammount>_OF_<type>_TO_<destination>","DELIVER_<ammount>_OF_<type>_TO_<destination>",
"<destination>_NEEDS_A_DELIVERY_OF_<ammount>_OF_<type>"
]
const str_transport_accepted_first = [
"THE_CONTAINERS_OF_<type>_ARE_LOADED_ON_YOUR_SHIP",
"THE_CRATES_OF_<type>_ARE_CARRIED_OVER_TO_YOUR_SHIP"
]
const str_transport_accepted_last = [
"TRANSPORT_THEM_TO_<destination>","FLY_TO_<destination>"
]
const str_transport_finished = [
"YOU_DROP_OFF_YOUR_CARGO_OF_<type>_AND_COLLECT_YOUR_PAYMENT_OF_<payment>",
"THE_CONTAINERS_OF_<type>_ARE_UNLOADED_BY_ROBOTIC_DRONES_AND_THE_OVERSEER_HANDS_YOU_OVER_A_CREDIT_CHIP_WORTH_<payment>"
]

func basic_transport_mission_init():
	var cargo_type = basic_cargo[randi()%(basic_cargo.size())]
	var cargo_space = randi()%36+5
	var to = Player.station
	while(to==Player.station):
		to = Stations.stations[randi()%(Stations.stations.size())]
	var reward = floor((cargo_space+10)*(100+Stations.stations_pos[Player.station].distance_squared_to(Stations.stations_pos[to])/1e8)*rand_range(0.009,0.011))
	var title = tr(str_transport_title[randi()%(str_transport_title.size())]).replace("<ammount>",str(cargo_space)+Equipment.units["cargo_space"]).replace("<type>",tr(Equipment.outfits[cargo_type]["name"])).replace("<destination>",tr(Stations.stations_name[to]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_transport_accepted_first[randi()%(str_transport_accepted_first.size())]).replace("<type>",tr(Equipment.outfits[cargo_type]["name"]))+"\n"+tr(str_transport_accepted_last[randi()%(str_transport_accepted_last.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var text_finished = tr(str_transport_finished[randi()%(str_transport_finished.size())]).replace("<type>",tr(Equipment.outfits[cargo_type]["name"])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"free_cargo":cargo_space}
	var data = {
	"requirements":requirements,"cargo_type":cargo_type,"cargo_space":cargo_space,
	"destination":to,"reward":reward,"on_accept":"basic_transport_mission_accept",
	"on_land":"basic_transport_mission_on_land","on_abord":"basic_transport_mission_done",
	"title":title,"description":desc,"text_finished":text_finished,"text_accepted":text_accepted
	}
	return data

func basic_transport_mission_accept(ID):
	var data = missions_available[ID]
	var window = HUD.get_node("Station/MissionWindow").duplicate()
	window.set_title(tr("MISSION_ACCEPTED"))
	window.get_node("Text").set_text(data["text_accepted"])
	HUD.get_node("Station").add_child(window)
	window.popup()
	Equipment.add_item([data["cargo_type"],data["cargo_space"]])
	missions.push_back(data)
	missions_available.remove(ID)
	Player.free_cargo_space -= data["cargo_space"]

func basic_transport_mission_done(ID):
	var data = missions[ID]
	Equipment.remove_item([data["cargo_type"],data["cargo_space"]])
	missions.erase(data)
	Player.free_cargo_space += data["cargo_space"]

func basic_transport_mission_on_land(station,ID):
	var data = missions[ID]
	if (station==data["destination"]):
		var window = HUD.get_node("Station/MissionWindow").duplicate()
		window.set_title(tr("MISSION_SUCCESSFUL"))
		window.get_node("Text").set_text(data["text_finished"])
		HUD.get_node("Station").add_child(window)
		window.popup()
		Player.credits += data["reward"]
		basic_transport_mission_done(ID)


func large_transport_mission_init():
	var cargo_type = basic_cargo[randi()%(basic_cargo.size())]
	var cargo_space = randi()%86+15
	var to = Player.station
	while(to==Player.station):
		to = Stations.stations[randi()%(Stations.stations.size())]
	var reward = floor((cargo_space+20)*(250+Stations.stations_pos[Player.station].distance_squared_to(Stations.stations_pos[to])/1e8)*rand_range(0.009,0.011))
	var title = tr(str_transport_title[randi()%(str_transport_title.size())]).replace("<ammount>",str(cargo_space)+Equipment.units["cargo_space"]).replace("<type>",tr(Equipment.outfits[cargo_type]["name"])).replace("<destination>",tr(Stations.stations_name[to]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_transport_accepted_first[randi()%(str_transport_accepted_first.size())]).replace("<type>",tr(Equipment.outfits[cargo_type]["name"]))+"\n"+tr(str_transport_accepted_last[randi()%(str_transport_accepted_last.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var text_finished = tr(str_transport_finished[randi()%(str_transport_finished.size())]).replace("<type>",tr(Equipment.outfits[cargo_type]["name"])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"free_cargo":cargo_space}
	var data = {
	"requirements":requirements,"cargo_type":cargo_type,"cargo_space":cargo_space,
	"destination":to,"reward":reward,"on_accept":"basic_transport_mission_accept",
	"on_land":"basic_transport_mission_on_land","on_abord":"basic_transport_mission_done",
	"title":title,"description":desc,"text_finished":text_finished,"text_accepted":text_accepted
	}
	return data


# passenger transport missions
const passenger_cargo = ["bags","crates"]
const str_passenger_title = [
"BRING_<ammount>_PASSENGERS_TO_<destination>",
"<ammount>_PASSENGERS_NEED_A_LIFT_TO_<destination>"
]
const str_passenger_accepted_first = [
"YOU_OPEN_THE_AIRLOCK_AND_LET_A_GROUP_OF_<ammount>_PASSENGERS_ENTER_YOUR SHIP"
]
const str_passenger_accepted_last = [
"FLY_THEM_TO_<destination>","DROP_THEM_OFF_AT_<destination>"
]
const str_passenger_finished = [
"YOU_WISH_YOUR_PASSENGERS_BEST_OF_LUCK_ON_<destination>_AND_COLLECT_YOUR_PAYMENT_OF_<payment>",
"AFTER_YOU_LANDED_ON_<destination>_THE_PASSENGERS_LEAVE_YOUR_SHIP_AND_YOU_RECEIVE_<payment>"
]
const str_passenger_cargo_title = [
"BRING_<passengers>_PASSENGERS_AND_<ammount>_OF_<type>_TO_<destination>",
"<passengers>_PASSENGERS_WITH_<ammount>_OF_<type>_WANT_TO_MOVE_TO_<destination>"
]

func basic_passenger_mission_init():
	var passengers = randi()%4+1
	var to = Player.station
	while(to==Player.station):
		to = Stations.stations[randi()%(Stations.stations.size())]
	var reward = floor((passengers+1)*(100+Stations.stations_pos[Player.station].distance_squared_to(Stations.stations_pos[to])/1e8)*rand_range(0.09,0.11))
	var title = tr(str_passenger_title[randi()%(str_passenger_title.size())]).replace("<ammount>",str(passengers)).replace("<destination>",tr(Stations.stations_name[to]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_passenger_accepted_first[randi()%(str_passenger_accepted_first.size())]).replace("<ammount>",str(passengers))+"\n"+tr(str_passenger_accepted_last[randi()%(str_passenger_accepted_last.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var text_finished = tr(str_passenger_finished[randi()%(str_passenger_finished.size())]).replace("<destination>",tr(Stations.stations_name[to])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"free_bunks":passengers}
	var data = {
	"requirements":requirements,"passengers":passengers,"destination":to,"reward":reward,
	"on_accept":"basic_passenger_mission_accept","on_land":"basic_passenger_mission_on_land",
	"on_abord":"basic_passenger_mission_done",
	"title":title,"description":desc,"text_finished":text_finished,"text_accepted":text_accepted
	}
	return data

func basic_passenger_mission_accept(ID):
	var data = missions_available[ID]
	var window = HUD.get_node("Station/MissionWindow").duplicate()
	window.set_title(tr("MISSION_ACCEPTED"))
	window.get_node("Text").set_text(data["text_accepted"])
	HUD.get_node("Station").add_child(window)
	window.popup()
	Player.passengers += data["passengers"]
	missions.push_back(data)
	missions_available.remove(ID)
	Player.free_bunks -= data["passengers"]

func basic_passenger_mission_done(ID):
	var data = missions[ID]
	Player.passengers -= data["passengers"]
	missions.erase(data)
	Player.free_bunks += data["passengers"]

func basic_passenger_mission_on_land(station,ID):
	var data = missions[ID]
	if (station==data["destination"]):
		var window = HUD.get_node("Station/MissionWindow").duplicate()
		window.set_title(tr("MISSION_SUCCESSFUL"))
		window.get_node("Text").set_text(data["text_finished"])
		HUD.get_node("Station").add_child(window)
		window.popup()
		Player.credits += data["reward"]
		basic_passenger_mission_done(ID)


func cargo_passenger_mission_init():
	var passengers = randi()%3+1
	var cargo_type = passenger_cargo[randi()%(passenger_cargo.size())]
	var cargo_space = randi()%5+1
	var to = Player.station
	while(to==Player.station):
		to = Stations.stations[randi()%(Stations.stations.size())]
	var reward = floor((passengers+0.2*cargo_space+2)*(100+Stations.stations_pos[Player.station].distance_squared_to(Stations.stations_pos[to])/1e8)*rand_range(0.09,0.11))
	var title = tr(str_passenger_cargo_title[randi()%(str_passenger_cargo_title.size())]).replace("<passengers>",str(passengers)).replace("<ammount>",str(cargo_space)+Equipment.units["cargo_space"]).replace("<type>",tr(Equipment.outfits[cargo_type]["name"])).replace("<destination>",tr(Stations.stations_name[to]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_passenger_accepted_first[randi()%(str_passenger_accepted_first.size())]).replace("<ammount>",str(passengers))+"\n"+tr(str_passenger_accepted_last[randi()%(str_passenger_accepted_last.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var text_finished = tr(str_passenger_finished[randi()%(str_passenger_finished.size())]).replace("<destination>",tr(Stations.stations_name[to])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"free_cargo":cargo_space,"free_bunks":passengers}
	var data = {
	"requirements":requirements,"passengers":passengers,"cargo_type":cargo_type,"cargo_space":cargo_space,
	"destination":to,"reward":reward,
	"on_accept":"cargo_passenger_mission_accept","on_land":"cargo_passenger_mission_on_land",
	"on_abord":"cargo_passenger_mission_done",
	"title":title,"description":desc,"text_finished":text_finished,"text_accepted":text_accepted
	}
	return data

func cargo_passenger_mission_accept(ID):
	var data = missions_available[ID]
	var window = HUD.get_node("Station/MissionWindow").duplicate()
	window.set_title(tr("MISSION_ACCEPTED"))
	window.get_node("Text").set_text(data["text_accepted"])
	HUD.get_node("Station").add_child(window)
	window.popup()
	Equipment.add_item([data["cargo_type"],data["cargo_space"]])
	Player.passengers += data["passengers"]
	missions.push_back(data)
	missions_available.remove(ID)
	Player.free_bunks -= data["passengers"]
	Player.free_cargo_space -= data["cargo_space"]

func cargo_passenger_mission_done(ID):
	var data = missions[ID]
	Equipment.remove_item([data["cargo_type"],data["cargo_space"]])
	Player.passengers -= data["passengers"]
	missions.erase(data)
	Player.free_bunks += data["passengers"]
	Player.free_cargo_space += data["cargo_space"]

func cargo_passenger_mission_on_land(station,ID):
	var data = missions[ID]
	if (station==data["destination"]):
		var window = HUD.get_node("Station/MissionWindow").duplicate()
		window.set_title(tr("MISSION_SUCCESSFUL"))
		window.get_node("Text").set_text(data["text_finished"])
		HUD.get_node("Station").add_child(window)
		window.popup()
		Player.credits += data["reward"]
		cargo_passenger_mission_done(ID)
