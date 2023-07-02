const std = @import("std");
const sdl = @import("zsdl");

const Game = struct {
    is_running: bool,
    window: *sdl.Window,
    renderer: *sdl.Renderer,
    paddle_pos: Vec2,
    ball_pos: Vec2,
    ball_vel: Vec2,
    ticks_count: u32,
    paddle_dir: f32,
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

    const renderer = sdl.Renderer.create(window, null, .{ .accelerated = true, .present_vsync = false }) catch {
        std.log.err("Failed to create renderer: {s}", .{sdl.getError().?});
        return error.InitError;
    };

    const ball_pos = .{
        .x = 512,
        .y = 384,
    };

    const paddle_pos = .{
        .x = THICKNESS,
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
        .paddle_pos = paddle_pos,
        .ticks_count = sdl.getTicks(),
        .paddle_dir = 0.0,
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

    game.paddle_dir = 0.0;
    if (key_state[@intFromEnum(sdl.Scancode.w)] != 0) {
        game.paddle_dir = -1.0;
    }
    if (key_state[@intFromEnum(sdl.Scancode.s)] != 0) {
        game.paddle_dir += 1.0;
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

    const paddle = sdl.RectF{
        .x = game.paddle_pos.x - THICKNESS / 2.0,
        .y = game.paddle_pos.y - PADDLE_HEIGHT / 2.0,
        .w = THICKNESS,
        .h = PADDLE_HEIGHT,
    };

    game.renderer.fillRectF(ball) catch unreachable;
    game.renderer.fillRectF(paddle) catch unreachable;

    game.renderer.present();
}

fn update_game(game: *Game) void {
    defer game.ticks_count = sdl.getTicks();

    var delta_time = @as(f32, @floatFromInt(sdl.getTicks() - game.ticks_count)) / 1000.0;

    if (0.05 < delta_time) delta_time = 0.05;

    if (game.paddle_dir != 0.0) {
        game.paddle_pos.y += game.paddle_dir * 400.0 * delta_time;
        if (game.paddle_pos.y < (PADDLE_HEIGHT / 2.0 + THICKNESS)) {
            game.paddle_pos.y = PADDLE_HEIGHT / 2.0 + THICKNESS;
        } else if ((768.0 - PADDLE_HEIGHT / 2.0 - THICKNESS) < game.paddle_pos.y) {
            game.paddle_pos.y = 768.0 - PADDLE_HEIGHT / 2.0 - THICKNESS;
        }
    }

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

    const diff = @fabs(game.ball_pos.y - game.paddle_pos.y);

    if (diff <= PADDLE_HEIGHT / 2.0 and
        20.0 <= game.ball_pos.x and game.ball_pos.x <= 25.0 and
        game.ball_vel.x < 0.0)
    {
        game.ball_vel.x *= -1.0;
    }
}
