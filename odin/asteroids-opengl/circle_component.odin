package asteroids

import "core:fmt"
import "core:math/linalg"

Circle_Component :: struct {
	base:   ^Component,
	radius: f32,
}

create_circle_component :: proc(owner: ^Actor) -> ^Circle_Component {
	comp := create_component(Circle_Component, owner)
	return comp
}

get_circle_component_center :: proc(cc: ^Circle_Component) -> Vector2 {
	return cc.base.owner._position
}

get_circle_component_radius :: proc(cc: ^Circle_Component) -> f32 {
	return cc.base.owner._scale * cc.radius
}

check_is_circles_intersect :: proc(a: ^Circle_Component, b: ^Circle_Component) -> bool {
	diff := get_circle_component_center(a) - get_circle_component_center(b)
	dist_sq := linalg.length2(diff)
	radi_sq := get_circle_component_radius(a) + get_circle_component_radius(b)
	radi_sq *= radi_sq
	return dist_sq < radi_sq
}
