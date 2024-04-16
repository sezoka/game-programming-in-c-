package asteroids

import "core:fmt"
import sdl "vendor:sdl2"

Input_Component :: struct {
	base:            ^Move_Component,
	// The maximum forward/angular speeds
	max_forward_speed:     f32,
	max_angular_speed:     f32,
	// Keys for forward/back movement
	forward_key:           sdl.Scancode,
	back_key:              sdl.Scancode,
	// Keys for angular movement
	clockwise_key:         sdl.Scancode,
	counter_clockwise_key: sdl.Scancode,
}

create_input_component :: proc(a: ^Actor) -> ^Input_Component {
	move := create_move_component_variant(Input_Component, a)
	return move
}

process_input_for_input_component :: proc(ic: ^Input_Component, key_state: [^]u8) {
	// Calculate forward speed for MoveComponent
	forward_speed: f32
	if key_state[ic.forward_key] != 0 {
		forward_speed += ic.max_forward_speed
	}
	if (key_state[ic.back_key] != 0) {
		forward_speed -= ic.max_forward_speed
	}
	ic.base.forward_speed = forward_speed

	// Calculate angular speed for MoveComponent
	angular_speed: f32
	if (key_state[ic.clockwise_key] != 0) {
		angular_speed += ic.max_angular_speed
	}
	if (key_state[ic.counter_clockwise_key] != 0) {
		angular_speed -= ic.max_angular_speed
	}
	ic.base.angular_speed = angular_speed
}
