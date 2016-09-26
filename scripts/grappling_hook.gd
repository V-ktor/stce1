
extends Area2D

var speed = 0
var dir = Vector2(0,0)
var length = 0
var max_length = 0
var rest_length = 0
var faction = 0
var ship
var target
var offset = Vector2(0,0)
var retract = false
var joint
var disabled = false


func _destroy():
	if (disabled):
		return
	
	disabled = true
	set_process(false)
	get_node("Anim").play("destroy")
	joint.queue_free()

func _collide(body):
	if (!body.disabled && !Factions.is_enemy(faction,body.faction)):
		return
	
	target = body
	offset = (get_global_pos()-body.get_global_pos()).rotated(-body.get_rot())
	joint.set_node_a(ship.get_path())
	joint.set_node_b(body.get_path())
	_retract()
	dir = (body.get_global_pos()-get_parent().get_global_pos()).normalized()
	speed *= 0.5
	rest_length += max(body.size.x,body.size.y)/2.0

func _retract():
	if (retract):
		return
	
	clear_shapes()
	speed *= 0.5
	retract = true

func _detach():
	if (disabled):
		return
	
	_retract()
	get_node("Particles").set_emitting(true)
	if (target!=null):
		get_node("Particles").set_initial_velocity(target.get_lv())
	target = null
	joint.set_node_a("")
	joint.set_node_b("")

func _process(delta):
	if (retract):
		if (target!=null):
			if (length>rest_length):
				length -= delta*speed
				joint.set_node_b("")
				target.set_pos(target.get_pos()-delta*speed*dir)
				joint.set_node_b(target.get_path())
				if (ship.get_global_pos().distance_squared_to(target.get_global_pos())<rest_length*rest_length):
					length = rest_length
			else:
				target.boarding = true
				ship.board_target = target
				ship.start_boarding()
			set_global_pos(target.get_global_pos()+offset.rotated(target.get_rot()))
		else:
			length -= delta*speed
			if (length<=0):
				_destroy()
				return
			set_global_pos(get_parent().get_global_pos()+length*dir)
	else:
		length += delta*speed
		if (length>max_length):
			_retract()
		set_global_pos(get_parent().get_global_pos()+length*dir)
	
	get_node("Wire").set_region_rect(Rect2(0,0,32,2*get_global_pos().distance_to(get_parent().get_global_pos())-16))
	set_rot(get_pos().angle()-PI)

func _ready():
	joint = get_node("Joint")
	set_process(true)
	get_node("Wire").set_material(get_node("Wire").get_material().duplicate())
