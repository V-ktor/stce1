
extends Sprite

export var fr = 0.01

func _process(delta):
	set_rot(fr*Time.time)

func _ready():
	set_process(true)
	pass
