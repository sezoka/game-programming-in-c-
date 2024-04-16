package asteroids

import "core:math/linalg"
import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

Sprite_Variant :: union {}

Sprite_Component :: struct {
	base:           ^Component,
	texture:        ^sdl.Texture,
	draw_order:     i32,
	tex_width:      i32,
	tex_height:     i32,
	derived_sprite: Sprite_Variant,
}

create_sprite_component :: proc(owner: ^Actor, draw_order: i32 = 100) -> ^Sprite_Component {
	comp := create_component(Sprite_Component, owner, draw_order)
	sc := &comp.base.derived.(Sprite_Component)
	sc.draw_order = draw_order

	add_sprite_to_game(owner.game, sc)

	return sc
}

destroy_sprite_component :: proc(s: ^Sprite_Component) {
	remove_sprite_from_game(s.base.owner.game, s)
}

draw_sprite_component :: proc(s: ^Sprite_Component) {
	gl.DrawElements(u32(gl.TRIANGLES), 6, gl.UNSIGNED_INT, nil)

	// a := s.owner

	// if s.texture == nil do return

	// r: sdl.Rect
	// r.w = i32(f32(s.tex_width) * a.scale)
	// r.h = i32(f32(s.tex_height) * a.scale)
	// r.x = i32(a.position.x - f32(r.w / 2))
	// r.y = i32(a.position.y - f32(r.h / 2))

	// sdl.RenderCopyEx(
	// 	a.game.renderer,
	// 	s.texture,
	// 	nil,
	// 	&r,
	// 	f64(linalg.to_degrees(a.rotation)),
	// 	nil,
	// 	.NONE,
	// )
}

set_sprite_texture :: proc(s: ^Sprite_Component, texture: ^sdl.Texture) {
	s.texture = texture
	sdl.QueryTexture(texture, nil, nil, &s.tex_width, &s.tex_height)
}

get_sprite_from_component :: proc(comp: ^Component) -> ^Sprite_Component {
	#partial switch &variant in comp.derived {
	case Sprite_Component:
		return &variant
	}
	panic("unhandled sprite component")
}
