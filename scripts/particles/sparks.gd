
extends Particles2D

var lv = Vector2(0,0)

func _process(delta):
	set_pos(get_pos()+delta*lv)

func _ready():
	set_process(true)
