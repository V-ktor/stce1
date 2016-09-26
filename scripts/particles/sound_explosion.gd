
extends SamplePlayer2D

func _play():
	play("explosion"+str(1+(randi()%9)))
