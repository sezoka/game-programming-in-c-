package asteroids

import "core:fmt"

Laser_Actor :: struct {
	circle:      ^Circle_Component,
	death_timer: f32,
	using base:  ^Actor,
}

create_laser_actor :: proc(g: ^Game) -> ^Laser_Actor {
	laser := create_actor(Laser_Actor, g)
	laser.death_timer = 1.0

	sc := create_sprite_component(laser)
	set_sprite_texture(sc, get_texture(g, "../../assets/asteroids/Laser.png"))

	mc := create_move_component(laser)
	mc.forward_speed = 800


	circle := create_circle_component(laser)
	circle.radius = 11
  laser.circle = circle

	return laser
}

update_laser_actor :: proc(la: ^Laser_Actor, delta: f32) {

	// If we run out of time, laser is dead
	la.death_timer -= delta
	if (la.death_timer <= 0.0) {
		la.state = .Dead
		return
	}
	// Do we intersect with an asteroid?
	for asteroid in la.game.asteroids {
		if (check_is_circles_intersect(la.circle, asteroid.circle)) {
			// The first asteroid we intersect with,
			// set ourselves and the asteroid to dead
			la.state = .Dead
			asteroid.state = .Dead
			break
		}
	}
  fmt.print("HER\n")
}
