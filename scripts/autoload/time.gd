
extends Node

var time = 0.0
var pause = false

func enable_pause():
	pause = true
	set_process(false)
	Economy.get_node("TimerEconomyUpdate").set_active(false)

func disable_pause():
	pause = false
	set_process(true)
	Economy.get_node("TimerEconomyUpdate").set_active(true)

func _process(delta):
	time += delta

func _ready():
	set_process(true)
