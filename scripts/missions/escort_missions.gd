
const small_trader_ships = [
[["fr2",1],["chg",1],["chg",1],["mis",4],["rbs",1],["shs",1],["ebs",1],["ebs",1],["bos",1]],
[["fr2",1],["paa",1],["paa",1],["mis",4],["rbs",1],["ces",1],["egs",1],["egs",1],["ass",1]],
[["tr1",1],["plt",1],["drt",6],["drt",6],["rbs",1],["ces",1],["ebs",1],["ebs",1],["aps",1],["sts",1]],
[["tr1",1],["cgt",1],["mis",4],["mis",4],["rbs",1],["ces",1],["ebs",1],["ebs",1],["ass",1],["bos",1]]]
const medium_trader_ships = [
[["fr1",1],["chg",1],["chg",1],["plt",1],["cgt",1],["plt",1],["mis",4],["rbs",1],["rbs",1],["rbs",1],["shm",1],["cem",1],["cem",1],["ebm",1],["ebm",1],["ebm",1],["apm",1],["apm",1]],
[["fr1",1],["paa",1],["paa",1],["cgt",1],["cgt",1],["mlt",1],["mis",4],["rbs",1],["rbs",1],["rbs",1],["cem",1],["cem",1],["cem",1],["egm",1],["egm",1],["egm",1],["asm",1],["asm",1]],
[["fr1",1],["elb",1],["elb",1],["plt",1],["plt",1],["mlt",1],["drt",4],["rbs",1],["rbs",1],["rbs",1],["bam",1],["cem",1],["cem",1],["ebm",1],["ebm",1],["ebm",1],["stm",1],["asm",1]]]

# small escort mission
const str_basic_escort_title = [
"ESCORT_A_SMALL_FREIGHTER_SAFELY_TO_<destination>",
"A_SMALL_FREIGHTER_IS_LOOKING_FOR_AN_ESCORT_TO_GET_SAFELY_TO_<destination>"]
const str_basic_escort_accepted = [
"THE_CAPTAIN_OF_THE_FREIGHTER_IS_READY_TO_TAKE_OFF_ESCORT_HIM_TO_<destination>",
"ESCORT_THE_FREIGHTER_SAFELY_TO_<destination>"]
const  str_basic_escort_finished = [
"AFTER_YOU_LANDED_ON_<destination>_THE_CAPTAIN_OF_THE_FREIGHTER_PAYS_YOU_<payment>_AND_THANKS_YOU_FOR_YOUR_ESCORT_SERVICE",
"THE_CAPTAIN_OF_THE_FREIGHTER_THANKS_YOU_FOR_ESCORTING_HIM_SAFELY_TO_<destination>_AND_HANDS_YOU_<payment>"]

func basic_escort_mission_init():
	var to = Player.station
	while(Stations.stations_current_pos[to].distance_squared_to(Stations.stations_current_pos[Player.station])<100000000):
		to = Stations.stations[randi()%(Stations.stations.size())]
	var ship = small_trader_ships[randi()%(small_trader_ships.size())]
	var reward = floor((100000+Stations.stations_pos[Player.station].distance_squared_to(Stations.stations_pos[to])/1e8)*rand_range(0.008,0.010))
	var title = tr(str_basic_escort_title[randi()%(str_basic_escort_title.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_basic_escort_accepted[randi()%(str_basic_escort_accepted.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var text_finished = tr(str_basic_escort_finished[randi()%(str_basic_escort_finished.size())]).replace("<destination>",tr(Stations.stations_name[to])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"num_weapons":2}
	var data = {
	"requirements":requirements,"equipment":[ship],"ships":[],
	"destination":to,"reward":reward,"on_accept":"basic_escort_mission_accept",
	"on_take_off":"basic_escort_mission_on_take_off",
	"on_land":"basic_escort_mission_on_land","on_abord":"basic_escort_mission_done",
	"title":title,"description":desc,"text_finished":text_finished,"text_accepted":text_accepted
	}
	return data

func basic_escort_mission_accept(ID):
	var data = missions_available[ID]
	var window = HUD.get_node("Station/MissionWindow").duplicate()
	window.set_title(tr("MISSION_ACCEPTED"))
	window.get_node("Text").set_text(data["text_accepted"])
	HUD.get_node("Station").add_child(window)
	window.popup()
	missions.push_back(data)
	missions_available.remove(ID)

func basic_escort_mission_on_take_off(station,ID):
	var data = missions[ID]
	
	data["ships"].clear()
	for ship in data["equipment"]:
		var dock = get_node("/root/Main/"+station).request_landing_position()
		if (dock==-1):
			dock = Player.dock
		var name = "Civil Trade Ship "+str(randi()%1000)
		var crew = Equipment.outfits[ship[0][Equipment.TYPE]]["bunks"]
		var inventory = [[Economy.commodities[randi()%(Economy.commodities.size())],Equipment.outfits[ship[0][Equipment.TYPE]]["cargo_space"]]]
		var si = Stations.take_off(station,dock,ship[0][Equipment.TYPE],ship,inventory,Ships.script_escort_freighter,Factions.PLAYER,name,crew)
		si.connect("destroyed",self,"basic_escort_mission_done",[ID])
		si.station = data["destination"]
		si.leader = get_node("/root/Main/Player")
		data["ships"].push_back(si)

func basic_escort_mission_done(ID):
	var data = missions[ID]
	missions.erase(data)

func basic_escort_mission_on_land(station,ID):
	var data = missions[ID]
	if (station==data["destination"]):
		var window = HUD.get_node("Station/MissionWindow").duplicate()
		window.set_title(tr("MISSION_SUCCESSFUL"))
		window.get_node("Text").set_text(data["text_finished"])
		HUD.get_node("Station").add_child(window)
		window.popup()
		Player.credits += data["reward"]
		basic_escort_mission_done(ID)


# medium escort mission
const str_medium_escort_title = [
"ESCORT_A_FREIGHTER_SAFELY_TO_<destination>",
"A_FREIGHTER_IS_LOOKING_FOR_AN_ESCORT_TO_GET_SAFELY_TO_<destination>"]

func medium_escort_mission_init():
	var to = Player.station
	while(Stations.stations_current_pos[to].distance_squared_to(Stations.stations_current_pos[Player.station])<100000000):
		to = Stations.stations[randi()%(Stations.stations.size())]
	var ship = medium_trader_ships[randi()%(medium_trader_ships.size())]
	var dist = Stations.stations_pos[Player.station].distance_to(Stations.stations_pos[to])
	var time = dist/3000.0*rand_range(0.8,1.2)
	var reward = floor((100000+dist*dist/1e8)*rand_range(0.009,0.011))
	var title = tr(str_medium_escort_title[randi()%(str_medium_escort_title.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_basic_escort_accepted[randi()%(str_basic_escort_accepted.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var text_finished = tr(str_basic_escort_finished[randi()%(str_basic_escort_finished.size())]).replace("<destination>",tr(Stations.stations_name[to])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"num_weapons":2}
	var data = {
	"requirements":requirements,"equipment":[ship],"ships":[],"time":time,
	"destination":to,"reward":reward,"on_accept":"basic_escort_mission_accept",
	"on_take_off":"medium_escort_mission_on_take_off",
	"on_land":"basic_escort_mission_on_land","on_abord":"basic_escort_mission_done",
	"title":title,"description":desc,"text_finished":text_finished,"text_accepted":text_accepted
	}
	return data

func medium_escort_mission_on_take_off(station,ID):
	var data = missions[ID]
	var timer = Timer.new()
	
	timer.set_wait_time(data["time"])
	timer.connect("timeout",self,"medium_escort_spawn_pirates",[ID,timer])
	timer.set_one_shot(true)
	add_child(timer)
	timer.start()
	
	data["ships"].clear()
	for ship in data["equipment"]:
		var dock = get_node("/root/Main/"+station).request_landing_position()
		if (dock==-1):
			dock = Player.dock
		var name = "Civil Trade Ship "+str(randi()%1000)
		var crew = Equipment.outfits[ship[0][Equipment.TYPE]]["bunks"]
		var inventory = [[Economy.commodities[randi()%(Economy.commodities.size())],Equipment.outfits[ship[0][Equipment.TYPE]]["cargo_space"]]]
		var si = Stations.take_off(station,dock,ship[0][Equipment.TYPE],ship,inventory,Ships.script_escort_freighter,Factions.PLAYER,name,crew)
		si.connect("destroyed",self,"basic_escort_mission_done",[ID])
		si.station = data["destination"]
		si.leader = get_node("/root/Main/Player")
		data["ships"].push_back(si)

func medium_escort_spawn_pirates(ID,timer):
	var data = missions[ID]
	var num = randi()%3+2
	
	get_node("/root/Main").num_pirates += num
	for i in range(num):
		var target = data["ships"][randi()%(data["ships"].size())]
		var pos = get_node("/root/Main/Player").get_global_pos()+Vector2(rand_range(25000,50000),0).rotated(2*PI*randf())
		var p = Ships.create_rnd_pirate(pos,target.get_lv()+(target.get_global_pos()-pos).normalized()*rand_range(500,3000))
		p.target = target
		p.connect("destroyed",get_node("/root/Main"),"pirate_destroyed")
	
	timer.queue_free()


# escort small fleet
const str_small_fleet_escort_title = [
"ESCORT_A_SMALL_GROUP_OF_<ammount>_FREIGHTERS_SAFELY_TO_<destination>",
"A_SMALL_GROUP_OF_<ammount>_FREIGHTERS_IS_LOOKING_FOR_AN_ESCORT_TO_GET_SAFELY_TO_<destination>"]
const str_small_fleet_escort_accepted = [
"THE_FREIGHTERS_ARE_READY_TO_TAKE_OFF_ESCORT_THEM_TO_<destination>",
"ESCORT_THE_FREIGHTERS_SAFELY_TO_<destination>"]
const  str_small_fleet_escort_finished = [
"AFTER_YOU_LANDED_ON_<destination>_THE_CAPTAIN_OF_ONE_OF_THE_FREIGHTERS_PAYS_YOU_<payment>_AND_THANKS_YOU_FOR_YOUR_ESCORT_SERVICE",
"THE_CAPTAIN_OF_ONE_OF_THE_FREIGHTERS_THANKS_YOU_FOR_ESCORTING_THEM_SAFELY_TO_<destination>_AND_HANDS_YOU_<payment>"]

func small_fleet_escort_mission_init():
	var to = Player.station
	while(Stations.stations_current_pos[to].distance_squared_to(Stations.stations_current_pos[Player.station])<100000000):
		to = Stations.stations[randi()%(Stations.stations.size())]
	var num_ships = randi()%2+2
	var ships = []
	ships.resize(num_ships)
	for i in range(num_ships):
		ships[i] = small_trader_ships[randi()%(small_trader_ships.size())]
	var dist = Stations.stations_pos[Player.station].distance_to(Stations.stations_pos[to])
	var time = dist/3000.0*rand_range(0.8,1.2)
	var reward = floor((num_ships+2)*(100000+dist*dist/1e8)/3.0*rand_range(0.009,0.011))
	var title = tr(str_small_fleet_escort_title[randi()%(str_small_fleet_escort_title.size())]).replace("<destination>",tr(Stations.stations_name[to])).replace("<ammount>",str(num_ships))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_small_fleet_escort_accepted[randi()%(str_small_fleet_escort_accepted.size())]).replace("<destination>",tr(Stations.stations_name[to]))
	var text_finished = tr(str_small_fleet_escort_finished[randi()%(str_small_fleet_escort_finished.size())]).replace("<destination>",tr(Stations.stations_name[to])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"num_weapons":2}
	var data = {
	"requirements":requirements,"equipment":ships,"ships":[],"time":time,
	"destination":to,"reward":reward,"on_accept":"basic_escort_mission_accept",
	"on_take_off":"medium_escort_mission_on_take_off",
	"on_land":"basic_escort_mission_on_land","on_abord":"basic_escort_mission_done",
	"title":title,"description":desc,"text_finished":text_finished,"text_accepted":text_accepted
	}
	return data
