extends Area2D

const SPEED = 20000

var screen_size_y
var paddle_height

func _ready():
	screen_size_y = get_viewport_rect().size.y
	var collision: CollisionShape2D = $CollisionShape2D	
	paddle_height = collision.shape.get_rect().size.y

func _process(delta):
	if Input.is_action_pressed("left_up"):
		position.y -= 1000 * delta
	elif Input.is_action_pressed("left_down"):
		position.y += 1000 * delta
	
	
	position.y = clamp(position.y, paddle_height / 2, screen_size_y - paddle_height / 2)


