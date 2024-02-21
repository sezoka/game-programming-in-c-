package sidescroller

import sdl "vendor:sdl2"
import "core:fmt"

Component :: struct {
	owner:        ^Actor,
	update_order: i32,
	variant:      Component_Variant,
}

Component_Variant :: union {
	Sprite_Component,
	Anim_Sprite_Component,
	BG_Sprite_Component,
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
	case Sprite_Component:
		{}
	case BG_Sprite_Component:
		{delete(comp.bg_textures)}
	case Anim_Sprite_Component:
		{delete(comp.anim_textures)}
	}

	free(c)
}
