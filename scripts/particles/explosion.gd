
extends Particles2D

var destroy_parent = false

func hide_parent():
	if (destroy_parent):
		get_node("../Sprite").hide()

func explode():
	if (destroy_parent):
		get_parent().queue_free()
	else:
		queue_free()
