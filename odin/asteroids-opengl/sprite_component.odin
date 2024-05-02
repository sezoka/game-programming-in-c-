package asteroids

import "core:fmt"
import "core:math/linalg"
import glsl "core:math/linalg/glsl"
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


draw_sprite_component :: proc(s: ^Sprite_Component, shader: ^Shader) {
	scale_matrix := create_scale_matrix(f32(50), f32(50), 1.0)
	world_matrix := scale_matrix * s.base.owner.world_transform

	// for index in indices {
	// 	line := verts[index * 5:index * 5 + 5]
	// 	mat: matrix[1, 4]f32
	// 	mat[0, 0] = line[0]
	// 	mat[0, 1] = line[1]
	// 	mat[0, 2] = line[2]
	// 	mat[0, 3] = 1
	// 	mult := mat * scale_matrix * world_matrix * simple_view_projection
	// }

	set_matrix_uniform(shader, "u_world_transform", linalg.transpose(world_matrix))

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
