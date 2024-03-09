package asteroids

import "core:fmt"
import sdl "vendor:sdl2"

Component :: struct {
	owner:        ^Actor,
	update_order: i32,
	variant:      Component_Variant,
}

Component_Variant :: union {
	Sprite_Component,
	Anim_Sprite_Component,
	BG_Sprite_Component,
	Move_Component,
	Circle_Component,
  Input_Component,
}

create_component :: proc(owner: ^Actor, update_order: i32 = 100) -> ^Component {
	comp := new(Component)
	comp.update_order = update_order
	comp.owner = owner
	add_component(owner, comp)
	return comp
}

destroy_component :: proc(c: ^Component) {
	switch comp in c.variant {
	case Move_Component:
	case Sprite_Component:
	case BG_Sprite_Component:
		{delete(comp.bg_textures)}
	case Anim_Sprite_Component:
		{delete(comp.anim_textures)}
	case Circle_Component:
  case Input_Component:
	}

	free(c)
}

update_component :: proc {
	update_bg_sprite_component,
	update_anim_sprite_component,
	update_move_component,
}
