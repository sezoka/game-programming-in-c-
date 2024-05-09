package asteroids

update_actor_user_code :: proc(a: ^Actor, delta: f32) {
	switch &actor in a.derived {
	case Laser_Actor:
		update_laser_actor(&actor, delta)
	case Asteroid_Actor: // TODO
	case Ship_Actor:
		update_ship_actor(&actor, delta)
	}
}

destroy_actor :: proc(a: ^Actor) {
	for len(a.components) != 0 {
		comp := a.components[0]
		destroy_component(comp)
	}
	delete(a.components)
	switch &actor in a.derived {
	case Ship_Actor:
	case Asteroid_Actor:
		remove_asteroid_from_game(a.game, &actor)
	case Laser_Actor:
	}
	remove_actor_from_game(a.game, a)
	free(a)
}
