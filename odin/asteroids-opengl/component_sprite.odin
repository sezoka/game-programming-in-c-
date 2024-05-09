package asteroids

import "core:fmt"
import "core:math/linalg"
import glsl "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

Sprite_Variant :: union {}
Sprite_Component :: struct {
	base:           ^Component,
	texture:        ^Texture,
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
	scale_matrix := create_scale_matrix(f32(s.tex_width), f32(s.tex_height), 1.0)
	world_matrix := scale_matrix * s.base.owner.world_transform
	set_matrix_uniform(shader, "u_world_transform", linalg.transpose(world_matrix))
	set_active_texture(s.texture)
	gl.DrawElements(u32(gl.TRIANGLES), 6, gl.UNSIGNED_INT, nil)
}

set_sprite_texture :: proc(s: ^Sprite_Component, texture: ^Texture) {
	s.texture = texture
	s.tex_width = texture.width
	s.tex_height = texture.height
}

get_sprite_from_component :: proc(comp: ^Component) -> ^Sprite_Component {
	#partial switch &variant in comp.derived {
	case Sprite_Component:
		return &variant
	}
	panic("unhandled sprite component")
}
