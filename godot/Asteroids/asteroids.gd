extends Node2D

const Asteroid = preload("res://asteroid.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(20):
		var asteroid = Asteroid.instantiate()
		add_child(asteroid)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
