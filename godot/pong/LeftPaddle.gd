extends Area2D

const SPEED = 20000

func _process(delta):
	if Input.is_action_pressed("left_up"):
		position.y -= 1000 * delta
	elif Input.is_action_pressed("left_down"):
		position.y += 1000 * delta

