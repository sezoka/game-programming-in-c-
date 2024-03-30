package asteroids

import "core:fmt"
import "core:math"

Move_Comp_Variant :: union {
	Input_Component,
}

Move_Component :: struct {
	angular_speed: f32,
	forward_speed: f32,
	derived:       Move_Comp_Variant,
	using base:    ^Component,
}

create_move_component :: proc(a: ^Actor, update_order: i32 = 10) -> ^Move_Component {
	return create_component(Move_Component, a, update_order)
}

create_move_component_variant :: proc($T: typeid, a: ^Actor, update_order: i32 = 10) -> ^T {
	comp := create_move_component(a, update_order)
	comp.derived = T {
		base = comp,
	}
	return &comp.derived.(T)
}

update_move_component :: proc(mc: ^Move_Component, delta: f32) {
	if !near_zero(mc.angular_speed) {
		rot := &mc.owner.rotation
		rot^ += mc.angular_speed * delta
	}
	if !near_zero(mc.forward_speed) {
		pos := &mc.owner.position
		pos^ += get_actor_forward_vector(mc.owner) * mc.forward_speed * delta

		if pos.x + 32 < 0 do pos.x = f32(WIDTH + 32)
		if WIDTH < pos.x - 32 do pos.x = f32(-32)

		if pos.y + 32 < 0 do pos.y = f32(HEIGHT + 32)
		if HEIGHT < pos.y - 32 do pos.y = f32(-32)
	}
}
