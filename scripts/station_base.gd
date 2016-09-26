
extends Node2D
# base script for space stations

export var docks = 8
var hp = 1
var docked = []
var take_off_delay = []
var faction = 0

func damage(pos,type,dmg,disable,heat):
	pass

func clear_all_docks():
	for i in range(docks):
		docked[i] = false
		take_off_delay[i] = 0.0

func request_landing_position():
	for i in range(docks):
		if (!docked[i]):
			docked[i] = true
			return i
	return -1

func get_lv():
	if (get_parent().get_name()=="Main"):
		return Vector2(0,0)
	else:
		return get_parent().get_lv()

func _process(delta):
	for i in range(take_off_delay.size()):
		if (take_off_delay[i]>0.0):
			take_off_delay[i] -= delta
			if (take_off_delay[i]<=0.0):
				docked[i] = false

func _ready():
	set_process(true)
	docked.resize(docks)
	take_off_delay.resize(docks)
	for i in range(docks):
		docked[i] = false
		take_off_delay[i] = 0.0
