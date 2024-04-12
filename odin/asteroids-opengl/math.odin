package asteroids

import "core:math"
import "core:math/linalg"

Vector2 :: linalg.Vector2f32

near_zero :: proc(val: f32) -> bool {
	return abs(val) <= math.F32_EPSILON
}
