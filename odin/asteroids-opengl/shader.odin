package asteroids

import "core:fmt"
import "core:log"
import "core:math/linalg"
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

set_matrix_uniform :: proc(s: ^Shader, name: cstring, mat: matrix[4, 4]f32) {
	mat := mat
	location := gl.GetUniformLocation(s.shader_program_id, name)
	gl.UniformMatrix4fv(location, 1, gl.TRUE, &mat[0, 0])
}

set_active_shader :: proc(s: ^Shader) {
	gl.UseProgram(s.shader_program_id)
}

destroy_shader :: proc(s: ^Shader) {
	gl.DeleteShader(s.shader_program_id)
}
