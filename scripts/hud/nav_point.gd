
extends Sprite

var lv = Vector2(0,0)

func get_lv():
	if (get_parent().has_method("get_lv")):
		return get_parent().get_lv()+lv
	else:
		return lv
