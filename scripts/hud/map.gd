
extends Control

const num_points = 256

func _draw():
	if (!get_node("/root").has_node("Main")):
		return
	
	var center = OS.get_video_mode_size()/2.0+HUD.map_center
	for i in range(get_node("/root/Main").num_planets):
		var pos = (get_node("/root/Main/Planet"+str(i+1)+"/Planet").get_global_pos())*HUD.map_scale*HUD.map_zoom
		var posn
		for k in range(num_points):
			posn = pos.rotated(2.0*PI/num_points)
			draw_line(pos+center,posn+center,Color(1.0,1.0,1.0,0.5),2)
			pos = posn
	
	if (get_node("/root/Main").has_node("Player")):
		var icon = HUD.get_node("Map/Map/Player")
		icon.radius = get_node("/root/Main/Player").radar*HUD.map_scale*HUD.map_zoom
		icon.update()
