package asteroids

import "core:math"

Move_Component :: struct {
	angular_speed: f64,
	forward_speed: f64,
}

create_move_component :: proc(a: ^Actor, update_order: i32 = 10) -> ^Component {
	base := create_component(a, update_order)
	comp: Move_Component
	base.variant = comp
	return base
}

update_move_component :: proc(mc: ^Move_Component, base: ^Component, delta: f64) {
	if math.F32_EPSILON < mc.angular_speed {
		rot := &base.owner.rotation
		rot^ += mc.angular_speed * delta
	}
	if math.F32_EPSILON < mc.forward_speed {
		pos := &base.owner.position
		pos^ += get_actor_forward(base.owner) * mc.forward_speed * delta
	}
}
