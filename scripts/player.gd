
extends "res://scripts/ship_base.gd"

var weapon_group_selected = 0
var shake = 0.0
var shake_disable = 0.0

var nav_point = load("res://scenes/hud/nav.tscn")


func destroyed():
	set_process_input(false)

func damaged(pos,type,dmg,disable,heat):
	shake += 100.0*dmg/hp_max
	shake_disable += 0.1*min(disable,sp_max/10.0)/max(sp,sp_max/4.0)

func select_missile(m):
	if (missile_selected==m):
		return
	HUD.get_node("Target").hide()
	if (num_missiles<=m):
		missile_selected = -1
		missile_locked = false
		missile_lock = 0.0
		missile_target = null
		return
	
	missile_selected = m
	missile_locked = false
	missile_lock = missile_tt[missile_selected]
	missile_cd = missile_st[missile_selected]
	
	for i in range(missile_selected)+range(missile_selected+1,num_missiles):
		HUD.get_node("Weapons/VBoxContainer/Missile"+str(i+1)+"/Selected").hide()
		HUD.get_node("Weapons/VBoxContainer/Missile"+str(i+1)+"/Targetting").set_value(0.0)
		HUD.get_node("Weapons/VBoxContainer/Missile"+str(i+1)+"/Time").set_value(0.0)
	HUD.get_node("Weapons/VBoxContainer/Missile"+str(missile_selected+1)+"/Selected").show()

func change_weapon_group():
	for i in range(num_weapons):
		if (Player.weapon_group[weapon_group_selected][i]):
			HUD.get_node("Weapons/VBoxContainer/Weapon"+str(i+1)+"/Selected").show()
		else:
			HUD.get_node("Weapons/VBoxContainer/Weapon"+str(i+1)+"/Selected").hide()
	for i in range(num_turrets):
		var active = Player.weapon_group[weapon_group_selected][num_weapons+i]
		get_node("Turret"+str(i+1)+"/Turret").active = active
		if (active):
			HUD.get_node("Weapons/VBoxContainer/Turret"+str(i+1)+"/Selected").show()
		else:
			HUD.get_node("Weapons/VBoxContainer/Turret"+str(i+1)+"/Selected").hide()

func start_boarding():
	if (boarding):
		return
	
	HUD.get_node("Boarding").enemy = board_target
	HUD.get_node("Boarding")._start(true)
	boarding = true

func enable_autopilot():
	if (nav.size()<1):
		return
	
	ap = true
	last_collider = null
	evading = false
	Player.time_speedup = true

func disable_autopilot():
	ap = false
	for n in nav:
		n.queue_free()
	nav.clear()
	last_collider = null
	evading = false
	Player.time_speedup = false

func autopilot(delta):
	# auto pilot
	if (ap):
		var tpos = nav[0].get_global_pos()
		var tlv = nav[0].get_lv()
		
		get_node("/root/Main/Pos").set_pos(tpos)
		
		var pos = get_global_pos()
		var lv = get_linear_velocity()-tlv
		var d = (tpos-pos).length()
		var v = lv.dot((tpos-pos)/d)
		var t = d/max(v,d/10.0)
		if (v<0):
			t += abs(v)/la
		var damp = max(1-damping*t,0)
		var s = (t-damp*abs(v)/la-PI/ts)
		var target_lv = s*(tpos-pos)/t-t*(lv-abs(v)*(tpos-pos)/d)
		var ang = Vector2(0,-1).rotated(get_rot()).angle_to(target_lv)
		if (abs(ang)<0.01):
			thrust = true
		else:
			thrust = false
		rotate = -min(abs(ang)/(ts*delta),1)*sign(ang)
		if (s<0):
			Player.time_speedup = false
		if (dock>=0):
			if (d<50 && abs(v)<20 && nav.size()<2):
				disable_autopilot()
				Stations.player_land(station,dock)
				thrust = false
				rotate = 0
				return
		elif (d<125 && abs(v)<30):
			nav[0].queue_free()
			nav.remove(0)
			if (nav.size()<1):
				disable_autopilot()
	else:
		if (!HUD.map && !disabled):
			var ang = get_local_mouse_pos().angle()
			rotate = 1.0*sign(ang)
			ang = PI-ang
			rotate *= min(min(abs(ang),abs(abs(ang)-2*PI)),1)
		else:
			rotate = 0

func hud(delta):
	var zoom = Input.is_action_pressed("zoom_out")-Input.is_action_pressed("zoom_in")
	var shake_pos = shake*sin(100.0*time)*Vector2(1,0).rotated(get_rot())
	var shake_width = shake_disable*cos(45.7*time)*Vector2(0,1).rotated(get_rot())
	var noise_alpha = 0.75*max(0.75-hp/hp_max,0.0)
	var bw_alpha = 2.0*max(0.5-hp/hp_max,0.0)
	noise_alpha *= noise_alpha
	shake -= 100.0*delta
	if (shake<0.0):
		shake = 0.0
	shake_disable -= 0.1*delta
	if (shake_disable<0.005*(1.0-sp/sp_max)+0.001*(1.0-hp/hp_max)):
		shake_disable = 0.005*(1.0-sp/sp_max)+0.001*(1.0-hp/hp_max)
	
	get_node("/root/Main/Camera").set_pos(get_global_pos()+shake_pos)
	get_node("/root/Main/Camera").set_zoom(clamp(get_node("/root/Main/Camera").get_zoom().x*(1.0+delta*zoom),1.0,10.0)*Vector2(1.0,1.0))
	get_node("/root/Main/Camera/BackBufferCopy").set_rect(Rect2(-OS.get_video_mode_size()/2.0*get_node("/root/Main/Camera").get_zoom(),OS.get_video_mode_size()/2.0*get_node("/root/Main/Camera").get_zoom()))
	get_node("/root/Main/Camera/BackBufferCopy/Sprite").get_material().set_shader_param("offset_r", shake_width)
	get_node("/root/Main/Camera/BackBufferCopy/Sprite").get_material().set_shader_param("offset_b",-shake_width)
	get_node("/root/Main/Camera/BackBufferCopy/Sprite").get_material().set_shader_param("noise_alpha",noise_alpha)
	get_node("/root/Main/Camera/BackBufferCopy/Sprite").set_pos(-OS.get_video_mode_size()/2.0*get_node("/root/Main/Camera").get_zoom())
	get_node("/root/Main/Camera/BackBufferCopy/Sprite").set_size(OS.get_video_mode_size()*get_node("/root/Main/Camera").get_zoom())
	get_node("/root/Main/Camera/BackBufferCopy/Sprite").get_material().set_shader_param("bw_alpha",bw_alpha)
	
	for i in range(num_weapons):
		HUD.get_node("Weapons/VBoxContainer/Weapon"+str(i+1)+"/SP").set_value(weapon_sp[i])
		HUD.get_node("Weapons/VBoxContainer/Weapon"+str(i+1)+"/Time").set_value(weapon_st[i]-weapon_cd[i])
		HUD.get_node("Weapons/VBoxContainer/Weapon"+str(i+1)+"/Temp").set_value(weapon_temp[i])
	for i in range(num_turrets):
		var turret = get_node("Turret"+str(i+1)+"/Turret")
		HUD.get_node("Weapons/VBoxContainer/Turret"+str(i+1)+"/SP").set_value(turret.sp)
		HUD.get_node("Weapons/VBoxContainer/Turret"+str(i+1)+"/Time").set_value(turret.st-turret.cd)
		HUD.get_node("Weapons/VBoxContainer/Turret"+str(i+1)+"/Temp").set_value(turret.temp)
	for i in range(num_missiles):
		if (missile_selected==i):
			HUD.get_node("Weapons/VBoxContainer/Missile"+str(i+1)+"/Targetting").set_value(missile_tt[i]-missile_lock)
			HUD.get_node("Weapons/VBoxContainer/Missile"+str(i+1)+"/Time").set_value(missile_st[i]-missile_cd)
		HUD.get_node("Weapons/VBoxContainer/Missile"+str(i+1)+"/Ammo").set_value(missile_ammo[i])
	
	HUD.get_node("Status/Outlines/Base").set_modulate(Color(disabled,1-disabled,0.0))
	if (ep+steering_power<0.0):
		HUD.get_node("Status/Outlines/Base/Energy").show()
	else:
		HUD.get_node("Status/Outlines/Base/Energy").hide()
	for i in range(num_reactors):
		if (!reactor_disabled[i]):
			HUD.get_node("Status/Outlines/Reactor"+str(i+1)+"/Disabled").hide()
			if (reactor_overheating[i]):
				HUD.get_node("Status/Outlines/Reactor"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Reactor"+str(i+1)+"/Temp").show()
			else:
				HUD.get_node("Status/Outlines/Reactor"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Reactor"+str(i+1)+"/Temp").hide()
		else:
			HUD.get_node("Status/Outlines/Reactor"+str(i+1)).set_modulate(Color(1.0,0.0,0.0))
			HUD.get_node("Status/Outlines/Reactor"+str(i+1)+"/Disabled").show()
			HUD.get_node("Status/Outlines/Reactor"+str(i+1)+"/Temp").hide()
	for i in range(num_internal):
		if (!internal_disabled[i]):
			HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Disabled").hide()
			if (internal_overheating[i]):
				HUD.get_node("Status/Outlines/Internal"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Temp").show()
			else:
				HUD.get_node("Status/Outlines/Internal"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Temp").hide()
			if (internal_no_power[i]):
				HUD.get_node("Status/Outlines/Internal"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Energy").show()
			else:
				if (!internal_overheating[i]):
					HUD.get_node("Status/Outlines/Internal"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Energy").hide()
		else:
			HUD.get_node("Status/Outlines/Internal"+str(i+1)).set_modulate(Color(1.0,0.0,0.0))
			HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Disabled").show()
			HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Energy").hide()
			HUD.get_node("Status/Outlines/Internal"+str(i+1)+"/Temp").hide()
	for i in range(num_external):
		if (!external_disabled[i]):
			HUD.get_node("Status/Outlines/External"+str(i+1)+"/Disabled").hide()
			if (external_overheating[i]):
				HUD.get_node("Status/Outlines/External"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/External"+str(i+1)+"/Temp").show()
			else:
				HUD.get_node("Status/Outlines/External"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/External"+str(i+1)+"/Temp").hide()
			if (external_no_power[i]):
				HUD.get_node("Status/Outlines/External"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/External"+str(i+1)+"/Energy").show()
			else:
				if (!external_overheating[i]):
					HUD.get_node("Status/Outlines/External"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/External"+str(i+1)+"/Energy").hide()
		else:
			HUD.get_node("Status/Outlines/External"+str(i+1)).set_modulate(Color(1.0,0.0,0.0))
			HUD.get_node("Status/Outlines/External"+str(i+1)+"/Disabled").show()
			HUD.get_node("Status/Outlines/External"+str(i+1)+"/Energy").hide()
			HUD.get_node("Status/Outlines/External"+str(i+1)+"/Temp").hide()
	for i in range(num_engines):
		if (!engine_disabled[i]):
			HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Disabled").hide()
			if (temp+delta*thrust_heat>temp_max):
				HUD.get_node("Status/Outlines/Engine"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Temp").show()
			else:
				HUD.get_node("Status/Outlines/Engine"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Temp").hide()
			if (ep+delta*thrust_power<0.0):
				HUD.get_node("Status/Outlines/Engine"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Energy").show()
			else:
				if (temp+delta*thrust_heat<temp_max):
					HUD.get_node("Status/Outlines/Engine"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Energy").hide()
		else:
			HUD.get_node("Status/Outlines/Engine"+str(i+1)).set_modulate(Color(1.0,0.0,0.0))
			HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Disabled").show()
			HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Energy").hide()
			HUD.get_node("Status/Outlines/Engine"+str(i+1)+"/Temp").hide()
	for i in range(num_weapons):
		if (!weapon_disabled[i]):
			HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Disabled").hide()
			if (ep+weapon_ep[i]<0.0):
				HUD.get_node("Status/Outlines/Weapon"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Energy").show()
			else:
				HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Energy").hide()
				HUD.get_node("Status/Outlines/Weapon"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
			if (weapon_temp[i]+weapon_heat[i]>weapon_max_temp[i] || temp+weapon_heat[i]>temp_max):
				HUD.get_node("Status/Outlines/Weapon"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Temp").show()
			else:
				if (ep+weapon_ep[i]>0.0):
					HUD.get_node("Status/Outlines/Weapon"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Temp").hide()
		else:
			HUD.get_node("Status/Outlines/Weapon"+str(i+1)).set_modulate(Color(1.0,0.0,0.0))
			HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Disabled").show()
			HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Energy").hide()
			HUD.get_node("Status/Outlines/Weapon"+str(i+1)+"/Temp").hide()
	for i in range(num_turrets):
		var turret = get_node("Turret"+str(i+1)+"/Turret")
		if (!turret.disabled):
			HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Disabled").hide()
			if (ep+turret.ep<0.0):
				HUD.get_node("Status/Outlines/Turret"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Energy").show()
			else:
				HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Energy").hide()
				HUD.get_node("Status/Outlines/Turret"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
			if (turret.temp+turret.heat>turret.max_temp || temp>temp_max):
				HUD.get_node("Status/Outlines/Turret"+str(i+1)).set_modulate(Color(1.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Temp").show()
			else:
				if (ep+turret.ep>0.0):
					HUD.get_node("Status/Outlines/Turret"+str(i+1)).set_modulate(Color(0.0,1.0,0.0))
				HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Temp").hide()
		else:
			HUD.get_node("Status/Outlines/Turret"+str(i+1)).set_modulate(Color(1.0,0.0,0.0))
			HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Disabled").show()
			HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Energy").hide()
			HUD.get_node("Status/Outlines/Turret"+str(i+1)+"/Temp").hide()
	
	HUD.get_node("Status/VBoxContainer/HP/HP").set_value(hp)
	HUD.get_node("Status/VBoxContainer/HP/HP").set_max(hp_max)
	HUD.get_node("Status/VBoxContainer/HP/Text").set_text(str(round(hp))+Equipment.units["armor"]+" / "+str(round(hp_max))+Equipment.units["armor"])
	HUD.get_node("Status/VBoxContainer/EP/EP").set_value(ep)
	HUD.get_node("Status/VBoxContainer/EP/EP").set_max(ep_max)
	HUD.get_node("Status/VBoxContainer/EP/Text").set_text(str(round(ep))+Equipment.units["energy"]+" / "+str(round(ep_max))+Equipment.units["energy"])
	HUD.get_node("Status/VBoxContainer/Temp/Temp").set_value(temp)
	HUD.get_node("Status/VBoxContainer/Temp/Temp").set_max(temp_max)
	HUD.get_node("Status/VBoxContainer/Temp/Text").set_text(str(round(temp))+Equipment.units["max_temperature"]+" / "+str(round(temp_max))+Equipment.units["max_temperature"])
	HUD.get_node("Status/VBoxContainer/Disable/Disable").set_value(sp)
	HUD.get_node("Status/VBoxContainer/Disable/Disable").set_max(sp_max)
	HUD.get_node("Status/VBoxContainer/Disable/Text").set_text(str(round(sp))+Equipment.units["sp"]+" / "+str(round(sp_max))+Equipment.units["sp"])

func _input(event):
	var s = (Input.is_action_pressed("shoot") || (Input.is_action_pressed("LMB") && !HUD.map))
	for i in range(num_weapons):
		shoot[i] = s && Player.weapon_group[weapon_group_selected][i]
	launch_missile = (Input.is_action_pressed("RMB") && !HUD.map || Input.is_action_pressed("launch_missile"))
	if (s || launch_missile):
		disable_autopilot()
	if (Input.is_action_pressed("thrust") || Input.is_action_pressed("reverse_thrust")):
		disable_autopilot()
	if (!ap):
		thrust = Input.is_action_pressed("thrust")*(1-disabled)
		reverse_thrust = Input.is_action_pressed("reverse_thrust")*(1-disabled)
	
	if (Input.is_action_pressed("shoot_at_me")):
		var ang = 2*PI*randf()
		var dir = Vector2(0,-1).rotated(ang)
		var pos = get_global_pos()-dir*rand_range(400,1000)
		var node = Position2D.new()
		node.set_pos(pos)
		node.set_rot(ang)
		get_node("/root/Main").add_child(node)
		Weapons.shoot("paa",node,1.0,dir,ang,get_lv(),Factions.ENEMY)
	
	if (event.is_pressed()):
		if(event.is_action_pressed("RMB") && HUD.map):
			var pos = (get_global_mouse_pos()-get_global_pos())/get_node("/root/Main/Camera").get_zoom()/(HUD.map_scale*HUD.map_zoom)-HUD.map_center/(HUD.map_zoom*HUD.map_scale)
			var ni = nav_point.instance()
			target = null
			ni.set_pos(pos)
			get_node("/root/Main").add_child(ni)
			if (!Input.is_action_pressed("shift")):
				for n in nav:
					n.queue_free()
				nav.clear()
			nav.push_back(ni)
			if (dock>=0):
				get_node("/root/Main/"+station).docked[dock] = false
			dock = -1
			station = null
			enable_autopilot()
		elif (event.is_action_pressed("land")):
			var pos = get_global_mouse_pos()
			var dist = 1000000000
			if (dock>=0):
				get_node("/root/Main/"+station).docked[dock] = false
			station = null
			for s in Stations.stations:
				var dist2 = pos.distance_squared_to(get_node("/root/Main/"+s).get_global_pos())
				if (dist2<dist):
					dist = dist2
					station = s
			if (station!=null):
				disable_autopilot()
				var ni = nav_point.instance()
				dock = get_node("/root/Main/"+station).request_landing_position()		# reserve docking slot
				if (dock<0):
					return
				target = null
				get_node("/root/Main/"+station).add_child(ni)
				ni.set_global_pos(get_node("/root/Main/"+station+"/Position"+str(dock)).get_global_pos())
				nav.resize(1)
				nav[0] = ni
				docking = false
				enable_autopilot()
		elif (event.is_action_pressed("board")):
			disable_autopilot()
			if (boarding):
				HUD.get_node("Boarding")._player_undock()
			else:
				disable_grappling_hook()
				var pos = get_global_mouse_pos()
				var dist = 100000
				board_target = null
				for s in get_node("/root/Main").ships:
					if (s.disabled):
						var dist2 = pos.distance_squared_to(s.get_global_pos())
						if (dist2<dist):
							dist = dist2
							board_target = s
				if (board_target!=null):
					board = true
		elif (event.is_action_pressed("missile_cycle_up")):
			select_next_missile()
		elif (event.is_action_pressed("missile_cycle_dn")):
			select_prev_missile()
		elif (event.is_action_pressed("zoom_in")):
			get_node("/root/Main/Camera").set_zoom(clamp(get_node("/root/Main/Camera").get_zoom().x*0.9,1.0,10.0)*Vector2(1.0,1.0))
		elif (event.is_action_pressed("zoom_out")):
			get_node("/root/Main/Camera").set_zoom(clamp(get_node("/root/Main/Camera").get_zoom().x*1.1,1.0,10.0)*Vector2(1.0,1.0))
		elif (event.is_action_pressed("weapon_group_1")):
			weapon_group_selected = 0
			change_weapon_group()
		elif (event.is_action_pressed("weapon_group_2")):
			weapon_group_selected = 1
			change_weapon_group()
		elif (event.is_action_pressed("weapon_group_3")):
			weapon_group_selected = 2
			change_weapon_group()
		elif (event.is_action_pressed("weapon_group_4")):
			weapon_group_selected = 3
			change_weapon_group()
	elif (event.type==InputEvent.MOUSE_MOTION && missile_selected>=0 && missile_tt[missile_selected]>0.0 && missile_ammo[missile_selected]>0):
		var dist = 50000
		missile_target = null
		for t in get_node("/root/Main").ships:
			if (Factions.is_enemy(faction,t.faction) && t.faction!=Factions.NEUTRAL):
				var dist2 = get_global_mouse_pos().distance_squared_to(t.get_global_pos())/(get_node("/root/Main/Camera").get_zoom().x*get_node("/root/Main/Camera").get_zoom().x)
				if (dist2<dist):
					dist = dist2
					missile_target = t
		if (missile_target!=missile_target_old && missile_type.size()>0):
			missile_lock = missile_tt[missile_selected]
			missile_locked = false
		if (missile_target!=null):
			var size = missile_target.get_node("Sprite").get_texture().get_size()/get_node("/root/Main/Camera").get_zoom()/2.0
			size = max(max(size.x,size.y),80.0)
			HUD.get_node("Target/Up").set_pos(Vector2(0,-size))
			HUD.get_node("Target/Down").set_pos(Vector2(0,size))
			HUD.get_node("Target/Right").set_pos(Vector2(size,0))
			HUD.get_node("Target/Left").set_pos(Vector2(-size,0))
			HUD.get_node("Target").show()
		else:
			HUD.get_node("Target").hide()

func targeting():
	HUD.get_node("Target").set_pos((missile_target.get_global_pos()-get_node("/root/Main/Camera").get_camera_pos())/get_node("/root/Main/Camera").get_zoom()+OS.get_video_mode_size()/2.0)
	for s in ["Up","Right","Down","Left"]:
		HUD.get_node("Target/"+s).set_offset(Vector2(0,16.0-64.0*missile_lock/missile_tt[missile_selected]))

func target_locked():
	HUD.get_node("Target/Anim").play("missile_lock")

func target_lost():
	HUD.get_node("Target").hide()

func init():
	connect("targeting",self,"targeting")
	connect("target_locked",self,"target_locked")
	connect("target_lost",self,"target_lost")
	
	icon = HUD.get_node("Map/Map/Player")
