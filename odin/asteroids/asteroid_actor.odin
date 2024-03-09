package asteroids

import "../shared"
import "core:fmt"
import "core:math"
import "core:math/rand"

Asteroid_Actor :: struct {
  circle: ^Component
}


create_asteroid_actor :: proc(g: ^Game) -> ^Actor {
	actor := create_actor(g)
	asteroid: Asteroid_Actor

	actor.position = shared.Vector2{rand.float64_range(0, WIDTH), rand.float64_range(0, HEIGHT)}
	actor.rotation = rand.float64_range(0, math.PI * 2)

	sprite := create_sprite_component(actor)
	texture := get_texture(g, "../../assets/asteroids/Asteroid.png")
	set_texture(&sprite.variant.(Sprite_Component), texture)
	add_component(actor, sprite)

	move := create_move_component(actor)
	mc := &move.variant.(Move_Component)
	mc.forward_speed = 10
	add_component(actor, move)

  circle := create_circle_component(actor)
  c := circle.variant.(Circle_Component)
  c.radius = 10
  asteroid.circle = circle

	actor.variant = asteroid

	return actor
}
