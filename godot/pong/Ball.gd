extends Area2D

var vel := Vector2.LEFT
var speed := 600


func _process(delta):
	position = position + vel * speed * delta
	speed += delta * 2
