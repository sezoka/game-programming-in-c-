package asteroids

import "core:math/linalg"

Circle_Component :: struct {
	radius: f64,
}

get_circle_radius :: proc(c: ^Circle_Component, a: ^Actor) -> f64 {
	return c.radius * a.scale
}

is_circle_intersect :: proc(
	c1: ^Circle_Component,
	a1: ^Actor,
	c2: ^Circle_Component,
	a2: ^Actor,
) -> bool {
	diff := a1.position - a2.position
	dist_sq := linalg.length2(diff)

	radius_sq := c1.radius + c2.radius
	radius_sq *= radius_sq

	return dist_sq <= radius_sq
}

create_circle_component :: proc(a: ^Actor) -> ^Component {
	circle := create_component(a)
	circle.variant = Circle_Component {
		radius = 0,
	}
	return circle
}
