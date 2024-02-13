package pong

import "core:fmt"
import "core:math"
import sdl "vendor:sdl2"

WIDTH :: 1024
HEIGHT :: 768
THICKNESS :: 15
PADDLE_H :: THICKNESS * 6

Vector2 :: struct {
	x: f32,
	y: f32,
}

Game :: struct {
	is_running:       bool,
	window:           ^sdl.Window,
	renderer:         ^sdl.Renderer,
	ball_poss:        [2]Vector2,
	ball_vels:        [2]Vector2,
	ticks_count:      u32,
	left_paddle_pos:  Vector2,
	left_paddle_dir:  f32,
	right_paddle_pos: Vector2,
	right_paddle_dir: f32,
}

pong_main :: proc() {
	game: Game
	if !init(&game) do return
	run_loop(&game)
	shutdown(&game)
}

init :: proc(g: ^Game) -> bool {
	sdl_result := sdl.Init(sdl.INIT_VIDEO)
	if sdl_result != 0 {
		sdl.Log("Unable to initialize SDL: %s", sdl.GetError())
		return false
	}

	g.window = sdl.CreateWindow("Pong", 100, 100, WIDTH, HEIGHT, nil)
	if g.window == nil {
		sdl.Log("Failed to create window: %s", sdl.GetError())
		return false
	}

	g.renderer = sdl.CreateRenderer(g.window, -1, {.PRESENTVSYNC, .ACCELERATED})
	g.is_running = true
	g.ball_poss[0] = Vector2 {
		x = WIDTH / 2 - THICKNESS / 2,
		y = HEIGHT / 2 - THICKNESS / 2,
	}
	g.ball_poss[1] = Vector2 {
		x = WIDTH / 2 - THICKNESS / 2,
		y = HEIGHT / 2 - THICKNESS / 2,
	}
	g.left_paddle_pos = Vector2 {
		x = WIDTH / 4 - THICKNESS / 2,
		y = HEIGHT / 2 - THICKNESS,
	}
	g.right_paddle_pos = Vector2 {
		x = WIDTH / 4 * 3 - THICKNESS / 2,
		y = HEIGHT / 2 - THICKNESS,
	}
	g.ball_vels[0] = {
		x = -200,
		y = 235,
	}
	g.ball_vels[1] = {
		x = 200,
		y = -235,
	}

	return true
}

run_loop :: proc(g: ^Game) {
	for g.is_running {
		process_input(g)
		update_game(g)
		generate_output(g)
	}
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

	if state[sdl.SCANCODE_ESCAPE] != 0 {
		g.is_running = false
	}

	g.left_paddle_dir = 0
	if state[sdl.SCANCODE_W] != 0 {
		g.left_paddle_dir -= 1
	}
	if state[sdl.SCANCODE_S] != 0 {
		g.left_paddle_dir += 1
	}

	g.right_paddle_dir = 0
	if state[sdl.SCANCODE_UP] != 0 {
		g.right_paddle_dir -= 1
	}
	if state[sdl.SCANCODE_DOWN] != 0 {
		g.right_paddle_dir += 1
	}

}

update_game :: proc(g: ^Game) {
	for !sdl.TICKS_PASSED(sdl.GetTicks(), g.ticks_count + 16) {}

	delta_time := f32(sdl.GetTicks() - g.ticks_count) / 1000
	g.ticks_count = sdl.GetTicks()

	if 0.05 < delta_time {
		delta_time = 0.05
	}

	if g.left_paddle_dir != 0 {
		g.left_paddle_pos.y += g.left_paddle_dir * 300 * delta_time
		if g.left_paddle_pos.y < (PADDLE_H / 2 + THICKNESS) {
			g.left_paddle_pos.y = PADDLE_H / 2 + THICKNESS
		} else if (HEIGHT - PADDLE_H / 2 - THICKNESS) < g.left_paddle_pos.y {
			g.left_paddle_pos.y = HEIGHT - PADDLE_H / 2 - THICKNESS
		}
	}

	if g.right_paddle_dir != 0 {
		g.right_paddle_pos.y += g.right_paddle_dir * 300 * delta_time
		if g.right_paddle_pos.y < (PADDLE_H / 2 + THICKNESS) {
			g.right_paddle_pos.y = PADDLE_H / 2 + THICKNESS
		} else if (HEIGHT - PADDLE_H / 2 - THICKNESS) < g.right_paddle_pos.y {
			g.right_paddle_pos.y = HEIGHT - PADDLE_H / 2 - THICKNESS
		}
	}

	for i in 0 ..< 2 {
		ball_vel := &g.ball_vels[i]
		ball_pos := &g.ball_poss[i]

		ball_pos.x += ball_vel.x * delta_time
		ball_pos.y += ball_vel.y * delta_time

		if ball_pos.y < THICKNESS + THICKNESS / 2 && ball_vel.y < 0 {
			ball_vel.y *= -1
		}
		if HEIGHT - THICKNESS - THICKNESS / 2 <= ball_pos.y && 0 < ball_vel.y {
			ball_vel.y *= -1
		}
		if ball_pos.x < THICKNESS / 2 && ball_vel.x < 0 {
			ball_vel.x *= -1
		}
		if WIDTH - THICKNESS / 2 <= ball_pos.x && 0 < ball_vel.x {
			ball_vel.x *= -1
		}

		left_diff := abs(g.left_paddle_pos.y - ball_pos.y)
		if left_diff <= PADDLE_H / 2 &&
		   ball_pos.x <= g.left_paddle_pos.x + THICKNESS &&
		   g.left_paddle_pos.x <= ball_pos.x &&
		   ball_vel.x < 0 {
			ball_vel.x *= -1
		}
		right_diff := abs(g.right_paddle_pos.y - ball_pos.y)
		if right_diff <= PADDLE_H / 2 &&
		   ball_pos.x <= g.right_paddle_pos.x + THICKNESS &&
		   g.right_paddle_pos.x - THICKNESS <= ball_pos.x &&
		   0 < ball_vel.x {
			ball_vel.x *= -1
		}
	}

}

generate_output :: proc(g: ^Game) {
	sdl.SetRenderDrawColor(g.renderer, 100, 100, 100, 100)
	sdl.RenderClear(g.renderer)

	sdl.SetRenderDrawColor(g.renderer, 0, 0, 0, 255)
	top_wall := sdl.Rect{0, 0, WIDTH, THICKNESS}
	sdl.RenderFillRect(g.renderer, &top_wall)
	bottom_wall := sdl.Rect{0, HEIGHT - THICKNESS, WIDTH, THICKNESS}
	sdl.RenderFillRect(g.renderer, &bottom_wall)

	for ball_pos in g.ball_poss {
		ball := sdl.Rect {
			i32(ball_pos.x) - THICKNESS / 2,
			i32(ball_pos.y) - THICKNESS / 2,
			THICKNESS,
			THICKNESS,
		}
		sdl.SetRenderDrawColor(g.renderer, 200, 200, 200, 255)
		sdl.RenderFillRect(g.renderer, &ball)
	}

	left_paddle := sdl.Rect {
		i32(g.left_paddle_pos.x) - THICKNESS / 2,
		i32(g.left_paddle_pos.y) - PADDLE_H / 2,
		THICKNESS,
		PADDLE_H,
	}
	sdl.SetRenderDrawColor(g.renderer, 0, 0, 0, 255)
	sdl.RenderFillRect(g.renderer, &left_paddle)

	right_paddle := sdl.Rect {
		i32(g.right_paddle_pos.x) - THICKNESS / 2,
		i32(g.right_paddle_pos.y) - PADDLE_H / 2,
		THICKNESS,
		PADDLE_H,
	}
	sdl.RenderFillRect(g.renderer, &right_paddle)

	sdl.RenderPresent(g.renderer)
}

shutdown :: proc(g: ^Game) {
	sdl.DestroyWindow(g.window)
	sdl.Quit()
}
