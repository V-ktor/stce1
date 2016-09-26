
extends Area2D

var faction = Factions.UNATACKABLE

func _process(delta):
	# Increase temperature of objects too close to the sun
	for body in get_overlapping_bodies():
		if (body.has_meta("temp")):
			body.temp += delta*10000000.0*get_node("/root/Main").sun_scale/max(body.get_global_pos().distance_to(get_parent().get_global_pos()),10000.0)/sqrt(body.mass)

func _ready():
	set_process(true)
