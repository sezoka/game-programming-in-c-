package asteroids

Laser_Actor :: struct {
	circle:      ^Component,
	death_timer: f64,
}

create_laser_actor :: proc(g: ^Game) -> ^Actor {
	actor := create_actor(g)
	actor.variant = Laser_Actor {
		circle      = nil,
		death_timer = 1.0,
	}

	sc := create_sprite_component(actor)
	sv := &sc.variant.(Sprite_Component)
	set_texture(sv, get_texture(g, "./assets/Laser.png"))

	mc := create_move_component(actor)
	mv := &mc.variant.(Move_Component)
	mv.forward_speed = 800

	cc := create_circle_component(actor)
	cv := cc.variant.(Circle_Component)
	cv.radius = 11

	return actor
}

update_laser_actor :: proc(l: ^Laser_Actor, base: ^Actor, delta: f64) {
	l.death_timer -= delta
	if l.death_timer <= 0 {
		base.state = .Dead
		return
	}

	for ast in base.game.asteroids {
		if is_circle_intersect(
			   &l.circle.variant.(Circle_Component),
			   base,
			   &ast.variant.(Asteroid_Actor).circle.variant.(Circle_Component),
			   ast,
		   ) {
        base.state = .Dead
        ast.state = .Dead
        return
		}
	}
}
