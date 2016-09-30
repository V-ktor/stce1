
extends RigidBody2D
# base script for ships

var ship_type = ""
var base = {}
var equipment = []
var inventory = []
var reactors = []
var engines = []
var internal = []
var external = []
var weapons = []
var turrets = []
var missiles = []
var num_reactors = 0
var num_engines = 0
var num_internal = 0
var num_external = 0
var num_weapons = 0
var num_turrets = 0
var num_missiles = 0
var mass = 10.0
var hp = 100
var hp_max = 100
var hr = 0.0
var sp = 50
var sp_max = 50
var sr = 1.0
var ep = 100
var ep_max = 100
var er = 0.0
var temp = 100
var temp_max = 1000
var heat = 50.0
var heat_dissipation = 0.05
var cargo = 0.0
var radar = 0.0
var stealth = 0.0
var crew = 0
var crew_min = 1
var la = 0.0
var thrust_power = 0.0
var thrust_heat = 0.0
var steering_power = 0.0
var steering_heat = 0.0
var ts = 2.5
var damping = 0.0
var resist_impact = 0.0
var resist_plasma = 0.0
var resist_explosive = 0.0
var average_weapon_speed = 0.0
var missile_cd = 0.0
var reactor_disabled = []
var reactor_overheating = []
var reactor_sp = []
var reactor_sp_max = []
var reactor_sr = []
var engine_disabled = []
var engine_sp = []
var engine_sp_max = []
var engine_sr = []
var internal_disabled = []
var internal_overheating = []
var internal_no_power = []
var internal_sp = []
var internal_sp_max = []
var internal_sr = []
var external_disabled = []
var external_overheating = []
var external_no_power = []
var external_sp = []
var external_sp_max = []
var external_sr = []
var weapon_disabled = []
var weapon_sp = []
var weapon_sp_max = []
var weapon_sr = []
var weapon_temp = []
var weapon_cd = []
var weapon_ep = []
var weapon_heat = []
var weapon_st = []
var weapon_max_temp = []
var weapon_time = []
var weapon_range = []
var weapon_hd = []
var missile_ammo = []
var missile_st = []
var missile_tt = []
var missile_type = []
var missile_range = []
var num_grappling_hooks = 1
var grappling_hook_speed = 750
var grappling_hook_range = 100
var grappling_hook_cd = 0
var grappling_hook_delay = 1.0
var attack_bonus = 1.0
var defense_bonus = 1.0
var credits = 0

var thrust = false
var reverse_thrust = false
var rotate = 0
var nav = []
var evading = false
var target
var dock = -1
var station
var docking = false
var ap = false
var disabled = false
var faction = 0
var destroyed = false
var missile_selected = -1
var missile_target
var missile_target_old
var missile_lock = 0.0
var missile_locked = false
var board_target
var boarding = false
var time = 0.0
var size = Vector2(0,0)
var last_collider
var shoot = []
var launch_missile = false
var board = false
var zoom = 1.0
var name = ""
var icon

var sparks = preload("res://scenes/particles/sparks.tscn")
var explosion = preload("res://scenes/particles/explosion.tscn")

func explode():
	if (destroyed):
		return
	
	destroyed = true
	disable_grappling_hook()
	set_process(false)
	clear_shapes()
	set_sleeping(true)
	get_node("/root/Main").ships.erase(self)
	
	for i in range(rand_range(0.05,0.1)*(size.x+size.y)):
		var ang = 2*PI*randf()
		var si = sparks.instance()
		si.lv = 0.75*get_lv()+Vector2(0,-rand_range(200,275)).rotated(ang)
		si.set_initial_velocity(0.5*get_lv()+0.25*si.lv)
		si.set_pos(get_global_pos())
		get_node("/root/Main").add_child(si)
	var ei = explosion.instance()
	ei.destroy_parent = true
	add_child(ei)
	
	emit_signal("destroyed")
	destroyed()

func destroyed():
	pass

func recalc():
	var v = Equipment.outfits[ship_type]
	for s in Equipment.stats:
		if (v.has(s)):
			base[s] = v[s]
		else:
			base[s] = 0
	
	weapons = []
	turrets = []
	missiles = []
	missile_ammo = []
	reactors = []
	engines = []
	internal = []
	external = []
	for eq in equipment:
		if (eq[Equipment.TYPE]!=""):
			var type = Equipment.outfits[eq[Equipment.TYPE]]["type"]
			if (type=="reactor"):
				reactors.push_back(eq[Equipment.TYPE])
			elif (type=="engine"):
				engines.push_back(eq[Equipment.TYPE])
			elif (type=="internal"):
				internal.push_back(eq[Equipment.TYPE])
			elif (type=="external"):
				external.push_back(eq[Equipment.TYPE])
			elif (type=="weapon"):
				weapons.push_back(eq[Equipment.TYPE])
			elif (type=="turret"):
				turrets.push_back(eq[Equipment.TYPE])
			elif (type=="missile"):
				missiles.push_back(eq[Equipment.TYPE])
				missile_ammo.push_back(eq[Equipment.AMMOUNT])
	num_reactors = reactors.size()
	num_engines = engines.size()
	num_internal = internal.size()
	num_external = external.size()
	num_weapons = weapons.size()
	num_turrets = turrets.size()
	num_missiles = missiles.size()
	
	reactor_disabled.resize(num_reactors)
	reactor_overheating.resize(num_reactors)
	reactor_sp.resize(num_reactors)
	reactor_sp_max.resize(num_reactors)
	reactor_sr.resize(num_reactors)
	for i in range(num_reactors):
		var v = Equipment.outfits[reactors[i]]
		reactor_disabled[i] = false
		reactor_overheating[i] = false
		reactor_sp[i] = v["sp"]
		reactor_sp_max[i] = v["sp"]
		reactor_sr[i] = v["stress_dissipation"]
		for s in Equipment.ship_stats:
			if (v.has(s)):
				base[s] += v[s]
	
	engine_disabled.resize(num_engines)
	engine_sp.resize(num_engines)
	engine_sp_max.resize(num_engines)
	engine_sr.resize(num_engines)
	for i in range(num_engines):
		var v = Equipment.outfits[engines[i]]
		engine_disabled[i] = false
		engine_sp[i] = v["sp"]
		engine_sp_max[i] = v["sp"]
		engine_sr[i] = v["stress_dissipation"]
		for s in Equipment.ship_stats:
			if (v.has(s)):
				base[s] += v[s]
	
	internal_disabled.resize(num_internal)
	internal_overheating.resize(num_internal)
	internal_no_power.resize(num_internal)
	internal_sp.resize(num_internal)
	internal_sp_max.resize(num_internal)
	internal_sr.resize(num_internal)
	for i in range(num_internal):
		var v = Equipment.outfits[internal[i]]
		internal_disabled[i] = false
		internal_overheating[i] = false
		internal_no_power[i] = false
		internal_sp[i] = v["sp"]
		internal_sp_max[i] = v["sp"]
		internal_sr[i] = v["stress_dissipation"]
		for s in Equipment.ship_stats:
			if (v.has(s)):
				base[s] += v[s]
	
	external_disabled.resize(num_external)
	external_overheating.resize(num_external)
	external_no_power.resize(num_external)
	external_sp.resize(num_external)
	external_sp_max.resize(num_external)
	external_sr.resize(num_external)
	for i in range(num_external):
		var v = Equipment.outfits[external[i]]
		external_disabled[i] = false
		external_overheating[i] = false
		external_no_power[i] = false
		external_sp[i] = v["sp"]
		external_sp_max[i] = v["sp"]
		external_sr[i] = v["stress_dissipation"]
		for s in Equipment.ship_stats:
			if (v.has(s)):
				base[s] += v[s]
	
	shoot.resize(num_weapons)
	weapon_disabled.resize(num_weapons)
	weapon_sp.resize(num_weapons)
	weapon_sp_max.resize(num_weapons)
	weapon_sr.resize(num_weapons)
	weapon_temp.resize(num_weapons)
	weapon_cd.resize(num_weapons)
	weapon_ep.resize(num_weapons)
	weapon_heat.resize(num_weapons)
	weapon_st.resize(num_weapons)
	weapon_max_temp.resize(num_weapons)
	weapon_time.resize(num_weapons)
	weapon_range.resize(num_weapons)
	weapon_hd.resize(num_weapons)
	average_weapon_speed = 0.0
	for i in range(num_weapons):
		var v = Equipment.outfits[weapons[i]]
		weapon_temp[i] = 0.0
		weapon_cd[i] = 0.0
		weapon_disabled[i] = false
		weapon_sp[i] = v["sp"]
		weapon_sp_max[i] = v["sp"]
		weapon_sr[i] = v["stress_dissipation"]
		weapon_ep[i] = v["firing_energy"]
		average_weapon_speed += v["speed"]
		weapon_sr[i] = v["stress_dissipation"]
		weapon_ep[i] = v["firing_energy"]
		weapon_heat[i] = v["firing_heat"]
		weapon_hd[i] = v["internal_heat_dissipation"]/100.0
		weapon_st[i] = v["reload_delay"]
		weapon_max_temp[i] = v["internal_max_temperature"]
		weapon_time[i] = v["life_time"]
		weapon_range[i] = v["range"]
		for s in Equipment.ship_stats:
			if (v.has(s)):
				base[s] += v[s]
	average_weapon_speed /= num_weapons
	
	for i in range(num_turrets):
		var v = Equipment.outfits[turrets[i]]
		for s in Equipment.ship_stats:
			if (v.has(s)):
				base[s] += v[s]
		if (get_node("Turret"+str(i+1)).has_node("Turret")):
			get_node("Turret"+str(i+1)+"/Turret").queue_free()
			get_node("Turret"+str(i+1)+"/Turret").set_name("deleted")
		var ti = Equipment.outfits[turrets[i]]["scene"].instance()
		ti.type = turrets[i]
		ti.sp_max = Equipment.outfits[ti.type]["sp"]
		ti.sr = Equipment.outfits[ti.type]["stress_dissipation"]
		ti.range_max = Equipment.outfits[ti.type]["range"]
		ti.max_temp = Equipment.outfits[ti.type]["internal_max_temperature"]
		ti.heat_dissipation = Equipment.outfits[ti.type]["internal_heat_dissipation"]/100.0
		ti.heat = Equipment.outfits[ti.type]["firing_heat"]
		ti.ep = Equipment.outfits[ti.type]["firing_energy"]
		ti.st = Equipment.outfits[ti.type]["reload_delay"]
		ti.av =  deg2rad(Equipment.outfits[ti.type]["rotation_speed"])
		ti.speed = Equipment.outfits[ti.type]["speed"]
		ti.rays = Equipment.outfits[ti.type]["rays"]
		get_node("Turret"+str(i+1)).add_child(ti)
	
	missile_selected = num_missiles-1
	missile_st.resize(num_missiles)
	missile_tt.resize(num_missiles)
	missile_type.resize(num_missiles)
	missile_range.resize(num_missiles)
	for i in range(num_missiles):
		var v = Equipment.outfits[missiles[i]]
		missile_type[i] = v["targetting_type"]
		if (missile_type[i]=="none"):
			missile_tt[i] = 0
		else:
			missile_tt[i] = v["targetting_time"]
		missile_range[i] = v["range"]
		missile_st[i] = v["reload_delay"]
		for s in Equipment.ship_stats:
			if (v.has(s)):
				base[s] += v[s]*missile_ammo[i]
	
	for i in inventory:
		base["mass"] += Equipment.outfits[i[Equipment.TYPE]]["mass"]*i[Equipment.AMMOUNT]
	
	update()

func update():
	var values = {}
	for s in base.keys():
		values[s] = base[s]
	for i in range(num_reactors):
		if (!reactor_disabled[i] && !reactor_overheating[i]):
			var v = Equipment.outfits[reactors[i]]
			for s in Equipment.stats:
				if (v.has(s+"_active")):
					values[s] += v[s+"_active"]
	for i in range(num_engines):
		if (!engine_disabled[i]):
			var v = Equipment.outfits[engines[i]]
			for s in Equipment.stats:
				if (v.has(s+"_active")):
					values[s] += v[s+"_active"]
	for i in range(num_internal):
		if (!internal_disabled[i] && !internal_overheating[i] && !internal_no_power[i]):
			var v = Equipment.outfits[internal[i]]
			for s in Equipment.stats:
				if (v.has(s+"_active")):
					values[s] += v[s+"_active"]
	for i in range(num_external):
		if (!external_disabled[i] && !external_overheating[i] && !external_no_power[i]):
			var v = Equipment.outfits[external[i]]
			for s in Equipment.stats:
				if (v.has(s+"_active")):
					values[s] += v[s+"_active"]
	
	mass = values["mass"]
	hp_max = values["armor"]
	hr = values["repair"]
	sp_max = values["sp"]
	sr = values["stress_dissipation"]
	ep_max = values["energy"]
	er = values["power"]
	temp_max = values["max_temperature"]
	heat = values["heat"]
	heat_dissipation = values["heat_dissipation"]/100.0
	la = values["thrust"]/mass
	thrust_power = values["thrust_power"]
	thrust_heat = values["thrust_heat"]
	ts = deg2rad(values["steering"])/mass
	steering_power = values["steering_power"]
	steering_heat = values["steering_heat"]
	damping = values["damping"]/100.0
	resist_impact = 1-exp(-values["resistance_impact"]/100.0)
	resist_plasma = 1-exp(-values["resistance_plasma"]/100.0)
	resist_explosive = 1-exp(-values["resistance_explosive"]/100.0)
	cargo = values["cargo_space"]
	radar = values["radar_range"]
	stealth = values["stealth"]
	crew_min = values["min_crew"]
	
	set_mass(mass)

func update_mass(new_mass):
	var factor = mass/new_mass
	
	la *= factor
	ts *= factor
	
	base["mass"] = new_mass
	mass = new_mass
	set_mass(mass)

func damage(pos,type,dmg,disable,heat):
	var status_changed = false
	hp -= dmg*(1.0-{"impact":resist_impact,"plasma":resist_plasma,"explosive":resist_explosive}[type])
	if (hp<0):
		hp = 0
		explode()
		return
	
	if (type=="plasma"):
		heat *= 1-0-resist_plasma
	temp += heat/mass
	
	var dis = 0.25*disable
	disable *= 0.75
	for i in range(num_external):
		var d = min(min(10*disable/max(pos.distance_to(get_node("External"+str(i+1)).get_global_pos()),1.0),external_sp[i]),disable)
		disable -= d
		external_sp[i] -= d
		if (external_sp[i]<=0.0):
			external_sp[i] = 0.0
			if (!external_disabled[i]):
				status_changed = true
			external_disabled[i] = true
	for i in range(num_turrets):
		var turret = get_node("Turret"+str(i+1)+"/Turret")
		var d = min(min(10*disable/max(pos.distance_to(turret.get_global_pos()),1.0),turret.sp),disable)
		disable -= d
		turret.sp -= d
		if (turret.sp<=0.0):
			turret.sp = 0.0
			if (!turret.disabled):
				status_changed = true
			turret.disabled = true
	for i in range(num_engines):
		var d = min(min(10*disable/max(pos.distance_to(get_node("Engine"+str(i+1)).get_global_pos()),1.0),engine_sp[i]),disable)
		disable -= d
		engine_sp[i] -= d
		if (engine_sp[i]<=0.0):
			engine_sp[i] = 0.0
			if (!engine_disabled[i]):
				status_changed = true
			engine_disabled[i] = true
	for i in range(num_weapons):
		var d = min(min(10*disable/max(pos.distance_to(get_node("Weapon"+str(i+1)).get_global_pos()),1.0),weapon_sp[i]),disable)
		disable -= d
		weapon_sp[i] -= d
		if (weapon_sp[i]<=0.0):
			weapon_sp[i] = 0.0
			if (!weapon_disabled[i]):
				status_changed = true
			weapon_disabled[i] = true
	for i in range(num_internal):
		var d = min(min(10*disable/max(pos.distance_to(get_node("Internal"+str(i+1)).get_global_pos()),1.0),internal_sp[i]),disable)
		disable -= d
		internal_sp[i] -= d
		if (internal_sp[i]<=0.0):
			internal_sp[i] = 0.0
			if (!internal_disabled[i]):
				status_changed = true
			internal_disabled[i] = true
	for i in range(num_reactors):
		var d = min(min(10*disable/max(pos.distance_to(get_node("Reactor"+str(i+1)).get_global_pos()),1.0),reactor_sp[i]),disable)
		disable -= d
		reactor_sp[i] -= d
		if (reactor_sp[i]<=0.0):
			reactor_sp[i] = 0.0
			if (!reactor_disabled[i]):
				status_changed = true
			reactor_disabled[i] = true
	sp -= dis+disable
	if (sp<=0.0):
		sp = 0.0
		missile_target = null
		disabled = true
		status_changed = true
	
	if (status_changed):
		update()
	damaged(pos,type,dmg,disable,heat)

func damaged(pos,type,dmg,disable,heat):
	pass

func get_lv():
	return get_linear_velocity()

func select_missile(m):
	if (missile_selected==m):
		return
	if (num_missiles<=m):
		missile_selected = -1
		missile_locked = false
		missile_lock = 0.0
		missile_target = null
		return
	
	missile_selected = m
	missile_locked = false
	missile_lock = missile_tt[missile_selected]
	missile_target = null

func select_next_missile():
	for i in range(missile_selected+1,num_missiles)+range(0,missile_selected):
		if (missile_ammo[i]>0):
			select_missile(i)
			return
	select_missile(-1)

func select_prev_missile():
	for i in range(missile_selected-1,-1,-1)+range(num_missiles-1,missile_selected,-1):
		if (missile_ammo[i]>0):
			select_missile(i)
			return
	select_missile(-1)

func disable_grappling_hook():
	for i in range(1,1+num_grappling_hooks):
		for c in get_node("GrapplingHook"+str(i)).get_children():
			c._detach()
	
	boarding = false

func start_boarding():
	pass

func enable_autopilot():
	if (nav.size()<1):
		return
	
	ap = true
#	get_node("RayCast").set_enabled(true)
	last_collider = null

func disable_autopilot():
	ap = false
	nav.clear()
#	get_node("RayCast").set_enabled(false)
	last_collider = null

func autopilot():
	pass

func hud(delta):
	pass

func _integrate_forces(state):
	if (destroyed):
		return
	
	var delta = state.get_step()
	var pos = get_global_pos()
	var rot = get_rot()
	var lv = state.get_linear_velocity()
	var av = 0.0
	var ht = heat
	var dir = Vector2(0,-1).rotated(rot)
	var wt = 0.0
	var status_changed = false
	
	hp += delta*hr
	if (hp>hp_max):
		hp = hp_max
	sp += delta*sr
	if (sp>sp_max):
		sp = sp_max
		if (!boarding):
			if (disabled):
				status_changed = true
			disabled = false
	for i in range(num_reactors):
		var overheating = temp>temp_max
		reactor_sp[i] += delta*reactor_sr[i]
		if (reactor_sp[i]>reactor_sp_max[i]):
			reactor_sp[i] = reactor_sp_max[i]
			if (reactor_disabled[i]):
				status_changed = true
			reactor_disabled[i] = false
		if (reactor_overheating[i]!=overheating):
			status_changed = true
		reactor_overheating[i] = overheating
	for i in range(num_internal):
		internal_sp[i] += delta*internal_sr[i]
		if (internal_sp[i]>internal_sp_max[i]):
			internal_sp[i] = internal_sp_max[i]
			if (internal_disabled[i]):
				status_changed = true
			internal_disabled[i] = false
		if (Equipment.outfits[internal[i]].has("heat_active")):
			var overheating = temp+Equipment.outfits[internal[i]]["heat_active"]>temp_max
			if (internal_overheating[i]!=overheating):
				status_changed = true
			internal_overheating[i] = overheating
		if (Equipment.outfits[internal[i]].has("power_active") && Equipment.outfits[internal[i]]["power_active"]<0):
			var no_power = ep+Equipment.outfits[internal[i]]["power_active"]<0
			if (internal_no_power[i]!=no_power):
				status_changed = true
			internal_no_power[i] = no_power
	for i in range(num_external):
		external_sp[i] += delta*external_sr[i]
		if (external_sp[i]>external_sp_max[i]):
			external_sp[i] = external_sp_max[i]
			if (external_disabled[i]):
				status_changed = true
			external_disabled[i] = false
		if (Equipment.outfits[external[i]].has("heat_active")):
			var overheating = temp+Equipment.outfits[external[i]]["heat_active"]>temp_max
			if (external_overheating[i]!=overheating):
				status_changed = true
			external_overheating[i] = overheating
		if (Equipment.outfits[external[i]].has("power_active") && Equipment.outfits[external[i]]["power_active"]<0):
			var no_power = ep+Equipment.outfits[external[i]]["power_active"]<0
			if (external_no_power[i]!=no_power):
				status_changed = true
			external_no_power[i] = no_power
	for i in range(num_engines):
		engine_sp[i] += delta*engine_sr[i]
		if (engine_sp[i]>engine_sp_max[i]):
			engine_sp[i] = engine_sp_max[i]
			if (engine_disabled[i]):
				status_changed = true
			engine_disabled[i] = false
	for i in range(num_weapons):
		weapon_sp[i] += delta*weapon_sr[i]
		if (weapon_sp[i]>weapon_sp_max[i]):
			weapon_sp[i] = weapon_sp_max[i]
#			if (weapon_disabled[i]):
#				status_changed = true
			weapon_disabled[i] = false
	
	autopilot(delta)
	if (disabled):
		thrust = false
		rotate = 0
	
	if (ep<delta*thrust_power || temp+delta*thrust_heat>temp_max || boarding):
		thrust = false
	if (ep<delta*steering_power*abs(rotate) || temp+delta*steering_heat>temp_max || boarding):
		rotate = 0
	ep += delta*(er+thrust_power*thrust+steering_power*abs(rotate))
	ht += thrust_heat*thrust+steering_heat*abs(rotate)
	if (ep>ep_max):
		ep = ep_max
	missile_cd -= delta
	for i in range(num_weapons):
		var t = delta*weapon_hd[i]*weapon_temp[i]
		wt += t
		weapon_temp[i] -= t
		weapon_cd[i] -= delta
	temp += wt*10.0/mass
	if (temp>temp_max):
		hp -= delta*(temp-temp_max)
		if (hp<0):
			explode()
			hp = 0
	
	lv *= 1.0-damping*delta
	av = ts*rotate
	lv += delta*la*dir*thrust
	
	if (ht<0):
		ht = 0
	temp = temp*(1-delta*heat_dissipation)+delta*ht/mass
	
	get_node("Engine").set_opacity(min(max(get_node("Engine").get_opacity()+delta*10*(thrust-0.5),0.0),1.0))
	get_node("SteeringLeft").set_opacity(min(max(get_node("SteeringLeft").get_opacity()+delta*10*((max(-rotate,0))-0.5),0.0),1.0))
	get_node("SteeringRight").set_opacity(min(max(get_node("SteeringRight").get_opacity()+delta*10*((max(rotate,0))-0.5),0.0),1.0))
	
	set_linear_velocity(lv)
	set_angular_velocity(av)
	
	if (status_changed):
		update()
	
	if (disabled || boarding):
		return
	
	for i in range(num_weapons):
		if (shoot[i] && !weapon_disabled[i] && weapon_cd[i]<=0.0 && ep+weapon_ep[i]>0.0 && weapon_temp[i]+weapon_heat[i]<weapon_max_temp[i] && temp<temp_max):
			Weapons.shoot(weapons[i],get_node("Weapon"+str(i+1)),weapon_temp[i]/weapon_max_temp[i]+0.75,dir,rot,lv,faction)
			ep += weapon_ep[i]
			weapon_temp[i] += weapon_heat[i]
			weapon_cd[i] = weapon_st[i]
	
	if (launch_missile && missile_cd<=0.0 && missiles.size()>0 && missile_selected>=0 && missile_ammo[missile_selected]>0 && (missile_locked || missile_type[missile_selected]=="none")):
		Weapons.launch(missiles[missile_selected],get_node("Missile"+str(missile_selected+1)),dir,rot,lv,faction,missile_target)
		missile_cd =missile_st[missile_selected]
		missile_ammo[missile_selected] -= 1
		update_mass(mass-Equipment.outfits[missiles[missile_selected]]["mass"])
		if (missile_ammo[missile_selected]<=0):
			select_next_missile()
	

func _process(delta):
	time += delta
	
	if (missile_target!=null && missile_target==missile_target_old && !disabled):
		if (get_node("/root/Main").ships.find(missile_target)==-1):
			missile_target = null
			missile_locked = false
			emit_signal("target_lost")
		else:
			missile_lock -= delta
			emit_signal("targeting")
			if (missile_lock<0.0):
				missile_lock = 0.0
				if (!missile_locked):
					missile_locked = true
					emit_signal("target_locked")
	missile_target_old = missile_target
	
	grappling_hook_cd -= delta
	if (board && !boarding && grappling_hook_cd<=0.0):
		var tpos = board_target.get_global_pos()
		
		for i in range(num_grappling_hooks):
			var node = get_node("GrapplingHook"+str(i+1))
			var pos = node.get_global_pos()
			var dir = (tpos-pos).normalized()
			var length = max(size.x,size.y)/2.0+16
			Weapons.grappling_hook(node,self,pos,dir.angle()-PI,dir,length,length+200,grappling_hook_speed,faction)
		
		grappling_hook_cd = grappling_hook_delay
	board = false
	
	hud(delta)

func init():
	pass

func _ready():
	recalc()
	hp = hp_max
	ep = ep_max
	sp = sp_max
	
#	var ri = RayCast2D.new()
#	ri.set_enabled(false)
#	ri.add_exception(self)
#	ri.set_name("RayCast")
#	add_child(ri)
	
	get_node("/root/Main").ships.push_back(self)
	set_process(true)
	set_process_input(true)
	add_user_signal("targeting")
	add_user_signal("target_locked")
	add_user_signal("target_lost")
	add_user_signal("destroyed")
	
	init()
