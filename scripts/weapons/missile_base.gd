
extends Area2D
# base guided missile script

var type = 1
var dt = 1
var dmg = 5.0
var disable = 2.0
var heat = 2.0
var hp = 5.0
var faction = 0
var dir = Vector2(0,0)
var lv = Vector2(0,0)
var a = 0.0
var damping = 0.0
var target
var disabled = false

func disable():
	if (disabled):
		return
	
	disabled = true
	get_node("/root/Main").missiles.erase(self)
	clear_shapes()
	get_node("Anim").play("fade_out")

func damage(pos,type,dmg,disable,heat):
	hp -= dmg
	if (hp<=0):
		disable()

func get_lv():
	return lv

func _on_body_enter(body):
	if (!Factions.is_enemy(faction,body.faction)):
		return
	
	if (body.has_method("damage")):
		body.damage(get_global_pos(),dt,dmg,disable,heat)
		lv = body.get_lv()
		var pi = Equipment.outfits[type]["particles_impact"].instance()
		body.add_child(pi)
		pi.set_global_pos(get_global_pos())
		disable()

func _fixed_process(delta):
	if (!disabled && target!=null):
		if !(target in get_node("/root/Main").ships):
			target = null
		else:
			var pos = get_global_pos()
			var tpos = target.get_global_pos()
			var tlv = target.get_lv()
			var d = (tpos-pos).length()
			var v = (lv-tlv).dot((tpos-pos)/d)
			var t = d/max(v,d/10.0)
			if (v<0):
				t += abs(v)/a
			var target_lv = tpos-pos-10.0*t*(lv-tlv-abs(v)*(tpos-pos)/d)
			var dir = target_lv.normalized()
			lv += delta*a*dir
			set_rot(PI+dir.angle())
			get_node("Particles").set_param(Particles2D.PARAM_INITIAL_ANGLE,rad2deg(Vector2(0,0).angle_to_point(lv)))
			get_node("Particles").set_initial_velocity(lv)
	
	lv *= 1.0-damping*delta
	set_pos(get_pos()+delta*lv)

func _ready():
	get_node("Particles").set_param(Particles2D.PARAM_INITIAL_ANGLE,rad2deg(Vector2(0,0).angle_to_point(lv)))
	get_node("Particles").set_initial_velocity(lv)
	set_fixed_process(true)
	get_node("/root/Main").missiles.push_back(self)
