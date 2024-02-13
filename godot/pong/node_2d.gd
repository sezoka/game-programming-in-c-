extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_walls_area_entered(area):
	if area.name == "Ball":
		area.vel = Vector2(area.vel.x + randf_range(-0.1, +0.1), -area.vel.y)


func _on_ceil_floor_area_entered(area):
	if area.name == "Ball":
		area.vel = Vector2(area.vel.x + randf_range(-0.1, +0.1), -area.vel.y)


func _on_right_paddle_area_entered(area):
	print(area.name)
	if area.name == "Ball":
		area.vel = Vector2(-area.vel.x, area.vel.y + randf_range(-0.1, +0.1))


func _on_left_paddle_area_entered(area):
	print(area.name)
	if area.name == "Ball":
		area.vel = Vector2(-area.vel.x, area.vel.y + randf_range(-0.1, +0.1))
