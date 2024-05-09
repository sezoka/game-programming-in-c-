package asteroids

import gl "vendor:OpenGL"


Vertex_Array :: struct {
	num_verts:        int,
	num_indices:      int,
	vertex_buffer_id: u32,
	index_buffer_id:  u32,
	vertex_array_id:  u32,
}

create_vertex_array :: proc(verts: []f32, num_verts: int, indices: []u32) -> Vertex_Array {
	arr: Vertex_Array
	arr.num_indices = len(indices)
	arr.num_verts = num_verts

	gl.GenVertexArrays(1, &arr.vertex_array_id)
	gl.BindVertexArray(arr.vertex_array_id)

	gl.GenBuffers(1, &arr.vertex_buffer_id)
	gl.BindBuffer(gl.ARRAY_BUFFER, arr.vertex_buffer_id)
	gl.BufferData(
		u32(gl.ARRAY_BUFFER),
		num_verts * 5 * size_of(f32),
		raw_data(verts),
		gl.STATIC_DRAW,
	)

	gl.GenBuffers(1, &arr.index_buffer_id)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, arr.index_buffer_id)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 6 * size_of(u32), raw_data(indices), gl.STATIC_DRAW)

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(f32) * 5, 0)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, size_of(f32) * 5, size_of(f32) * 3)
	return arr
}

destroy_vertex_array :: proc(arr: ^Vertex_Array) {
	gl.DeleteBuffers(1, &arr.vertex_array_id)
	gl.DeleteBuffers(1, &arr.index_buffer_id)
	gl.DeleteVertexArrays(1, &arr.vertex_array_id)
}

set_active_vertex_array :: proc(arr: ^Vertex_Array) {
	gl.BindVertexArray(arr.vertex_array_id)
}
