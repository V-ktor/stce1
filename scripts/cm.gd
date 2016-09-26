
extends Area2D

var hp = 1
var lv = Vector2(0,0)
var faction = 0
var disabled = false

func disable():
	if (disabled):
		return
	
	disabled = true
	get_node("Anim").play("fade_out")
	clear_shapes()
	get_node("/root/Main").missiles.erase(self)

func damage(pos,type,dmg,disable,heat):
	disable()

func get_lv():
	return lv

func _on_area_enter(area):
	if (area in get_node("/root/Main").missiles && Factions.is_enemy(faction,area.faction)):
		area.disable()
		disable()

func _process(delta):
	set_pos(get_pos()+delta*lv)

func _ready():
	get_node("/root/Main").missiles.push_back(self)
	set_process(true)
