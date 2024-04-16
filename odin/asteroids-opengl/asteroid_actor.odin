package asteroids

import "core:math"
import "core:fmt"
import "core:math/rand"

Asteroid_Actor :: struct {
	base: ^Actor,
	circle:     ^Circle_Component,
}


create_asteroid_actor :: proc(g: ^Game) -> ^Asteroid_Actor {
	asteroid := create_actor(Asteroid_Actor, g)

	asteroid.base.position = Vector2{rand.float32_range(0, WIDTH), rand.float32_range(0, HEIGHT)}
	asteroid.base.rotation = rand.float32_range(0, math.PI * 2)

	sc := create_sprite_component(asteroid.base)
	texture := get_texture(g, "../../assets/asteroids/Asteroid.png")
	set_sprite_texture(sc, texture)

	mc := create_move_component(asteroid.base)
	mc.forward_speed = 10

	circle := create_circle_component(asteroid.base)
	circle.radius = 20
	asteroid.circle = circle

	return asteroid
}
