package asteroids

import "core:math"
import sdl "vendor:sdl2"

Input_Component :: struct {
	max_forward_speed:     f64,
	max_angular_speed:     f64,
	forward_key:           sdl.Scancode,
	back_key:              sdl.Scancode,
	clockwise_key:         sdl.Scancode,
	counter_clockwise_key: sdl.Scancode,
	using move_comp:       ^Move_Component,
}

create_input_component :: proc(a: ^Actor) -> ^Component {
	input := create_component(a)
	input.variant = Input_Component{}
	return input
}

process_input_input_component :: proc(ic: ^Input_Component, base: ^Component, key_state: []u8) {
	forward_speed := 0.0
	if key_state[ic.forward_key] != 0 {
		forward_speed += ic.max_forward_speed
	}
	if key_state[ic.back_key] != 0 {
		forward_speed -= ic.max_forward_speed
	}
	ic.forward_speed = forward_speed

  angular_speed := 0.0
  if key_state[ic.clockwise_key] != 0 {
    angular_speed += ic.angular_speed
  }
  if key_state[ic.counter_clockwise_key] != 0 {
    angular_speed -= ic.angular_speed
  }
  ic.angular_speed = angular_speed
}
