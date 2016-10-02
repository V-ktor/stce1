
extends Node
# outfits and ships

# constants #

const TYPE = 0
const AMMOUNT = 1
const INVENTORY = 0
const EQUIPMENT = 1
const STORE = 2
const HANGAR = 4
const item_colors = [Color(0.75,0.75,0.75),Color(1.0,1.0,1.0),Color(0.3,1.0,0.4),Color(0.3,0.4,1.0),Color(0.8,0.75,0.2),Color(1.0,0.6,0.2)]
const stats = ["mass","armor","repair","sp","stress_dissipation","energy","power",
"thrust_power","steering_power","max_temperature","heat","thrust_heat","steering_heat","heat_dissipation",
"damping","thrust","steering","cargo_space",
"resistance_impact","resistance_plasma","resistance_explosive",
"radar_range","stealth","min_crew","bunks"]
const ship_stats = ["mass","armor","repair","energy","power",
"thrust_power","steering_power",
"max_temperature","heat","thrust_heat","steering_heat","heat_dissipation",
"damping","thrust","steering","cargo_space",
"resistance_impact","resistance_plasma","resistance_explosive",
"radar_range","stealth","min_crew","bunks"]
const weapon_stats = ["rotation_speed","projectile_armor",
"internal_max_temperature","internal_heat_dissipation",
"firing_energy","dmg_type","damage","disable","impact_heat","fire_rate","speed",
"spread","acceleration","range","rays","life_time","ammo","targetting_type","targetting_time"]
const units = {"mass":"t","price":" Credits","armor":"MJ","repair":"MW",
"sp":"MJ","stress_dissipation":"MW","energy":"MJ","power":"MW","thrust_power":"MW","steering_power":"MW",
"firing_energy":"MJ","enps":"MW",
"max_temperature":"K","heat":"MW","thrust_heat":"MW","steering_heat":"MW","heat_dissipation":"%/s","firing_heat":"MJ",
"htps":"MW",
"damping":"%/s","thrust":"MN","steering":"","velocity":"m/s","acceleration":"m/s²",
"turning_speed":"°/s","rotation_speed":"°/s",
"cargo_space":"t","resistance_impact":"","resistance_plasma":"","resistance_explosive":"",
"radar_range":"km","stealth":"","min_crew":"","bunks":"",
"damage":"MJ","disable":"MJ","impact_heat":"MJ","dmgps":"MW","disps":"MW","ihtps":"MW",
"fire_rate":"Hz","speed":"m/s","spread":"°","range":"km","rays":"","life_time":"s","ammo":""}
const stats_tooltip = ["min_crew","bunks","armor","repair","rotation_speed","energy","power",
"thrust_power","enps",
"max_temperature","heat","thrust_heat","heat_dissipation","htps",
"damping","thrust","steering",
"dmgps","disps","ihtps","fire_rate","range","speed","spread","rays","life_time","ammo",
"cargo_space","resistance_impact","resistance_plasma","resistance_explosive",
"radar_range","stealth","price"]
const slot_sizes = ["small","medium","large","huge"]

const base_weapons = [
["paa",8],["chg",8],["elb",4],["las",4],
["plc",6],["vug",6],["grl",2],["ioc",2],
["mad",4],["plb",4],
["pbc",2],["rlg",2]]
const melee_weapons = [
["scg",6],["flt",6]]
const good_weapons = [
["plg",4],
["shr",4],["iog",4],["skg",2],
["pbg",4]]

const  base_turrets = [
["cgt",8],["flk",4],["ebt",4]]

const good_turrets = [
["plt",6],["mlt",4]]

const base_missiles = [
["drt",200],["mis",150],["jav",150],["mtr",100]]
const good_missiles = [
["siw",75]]

const base_reactors = [
["rbs",8],["rbm",6],["rbl",4],["rbh",2]]
const good_reactors = [
["rgs",4],["rgm",3],["rgl",2],["rgh",1]]
const advanced_reactors = [
["rrs",4],["rcs",4]]

const base_engines = [
["ebs",8],["ebm",6],["ebl",4],["ebh",2]]
const good_engines = [
["egs",4],["egm",3],["egl",2],["egh",1]]
const advanced_engines = [
["ets",4],["ess",4]]

const base_internal = [
["bas",5],["bam",4],["bal",3],["bah",2],
["shs",4],["shm",3],["shl",2],["shh",1],
["fcs",4],["fcm",2],["cld",4],
["ces",8],["cem",6],["cel",4],["ceh",2],
["bus",8],["bum",6],["bul",4],["buh",2]]
const advanced_internal = [
["res",4]]

const base_external = [
["ass",6],["asm",5],["asl",4],["ash",3],
["aps",6],["apm",5],["apl",4],["aph",3],
["sps",4],
["scs",6],["scm",5],["scl",4],["sch",3],
["sts",2],["stm",2],["bos",2],["bom",2]]

const republic_ships1 = [
["sos",10],["srf",8],["rpf",6],["hwf",8],["b01",6]]
const repulic_military1 = [
["sos-m",10],["srf-m",8],["rpf-m",6],["hwf-m",8],["b01-m",6]]
const ships2 = [
["exs",10],["f07",8],["b02",6],["c01",4]]
const civil_ships1 = [
["fr2",10],["fr1",6],["tr1",10]]


# outfit data
# per grade +200% mass, firing heat, max temp, energy usage; +300% price; +300% thrust; +250 range; +100% other stats
# weapon types:    plasma: default
#                  impact: -25% energy usage; +25% firing heat; -50% impact heat, disable
#               explosive: -33% energy usage; +33% firing heat; +200% mass; -25% damage, impact heat; -50% disable
#                turreted: -25% fire rate; +200% mass (+100% mass for explosive weapons); +25% hp; +50% price
#                 disable: -50% damage; +200% disable; -75% impact heat; -50% firing heat
#                    heat: -50% dmg, disable; +100% impact heat
#             short range: +50% dmg; (+50% impact heat instead for heat weapons)
#              long range: -50% dmg
#                    beam: -25% dmg
#                  guided: -25% dmg, disable
# missiles: base dmg: 50, base range: 3000
#           unguided: +100% ammo; -50% mass
# base firing energy/s: -10; base firing heat/s: 20
# base dps: 10; base disable/s: 5; base impact heat/s: 400; base range: 800
# good: +30% mass; +30% energy usage, heat; +100% price; +25% other stats; +1 grade
# specialist: +12.5% mass; +25% energy usage, heat; +150% price; +50% single stat; +1 grade
var outfits = {}


# variables #

var base = {}
var weapons = []
var turrets = []
var missiles = []
var missile_ammo = []
var reactors = []
var engines = []
var internal = []
var external = []

var store = []
var shipyard = []

var buy_ammount = 1
var player_power = false
var player_thrust = false
var player_cargo = false
var player_heat = false
var player_crew = 0
var player_bunks = 0
var player_weapons = []


# data #

var bg = {
"ship":preload("res://scripts/items/yellow.tres"),
"weapon":preload("res://scripts/items/red.tres"),
"turret":preload("res://scripts/items/yellow.tres"),
"missile":preload("res://scripts/items/orange.tres"),
"reactor":preload("res://scripts/items/blue.tres"),
"engine":preload("res://scripts/items/cyan.tres"),
"internal":preload("res://scripts/items/purple.tres"),
"external":preload("res://scripts/items/green.tres"),
"commodity":preload("res://scripts/items/grey.tres")
}
var icon_size = {
"small":preload("res://scripts/items/small.tres"),
"medium":preload("res://scripts/items/medium.tres"),
"large":preload("res://scripts/items/large.tres"),
"huge":preload("res://scripts/items/huge.tres")
}
var slot_icons = {
"weapon_small":preload("res://images/outfits/w1.png"),
"weapon_medium":preload("res://images/outfits/w2.png"),
"weapon_large":preload("res://images/outfits/w3.png"),
"weapon_huge":preload("res://images/outfits/w4.png"),
"turret_small":preload("res://images/outfits/t1.png"),
"turret_medium":preload("res://images/outfits/t2.png"),
"turret_large":preload("res://images/outfits/t3.png"),
"turret_huge":preload("res://images/outfits/t4.png"),
"missile_small":preload("res://images/outfits/m1.png"),
"missile_medium":preload("res://images/outfits/m2.png"),
"missile_large":preload("res://images/outfits/m3.png"),
"missile_huge":preload("res://images/outfits/m4.png"),
"reactor_small":preload("res://images/outfits/r1.png"),
"reactor_medium":preload("res://images/outfits/r2.png"),
"reactor_large":preload("res://images/outfits/r3.png"),
"reactor_huge":preload("res://images/outfits/r4.png"),
"engine_small":preload("res://images/outfits/a1.png"),
"engine_medium":preload("res://images/outfits/a2.png"),
"engine_large":preload("res://images/outfits/a3.png"),
"engine_huge":preload("res://images/outfits/a4.png"),
"internal_small":preload("res://images/outfits/i1.png"),
"internal_medium":preload("res://images/outfits/i2.png"),
"internal_large":preload("res://images/outfits/i3.png"),
"internal_huge":preload("res://images/outfits/i4.png"),
"external_small":preload("res://images/outfits/e1.png"),
"external_medium":preload("res://images/outfits/e2.png"),
"external_large":preload("res://images/outfits/e3.png"),
"external_huge":preload("res://images/outfits/e4.png")
}


# functions #
func is_bigger(size1,size2):
	return (size1 in {"small":["medium","large","huge"],"medium":["large","huge"],"large":["huge"],"huge":[]}[size2])

func equip(sID,iID):
	# equip item to given slot
	if (Player.ship_selected<0 || outfits[Player.inventory[iID][TYPE]]["type"]=="commodity"):
		return
	
	var slot = outfits[Player.equipment[Player.ship_selected][0][TYPE]]["slots"][sID-1]
	var type = slot.split("_")[0]
	var size = slot.split("_")[1]
	var itype = outfits[Player.inventory[iID][TYPE]]["type"]
	var isize = outfits[Player.inventory[iID][TYPE]]["size"]
	if (type==itype && !is_bigger(isize,size)):
		var ammount = 1
		if (outfits[Player.inventory[iID][TYPE]].has("ammo")):
			ammount = min(Player.inventory[iID][AMMOUNT],outfits[Player.inventory[iID][TYPE]]["ammo"])
		if (Player.equipment[Player.ship_selected][sID][TYPE]!=""):
			add_item(Player.equipment[Player.ship_selected][sID])
		Player.equipment[Player.ship_selected][sID] = [Player.inventory[iID][TYPE],ammount]
		remove_item([Player.inventory[iID][TYPE],ammount])
		HUD.get_node("Station").update_icons()

func find_smallest_slot(type,size):
	var sizes = {"small":["small","medium","large","huge"],"medium":["medium","large","huge"],"large":["large","huge"],"huge":["huge"]}[size]
	for z in sizes:
		for s in range(1,1+outfits[Player.equipment[Player.ship_selected][0][TYPE]]["slots"].size()):
			var sslot = outfits[Player.equipment[Player.ship_selected][0][TYPE]]["slots"][s-1]
			var stype = sslot.split("_")[0]
			var ssize = sslot.split("_")[1]
			if (stype==type && ssize==z && Player.equipment[Player.ship_selected][s][TYPE]==""):
				return s
	return -1

func equip_i(ID):
	# equip item to first free slot
	if (Player.ship_selected<0 || outfits[Player.inventory[ID][TYPE]]["type"]=="commodity"):
		return
	
	var type = outfits[Player.inventory[ID][TYPE]]["type"]
	var size = outfits[Player.inventory[ID][TYPE]]["size"]
	var sID = find_smallest_slot(type,size)
	
	if (sID>=0):
		var ammount = 1
		if (outfits[Player.inventory[ID][TYPE]].has("ammo")):
			 ammount = min(Player.inventory[ID][AMMOUNT],outfits[Player.inventory[ID][TYPE]]["ammo"])
		Player.equipment[Player.ship_selected][sID] = [Player.inventory[ID][TYPE],ammount]
		remove_item([Player.inventory[ID][TYPE],ammount])
		HUD.get_node("Station").update_icons()

func unequip(ID):
	# move equiped item to inventory
	if (Player.equipment[Player.ship_selected][ID][TYPE]==""):
		return false
	
	add_item([Player.equipment[Player.ship_selected][ID][TYPE],Player.equipment[Player.ship_selected][ID][AMMOUNT]])
	Player.equipment[Player.ship_selected][ID][TYPE] = ""
	Player.equipment[Player.ship_selected][ID][AMMOUNT] = 0
	HUD.get_node("Station").update_icons()
	return true

func add_item(item):
	# add item to inventory
	if (item[AMMOUNT]<1):
		return
	var s = find_item(item)
	
	if (s>=0):
		Player.inventory[s][AMMOUNT] += item[AMMOUNT]
	else:
		Player.inventory.push_back(item)

func remove_item(item):
	# remove item from inventory
	if (item[AMMOUNT]<1):
		return
	var s = find_item(item)
	
	if (s>=0):
		if (Player.inventory[s][AMMOUNT]>item[AMMOUNT]):
			Player.inventory[s][AMMOUNT] -= item[AMMOUNT]
		else:
			Player.inventory.remove(s)
		return true
	else:
		return false

func find_item(item):
	# find item in inventory
	for i in range(Player.inventory.size()):
		if (Player.inventory[i][TYPE]==item[TYPE]):
			return i
	
	return -1

func find_eq(item):
	# find equiped item
	for i in range(1,Player.equipment[Player.ship_selected].size()):
		if (Player.equipment[Player.ship_selected][i][TYPE]==item[TYPE]):
			return i
	
	return -1

func find_store(item):
	# find item in store
	for i in range(store.size()):
		if (store[i][TYPE]==item[TYPE]):
			return i
	
	return -1

func find_shipyard(item):
	# find ship in shipyard
	for i in range(shipyard.size()):
		if (shipyard[i][TYPE]==item[TYPE]):
			return i
	
	return -1

func add_store(item):
	# add item to store
	if (item[AMMOUNT]<1):
		return
	var s = find_store(item)
	
	if (s>=0):
		store[s][AMMOUNT] += item[AMMOUNT]
	else:
		store.push_back(item)

func remove_store(item):
	# remove item from store
	if (item[AMMOUNT]<1):
		return
	var s = find_store(item)
	
	if (s>=0):
		if (store[s][AMMOUNT]>item[AMMOUNT]):
			store[s][AMMOUNT] -= item[AMMOUNT]
		else:
			store.remove(s)
		return true
	else:
		return false

func buy(ID):
	# buy item
	var price
	if (outfits[store[ID][TYPE]]["type"]=="commodity"):
		price = Stations.stations_price[Player.station][store[ID][TYPE]]
	else:
		price = outfits[store[ID][TYPE]]["price"]
	var ammount = min(buy_ammount,store[ID][AMMOUNT])
	price *= ammount
	if (price>Player.credits):
		return false
	
	Player.credits -= price
	add_item([store[ID][TYPE],ammount])
	remove_store([store[ID][TYPE],ammount])
	HUD.get_node("Station").update_icons()
	return true

func sell(ID):
	# sell item
	if (outfits[Player.inventory[ID][TYPE]].has("unsellable") && outfits[Player.inventory[ID][TYPE]]["unsellable"]):
		return
	var price
	if (outfits[Player.inventory[ID][TYPE]]["type"]=="commodity"):
		if (!Stations.stations_cargo[Player.station].has(Player.inventory[ID][TYPE])):
			return false
		price = Stations.stations_price[Player.station][Player.inventory[ID][TYPE]]
	else:
		price = outfits[Player.inventory[ID][TYPE]]["price"]
	var ammount = min(buy_ammount,Player.inventory[ID][AMMOUNT])
	
	Player.credits += price*ammount
	add_store([Player.inventory[ID][TYPE],ammount])
	remove_item([Player.inventory[ID][TYPE],ammount])
	HUD.get_node("Station").update_icons()
	return true

func add_shipyard(item):
	# add ship to shipyard
	if (item[AMMOUNT]<1):
		return
	var s = find_shipyard(item)
	
	if (s>=0):
		shipyard[s][AMMOUNT] += item[AMMOUNT]
	else:
		shipyard.push_back(item)

func buy_ship(ID):
	# buy ship
	var ammount = min(buy_ammount,shipyard[ID][AMMOUNT])
	var values = outfits[shipyard[ID][TYPE]]
	var price = values["price"]*ammount
	if (price>Player.credits):
		return false
	
	Player.credits -= price
	var eq = [[shipyard[ID][0],1]]
	eq.resize(values["slots"].size()+1)
	for s in range(1,eq.size()):
		eq[s] = ["",0]
	for i in range(ammount):
		Player.equipment.push_back([]+eq)
	Player.ship_location.push_back(Player.station)
	Player.ship_crew.push_back(outfits[shipyard[ID][0]]["min_crew"])
	Player.ship_name.push_back("Player")
	shipyard[ID][AMMOUNT] -= ammount
	if (shipyard[ID][AMMOUNT]<=0):
		shipyard.remove(ID)
	if (Player.ship_selected==-1):
		Player.ship_selected = Player.equipment.size()-1
	HUD.get_node("Station").update_icons()

func sell_ship(ID):
	# sell ship
	var ammount = Player.equipment[ID][0][AMMOUNT]
	var values = outfits[Player.equipment[ID][0][TYPE]]
	var price = values["price"]*ammount
	
	Player.credits += price
	for i in range(1,Player.equipment[ID].size()):
		add_store(Player.equipment[ID][i])
	add_shipyard([Player.equipment[ID][0][TYPE],ammount])
	Player.equipment.remove(ID)
	Player.ship_location.remove(ID)
	Player.ship_crew.remove(ID)
	Player.ship_name.remove(ID)
	if (Player.ship_selected>=Player.equipment.size()):
		Player.ship_selected = Player.equipment.size()-1
	HUD.get_node("Station").update_icons()

func swap_ship(ID):
	# change ship
	if (Player.ship_location[ID]!=Player.station):
		return
	
	if (Player.ship_selected>=0):
		HUD.get_node("Station/Hangar/Hangar/Item"+str(Player.ship_selected)+"/Selected").hide()
	Player.ship_selected = ID
	HUD.get_node("Station/Hangar/Hangar/Item"+str(Player.ship_selected)+"/Selected").show()
	HUD.get_node("Station").update_icons()

func hire_crew():
	var ammount = min(buy_ammount,player_bunks-Player.passengers-Player.ship_crew[Player.ship_selected])
	if (ammount<1):
		return false
	
	Player.ship_crew[Player.ship_selected] += ammount
	HUD.get_node("Station").update_icons()
	
	return true

func fire_crew():
	var ammount = min(buy_ammount,Player.ship_crew[Player.ship_selected]-player_crew)
	if (ammount<1):
		return false
	
	Player.ship_crew[Player.ship_selected] -= ammount
	HUD.get_node("Station").update_icons()
	
	return true

func update_stats():
	# recalculate the player's total values
	if (Player.ship_selected<0):
		HUD.get_node("Station/Equipment/Text").clear()
		HUD.get_node("Station/Inventory/Cargo").set_text("0 / 0")
		HUD.get_node("Station/Inventory/Cargo").add_color_override("font_color",Color(1.0,0.0,0.0))
		return
	
	var player_stats = {}
	var cargo_inventory = get_player_cargo()
	var num_weapons
	var num_turrets
	var num_missiles
	var max_power
	var min_heat
	for s in stats:
		player_stats[s] = 0
	
	weapons = []
	turrets = []
	missiles = []
	missile_ammo = []
	reactors = []
	engines = []
	internal = []
	external = []
	for eq in Player.equipment[Player.ship_selected]:
		if (eq[TYPE]!=""):
			var type = outfits[eq[TYPE]]["type"]
			if (type=="reactor"):
				reactors.push_back(eq[TYPE])
			elif (type=="engine"):
				engines.push_back(eq[TYPE])
			elif (type=="internal"):
				internal.push_back(eq[TYPE])
			elif (type=="external"):
				external.push_back(eq[TYPE])
			elif (type=="weapon"):
				weapons.push_back(eq[TYPE])
			elif (type=="turret"):
				turrets.push_back(eq[TYPE])
			elif (type=="missile"):
				missiles.push_back(eq[TYPE])
				missile_ammo.push_back(eq[AMMOUNT])
	
	var values = outfits[Player.equipment[Player.ship_selected][0][TYPE]]
	for s in values.keys():
		player_stats[s] = values[s]
	min_heat = player_stats["heat"]
	for r in reactors:
		var values = outfits[r]
		for s in stats:
			if (values.has(s)):
				player_stats[s] += values[s]
			if (values.has(s+"_active")):
				player_stats[s] += values[s+"_active"]
	max_power = player_stats["power"]
	for o in engines+internal+external+weapons+turrets+missiles:
		var values = outfits[o]
		for s in stats:
			if (values.has(s)):
				player_stats[s] += values[s]
			if (values.has(s+"_active")):
				player_stats[s] += values[s+"_active"]
	player_stats["mass"] += get_player_cargo()
	player_stats["thrust"] /= player_stats["mass"]
	player_stats["steering"] /= player_stats["mass"]
	
	num_weapons = weapons.size()
	num_turrets = turrets.size()
	num_missiles = missiles.size()
	player_crew = player_stats["min_crew"]
	player_bunks = player_stats["bunks"]
	player_power = player_stats["power"]<=0 || player_stats["energy"]<=0
	player_thrust = player_stats["thrust"]<=0 && engines.size()<=0
	player_cargo = cargo_inventory>player_stats["cargo_space"]
#	player_heat = min_heat>=player_stats["max_temperature"]
	Player.free_cargo_space = player_stats["cargo_space"]-cargo_inventory
	Player.passengers = 0
	for m in Missions.missions:
		if (m.has("passengers")):
			Player.passengers += m["passengers"]
	Player.free_bunks = player_bunks-Player.ship_crew[Player.ship_selected]-Player.passengers
	
	for s in ["power","heat"]:
		player_stats[s] += player_stats["thrust_"+s]
		player_stats[s] += player_stats["steering_"+s]
#	for s in ["heat","thrust_heat","steering_heat"]:
#		player_stats[s] /= player_stats["mass"]
	
#	min_heat /= player_stats["mass"]
	
	player_weapons = weapons+turrets
	var num_w = player_weapons.size()
	for i in range(Player.weapon_group.size()):
		Player.weapon_group[i].resize(num_w)
		for j in range(player_weapons.size()):
			if (Player.weapon_group[i][j]==null):
				Player.weapon_group[i][j] = true
	HUD.update_weapon_groups()
	
	# print text
	HUD.get_node("Station/Equipment/Text").clear()
	HUD.get_node("Station/Equipment/Text").add_text(tr("mass")+": "+str(player_stats["mass"])+tr(units["mass"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("cargo_space")+": "+str(player_stats["cargo_space"])+tr(units["cargo_space"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("armor")+": "+str(player_stats["armor"])+tr(units["armor"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("repair")+": "+str(player_stats["repair"])+tr(units["repair"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("sp")+": "+str(player_stats["sp"])+tr(units["sp"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("stress_dissipation")+": "+str(player_stats["stress_dissipation"])+tr(units["stress_dissipation"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("energy")+": "+str(player_stats["energy"])+tr(units["energy"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("min_power")+": "+str(player_stats["power"])+tr(units["power"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("power")+": "+str(max_power)+tr(units["power"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("max_temperature")+": "+str(player_stats["max_temperature"])+tr(units["max_temperature"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("min_heat")+": "+str(min_heat)+tr(units["heat"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("max_heat")+": "+str(player_stats["heat"])+tr(units["heat"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("heat_dissipation")+": "+str(player_stats["heat_dissipation"])+tr(units["heat_dissipation"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("acceleration")+": "+str(round(10*player_stats["thrust"])/10.0)+tr(units["acceleration"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("max_velocity")+": "+str(round(1000.0*player_stats["thrust"]/player_stats["damping"])/10.0)+tr(units["velocity"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("turning_speed")+": "+str(round(10*player_stats["steering"])/10.0)+tr(units["turning_speed"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("resistance_impact")+": "+str(player_stats["resistance_impact"])+"%\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("resistance_plasma")+": "+str(player_stats["resistance_plasma"])+"%\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("resistance_explosive")+": "+str(player_stats["resistance_explosive"])+"%\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("radar_range")+": "+str(player_stats["radar_range"])+tr(units["radar_range"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("stealth")+": "+str(player_stats["stealth"])+tr(units["stealth"])+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("NUM_WEAPONS")+": "+str(num_weapons)+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("NUM_TURRETS")+": "+str(num_turrets)+"\n")
	HUD.get_node("Station/Equipment/Text").add_text(tr("NUM_MISSILES")+": "+str(num_missiles)+"\n")
	
	HUD.get_node("Station/Inventory/Cargo").set_text(str(cargo_inventory)+tr(units["cargo_space"])+" / "+str(player_stats["cargo_space"])+tr(units["cargo_space"]))
	if (player_cargo):
		HUD.get_node("Station/Inventory/Cargo").add_color_override("font_color",Color(1.0,0.0,0.0))
	else:
		HUD.get_node("Station/Inventory/Cargo").add_color_override("font_color",Color(1.0,1.0,1.0))

func get_cargo_mass(inventory):
	var cargo = 0
	for i in range(inventory.size()):
		if (inventory[i][TYPE]!=""):
			cargo += outfits[inventory[i][TYPE]]["mass"]*inventory[i][AMMOUNT]
	return cargo

func get_player_cargo():
	return get_cargo_mass(Player.inventory)


# tooltips

func tooltip_comm(type,ID):
	var station = Player.station
	var tooltip = HUD.get_node("Tooltip")
	var c
	
	if (type==INVENTORY):
		c = Player.inventory[ID][TYPE]
	elif (type==STORE):
		c = store[ID][TYPE]
	
	tooltip.get_node("VBoxContainer/Line1/Text").set_text(tr(c))
	tooltip.get_node("VBoxContainer/Line1/Text").add_color_override("font_color",Color(1.0,1.0,1.0))
	tooltip.get_node("VBoxContainer/Line1").show()
	tooltip.get_node("VBoxContainer/Line2/Text").set_text(tr("commodity"))
	tooltip.get_node("VBoxContainer/Line2/Number").set_text(tr(""))
	tooltip.get_node("VBoxContainer/Line2").show()
	tooltip.get_node("VBoxContainer/Line3").hide()
	tooltip.get_node("VBoxContainer/Line4").hide()
	if (outfits[c].has("unsellable") && outfits[c]["unsellable"]):
		tooltip.get_node("VBoxContainer/Line5").hide()
	else:
		tooltip.get_node("VBoxContainer/Line5/Text").set_text(tr("price")+": ")
		tooltip.get_node("VBoxContainer/Line5/Number").set_text(str(Stations.stations_price[station][c])+tr(units["price"]))
		tooltip.get_node("VBoxContainer/Line5").show()
	if (type==STORE):
		tooltip.get_node("VBoxContainer/Line6/Text").set_text(tr("AMMOUNT")+": ")
		tooltip.get_node("VBoxContainer/Line6/Number").set_text(str(Stations.stations_comm[station][c]))
		tooltip.get_node("VBoxContainer/Line6").show()
		tooltip.get_node("VBoxContainer/Line7/Text").set_text(tr("cargo_space")+": ")
		tooltip.get_node("VBoxContainer/Line7/Number").set_text(str(Stations.stations_cargo[station][c])+tr(units["cargo_space"]))
		tooltip.get_node("VBoxContainer/Line7").show()
	elif (type==INVENTORY):
		tooltip.get_node("VBoxContainer/Line6/Text").set_text(tr("AMMOUNT")+": ")
		tooltip.get_node("VBoxContainer/Line6/Number").set_text(str(Player.inventory[ID][AMMOUNT]))
		tooltip.get_node("VBoxContainer/Line6").show()
		tooltip.get_node("VBoxContainer/Line7").hide()
	for i in range(8,27):
		tooltip.get_node("VBoxContainer/Line"+str(i)).hide()
	
	var height = 10
	tooltip.show()
	for i in range(1,8):
		if (tooltip.get_node("VBoxContainer/Line"+str(i)).is_visible()):
			height += tooltip.get_node("VBoxContainer/Line"+str(i)+"/Text").get_line_count()*(tooltip.get_node("VBoxContainer/Line"+str(i)+"/Text").get_line_height()+1)
	
	tooltip.set_pos(HUD.get_node("Station").get_global_mouse_pos()-Vector2(192,0))
	tooltip.set_size(Vector2(192,height))

func show_tooltip(type,ID):
	var values
	var am
	var tooltip = HUD.get_node("Tooltip")
	var lines = 6
	if (type==INVENTORY):
		if (outfits[Player.inventory[ID][TYPE]]["type"]=="commodity"):
			tooltip_comm(type,ID)
			return
		values = outfits[Player.inventory[ID][TYPE]]
		am = Player.inventory[ID][AMMOUNT]
	elif (type==EQUIPMENT):
		if (Player.equipment[Player.ship_selected][ID][TYPE]==""):
			return
		values = outfits[Player.equipment[Player.ship_selected][ID][TYPE]]
		am = 1
	elif (type==STORE):
		if (outfits[store[ID][TYPE]]["type"]=="commodity"):
			tooltip_comm(type,ID)
			return
		
		values = outfits[store[ID][TYPE]]
		am = store[ID][AMMOUNT]
	elif (type==3):
		values = outfits[shipyard[ID][TYPE]]
		am = 1
	elif (type==HANGAR):
		values = outfits[Player.equipment[ID][0][TYPE]]
		am = 1
	
	tooltip.get_node("VBoxContainer/Line1/Text").set_text(tr(values["name"]))
	tooltip.get_node("VBoxContainer/Line1/Text").add_color_override("font_color",item_colors[values["grade"]])
	tooltip.get_node("VBoxContainer/Line1").show()
	tooltip.get_node("VBoxContainer/Line2/Text").set_text(tr(values["type"]))
	tooltip.get_node("VBoxContainer/Line2/Number").set_text("")
	tooltip.get_node("VBoxContainer/Line2").show()
	if (values.has("ship_class")):
		tooltip.get_node("VBoxContainer/Line3/Text").set_text(tr("SHIP_CLASS")+": "+tr(values["ship_class"]))
#		tooltip.get_node("VBoxContainer/Line3/Number").set_text("")
		tooltip.get_node("VBoxContainer/Line3").show()
	elif (values.has("slot")):
		tooltip.get_node("VBoxContainer/Line3/Text").set_text(tr("REQUIRES")+" "+tr(values["slot"]))
#		tooltip.get_node("VBoxContainer/Line3/Number").set_text("")
		tooltip.get_node("VBoxContainer/Line3").show()
	else:
		tooltip.get_node("VBoxContainer/Line3").hide()
	if (values.has("slots")):
		var slots = tooltip.get_node("VBoxContainer/Line4/Slots")
		slots.clear()
		slots.push_align(RichTextLabel.ALIGN_RIGHT)
		tooltip.get_node("VBoxContainer/Line4/Text").set_text(tr("SLOTS")+": ")
		for s in values["slots"]:
			slots.add_image(slot_icons[s])
		tooltip.get_node("VBoxContainer/Line4").show()
	else:
		tooltip.get_node("VBoxContainer/Line4").hide()
	tooltip.get_node("VBoxContainer/Line5/Text").set_text(tr("mass")+": ")
	tooltip.get_node("VBoxContainer/Line5/Number").set_text(str(values["mass"])+tr(units["mass"]))
	tooltip.get_node("VBoxContainer/Line5").show()
	if (values.has("dmg_type")):
		tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Text").set_text(str(tr(values["dmg_type"])))
		tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Number").set_text(str(tr(values["dmg_type"])))
		tooltip.get_node("VBoxContainer/Line"+str(lines)).show()
		lines += 1
	if (values.has("beam") && values["beam"]):
		tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Text").set_text(tr("BEAM_WEAPON"))
		tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Number").set_text("")
		tooltip.get_node("VBoxContainer/Line"+str(lines)).show()
		lines += 1
	for s in stats_tooltip:
		if (values.has(s)):
			var value = values[s]
			if (values.has(s+"_active")):
				value += values[s+"_active"]
			tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Text").set_text(tr(s)+": ")
			tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Number").set_text(str(value)+tr(units[s]))
			tooltip.get_node("VBoxContainer/Line"+str(lines)).show()
			lines += 1
		elif (values.has(s+"_active")):
			tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Text").set_text(tr(s)+": ")
			tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Number").set_text(str(values[s+"_active"])+tr(units[s]))
			tooltip.get_node("VBoxContainer/Line"+str(lines)).show()
			lines += 1
	if (am!=1):
		tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Text").set_text(tr("AMMOUNT")+": ")
		tooltip.get_node("VBoxContainer/Line"+str(lines)+"/Number").set_text(str(am))
		tooltip.get_node("VBoxContainer/Line"+str(lines)).show()
		lines += 1
	
	for i in range(lines,27):
		tooltip.get_node("VBoxContainer/Line"+str(i)).hide()
	
	var height = 10
	tooltip.show()
	for i in range(1,lines+1):
		if (tooltip.get_node("VBoxContainer/Line"+str(i)).is_visible()):
			height += tooltip.get_node("VBoxContainer/Line"+str(i)+"/Text").get_line_count()*(tooltip.get_node("VBoxContainer/Line"+str(i)+"/Text").get_line_height()+1)
	
	tooltip.set_pos(HUD.get_node("Station").get_global_mouse_pos()-Vector2(192,0))
	tooltip.set_size(Vector2(192,height))

func hide_tooltip():
	HUD.get_node("Tooltip").hide()


func _ready():
	# load outfit data
	var dir = Directory.new()
	var error = dir.open("res://scripts/outfits")
	if (error!=OK):
		print("Failed to load outfits!")
		return
	
	var file_name
	dir.list_dir_begin()
	file_name = dir.get_next()
	while (file_name!=""):
		if (!dir.current_is_dir()):
			var file = File.new()
			var error = file.open("res://scripts/outfits/"+file_name,File.READ)
			if (error==OK):
				var line = ""
				while (!file.eof_reached()):
					line += file.get_line()
					if (line.rfind("}")!=-1):
						var currentline = {}
						var error = currentline.parse_json(line)
						if (error!=OK):
							print("Error "+str(error)+" while parsing "+line+"!")
						elif (currentline.has("tag")):
							var data = {}
							for v in currentline.keys():
								data[v] = currentline[v]
							for k in ["icon","preview","scene","outlines","projectile","muzzle_flash","particles_impact"]:
								if (data.has(k)):
									data[k] = load(data[k])
							if (data.has("size")):
								data["slot"] = data["type"]+"_"+data["size"]
							if (data.has("fire_rate")):
								data["reload_delay"] = 1.0/data["fire_rate"]
							if (data.has("damage")):
								data["dmgps"] = data["damage"]*data["fire_rate"]*data["rays"]
							if (data.has("disable")):
								data["disps"] = data["disable"]*data["fire_rate"]*data["rays"]
							if (data.has("impact_heat")):
								data["ihtps"] = data["impact_heat"]*data["fire_rate"]*data["rays"]
							if (data.has("firing_energy")):
								data["enps"] = data["firing_energy"]*data["fire_rate"]
							if (data.has("firing_heat")):
								data["htps"] = data["firing_heat"]*data["fire_rate"]
							var tag = currentline["tag"]
							outfits[tag] = data
							if (currentline.has("size_x")):
								Ships.ship_size[tag] = Vector2(currentline["size_x"],currentline["size_y"])
							if (currentline.has("panel_x")):
								Ships.panel_ship_size[tag] = Vector2(currentline["panel_x"],currentline["panel_y"])
						line = ""
			else:
				print("Failed to open file "+file_name+".")
		file_name = dir.get_next()
	dir.list_dir_end()
	
