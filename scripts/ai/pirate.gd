
extends "res://scripts/ship_base.gd"

# simple AI that attacks all hostile objects

var tmr
var range_min = 100000


func destroyed():
	icon.queue_free()

func search_target():
	var pos = get_global_pos()
	var dist = 10000000
	var target_old = target
	missile_target = null
	launch_missile = false
	for t in get_node("/root/Main").ships:
		if (Factions.is_enemy(faction,t.faction) && t.faction!=Factions.NEUTRAL):
			var dist2 = pos.distance_squared_to(t.get_global_pos())
			if (dist2<dist):
				dist2 = dist
				target = t
	if (target!=null):
		if (target!=target_old && missile_type.size()>0):
			missile_lock = missile_tt[missile_selected]
			missile_locked = false
		missile_target = target
		nav.clear()
		evading = false

func autopilot(delta):
	var pos = get_global_pos()
	launch_missile = false
	for i in range(num_weapons):
		shoot[i] = false
	
	if (target==null || !(target in get_node("/root/Main").ships)):
		target = null
		search_target()
		if (target==null):
			return
	
	var attacking = false
	var tpos = nav
	var tlv = Vector2(0,0)
	if (nav.size()>0):
		tpos = nav[0]
	elif (target!=null):
		tpos = target.get_global_pos()
		tlv = target.get_lv()
		attacking = true
	elif (dock!=null):
		tpos = get_node("/root/Main/"+station+"/Position"+str(dock)+["/Position",""][int(docking)]).get_global_pos()
		tlv = get_node("/root/Main/"+station).get_lv()
	
	var lv = get_linear_velocity()-tlv
	var d = pos.distance_to(tpos)
	var v = lv.dot((tpos-pos)/d)
	var t
	var target_lv
	var ang = 0.0
	
	if (nav.size()>0):
		if (d<500):
			nav.pop_front()
		else:
			t = d/max(v,d/10.0)
			target_lv = (t-max(1-damping*t,0)*abs(v)*v/la-PI/ts)*(tpos-pos)/t-t*(lv-v*(tpos-pos)/d)
			ang = Vector2(0,-1).rotated(get_rot()).angle_to(target_lv)
			reverse_thrust = false
	elif (attacking):
		var ang2 = abs(Vector2(0,-1).rotated(get_rot()).angle_to(tpos-pos))
		t = d/max(v,d/10.0)
		if (d<400):
			tpos += 10*(tpos-pos).rotated(-ang2)
			target_lv = (t-0.5*v/la-PI/ts)*(tpos-pos)/t-t*(lv-v*(tpos-pos)/d)
			ang = Vector2(0,-1).rotated(get_rot()).angle_to(target_lv)
			reverse_thrust = false
		elif (d<2000):
			target_lv = tpos-pos-t*(lv-(v+average_weapon_speed)*(tpos-pos)/d)
			ang = Vector2(0,-1).rotated(get_rot()).angle_to(target_lv)
			reverse_thrust = d-v*t<0.8*range_min
		else:
			if (v<0):
				t += abs(v)/la
			target_lv = (t-max(1-damping*t,0)*abs(v)/la-PI/ts)*(tpos-pos)/t-t*(lv-abs(v)*(tpos-pos)/d)
			ang = Vector2(0,-1).rotated(get_rot()).angle_to(target_lv)
		if (abs(ang)<0.1 && ang2<0.5 && d<2000):
			for i in range(num_weapons):
				if (d-v*weapon_time[i]<weapon_range[i]):
					shoot[i] = true
			if (missile_type.size()>0 && d<missile_range[missile_selected]):
				launch_missile = missile_locked
				if (missile_selected<0 || missile_ammo[missile_selected]==0):
					select_next_missile()
	else:
		var t = d/max(v,d/10.0)
		if (v<0):
			t += abs(v)/la
		target_lv = (t-max(1-damping*t,0)*abs(v)/la-PI/ts)*(tpos-pos)/t-t*(lv-abs(v)*(tpos-pos)/d)
		ang = Vector2(0,-1).rotated(get_rot()).angle_to(target_lv)
		reverse_thrust = false
	if (abs(ang)<0.1):
		thrust = true
		rotate = 0
	else:
		rotate = -min(abs(ang)/(ts*delta),1)*sign(ang)
		thrust = false
	if (dock!=null && d<25 && v<50):
		docking = true
	thrust = thrust && !reverse_thrust

func init():
	tmr = Timer.new()
	tmr.set_wait_time(4.0)
	tmr.connect("timeout",self,"search_target")
	add_child(tmr)
	tmr.start()
	
	for i in range(num_weapons):
		if (weapon_range[i]<range_min):
			range_min = weapon_range[i]
	
	last_collider = null
	evading = false
	
	var ii = Sprite.new()
	ii.set_texture(load("res://images/icons/icon_pirate.png"))
	ii.set_name(get_name())
	HUD.get_node("Map/Map").add_child(ii)
	ii.hide()
	icon = ii
