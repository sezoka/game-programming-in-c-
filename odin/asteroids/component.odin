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
	derived_comp: Component_Variant,
}

create_component :: proc($T: typeid, a: ^Actor, update_order: i32 = 100) -> ^T {
	comp := new(Component)
	comp.derived_comp = T {
		base = comp,
	}
	comp.owner = a
	comp.update_order = update_order
	add_component_to_actor(a, comp)
	return &comp.derived_comp.(T)
}

destroy_component :: proc(c: ^Component) {
	remove_component_from_actor(c.owner, c)
	free(c)
}

update_component :: proc(c: ^Component, delta: f32) {
	switch comp in &c.derived_comp {
	case Move_Component:
		update_move_component(&comp, delta)
	case Sprite_Component, Circle_Component:
	}
}

process_input_for_component :: proc(c: ^Component, key_state: [^]u8) {
	#partial switch comp in &c.derived_comp {
	case Move_Component:
		switch move_comp in &comp.derived {
		case Input_Component:
			process_input_for_input_component(&move_comp, key_state)
		}
	case Sprite_Component, Circle_Component:
	}
}
