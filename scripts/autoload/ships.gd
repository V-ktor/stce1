
extends Node
# ship generation

# constants #
var panel_ship_size = {}
var ship_size = {}
const pirate_ships = ["p01","p02","p03"]

# pirate names
const pirate_descriptors = [
"Bloody","Horrible","Terrible","Fearsome","Fearless","Mighty","Midnight",
"Black","Red","Gray","Dark","Crimson","Rotten","Lustful","Evil","Defiant",
"Brutal"]
const pirate_actors = [
"Beard","Moustache","Demon","Devil","Tyrant","Horror","Terror","Corsair",
"Raider","Grinder","Bandit","Thief","Marauder","Dominator","Slaughter",
"Destroyer","Death","Doom","Insanity","Inferno","Storm","Lance","Scythe",
"Chainsaw","Wolf","Dragon","Raptor","Falcon"]
const pirate_articles = ["The","The","Revenge of the"]
const pirate_suffix = [" of Doom"," of Destruction"," from Hell"," of Steel"," II"]
# random outfits useable by pirates
const pirate_outfits = {
"weapon_small":["paa","chg","scg","elb","elb"],
"weapon_medium":["plg","vug","grl","elb"],
"weapon_large":["mad","vug","iog","ioc"],
"weapon_huge":["mad","rlg","plb","ioc"],
"turret_small":["cgt"],
"turret_medium":["cgt","flk","ebt","ebt"],
"turret_large":["flk","ebt"],
"turret_huge":[""],
"missile_small":["","","drt","mis"],
"missile_medium":["","","mis","jav"],
"missile_large":["","mtr","jav"],
"missile_huge":[""],
"reactor_small":["rbs"],
"reactor_medium":["rbs","rbm","rbm"],
"reactor_large":["rbm","rbl","rbl"],
"reactor_huge":["rbl","rbh","rbh"],
"engine_small":["ebs"],
"engine_medium":["ebm"],
"engine_large":["ebl"],
"engine_huge":["ebh"],
"internal_small":["","bas","fcs","ces"],
"internal_medium":["","bam","bam","shs","fcs","cem"],
"internal_large":["","bal","bal","shm","fcm","cel"],
"internal_huge":["","bah","bah","shl","fcm","ceh"],
"external_small":["","ass","sps","sts","bos","scs"],
"external_medium":["","asm","apm","stm","bom","scm"],
"external_large":["","asl","asl","scl"],
"external_huge":["","ash","ash","sch"]
}
const pirate_crew = {
"p01":2,"p02":2.5,"p03":3.25}
const pirate_credits = {
"p01":750,"p02":1000,"p03":2000
}


# data #

var script_player = preload("res://scripts/player.gd")
var script_default = preload("res://scripts/ship_base.gd")
var script_pirate = preload("res://scripts/ai/pirate.gd")
var script_republic_police = preload("res://scripts/ai/republic_police.gd")
var script_republic_military = preload("res://scripts/ai/republic_military.gd")
var script_civil_trader = preload("res://scripts/ai/civil_trader.gd")
var script_escort_freighter = preload("res://scripts/ai/escort_freighter.gd")
var panel_weapon = preload("res://scenes/hud/weapon.tscn")
var panel_missile = preload("res://scenes/hud/missile.tscn")
var panel_ship = preload("res://scenes/hud/panel_ship.tscn")
var animation = preload("res://scenes/ships/animations.tscn")


# create ships
func create_ship(ship,equipment,inventory,script,faction,pos,rot,lv,name,crew):
	var si = Equipment.outfits[ship]["scene"].instance()
	si.set_script(script)
	
	si.ship_type = ship
	si.inventory = inventory
	si.equipment = equipment
	if (crew==-1):
		si.crew = round(rand_range(Equipment.outfits[ship]["min_crew"],Equipment.outfits[ship]["bunks"]))
	else:
		si.crew = crew
	
	si.set_name(name)
	si.set_pos(pos)
	si.set_rot(rot)
	si.set_linear_velocity(lv)
	si.faction = faction
	si.name = name
	si.size = ship_size[ship]
	si.num_grappling_hooks = Equipment.outfits[ship]["num_grappling_hooks"]
	
	var ai = animation.instance()
	si.add_child(ai)
	
	get_node("/root/Main").add_child(si)
	
	var pi = panel_ship.instance()
	var offset = (ship_size[ship].x+ship_size[ship].y)/2
	pi.ship = si
	pi.set_name(si.get_name())
	pi.size = (ship_size[ship].x+ship_size[ship].y)*Vector2(1,1)
	pi.set_size(pi.size)
	pi.set_pos((pos-get_node("/root/Main/Camera").get_camera_screen_center())/get_node("/root/Main/Camera").get_zoom()+OS.get_video_mode_size()/2.0-pi.get_size()/2.0)
	for i in range(1,5):
		pi.get_node("Center/Velocity/Velocity"+str(i)).set_pos(Vector2(0,offset-64))
	HUD.get_node("Ships").add_child(pi)
	
	return si

func create_player(pos,rot,lv):
	var pi = create_ship(Player.equipment[Player.ship_selected][0][Equipment.TYPE],Player.equipment[Player.ship_selected],Player.inventory,script_player,Factions.PLAYER,pos,rot,lv,Player.ship_name[Player.ship_selected],Player.ship_crew[Player.ship_selected])
	
	# set up UI
	HUD.get_node("Ships/Player").set_self_opacity(0.0)
	HUD.get_node("Ships/Player/Name").hide()
	HUD.get_node("Ships/Player/HP").hide()
	HUD.get_node("Ships/Player/Disable").hide()
	HUD.get_node("Ships/Player/Temp").hide()
	
	for c in HUD.get_node("Weapons/VBoxContainer").get_children():
		c.set_name("deleted")
		c.queue_free()
	HUD.get_node("Weapons").set_margin(MARGIN_TOP,49*(pi.num_weapons+pi.num_turrets+pi.num_missiles)+4)
	for i in range(pi.num_weapons):
		var wi = panel_weapon.instance()
		wi.set_name("Weapon"+str(i+1))
		wi.get_node("Icon").set_texture(Equipment.outfits[pi.weapons[i]]["icon"])
		wi.get_node("SP").set_max(Equipment.outfits[pi.weapons[i]]["sp"])
		wi.get_node("Time").set_max(Equipment.outfits[pi.weapons[i]]["reload_delay"])
		wi.get_node("Temp").set_max(Equipment.outfits[pi.weapons[i]]["internal_max_temperature"])
		HUD.get_node("Weapons/VBoxContainer").add_child(wi)
	for i in range(pi.num_turrets):
		var ti = panel_weapon.instance()
		ti.set_name("Turret"+str(i+1))
		ti.get_node("Icon").set_texture(Equipment.outfits[pi.turrets[i]]["icon"])
		ti.get_node("SP").set_max(Equipment.outfits[pi.turrets[i]]["sp"])
		ti.get_node("Time").set_max(Equipment.outfits[pi.turrets[i]]["reload_delay"])
		ti.get_node("Temp").set_max(Equipment.outfits[pi.turrets[i]]["internal_max_temperature"])
		HUD.get_node("Weapons/VBoxContainer").add_child(ti)
	for i in range(pi.num_missiles):
		var mi = panel_missile.instance()
		mi.set_name("Missile"+str(i+1))
		mi.get_node("Icon").set_texture(Equipment.outfits[pi.missiles[i]]["icon"])
		if (Equipment.outfits[pi.missiles[i]].has("targetting_time")):
			mi.get_node("Targetting").set_max(Equipment.outfits[pi.missiles[i]]["targetting_time"])
		else:
			mi.get_node("Targetting").set_max(0)
		mi.get_node("Time").set_max(Equipment.outfits[pi.missiles[i]]["reload_delay"])
		mi.get_node("Ammo").set_max(Equipment.outfits[pi.missiles[i]]["ammo"])
		HUD.get_node("Weapons/VBoxContainer").add_child(mi)
	if (HUD.has_node("Status/Outlines")):
		HUD.get_node("Status/Outlines").queue_free()
		HUD.get_node("Status/Outlines").set_name("deleted")
	HUD.get_node("Status").set_size(panel_ship_size[Player.equipment[Player.ship_selected][0][Equipment.TYPE]])
	var oi = Equipment.outfits[Player.equipment[Player.ship_selected][0][Equipment.TYPE]]["outlines"].instance()
	HUD.get_node("Status").add_child(oi)
	
	Player.missile_ammo = Equipment.missile_ammo
#	for j in range(pi.missile_type.size()):
#		for i in range(8):
#			HUD.get_node("Status/Outlines/Missile"+str(j+1)+"/Missile"+str(i+1)).set_texture(Equipment.outfits[pi.missiles[j]]["outlines"])
#		for i in range(pi.missile_ammo[j]):
#			HUD.get_node("Status/Outlines/Missile"+str(j+1)+"/Missile"+str(i+1)).show()
#		for i in range(pi.missile_ammo[j],8):
#			HUD.get_node("Status/Outlines/Missile"+str(j+1)+"/Missile"+str(i+1)).hide()
	pi.select_missile(0)
	pi.change_weapon_group()
	pi.credits = Player.credits


# generate a random name for pirate ships
func pirate_name():
	var name = ""
	if (randf()<0.1):
		name += pirate_articles[randi()%pirate_articles.size()]+" "
	if (randf()<0.5):
		name += pirate_descriptors[randi()%pirate_descriptors.size()]+" "
	name += pirate_actors[randi()%pirate_actors.size()]
	if (name.length()<12 && randf()<0.15):
		name += pirate_suffix[randi()%pirate_suffix.size()]
	return name

# create random pirate at a given position with velocity v
func create_rnd_pirate(pos,v):
	var s = pirate_ships[randi()%(pirate_ships.size())]
	var crew = clamp(round(pirate_crew[s]*rand_range(0.75,1.25)),2,Equipment.outfits[s]["bunks"])
	var p = create_ship(s,eq_rnd_pirate(s),inv_rnd_pirate(s),script_pirate,Factions.PIRATES,pos,2*PI*randf(),v,pirate_name(),crew)
	p.credits = pirate_credits[s]*rand_range(0.8,1.2)*rand_range(0.9,1.1)
	return p

# random pirate equipment
func eq_rnd_pirate(ship):
	var eq = [[ship,1]]
	for s in Equipment.outfits[ship]["slots"]:
		var ammount = 1
		var type = pirate_outfits[s][randi()%(pirate_outfits[s].size())]
		if (type!="" && Equipment.outfits[type].has("ammo")):
			ammount = round(Equipment.outfits[type]["ammo"]*rand_range(0.5,1.0))
		eq.push_back([type,ammount])
#	print(eq)
	return eq

# random pirate cargo
func inv_rnd_pirate(ship):
	var ammount = round(rand_range(0.0,0.5)*Equipment.outfits[ship]["cargo_space"])
	var type = Economy.commodities[randi()%(Economy.commodities.size())]
	return [[type,ammount]]
