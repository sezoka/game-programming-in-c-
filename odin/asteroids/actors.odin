package asteroids

import "../shared"
import "core:fmt"
import "core:math"
import "core:math/linalg"

Actor_Base :: struct {}

Actor :: struct {
	variant:    Actor_Variant,
	state:      shared.Actor_State,
	position:   shared.Vector2,
	scale:      f32,
	rotation:   f64,
	components: [dynamic]^Component,
	game:       ^Game,
}

Actor_Variant :: union {
	Asteroid_Actor,
}

create_actor :: proc(g: ^Game) -> ^Actor {
	actor := new(Actor)
	actor.game = g
	actor.scale = 1.0
	add_actor(g, actor)
	return actor
}

destroy_actor :: proc(a: ^Actor) {
	for len(a.components) != 0 {
		comp := a.components[0]
		remove_component(a, comp)
		#partial switch _ in comp.variant {
		case Sprite_Component, BG_Sprite_Component, Anim_Sprite_Component:
			continue
		}
		destroy_component(comp)
	}
	delete(a.components)
	switch &actor in &a.variant {
	case Asteroid_Actor:
	}
	remove_actor(a.game, a)
	free(a)
}

update_actor :: proc(a: ^Actor, delta: f64) {
	if a.state == .Active {
		update_components(a, delta)
		update_actor_user_code(a, delta)
	}
}

update_components :: proc(a: ^Actor, delta: f64) {
	for comp in &a.components {
		switch variant in &comp.variant {
		case Sprite_Component:
		case BG_Sprite_Component:
			update_bg_sprite_component(&variant, comp, delta)
		case Move_Component:
			update_move_component(&variant, comp, delta)
		case Anim_Sprite_Component:
			update_anim_sprite_component(&variant, comp, delta)
		}
	}
}

remove_component :: proc(a: ^Actor, component: ^Component) {
	for i in 0 ..< len(a.components) {
		comp := a.components[i]
		if comp == component {
			ordered_remove(&a.components, i)
			return
		}
	}
}

add_component :: proc(a: ^Actor, component: ^Component) {
	order := component.update_order
	insert_idx := 0
	for ; insert_idx < len(a.components); insert_idx += 1 {
		if order < a.components[insert_idx].update_order {
			break
		}
	}
	inject_at(&a.components, insert_idx, component)
}

update_actor_user_code :: proc(a: ^Actor, delta: f64) {
	switch _ in a.variant {
	case Asteroid_Actor:
	}
}

get_actor_forward :: proc(a: ^Actor) -> shared.Vector2 {
	return shared.Vector2{math.cos_f64(a.rotation), math.sin_f64(a.rotation)}
}
