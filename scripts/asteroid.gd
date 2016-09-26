
extends RigidBody2D

var hp = 1
var stealth = 0
var faction = Factions.NEUTRAL
var icon

func destroyed():
	icon.queue_free()

func _disable():
	get_node("/root/Main").objects.reamove(self)
	destroyed()

func damage(pos,type,dmg,disable,heat):
	pass

func get_lv():
	return get_linear_velocity()

func _ready():
	get_node("/root/Main").objects.push_back(self)
	var ii = Sprite.new()
	ii.set_texture(load("res://images/icons/icon_asteroid.png"))
	ii.set_name(get_name())
	HUD.get_node("Map/Map").add_child(ii)
	ii.hide()
	icon = ii
