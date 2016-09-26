
extends Node2D
# turret that attacks only missiles

var av = 2
var type = ""
var sp = 0
var sp_max = 0
var sr = 0
var ep = 0
var temp = 0
var heat = 0
var max_temp = 0
var heat_dissipation = 0
var time = 0
var cd = 0
var st = 0
var speed = 0
var rays = 0
var target
var disabled = false
var range_max = 0
var last_dist = 0
var ap = true
var active = true

func get_lv():
	return get_node("../../").get_lv()

func find_target():
	var dist = range_max*range_max+1000000
	var pos = get_global_pos()
	target = null
	for t in get_node("/root/Main").missiles:
		if (get_node("/root/Factions").is_enemy(get_node("../../").faction,t.faction)):
			var dist2 = pos.distance_squared_to(t.get_global_pos())+1000*t.hp
			if (dist2<dist):
				dist2 = dist
				target = t
				ap = true

func _process(delta):
	var pos = get_global_pos()
	var shoot = false
	var rotate = 0
	var ang = 0
	var dir = Vector2(0,-1).rotated(get_node("../../").get_rot()+get_rot())
	
	sp += delta*sr
	if (sp>sp_max):
		sp = sp_max
		if (disabled):
			get_node("../../").status_changed = true
		disabled = false
	var t = delta*heat_dissipation*temp
	temp -= t
	cd -= delta
	get_node("../../").temp += t/get_node("../../").mass
	
	if (target!=null && pos.distance_squared_to(target.get_global_pos())<4.0*range_max*range_max):
		var tpos = target.get_global_pos()
		var tlv = target.get_lv()
		var d = pos.distance_to(tpos)
		ang = (Vector2(0,-1).rotated(get_node("../../").get_rot()+get_rot())).angle_to(pos-tpos)+rand_range(-0.01,0.01)
		if (abs(ang)<0.15 || abs(ang)>3.05):
			shoot = active && !get_node("../../").boarding
		rotate = -sign(ang)
		
		if ((last_dist<d && ap) || !(target in get_node("/root/Main").missiles)):
			ap = false
			find_target()
		last_dist = d
	else:
		find_target()
	
	set_rot(get_rot()+min(av*delta,abs(ang))*rotate)
	
	if (shoot):
		if (!disabled && cd<=0.0 && get_node("../../").ep+ep>0.0 && temp+heat<max_temp && get_node("../../").temp<get_node("../../").temp_max):
			for i in range(1,rays+1):
				get_node("/root/Weapons").shoot(type,get_node("Gun"+str(i)),temp/max_temp+0.75,dir,get_node("../../").get_rot()+get_rot(),get_node("../../").get_lv(),get_node("../../").faction)
			get_node("../../").ep += ep
			temp += heat
			cd = st

func _ready():
	sp = sp_max
	set_process(true)
