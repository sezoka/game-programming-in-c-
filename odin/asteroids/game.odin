package asteroids

import "../shared"
import "core:fmt"
import sdl "vendor:sdl2"
import sdl_img "vendor:sdl2/image"

WIDTH :: 1280
HEIGHT :: 720

Game :: struct {
	actors:          [dynamic]^Actor,
	pending_actors:  [dynamic]^Actor,
	updating_actors: bool,
	ticks_count:     u32,
	window:          ^sdl.Window,
	renderer:        ^sdl.Renderer,
	is_running:      bool,
	sprites:         [dynamic]^Component,
	textures:        map[string]^sdl.Texture,
	ship:            ^Actor,
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
		actors          = make([dynamic]^Actor),
		pending_actors  = make([dynamic]^Actor),
		updating_actors = false,
		window          = window,
		renderer        = renderer,
		ticks_count     = sdl.GetTicks(),
		is_running      = true,
	}

	load_data(g)

	return false
}

add_actor :: proc(g: ^Game, actor: ^Actor) {
	if g.updating_actors {
		append(&g.pending_actors, actor)
	} else {
		append(&g.actors, actor)
	}
}

remove_actor :: proc(g: ^Game, actor: ^Actor) {
	for a, i in g.pending_actors {
		if a == actor {
			unordered_remove(&g.pending_actors, i)
			return
		}
	}

	for a, i in g.actors {
		if a == actor {
			unordered_remove(&g.actors, i)
			return
		}
	}
}

update_game :: proc(g: ^Game) {
	for !sdl.TICKS_PASSED(sdl.GetTicks(), g.ticks_count + 16) {}

	delta := f64(sdl.GetTicks() - g.ticks_count) / 1000
	g.ticks_count = sdl.GetTicks()

	if 0.05 < delta {
		delta = 0.05
	}

	{
		g.updating_actors = true
		for actor in g.actors {
			update_actor(actor, delta)
		}
		g.updating_actors = false
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

run_loop :: proc(g: ^Game) {
	for g.is_running {
		process_input(g)
		update_game(g)
		generate_output(g)
	}
}

generate_output :: proc(g: ^Game) {
	sdl.SetRenderDrawColor(g.renderer, 0, 0, 0, 255)
	sdl.RenderClear(g.renderer)

	for sprite in g.sprites {
		draw_sprite(sprite, g.renderer)
	}

	sdl.RenderPresent(g.renderer)
}

process_input :: proc(g: ^Game) {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {
		case .QUIT:
			g.is_running = false
		case:
		}
	}

	state := sdl.GetKeyboardState(nil)

	for actor in &g.actors {
		switch &inner in &actor.variant {
		case Asteroid_Actor:
		}
	}
}

shutdown :: proc(g: ^Game) {
	unload_data(g)
	sdl_img.Quit()
	sdl.DestroyRenderer(g.renderer)
	sdl.DestroyWindow(g.window)
	sdl.Quit()
}

add_sprite :: proc(g: ^Game, sprite_component: ^Component) {
	sprite := sprite_component.variant.(Sprite_Component)

	insert_idx := 0
	for ; insert_idx < len(g.sprites); insert_idx += 1 {
		if sprite.draw_order < get_sprite_draw_order(g.sprites[insert_idx]) {
			inject_at(&g.sprites, insert_idx, sprite_component)
			return
		}
	}

	append(&g.sprites, sprite_component)
}

remove_sprite :: proc(g: ^Game, sprite_component: ^Component) {
	for sprite, i in g.sprites {
		if sprite == sprite_component {
			ordered_remove(&g.sprites, i)
		}
	}
}

load_data :: proc(g: ^Game) {
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
	create_asteroid_actor(g)
}

unload_data :: proc(g: ^Game) {
	for len(g.pending_actors) != 0 {
		destroy_actor(g.pending_actors[0])
	}
	delete(g.pending_actors)

	for len(g.actors) != 0 {
		destroy_actor(g.actors[0])
	}
	delete(g.actors)

	for _, texture in g.textures {
		sdl.DestroyTexture(texture)
	}
	delete(g.textures)

	for sprite in g.sprites {
		destroy_component(sprite)
	}
	delete(g.sprites)
}
