extends Node2D

var velocity
const SPEED = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(randf_range(-SPEED, SPEED), randf_range(-SPEED, SPEED))
	rotation_degrees = randf_range(-360, 360)
	var size = get_viewport_rect().size
	position = Vector2(randf_range(0, size.x), randf_range(0, size.y))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += delta * velocity
	


func _on_visible_on_screen_notifier_2d_screen_exited():
	var scr_size = get_viewport_rect().size
	var size = $Sprite2D.get_rect().size
	var w = size.x / 2
	var h = size.y / 2
	
	if position.x - w < 0:
		position.x = scr_size.x + w / 2
	elif scr_size.x < position.x + w:
		position.x = -w
	
	if position.y - w < 0:
		position.y = scr_size.y + w / 2
	elif scr_size.y < position.y + w:
		position.y = -w

