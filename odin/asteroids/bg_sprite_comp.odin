package asteroids

import "../shared"
import "core:fmt"
import sdl "vendor:sdl2"

BG_Texture :: struct {
	texture: ^sdl.Texture,
	offset:  shared.Vector2,
}

BG_Sprite_Component :: struct {
	using sprite: Sprite_Component,
	bg_textures:  [dynamic]BG_Texture,
	screen_size:  shared.Vector2,
	scroll_speed: f64,
}

create_bg_sprite_component :: proc(owner: ^Actor, draw_order: i32 = 10) -> ^Component {
	bg_sprite := create_sprite_component(owner)
	bg_sprite.variant = BG_Sprite_Component{
    draw_order = draw_order
}

	return bg_sprite
}

draw_bg_sprite_component :: proc(bg: BG_Sprite_Component, c: ^Component, renderer: ^sdl.Renderer) {
	for tex in bg.bg_textures {
		r: sdl.Rect
		r.w = i32(bg.screen_size.x)
		r.h = i32(bg.screen_size.y)
		r.x = i32(c.owner.position.x - f64(r.w) / 2 + tex.offset.x)
		r.y = i32(c.owner.position.y - f64(r.h) / 2 + tex.offset.y)
		sdl.RenderCopy(renderer, tex.texture, nil, &r)
	}
}

set_bg_sprite_textures :: proc(bg: ^BG_Sprite_Component, textures: [dynamic]^sdl.Texture) {
	count: f64 = 0
	for tex in textures {
		temp: BG_Texture
		temp.offset.x = count * bg.screen_size.x
    temp.texture = tex
		append(&bg.bg_textures, temp)
		count += 1
	}
}

update_bg_sprite_component :: proc(bg: ^BG_Sprite_Component, s: ^Component, delta: f64) {
	for tex in &bg.bg_textures {
		tex.offset.x += bg.scroll_speed * delta
		if tex.offset.x < -bg.screen_size.x {
			tex.offset.x = f64((len(bg.bg_textures) - 1)) * bg.screen_size.x - 1
		}
	}
}
