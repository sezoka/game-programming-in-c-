extends Node2D

@onready var sprite_width = 64 * 1.5
@onready var sprite_height = 29 * 1.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var down_speed := 0
	var right_speed := 0
	if Input.is_key_pressed(KEY_A):
		right_speed -= 300
	if Input.is_key_pressed(KEY_D):
		right_speed += 300
	if Input.is_key_pressed(KEY_W):
		down_speed -= 300
	if Input.is_key_pressed(KEY_S):
		down_speed += 300
	position.x += right_speed * delta
	position.y += down_speed * delta
	
	var scr_w = get_viewport_rect().size.x
	var scr_h = get_viewport_rect().size.y
	
	if position.x < sprite_width / 2:
		position.x = sprite_width / 2
	if scr_w - sprite_width / 2 < position.x:
		position.x = scr_w - sprite_width / 2
	if position.y < sprite_height / 2:
		position.y = sprite_height / 2
	if scr_h - sprite_height / 2 < position.y:
		position.y = scr_h - sprite_height / 2
