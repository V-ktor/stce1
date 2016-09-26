
extends Node
# create shots, missiles and particles

# data #

var cm = preload("res://scenes/cm.tscn")
var hook = preload("res://scenes/grappling_hook.tscn")


# functions #

func shoot(type,node,spread,dir,rot,lv,faction):
	for k in range(Equipment.outfits[type]["rays"]):
		var sp = spread*rand_range(-1.0,1.0)*deg2rad(Equipment.outfits[type]["spread"])
		var si = Equipment.outfits[type]["projectile"].instance()
		si.type = type
		si.dmg = Equipment.outfits[type]["damage"]
		si.dt = Equipment.outfits[type]["dmg_type"]
		si.disable = Equipment.outfits[type]["disable"]
		si.heat = Equipment.outfits[type]["impact_heat"]
		si.get_node("Timer").set_wait_time(Equipment.outfits[type]["life_time"])
		si.get_node("Timer").start()
		si.faction = faction
		if !(Equipment.outfits[type].has("beam") && Equipment.outfits[type]["beam"]):
			dir = dir.rotated(sp)
			si.set_rot(rot+sp)
			si.lv = dir*Equipment.outfits[type]["speed"]+lv
			if (Equipment.outfits[type].has("acceleration")):
				si.a = Equipment.outfits[type]["acceleration"]
			si.dir = dir
			si.set_pos(node.get_global_pos())
			get_node("/root/Main").add_child(si)
		else:
			node.add_child(si)
	var fi = Equipment.outfits[type]["muzzle_flash"].instance()
	node.add_child(fi)
	fi.get_node("Sound").play(Equipment.outfits[type]["sound"])

func launch(type,node,dir,rot,lv,faction,target):
	for k in range(Equipment.outfits[type]["rays"]):
		var sp = rand_range(-1.0,1.0)*deg2rad(Equipment.outfits[type]["spread"])
		var si = Equipment.outfits[type]["projectile"].instance()
		si.type = type
		si.dmg = Equipment.outfits[type]["damage"]
		si.dt = Equipment.outfits[type]["dmg_type"]
		si.disable = Equipment.outfits[type]["disable"]
		si.heat = Equipment.outfits[type]["impact_heat"]
		si.hp = Equipment.outfits[type]["armor"]
		si.get_node("Timer").set_wait_time(Equipment.outfits[type]["life_time"])
		si.get_node("Timer").start()
		si.faction = faction
		dir = dir.rotated(sp)
		si.set_rot(rot+sp)
		si.lv = dir*Equipment.outfits[type]["speed"]+lv
		si.a = Equipment.outfits[type]["acceleration"]
		si.dir = dir
		if (Equipment.outfits[type].has("damping")):
			si.damping = Equipment.outfits[type]["damping"]
		si.set_pos(node.get_global_pos())
		si.target = target
		get_node("/root/Main").add_child(si)
	var fi = Equipment.outfits[type]["muzzle_flash"].instance()
	node.add_child(fi)
	fi.get_node("Sound").play(Equipment.outfits[type]["sound"])

func grappling_hook(node,ship,pos,rot,dir,rest_length,max_length,speed,faction):
	var hi = hook.instance()
	hi.set_rot(rot)
	hi.set_pos(pos)
#	hi.get_node("Joint").set_rest_length(rest_length)
#	hi.get_node("Joint").set_length(max_length)
#	hi.get_node("Joint").set_node_a(node.get_parent().get_path())
	hi.speed = speed
	hi.dir = dir
	hi.max_length = max_length
	hi.rest_length = rest_length
	hi.faction = faction
	hi.ship = ship
	node.add_child(hi)
#	get_node("/root/Main").add_child(hi)

func create_cm(type,pos,faction,lv):
	var ci = cm.instance()
	ci.set_pos(pos)
	ci.lv = lv
	ci.faction = faction
	get_node("/root/Main").add_child(ci)
