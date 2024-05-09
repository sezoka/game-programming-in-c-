package asteroids

import "core:fmt"
import "core:math"
import "core:math/rand"

Asteroid_Actor :: struct {
	base:   ^Actor,
	circle: ^Circle_Component,
}


create_asteroid_actor :: proc(g: ^Game) -> ^Asteroid_Actor {
	asteroid := create_actor(Asteroid_Actor, g)

	actor_set_position(asteroid.base, rand.float32_range(0, WIDTH), rand.float32_range(0, HEIGHT))
	actor_set_rotation(asteroid.base, rand.float32_range(0, math.PI * 2))

	sc := create_sprite_component(asteroid.base)
	texture := get_texture(g, "../../assets/asteroids/Asteroid.png")
	set_sprite_texture(sc, texture)

	// sc.tex_height = 10.0
	// sc.tex_width = 10.0

	mc := create_move_component(asteroid.base)
	mc.forward_speed = 10

	circle := create_circle_component(asteroid.base)
	circle.radius = 20
	asteroid.circle = circle

	return asteroid
}
