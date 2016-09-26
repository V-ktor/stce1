
extends Panel
# ship status panel

var ship
var size = Vector2(0,0)
var camera


var enemy = preload("res://images/ui/ship_fg_red.png")
var friendly = preload("res://images/ui/ship_fg_green.png")
var player = preload("res://images/ui/ship_fg_blue.png")
var pirate = preload("res://images/ui/ship_fg_orange.png")

func _process(delta):
	var v
	if (get_node("/root/Main").ships.find(ship)==-1):
		set_process(false)
		get_node("Anim").play("fade_out")
		return
	
	set_pos((ship.get_global_pos()-camera.get_camera_screen_center())/camera.get_zoom()+OS.get_video_mode_size()/2.0-get_size()/2.0)
	set_size(size/camera.get_zoom())
	
	get_node("HP").set_value(ship.hp)
	get_node("Temp").set_value(ship.temp)
	get_node("Disable").set_value(ship.sp)
	
	v = ship.get_lv().length_squared()
	get_node("Center/Velocity").set_rot(ship.get_lv().angle())
	for i in range(1,5):
		get_node("Center/Velocity/Velocity"+str(i)).set_opacity(min(v/(i*i*i*i*40000.0),1.0))

func _ready():
	var sb = get_stylebox("panel").duplicate()
	set_process(true)
	
	if (ship.faction==get_node("/root/Factions").PIRATES):
		sb.set_texture(pirate)
	elif (ship.faction==get_node("/root/Factions").PLAYER):
		sb.set_texture(player)
	elif (get_node("/root/Factions").is_enemy(get_node("/root/Factions").PLAYER,ship.faction)):
		sb.set_texture(enemy)
	else:
		sb.set_texture(friendly)
	add_style_override("panel",sb)
	
	get_node("Name").set_text(ship.name)
	get_node("HP").set_max(ship.hp_max)
	get_node("Temp").set_max(ship.temp_max)
	get_node("Disable").set_max(ship.sp_max)
	
	
	camera = get_node("/root/Main/Camera")
	set_pos((ship.get_global_pos()-camera.get_camera_screen_center())/camera.get_zoom()+OS.get_video_mode_size()/2.0-get_size()/2.0)
	set_size(size/camera.get_zoom())
