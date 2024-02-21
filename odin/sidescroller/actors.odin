package sidescroller

import "../shared"
import "core:fmt"

Actor_Base :: struct {
	state:      shared.Actor_State,
	position:   shared.Vector2,
	scale:      f32,
	rotation:   f64,
	components: [dynamic]^Component,
	game:       ^Game,
}

Actor :: struct {
	variant:    Actor_Variant,
	using base: Actor_Base,
}

Actor_Variant :: union {
	Ship_Actor,
}

create_actor :: proc(g: ^Game) -> ^Actor {
	actor := new(Actor)
	actor.game = g
	add_actor(g, actor)
	return actor
}

destroy_actor :: proc(a: ^Actor) {
	for len(a.components) != 0 {
		comp := a.components[0]
		remove_component(a, comp)
		switch _ in comp.variant {
		case Sprite_Component, BG_Sprite_Component, Anim_Sprite_Component:
			continue
		}
		destroy_component(comp)
	}
	delete(a.components)
	switch &actor in &a.variant {
	case Ship_Actor:
		{
		}
	}
	remove_actor(a.game, a)
	free(a)
}

update_actor :: proc(a: ^Actor, delta: f32) {
	if a.state == .Active {
		update_components(a, delta)
		update_actor_user_code(a, delta)
	}
}

update_components :: proc(a: ^Actor, delta: f32) {
	for comp in a.components {
		update_component(comp, delta)
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

update_actor_user_code :: proc(a: ^Actor, delta: f32) {
	switch _ in a.variant {
	case Ship_Actor:
		update_ship_actor(a, delta)
	}
}
