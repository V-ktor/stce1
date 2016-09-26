
extends Area2D

var type = 1
var dt = 1
var dmg = 5.0
var disable = 2.0
var heat = 2.0
var faction = 0
var lv = Vector2(0,0)
var a = 0.0
var dir = Vector2(0,0)
var disabled = false
var missile = true
var target

func disable():
	if (disabled):
		return
	
	disabled = true
	clear_shapes()
	get_node("Anim").play("fade_out")

func _on_body_enter(body):
	if (Factions.is_enemy(faction,body.faction)):
		if (body.has_method("damage")):
			body.damage(get_global_pos(),dt,dmg,disable,heat)
			lv = body.get_lv()
			var pi = Equipment.outfits[type]["particles_impact"].instance()
			body.add_child(pi)
			pi.set_global_pos(get_global_pos())
			disable()

func search_target():
	var dist = 100000000
	for t in get_node("/root/Main").ships:
		if (Factions.is_enemy(faction,t.faction) && t.faction!=Factions.NEUTRAL):
			var dist2 = get_global_pos().distance_squared_to(t.get_global_pos())*(0.5+Vector2(0,-1.0).rotated(get_rot()).angle_to(t.get_global_pos()-get_global_pos()))
			if (dist2<dist):
				dist2 = dist
				target = t

func _fixed_process(delta):
	if (not disabled and target!=null):
		if !(target in get_node("/root/Main").ships):
			target = null
		else:
			var dir = (Vector2(-1,0).rotated(get_rot()))
			var s = sign((target.get_global_pos()+target.get_lv()-get_global_pos()-lv).dot(dir))
			lv += delta*a*s*dir
			get_node("Particles").set_param(Particles2D.PARAM_INITIAL_ANGLE,(Vector2(0,0)).angle_to_point(Vector2(0,-1).rotated(get_rot())+0.05*s*dir)*180.0/PI)
	
	set_pos(get_pos()+delta*lv)

func _ready():
	get_node("Particles").set_initial_velocity(lv-Vector2(0,-600.0).rotated(get_rot()))
	get_node("Particles").set_param(Particles2D.PARAM_INITIAL_ANGLE,get_rot()*180.0/PI)
	search_target()
	
	set_fixed_process(true)
