
extends Node2D

var type = 1
var dt = 1
var dmg = 5.0
var disable = 2.0
var heat = 2.0
var faction = 0
var lv = Vector2(0,0)
var a = Vector2(0,0)
var dir = Vector2(0,0)
var disabled = false

func disable():
	if (disabled):
		return
	
	get_node("RayCast").set_enabled(false)
	set_process(false)
	disabled = true

func _process(delta):
	if (get_node("RayCast").is_colliding()):
		var body = get_node("RayCast").get_collider()
		if (body.has_method("damage") && Factions.is_enemy(faction,body.faction)):
			body.damage(get_node("RayCast").get_collision_point(),dt,dmg,disable,heat)
			var pi = Equipment.outfits[type]["particles_impact"].instance()
			pi.set_rot(-body.get_rot())
			body.add_child(pi)
			pi.set_global_pos(get_node("RayCast").get_collision_point())
			disable()

func _ready():
	a = a*dir
	set_process(true)
