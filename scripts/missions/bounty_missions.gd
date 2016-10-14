
const pirate_ships = [
[["p01",1],["chg",1],["rbs",1],["ebs",1],["ebs",1],["ass",1]],
[["p01",1],["paa",1],["rbs",1],["ebs",1],["ebs",1],["bos",1]],
[["p02",1],["chg",1],["drt",6],["rbs",1],["ebm",1],["aps",1],["aps",1]],
[["p02",1],["las",1],["mis",2],["rbs",1],["ebm",1],["bos",1],["ass",1]],
[["p03",1],["chg",1],["chg",1],["mis",1],["drt",2],["rbs",1],["ces",1],["ebs",1],["ebs",1],["ass",1],["bos",1]]
]


# dead or alive bounty mission
const str_bounty_title = [
"DESTROY_THE_PIRATE_VESSEL_<name>_NEAR_<destination>","AUTHORITIES_OF_<destination>_WANT_<name>_DEAD_OR_ALIVE"
]
const str_bounty_accepted = [
"THE_PIRATE_KNOWN_AS_<name>_WAS_SPOTTED_NEAR_<destination>_KILL_OR_CAPTURE_<name>_AND_RETURN_TO_<destination>",
"THE_PIRATE_VESSEL_<name>_HAS_BEEN_ATTACKING_MERCHANTS_NEAR_<destination>_DESTROY_IT_OR_CAPTURE_THEIR_LEADER_AND_RETURN_TO_<destination>",
]
const str_bounty_killed = [
"AFTER_AN_OFFICER_VERIFIED_THAT_YOU_KILLED_<name>_HE_HANDS_YOU_<reward>"
]
const str_bounty_captured = [
"YOU_TAKE_THE_CAPTURED_PIRATE_TO_<destination>_WHERE_AN_OFFICER_TAKES_<name>_INTO_CUSTODY_AND_PAYS_YOU_<reward>"
]

func basic_bounty_mission_init():
	var pirate = pirate_ships[randi()%(pirate_ships.size())]
	var name = Ships.pirate_name()
	var dest = Player.station
	var pos = Stations.stations_current_pos[dest]+Vector2(0,rand_range(50000,100000)).rotated(2*PI*randf())
	var reward = round(350*rand_range(0.9,1.1))
	var title = tr(str_bounty_title[randi()%(str_bounty_title.size())]).replace("<name>",name).replace("<destination>",tr(Stations.stations_name[dest]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_bounty_accepted[randi()%(str_bounty_accepted.size())]).replace("<name>",name).replace("<destination>",tr(Stations.stations_name[dest]))
	var text_killed = tr(str_bounty_killed[randi()%(str_bounty_killed.size())]).replace("<name>",name).replace("<destination>",tr(Stations.stations_name[dest])).replace("<payment>",str(reward)+Equipment.units["price"])
	var text_captured = tr(str_bounty_captured[randi()%(str_bounty_captured.size())]).replace("<name>",name).replace("<destination>",tr(Stations.stations_name[dest])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"num_weapons":1}
	var data = {
	"requirements":requirements,"destination":dest,"reward":reward,"ships":[],"name":name,
	"equipment":[pirate],"position_x":pos.x,"position_y":pos.y,"num_ships":1,"killed":false,"captured":false,
	"alive":false,"on_accept":"basic_bounty_mission_accept","on_take_off":"basic_bount_misison_on_take_off",
	"on_land":"basic_bounty_mission_on_land","on_abord":"basic_bounty_mission_done",
	"title":title,"description":desc,"text_accepted":text_accepted,"text_killed":text_killed,"text_captured":text_captured
	}
	return data

func basic_bounty_mission_accept(ID):
	var data = missions_available[ID]
	var window = HUD.get_node("Station/MissionWindow").duplicate()
	window.set_title(tr("MISSION_ACCEPTED"))
	window.get_node("Text").set_text(data["text_accepted"])
	HUD.get_node("Station").add_child(window)
	window.popup()
	missions.push_back(data)
	missions_available.remove(ID)

func basic_bounty_mission_done(ID):
	var data = missions[ID]
	missions[ID] = null

func basic_bounty_mission_on_land(station,ID):
	var data = missions[ID]
	if (station==data["destination"]):
		var window
		if (data["killed"]):
			window = HUD.get_node("Station/MissionWindow").duplicate()
			window.set_title(tr("MISSION_SUCCESSFUL"))
			window.get_node("Text").set_text(data["text_killed"])
		elif (data["captured"]):
			window = HUD.get_node("Station/MissionWindow").duplicate()
			window.set_title(tr("MISSION_SUCCESSFUL"))
			window.get_node("Text").set_text(data["text_captured"])
		else:
			return
		HUD.get_node("Station").add_child(window)
		window.popup()
		Player.credits += data["reward"]
		basic_bounty_mission_done(ID)

func basic_bount_misison_on_take_off(station,ID):
	var data = missions[ID]
	
	data["ships"].clear()
	for ship in data["equipment"]:
		var pos = Vector2(data["position_x"],data["position_y"])+Vector2(0,rand_range(200,2000)).rotated(2*PI*randf())
		var crew = rand_range(max(Equipment.outfits[ship[0][Equipment.TYPE]]["min_crew"],2),Equipment.outfits[ship[0][Equipment.TYPE]]["bunks"]+0.5)
		var si = Ships.create_ship(ship[0][Equipment.TYPE],ship,Ships.inv_rnd_pirate(ship[0][Equipment.TYPE]),Ships.script_pirate,Factions.PIRATES,pos,2*PI*randf(),Vector2(rand_range(-500,500),rand_range(-500,500)),data["name"],crew)
		si.credits = Ships.pirate_credits[ship[0][Equipment.TYPE]]*rand_range(0.8,1.2)*rand_range(0.9,1.1)
		si.target = get_node("/root/Main/Player")
		si.connect("destroyed",self,"basic_bounty_mission_pirate_destroyed",[ID])
		si.connect("captured",self,"basic_bounty_mission_pirate_captured",[ID])
		si.station = data["destination"]
		si.stealth -= 100000
		data["ships"].push_back(si)

func basic_bounty_mission_pirate_destroyed(ID):
	var data = missions[ID]
	data["num_ships"] -= 1
	if (data["num_ships"]<1):
		data["killed"] = true
	if (data["alive"]):
		basic_bounty_mission_done(ID)

func basic_bounty_mission_pirate_captured(ID):
	var data = missions[ID]
	data["num_ships"] -= 1
	if (data["num_ships"]<1):
		data["captured"] = true
	HUD.get_node("Boarding").text_log.add_text(tr("YOU_HAVE_CAPTURED_THE_CAPTAIN_OF")+" "+HUD.get_node("Boarding").enemy.name+".\n")


# alive bounty mission
const str_alive_bounty_title = [
"CAPTURE_<name>_NEAR_<destination>_ALIVE","AUTHORITIES_OF_<destination>_WANT_<name>_ALIVE"
]

func alive_bounty_mission_init():
	var pirate = pirate_ships[randi()%(pirate_ships.size())]
	var name = Ships.pirate_name()
	var dest = Player.station
	var pos = Stations.stations_current_pos[dest]+Vector2(0,rand_range(50000,100000)).rotated(2*PI*randf())
	var reward = round(500*rand_range(0.9,1.1))
	var title = tr(str_alive_bounty_title[randi()%(str_alive_bounty_title.size())]).replace("<name>",name).replace("<destination>",tr(Stations.stations_name[dest]))
	var desc = title+"\n"+tr("PAYMENT_IS")+" "+str(reward)+Equipment.units["price"]+"."
	var text_accepted = tr(str_bounty_accepted[randi()%(str_bounty_accepted.size())]).replace("<name>",name).replace("<destination>",tr(Stations.stations_name[dest]))
	var text_captured = tr(str_bounty_captured[randi()%(str_bounty_captured.size())]).replace("<name>",name).replace("<destination>",tr(Stations.stations_name[dest])).replace("<payment>",str(reward)+Equipment.units["price"])
	var requirements = {"num_weapons":1}
	var data = {
	"requirements":requirements,"destination":dest,"reward":reward,"ships":[],"name":name,
	"equipment":[pirate],"position_x":pos.x,"position_y":pos.y,"num_ships":1,"killed":false,"captured":false,
	"alive":true,"on_accept":"basic_bounty_mission_accept","on_take_off":"basic_bount_misison_on_take_off",
	"on_land":"basic_bounty_mission_on_land","on_abord":"basic_bounty_mission_done",
	"title":title,"description":desc,"text_accepted":text_accepted,"text_captured":text_captured
	}
	return data
