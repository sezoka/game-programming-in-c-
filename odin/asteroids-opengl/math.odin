package asteroids

import "core:math"
import "core:math/linalg"

Vector2 :: linalg.Vector2f32

near_zero :: proc(val: f32) -> bool {
	return abs(val) <= math.F32_EPSILON
}

create_scale_matrix :: proc(w: f32, h: f32, z: f32) -> matrix[4, 4]f32 {
	return matrix[4, 4]f32{
			w, 0, 0, 0, 
			0, h, 0, 0, 
			0, 0, z, 0, 
			0, 0, 0, 1, 
		}
}
