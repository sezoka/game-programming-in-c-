package asteroids

import "core:math"
import sdl "vendor:sdl2"

Ship_Actor :: struct {
	using base:     ^Actor,
	laser_cooldown: f32,
}

create_ship_actor :: proc(g: ^Game) -> ^Ship_Actor {
	ship := create_actor(Ship_Actor, g)

	sc := create_sprite_component(ship, 150)
	texture := get_texture(g, "../../assets/asteroids/Ship.png")
	set_sprite_texture(sc, texture)

	ic := create_input_component(ship)
	ic.forward_key = sdl.SCANCODE_W
	ic.back_key = sdl.SCANCODE_S
	ic.clockwise_key = sdl.SCANCODE_D
	ic.counter_clockwise_key = sdl.SCANCODE_A
	ic.max_forward_speed = 300
	ic.max_angular_speed = math.PI * 2

	return ship
}

update_ship_actor :: proc(sa: ^Ship_Actor, delta: f32) {
	sa.laser_cooldown -= delta
}

process_input_for_ship_actor :: proc(sa: ^Ship_Actor, key_state: [^]u8) {
	if key_state[sdl.SCANCODE_SPACE] != 0 && sa.laser_cooldown <= 0.0 {
		// Create a laser and set its position/rotation to mine
		laser := create_laser_actor(sa.game)
		laser.position = sa.position
		laser.rotation = sa.rotation
		// Reset laser cooldown (half second)
		sa.laser_cooldown = 0.5
	}
}
