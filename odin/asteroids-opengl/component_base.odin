package asteroids

import "core:fmt"


Component_Variant :: union {
	Sprite_Component,
	Circle_Component,
	Move_Component,
}

Component :: struct {
	owner:        ^Actor,
	update_order: i32,
	derived:      Component_Variant,
}

create_component :: proc($T: typeid, a: ^Actor, update_order: i32 = 100) -> ^T {
	comp := new(Component)
	comp.derived = T {
		base = comp,
	}
	comp.owner = a
	comp.update_order = update_order
	add_component_to_actor(a, comp)
	return &comp.derived.(T)
}

