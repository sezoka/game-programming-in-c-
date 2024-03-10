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
	add_component_to_actor(ship, sc)

	ic := create_input_component(ship)
	ic.forward_key = sdl.SCANCODE_W
	ic.back_key = sdl.SCANCODE_S
	ic.clockwise_key = sdl.SCANCODE_A
	ic.counter_clockwise_key = sdl.SCANCODE_D
	ic.max_forward_speed = 300
	ic.max_angular_speed = math.PI * 2

	return ship
}
