package asteroids

import "core:math"
import sdl "vendor:sdl2"

Ship_Actor :: struct {
	laser_cooldown: f64,
}

create_ship_actor :: proc(g: ^Game) {
	actor := create_actor(g)
	actor.variant = Ship_Actor {
		laser_cooldown = 1,
	}

	sc := create_sprite_component(actor)
	sv := &sc.variant.(Sprite_Component)
	set_texture(sv, get_texture(g, "./assets/Ship.png"))

	ic := create_input_component(actor)
	iv := &ic.variant.(Input_Component)
	iv^ = Input_Component {
		max_forward_speed     = 300,
		max_angular_speed     = 2 * math.PI,
		forward_key           = sdl.SCANCODE_W,
		back_key              = sdl.SCANCODE_S,
		clockwise_key         = sdl.SCANCODE_A,
		counter_clockwise_key = sdl.SCANCODE_D,
	}
}

update_ship_actor :: proc(s: ^Ship_Actor, base: ^Actor, delta: f64) {
	s.laser_cooldown -= delta
}
