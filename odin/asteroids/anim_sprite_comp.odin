package asteroids

import "core:fmt"
import sdl "vendor:sdl2"

Anim_Sprite_Component :: struct {
	using sprite:  Sprite_Component,
	anim_textures: [dynamic]^sdl.Texture,
	curr_frame:    f64,
	anim_fps:      f64,
}

create_anim_sprite_component :: proc(owner: ^Actor, draw_order: i32 = 100) -> ^Component {
	sprite := create_sprite_component(owner, draw_order)
	sprite.variant = Anim_Sprite_Component {
		draw_order = draw_order,
    anim_fps = 24,
	}
	return sprite
}

set_anim_textures :: proc(asc: ^Anim_Sprite_Component, textures: [dynamic]^sdl.Texture) {
	asc.anim_textures = textures
	if (0 < len(asc.anim_textures)) {
		asc.curr_frame = 0
		set_texture(&asc.sprite, asc.anim_textures[0])
	}
}

update_anim_sprite_component :: proc(s: ^Anim_Sprite_Component, c: ^Component, delta: f64) {
	if len(s.anim_textures) < 0 do return

	s.curr_frame += s.anim_fps * delta

	for f64(len(s.anim_textures)) <= s.curr_frame {
		s.curr_frame -= f64(len(s.anim_textures))
	}


	set_texture(&s.sprite, s.anim_textures[uint(s.curr_frame)])
}
