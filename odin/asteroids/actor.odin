package asteroids

import "core:fmt"
import "core:math"
import "core:math/linalg"

Actor_Variant :: union {
	Asteroid_Actor,
	Ship_Actor,
}

Actor_State :: enum {
	Active,
	Paused,
	Dead,
}

Actor :: struct {
	state:      Actor_State,
	position:   Vector2,
	scale:      f32,
	rotation:   f32,
	components: [dynamic]^Component,
	game:       ^Game,
	derived:    Actor_Variant,
}

create_actor :: proc($T: typeid, g: ^Game) -> ^T {
	actor := new(Actor)
	actor.state = .Active
	actor.scale = 1.0
	actor.rotation = 0
	actor.game = g
	actor.derived = T {
		base = actor,
	}
	add_actor_to_game(g, actor)
	return &actor.derived.(T)
}

destroy_actor :: proc(a: ^Actor_Variant) {
	free(a)
}

update_actor :: proc(a: ^Actor, delta: f32) {
	if a.state != .Active do return
	update_actor_components(a, delta)
	update_actor_user_code(a, delta)
}

update_actor_components :: proc(a: ^Actor, delta: f32) {
	for comp in &a.components {
		update_component(comp, delta)
	}
}

update_actor_user_code :: proc(a: ^Actor, delta: f32) {
	switch actor in a.derived {
	case Asteroid_Actor: // TODO
	case Ship_Actor:
		// update_ship_actor(actor, delta)
	}
}

process_input_for_actor :: proc(a: ^Actor, key_state: [^]u8) {
	if a.state != .Active do return
	for comp in a.components {
		process_input_for_component(comp, key_state)
	}
	process_input_for_actor_user_code(a, key_state)
}

process_input_for_actor_user_code :: proc(a: ^Actor, key_state: [^]u8) {
  // switch actor in a {
  // }
}

add_component_to_actor :: proc(a: ^Actor, c: ^Component) {
	my_order := c.update_order
	for comp, i in a.components {
		if my_order < comp.update_order {
			inject_at_elem(&a.components, i, c)
			break
		}
	}
	append(&a.components, c)
}

remove_component_from_actor :: proc(a: ^Actor, c: ^Component) {
	for comp, i in a.components {
		if comp == c {
			ordered_remove(&a.components, i)
			break
		}
	}
}

get_actor_forward_vector :: proc(a: ^Actor) -> Vector2 {
	return Vector2{math.cos_f32(a.rotation), math.sin_f32(a.rotation)}
}
