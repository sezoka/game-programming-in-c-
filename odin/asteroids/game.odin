package asteroids

import "core:math"
import "core:fmt"
import sdl "vendor:sdl2"
import sdl_img "vendor:sdl2/image"

WIDTH :: 1280
HEIGHT :: 720

Game :: struct {
	textures:           map[string]^sdl.Texture,
	actors:             [dynamic]^Actor,
	pending_actors:     [dynamic]^Actor,
	sprites:            [dynamic]^Sprite_Component,
	window:             ^sdl.Window,
	renderer:           ^sdl.Renderer,
	ticks_count:        u32,
	is_running:         bool,
	is_updating_actors: bool,

	// Game-specific
	// ship:               ^Ship_Actor,
	// asteroids:          [dynamic]^Asteroid,
}

create_game :: proc() -> Game {
	g: Game
	g.is_running = true
	return g
}

init_game :: proc(g: ^Game) -> bool {
	sdl_result := sdl.Init(sdl.INIT_VIDEO)
	if sdl_result != 0 {
		sdl.Log("Unable to initialize SDL: %s", sdl.GetError())
		return false
	}
	window := sdl.CreateWindow("Pong", 100, 100, WIDTH, HEIGHT, nil)
	if window == nil {
		sdl.Log("Failed to create window: %s", sdl.GetError())
		return false
	}
	renderer := sdl.CreateRenderer(window, -1, {.PRESENTVSYNC, .ACCELERATED})

	sdl_img.Init(sdl_img.INIT_PNG)
	if window == nil {
		sdl.Log("Failed to initialize SDL_image: %s", sdl.GetError())
		return false
	}

	g^ = {
		actors         = make([dynamic]^Actor),
		pending_actors = make([dynamic]^Actor),
		window         = window,
		renderer       = renderer,
		ticks_count    = sdl.GetTicks(),
		is_running     = true,
	}

	load_data(g)

	return false
}

run_game_loop :: proc(g: ^Game) {
	for g.is_running {
		process_game_input(g)
		update_game(g)
		generate_output(g)
	}
}


process_game_input :: proc(g: ^Game) {
	ev: sdl.Event
	for (sdl.PollEvent(&ev)) {
		#partial switch ev.type {
		case .QUIT:
			g.is_running = false
			break
		}
	}

	key_state := sdl.GetKeyboardState(nil)
	if (key_state[sdl.SCANCODE_ESCAPE] != 0) {
		g.is_running = false
	}

	g.is_updating_actors = true
	for actor in g.actors {
		process_input_for_actor(actor, key_state)
	}
	g.is_updating_actors = false
}

update_game :: proc(g: ^Game) {
	for !sdl.TICKS_PASSED(sdl.GetTicks(), g.ticks_count + 16) {}

	delta := f32(sdl.GetTicks() - g.ticks_count) / 1000
	g.ticks_count = sdl.GetTicks()

	if 0.05 < delta {
		delta = 0.05
	}

	{
		g.is_updating_actors = true
		for actor in g.actors {
			update_actor(actor, delta)
		}
		g.is_updating_actors = false
	}

	for actor in g.pending_actors {
		append(&g.actors, actor)
	}
	clear(&g.pending_actors)

	{
		dead_actors: [dynamic]^Actor
		for actor in g.actors {
			if actor.state == .Dead {
				append(&dead_actors, actor)
			}
		}
		for actor in dead_actors {
			free(actor)
		}
	}
}

generate_output :: proc(g: ^Game) {
	sdl.SetRenderDrawColor(g.renderer, 0, 0, 0, 255)
	sdl.RenderClear(g.renderer)

	for sprite in g.sprites {
		draw_sprite_component(sprite, g.renderer)
	}

	sdl.RenderPresent(g.renderer)
}

shutdown :: proc(g: ^Game) {
	unload_data(g)
	sdl_img.Quit()
	sdl.DestroyRenderer(g.renderer)
	sdl.DestroyWindow(g.window)
	sdl.Quit()
}

load_data :: proc(g: ^Game) {
  ship := create_ship_actor(g)
  ship.position = {512, 384}
  ship.rotation = math.PI / 2

	num_asteroids := 20
	for _ in 0 ..< num_asteroids {
		create_asteroid_actor(g)
	}

}

unload_data :: proc(g: ^Game) {

}

add_actor_to_game :: proc(g: ^Game, a: ^Actor) {
	if g.is_updating_actors {
		append(&g.pending_actors, a)
	} else {
		append(&g.actors, a)
	}
}

remove_actor_from_game :: proc(g: ^Game, a: ^Actor) {
	for actor, i in g.pending_actors {
		if a == actor {
			unordered_remove(&g.pending_actors, i)
			return
		}
	}

	for actor, i in g.actors {
		if a == actor {
			unordered_remove(&g.actors, i)
			return
		}
	}
}

add_sprite_to_game :: proc(g: ^Game, sc: ^Sprite_Component) {
	insert_idx := 0
	for ; insert_idx < len(g.sprites); insert_idx += 1 {
		if sc.draw_order < g.sprites[insert_idx].draw_order {
			inject_at(&g.sprites, insert_idx, sc)
			return
		}
	}

	append(&g.sprites, sc)
}

remove_sprite_from_game :: proc(g: ^Game, sprite_component: ^Sprite_Component) {
	for sprite, i in g.sprites {
		if sprite == sprite_component {
			ordered_remove(&g.sprites, i)
		}
	}
}
