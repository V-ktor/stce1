
extends Area2D

var type = 1
var dt = 1
var dmg = 5.0
var disable = 2.0
var heat = 2.0
var faction = 0
var lv = Vector2(0,0)

func _on_body_enter(body):
	if (Factions.is_enemy(faction,body.faction)):
		body.damage(get_global_pos(),dt,dmg,disable,heat)
		lv = body.get_lv()
		var pi = Equipment.outfits[type]["particles_impact"].instance()
		body.add_child(pi)
		pi.set_global_pos((get_global_pos()+body.get_global_pos())/2.0)
