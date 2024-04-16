package asteroids

import "core:fmt"
import "core:math"
import gl "vendor:OpenGL"
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
	gl_context:         sdl.GLContext,
	ticks_count:        u32,
	is_running:         bool,
	is_updating_actors: bool,
	ship:               ^Ship_Actor,
	asteroids:          [dynamic]^Asteroid_Actor,
	sprite_verts:       Vertex_Array,
	sprite_shader:      Shader,
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

	{
		// opengl attributes
		sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, i32(sdl.GLprofile.CORE))
		sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
		sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 3)

		sdl.GL_SetAttribute(.RED_SIZE, 8)
		sdl.GL_SetAttribute(.GREEN_SIZE, 8)
		sdl.GL_SetAttribute(.BLUE_SIZE, 8)
		sdl.GL_SetAttribute(.ALPHA_SIZE, 8)

		sdl.GL_SetAttribute(.DOUBLEBUFFER, 1)
		sdl.GL_SetAttribute(.ACCELERATED_VISUAL, 1)
	}

	window := sdl.CreateWindow(
		"Game Programming in Odin (Chapter 5)",
		100,
		100,
		WIDTH,
		HEIGHT,
		sdl.WINDOW_OPENGL,
	)

	gl_context := sdl.GL_CreateContext(window)
	gl.load_up_to(3, 3, sdl.gl_set_proc_address)

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
		gl_context     = gl_context,
		ticks_count    = sdl.GetTicks(),
		is_running     = true,
	}

	if !load_shaders(g) {
		return false
	}

	init_sprite_verts(g)

	load_data(g)

	return true
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
		defer delete(dead_actors)
		for actor in g.actors {
			if actor.state == .Dead {
				append(&dead_actors, actor)
			}
		}
		for actor in dead_actors {
			destroy_actor(actor)
		}
	}
}

init_sprite_verts :: proc(g: ^Game) {
  // odinfmt: disable
  verts := []f32{
		-0.5,  0.5, 0, 0, 0, // top let
		 0.5,  0.5, 0, 1, 0, // top right
		 0.5, -0.5, 0, 1, 1, // bottom right
		-0.5, -0.5, 0, 0, 1  // bottom let
	};

  indices := []i32{
		0, 1, 2,
		2, 3, 0,
	};
  // odinfmt: enable

	g.sprite_verts = create_vertex_array(verts, 4, indices)
}

load_shaders :: proc(g: ^Game) -> bool {
	if !load_shader(&g.sprite_shader, "./shaders/basic_vert.glsl", "./shaders/basic_frag.glsl") {
		return false
	}
	set_active_shader(&g.sprite_shader)
	return true
}

generate_output :: proc(g: ^Game) {
	gl.ClearColor(0.86, 0.86, 0.86, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	set_active_shader(&g.sprite_shader)
	set_active_vertex_array(&g.sprite_verts)

	for sprite in g.sprites {
		draw_sprite_component(sprite)
	}

	sdl.GL_SwapWindow(g.window)
}

shutdown :: proc(g: ^Game) {
	unload_data(g)
	sdl_img.Quit()
	sdl.GL_DeleteContext(g.gl_context)
	sdl.DestroyWindow(g.window)
	sdl.Quit()
}

load_data :: proc(g: ^Game) {
	ship := create_ship_actor(g)
	ship.base.position = {512, 384}
	ship.base.rotation = math.PI / 2
	g.ship = ship

	num_asteroids := 20
	for _ in 0 ..< num_asteroids {
		append(&g.asteroids, create_asteroid_actor(g))
	}
}

remove_asteroid_from_game :: proc(g: ^Game, a: ^Asteroid_Actor) {
	for ast, i in &g.asteroids {
		if ast == a {
			unordered_remove(&g.asteroids, i)
			return
		}
	}
}

unload_data :: proc(g: ^Game) {
	destroy_shader(&g.sprite_shader)
	destroy_vertex_array(&g.sprite_verts)

	// Delete actors
	for (len(g.actors) != 0) {
		destroy_actor(g.actors[len(g.actors) - 1])
	}

	// Destroy textures
	for _, tex in g.textures {
		sdl.DestroyTexture(tex)
	}
	delete(g.textures)

	delete(g.asteroids)
	delete(g.sprites)
	delete(g.pending_actors)
	delete(g.actors)
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
