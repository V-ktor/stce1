
extends Node
# player variables

var first = ""
var last = ""
var inventory = []
var passengers = 0
var credits = 100
var equipment = []
var missile_ammo = []
var ship_location = []
var ship_crew = []
var ship_name = []
var ship_selected = -1
var station
var dock
var docked = false
var parent
var time_speedup = false
var time_scale = 1.0
const max_time_scale = 10.0
var difficulty = 1.0
var weapon_group = [[],[],[],[]]

var variables = {}


func _input(event):
	if (event.type==InputEvent.KEY):
		if (!docked && event.is_action_pressed("time_speedup")):
			time_speedup = !time_speedup

func _process(delta):
	time_scale += delta*clamp(max_time_scale*time_speedup+(1-time_speedup)-time_scale,-2.0,1.0)
	HUD.get_node("TimeScale").set_value(time_scale)
	if (time_scale<1.01):
		HUD.get_node("TimeScale").set_opacity(clamp(HUD.get_node("TimeScale").get_opacity()*(1-2.0*delta),0.0,1.0))
	else:
		HUD.get_node("TimeScale").set_opacity(clamp(HUD.get_node("TimeScale").get_opacity()*(1+4.0*delta),0.1,1.0))
	OS.set_time_scale(time_scale)

func _ready():
	set_process_input(true)
	set_process(true)
