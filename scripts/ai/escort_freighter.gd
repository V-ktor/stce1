
extends "res://scripts/ship_base.gd"

# simple AI that flies and lands on a station

var tmr
var range_min = 100000
var type = "trader"
var leader


func destroyed():
	icon.queue_free()

func search_target():
	var pos = get_global_pos()
	var dist = 2500000
	var target_old = target
	target = null
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
		evading = false

func autopilot(delta):
	if (!ap):
		return
	
	var pos = get_global_pos()
	launch_missile = false
	for i in range(num_weapons):
		shoot[i] = false
	
	var attacking = false
	var tlv = Vector2(0,0)
	var tpos
	if (pos.distance_squared_to(leader.get_global_pos())>10000000):
		tpos = leader.get_global_pos()
		tlv = leader.get_lv()
	elif (target!=null):
		if !(target in get_node("/root/Main").ships):
			search_target()
			return
		tpos = target.get_global_pos()
		tlv = target.get_lv()
		attacking = true
	elif (dock>=0):
		tpos = get_node("/root/Main/"+station+"/Position"+str(dock)).get_global_pos()
		tlv = get_node("/root/Main/"+station).get_lv()
	elif (station!=""):
		tpos = get_node("/root/Main/"+station).get_global_pos()
		tlv = get_node("/root/Main/"+station).get_lv()
	
	var lv = get_linear_velocity()-tlv
	var d = pos.distance_to(tpos)
	var v = lv.dot((tpos-pos)/d)
	var t
	var target_lv
	var ang = 0.0
	
	if (attacking):
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
	if (dock<0 && d<1000):
		dock = get_node("/root/Main/"+station).request_landing_position()
	elif (d<50 && v<20):
		disable_autopilot()
		Stations.land(station,dock,self)
		thrust = false
		rotate = 0
		return
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
	
	ap = true
	last_collider = null
	evading = false
	
	var ii = Sprite.new()
	ii.set_texture(load("res://images/icons/icon_civil_trader.png"))
	ii.set_name(get_name())
	HUD.get_node("Map/Map").add_child(ii)
	ii.hide()
	icon = ii
