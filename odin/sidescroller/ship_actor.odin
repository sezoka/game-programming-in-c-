package sidescroller

import "core:fmt"
import sdl "vendor:sdl2"

Ship_Actor :: struct {
	right_speed: f32,
	down_speed:  f32,
}

create_ship_actor :: proc(g: ^Game) -> ^Actor {
	actor := create_actor(g)

	actor.variant = Ship_Actor {
		right_speed = 100,
	}
	asc_component := create_anim_sprite_component(actor, 120)
	asc := &asc_component.variant.(Anim_Sprite_Component)
	anims := [dynamic]^sdl.Texture {
		get_texture(g, "./sidescroller/assets/Ship01.png"),
		get_texture(g, "./sidescroller/assets/Ship02.png"),
		get_texture(g, "./sidescroller/assets/Ship03.png"),
		get_texture(g, "./sidescroller/assets/Ship04.png"),
	}

	set_anim_textures(asc, anims)

	return actor
}

update_ship_actor :: proc(a: ^Actor, delta: f32) {
	ship := a.variant.(Ship_Actor)

	pos := a.position
	pos.x += ship.right_speed * delta
	pos.y += ship.down_speed * delta

	if pos.x < 25 {
		pos.x = 25
	} else if pos.x > 500 {
		pos.x = 500
	}
	if pos.y < 25 {
		pos.y = 25.0
	} else if pos.y > HEIGHT - 64 {
		pos.y = HEIGHT - 64
	}
	a.position = pos
}

process_keyboard_ship :: proc(state: [^]u8, sa: ^Ship_Actor, base: ^Actor) {
	sa.right_speed = 0
	sa.down_speed = 0
	if state[sdl.SCANCODE_D] != 0 {
		sa.right_speed += 250
	}
	if state[sdl.SCANCODE_A] != 0 {
		sa.right_speed -= 250
	}
	if state[sdl.SCANCODE_S] != 0 {
		sa.down_speed += 300
	}
	if state[sdl.SCANCODE_W] != 0 {
		sa.down_speed -= 300
	}
}

