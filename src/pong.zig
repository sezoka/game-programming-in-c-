const std = @import("std");
const sdl = @import("zsdl");

const Game = struct {
    is_running: bool,
    window: *sdl.Window,
    renderer: *sdl.Renderer,
    ball_pos: Vec2,
    ball_vel: Vec2,
    ticks_count: u32,
    left_paddle_pos: Vec2,
    left_paddle_dir: f32,
    right_paddle_pos: Vec2,
    right_paddle_dir: f32,
};

const Vec2 = struct {
    x: f32,
    y: f32,
};

const THICKNESS = 15.0;
const PADDLE_HEIGHT = THICKNESS * 6.0;

pub fn main() !void {
    var game = initialize_game() catch return;

    run_loop(&game);

    defer shutdown(&game);
}

fn initialize_game() !Game {
    sdl.init(.{ .video = true }) catch {
        std.log.err("Unable to initialize SDL: {s}", .{sdl.getError().?});
        return error.InitError;
    };
    errdefer sdl.quit();

    const window = sdl.Window.create(
        "Game programming in C++ (Chapter 1)",
        100,
        100,
        1024,
        768,
        .{},
    ) catch {
        std.log.err("Failed to create window: {s}", .{sdl.getError().?});
        return error.InitError;
    };
    errdefer window.destroy();

    const renderer = sdl.Renderer.create(window, null, .{ .accelerated = true, .present_vsync = true }) catch {
        std.log.err("Failed to create renderer: {s}", .{sdl.getError().?});
        return error.InitError;
    };

    const ball_pos = .{
        .x = 512,
        .y = 384,
    };

    const left_paddle_pos = .{
        .x = THICKNESS,
        .y = 384,
    };

    const right_paddle_pos = .{
        .x = 1366 - THICKNESS,
        .y = 384,
    };

    const ball_vel = .{
        .x = -200.0,
        .y = 235.0,
    };

    return .{
        .is_running = false,
        .window = window,
        .renderer = renderer,
        .ball_pos = ball_pos,
        .ball_vel = ball_vel,
        .left_paddle_pos = left_paddle_pos,
        .right_paddle_pos = right_paddle_pos,
        .ticks_count = sdl.getTicks(),
        .left_paddle_dir = 0.0,
        .right_paddle_dir = 0.0,
    };
}

fn shutdown(game: *Game) void {
    game.window.destroy();
    game.renderer.destroy();
    sdl.quit();
}

fn run_loop(game: *Game) void {
    game.is_running = true;

    while (game.is_running) {
        process_input(game);
        update_game(game);
        generate_output(game);
    }
}

fn process_input(game: *Game) void {
    var event: sdl.Event = undefined;
    while (sdl.pollEvent(&event)) {
        switch (event.type) {
            .quit => {
                game.is_running = false;
            },
            else => {},
        }
    }

    const key_state = sdl.getKeyboardState();

    if (key_state[@intFromEnum(sdl.Scancode.escape)] != 0) {
        game.is_running = false;
    }

    game.left_paddle_dir = 0.0;
    if (key_state[@intFromEnum(sdl.Scancode.w)] != 0) {
        game.left_paddle_dir = -1.0;
    }
    if (key_state[@intFromEnum(sdl.Scancode.s)] != 0) {
        game.left_paddle_dir += 1.0;
    }

    game.right_paddle_dir = 0.0;
    if (key_state[@intFromEnum(sdl.Scancode.i)] != 0) {
        game.right_paddle_dir = -1.0;
    }
    if (key_state[@intFromEnum(sdl.Scancode.k)] != 0) {
        game.right_paddle_dir += 1.0;
    }
}

fn generate_output(game: *Game) void {
    game.renderer.setDrawColorRGBA(255, 255, 255, 255) catch unreachable;
    game.renderer.clear() catch unreachable;

    game.renderer.setDrawColorRGBA(0, 0, 0, 255) catch unreachable;

    const ball = sdl.RectF{
        .x = game.ball_pos.x - THICKNESS / 2.0,
        .y = game.ball_pos.y - THICKNESS / 2.0,
        .w = THICKNESS,
        .h = THICKNESS,
    };

    const left_paddle = sdl.RectF{
        .x = game.left_paddle_pos.x - THICKNESS / 2.0,
        .y = game.left_paddle_pos.y - PADDLE_HEIGHT / 2.0,
        .w = THICKNESS,
        .h = PADDLE_HEIGHT,
    };

    const right_paddle = sdl.RectF{
        .x = game.right_paddle_pos.x - THICKNESS / 2.0,
        .y = game.right_paddle_pos.y - PADDLE_HEIGHT / 2.0,
        .w = THICKNESS,
        .h = PADDLE_HEIGHT,
    };

    game.renderer.fillRectF(ball) catch unreachable;
    game.renderer.fillRectF(left_paddle) catch unreachable;
    game.renderer.fillRectF(right_paddle) catch unreachable;

    game.renderer.present();
}

fn update_game(game: *Game) void {
    defer game.ticks_count = sdl.getTicks();

    var delta_time = @as(f32, @floatFromInt(sdl.getTicks() - game.ticks_count)) / 1000.0;

    if (0.05 < delta_time) delta_time = 0.05;

    clap_paddle_position(&game.left_paddle_pos, game.left_paddle_dir, delta_time);
    clap_paddle_position(&game.right_paddle_pos, game.right_paddle_dir, delta_time);

    game.ball_pos.x += game.ball_vel.x * delta_time;
    game.ball_pos.y += game.ball_vel.y * delta_time;

    if (768.0 - THICKNESS < game.ball_pos.y) {
        game.ball_pos.y = 768.0 - THICKNESS;
        game.ball_vel.y *= -1.0;
    } else if (game.ball_pos.y < THICKNESS) {
        game.ball_pos.y = THICKNESS;
        game.ball_vel.y *= -1.0;
    } else if (game.ball_pos.x < THICKNESS) {
        game.ball_pos.x = THICKNESS;
        game.ball_vel.x *= -1.0;
    } else if (1366.0 - THICKNESS < game.ball_pos.x) {
        game.ball_pos.x = 1366.0 - THICKNESS;
        game.ball_vel.x *= -1.0;
    }

    if (is_ball_collide_with_paddle(game, game.left_paddle_pos.y, 20.0, 25.0, false))
        game.ball_vel.x *= -1.0;

    if (is_ball_collide_with_paddle(game, game.right_paddle_pos.y, 1366.0 - 25.0, 1366.0 - 20.0, true))
        game.ball_vel.x *= -1.0;
}

fn clap_paddle_position(paddle_pos: *Vec2, paddle_dir: f32, delta: f32) void {
    if (paddle_dir != 0.0) {
        paddle_pos.y += paddle_dir * 400.0 * delta;
        if (paddle_pos.y < (PADDLE_HEIGHT / 2.0 + THICKNESS)) {
            paddle_pos.y = PADDLE_HEIGHT / 2.0 + THICKNESS;
        } else if ((768.0 - PADDLE_HEIGHT / 2.0 - THICKNESS) < paddle_pos.y) {
            paddle_pos.y = 768.0 - PADDLE_HEIGHT / 2.0 - THICKNESS;
        }
    }
}

fn is_ball_collide_with_paddle(game: *Game, paddle_y: f32, paddle_left_border: f32, paddle_right_border: f32, ball_moves_right: bool) bool {
    const right_paddle_diff = @fabs(game.ball_pos.y - paddle_y);
    return right_paddle_diff <= PADDLE_HEIGHT / 2.0 and
        paddle_left_border <= game.ball_pos.x and game.ball_pos.x <= paddle_right_border and
        (ball_moves_right and 0.0 < game.ball_vel.x or
        !ball_moves_right and game.ball_vel.x < 0.0);
}
