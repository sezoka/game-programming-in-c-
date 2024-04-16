package asteroids

import "core:log"
import "core:os"
import gl "vendor:OpenGL"
import sdl "vendor:sdl2"

Shader :: struct {
	shader_program_id: u32,
}

load_shader :: proc(s: ^Shader, vert_name: string, frag_name: string) -> bool {
	program_id, ok := gl.load_shaders(vert_name, frag_name)
	if !ok {
		log.error("Failed to compile shaders:", vert_name, frag_name)
		return false
	}

	s.shader_program_id = program_id

	return true
}

set_active_shader :: proc(s: ^Shader) {
	gl.UseProgram(s.shader_program_id)
}

destroy_shader :: proc(s: ^Shader) {
	gl.DeleteShader(s.shader_program_id)
}
