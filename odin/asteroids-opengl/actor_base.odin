package asteroids

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"

Actor_Variant :: union {
	Asteroid_Actor,
	Ship_Actor,
	Laser_Actor,
}

Actor_State :: enum {
	Active,
	Paused,
	Dead,
}

Actor :: struct {
	state:                     Actor_State,
	_position:                 Vector2,
	_scale:                    f32,
	_rotation:                 f32,
	components:                [dynamic]^Component,
	game:                      ^Game,
	derived:                   Actor_Variant,
	world_transform:           matrix[4, 4]f32,
	recompute_world_transform: bool,
}

create_actor :: proc($T: typeid, g: ^Game) -> ^T {
	actor := new(Actor)
	actor.state = .Active
	actor._scale = 1.0
	actor._rotation = 0
	actor.game = g
	actor.recompute_world_transform = true
	actor.derived = T {
		base = actor,
	}
	add_actor_to_game(g, actor)
	return &actor.derived.(T)
}

update_actor :: proc(a: ^Actor, delta: f32) {
	if a.state != .Active do return
	compute_world_transform_for_actor(a)

	update_actor_components(a, delta)
	update_actor_user_code(a, delta)

	compute_world_transform_for_actor(a)
}

update_actor_components :: proc(a: ^Actor, delta: f32) {
	for comp in &a.components {
		update_component(comp, delta)
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
	#partial switch &actor in a.derived {
	case Ship_Actor:
		process_input_for_ship_actor(&actor, key_state)
	case:
	}
}

add_component_to_actor :: proc(a: ^Actor, c: ^Component) {
	my_order := c.update_order
	for comp, i in a.components {
		if my_order < comp.update_order {
			inject_at_elem(&a.components, i, c)
			return
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
	return Vector2{math.cos_f32(a._rotation), math.sin_f32(a._rotation)}
}

compute_world_transform_for_actor :: proc(a: ^Actor) {
	if a.recompute_world_transform {
		a.recompute_world_transform = false


		a.world_transform = matrix[4, 4]f32{
			a._scale, 0.0, 0.0, 0.0, 
			0.0, a._scale, 0.0, 0.0, 
			0.0, 0.0, a._scale, 0.0, 
			0.0, 0.0, 0.0, 1.0, 
		}
		a.world_transform *= matrix[4, 4]f32{
			math.cos_f32(a._rotation), math.sin_f32(a._rotation), 0.0, 0.0, 
			-math.sin_f32(a._rotation), math.cos_f32(a._rotation), 0.0, 0.0, 
			0.0, 0.0, 1.0, 0.0, 
			0.0, 0.0, 0.0, 1.0, 
		}
		a.world_transform *= matrix[4, 4]f32{
			1.0, 0.0, 0.0, 0.0, 
			0.0, 1.0, 0.0, 0.0, 
			0.0, 0.0, 1.0, 0.0, 
			a._position.x, a._position.y, 0, 1.0, 
		}
	}

	for comp in a.components {
		on_update_actor_world_transform(comp)
	}
}

actor_set_scale :: proc(a: ^Actor, scale: f32) {
	a._scale = scale
	a.recompute_world_transform = true
}

actor_set_rotation :: proc(a: ^Actor, rotation: f32) {
	a._rotation = rotation
	a.recompute_world_transform = true
}

actor_set_position :: proc(a: ^Actor, x: f32, y: f32) {
	a._position = {x, y}
	a.recompute_world_transform = true
}
