package asteroids

on_update_actor_world_transform :: proc(comp: ^Component) {
	switch comp in comp.derived {
	case Sprite_Component:
		{}
	case Circle_Component:
		{}
	case Move_Component:
		{}
	}
}

destroy_component :: proc(c: ^Component) {
	switch &comp in c.derived {
	case Sprite_Component:
		destroy_sprite_component(&comp)
	case Circle_Component, Move_Component:
	}

	free(c)
	remove_component_from_actor(c.owner, c)
}

update_component :: proc(c: ^Component, delta: f32) {
	switch &comp in c.derived {
	case Move_Component:
		update_move_component(&comp, delta)
	case Sprite_Component, Circle_Component:
	}
}

process_input_for_component :: proc(c: ^Component, key_state: [^]u8) {
	#partial switch &comp in c.derived {
	case Move_Component:
		switch &move_comp in comp.derived {
		case Input_Component:
			process_input_for_input_component(&move_comp, key_state)
		}
	case Sprite_Component, Circle_Component:
	}
}
