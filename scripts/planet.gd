
extends Node2D

var fr = 0.001
var pos = Vector2(0,0)

func get_lv():
	var lv = pos.rotated(fr*(Time.time+0.5))-pos.rotated(fr*(Time.time-0.5))
	return lv

func _process(delta):
	set_rot(fr*Time.time)

func _ready():
	var dist
	pos = get_node("Planet").get_global_pos()
	dist = pos.length()
	fr = 2.0*PI/((dist/300000.0)*(dist/300000.0)*(dist/300000.0)*365*24*60)
	
	set_process(true)
