const std = @import("std");
const sdl = @import("sdl");

const Vec2 = struct {
    x: f32,
    y: f32,
};

const THINKNESS = 15.0;

const PADDLE_HEIGHT = THINKNESS * 8.0;

const WIDTH = 1280;
const HEIGHT = 720;

const State = struct {
    is_running: bool,
    window: sdl.Window,
    renderer: sdl.Renderer,
    ticks_cnt: u32,
    left_paddle_pos: Vec2,
    right_paddle_pos: Vec2,
    left_paddle_dir: f32,
    right_paddle_dir: f32,
    ball_pos: [3]Vec2,
    ball_vel: [3]Vec2,
};

pub fn first_game_main() !void {
    var s: State = undefined;
    try init(&s);
    try run_loop(&s);
    shutdown(&s);
}

pub fn run_loop(s: *State) !void {
    while (s.is_running) {
        try process_input(s);
        update_game(s);
        try generate_output(s);
    }
}

fn update_game(s: *State) void {
    while (!sdl.getTicksPassed(sdl.getTicks(), s.ticks_cnt + 16)) {}

    var delta_time = @as(f32, @floatFromInt(sdl.getTicks() - s.ticks_cnt)) / 1000.0;
    s.ticks_cnt = sdl.getTicks();

    if (0.05 < delta_time) {
        delta_time = 0.05;
    }

    if (s.left_paddle_dir != 0) {
        s.left_paddle_pos.y += s.left_paddle_dir * 300.0 * delta_time;

        if (s.left_paddle_pos.y < (PADDLE_HEIGHT / 2.0 + THINKNESS)) {
            s.left_paddle_pos.y = PADDLE_HEIGHT / 2.0 + THINKNESS;
        } else if ((HEIGHT - PADDLE_HEIGHT / 2.0 - THINKNESS) < s.left_paddle_pos.y) {
            s.left_paddle_pos.y = HEIGHT - PADDLE_HEIGHT / 2.0 - THINKNESS;
        }
    }

    if (s.right_paddle_dir != 0) {
        s.right_paddle_pos.y += s.right_paddle_dir * 300.0 * delta_time;

        if (s.right_paddle_pos.y < (PADDLE_HEIGHT / 2.0 + THINKNESS)) {
            s.right_paddle_pos.y = PADDLE_HEIGHT / 2.0 + THINKNESS;
        } else if ((HEIGHT - PADDLE_HEIGHT / 2.0 - THINKNESS) < s.right_paddle_pos.y) {
            s.right_paddle_pos.y = HEIGHT - PADDLE_HEIGHT / 2.0 - THINKNESS;
        }
    }

    for (0..3) |i| {
        var ball_pos = &s.ball_pos[i];
        var ball_vel = &s.ball_vel[i];

        ball_pos.x += ball_vel.x * delta_time;
        ball_pos.y += ball_vel.y * delta_time;

        if (ball_pos.y <= THINKNESS and ball_vel.y < 0.0) {
            ball_vel.y *= -1;
        }

        if (HEIGHT - THINKNESS <= ball_pos.y and 0.0 < ball_vel.y) {
            ball_vel.y *= -1;
        }

        if (ball_pos.x <= THINKNESS and ball_vel.x < 0.0) {
            ball_vel.x *= -1;
        }

        if (WIDTH - THINKNESS <= ball_pos.x and 0.0 < ball_vel.x) {
            ball_vel.x *= -1;
        }

        var diff = @abs(ball_pos.y - s.left_paddle_pos.y);
        if (diff <= PADDLE_HEIGHT / 2.0 and 20.0 <= ball_pos.x and ball_pos.x <= 25.0 and ball_vel.x < 0.0) {
            ball_vel.x *= -1.0;
        }

        diff = @abs(ball_pos.y - s.right_paddle_pos.y);
        if (diff <= PADDLE_HEIGHT / 2.0 and WIDTH - 25.0 <= ball_pos.x and ball_pos.x <= WIDTH - 20.0 and 0.0 < ball_vel.x) {
            ball_vel.x *= -1.0;
        }
    }
}

fn generate_output(s: *State) !void {
    s.renderer.setColorRGB(0, 0, 0) catch undefined;
    s.renderer.clear() catch undefined;

    s.renderer.setColorRGB(128, 128, 128) catch undefined;

    for (0..3) |i| {
        const ball_pos = &s.ball_pos[i];
        const ball_rect = sdl.Rectangle{
            .x = @intFromFloat(ball_pos.x - THINKNESS / 2.0),
            .y = @intFromFloat(ball_pos.y - THINKNESS / 2.0),
            .width = @intFromFloat(THINKNESS),
            .height = @intFromFloat(THINKNESS),
        };
        try s.renderer.fillRect(ball_rect);
    }

    var paddle_rect = sdl.Rectangle{
        .x = @intFromFloat(s.left_paddle_pos.x - THINKNESS / 2.0),
        .y = @intFromFloat(s.left_paddle_pos.y - THINKNESS * 8.0 / 2.0),
        .width = @intFromFloat(THINKNESS),
        .height = @intFromFloat(PADDLE_HEIGHT),
    };
    try s.renderer.fillRect(paddle_rect);

    paddle_rect = sdl.Rectangle{
        .x = @intFromFloat(s.right_paddle_pos.x - THINKNESS / 2.0),
        .y = @intFromFloat(s.right_paddle_pos.y - THINKNESS * 8.0 / 2.0),
        .width = @intFromFloat(THINKNESS),
        .height = @intFromFloat(PADDLE_HEIGHT),
    };
    try s.renderer.fillRect(paddle_rect);

    s.renderer.present();
}

fn process_input(s: *State) !void {
    while (sdl.pollEvent()) |ev| {
        switch (ev) {
            .quit => {
                s.is_running = false;
            },
            else => {},
        }
    }

    var state = sdl.getKeyboardState();
    if (state.isPressed(.escape)) {
        s.is_running = false;
    }

    s.left_paddle_dir = 0;
    if (state.isPressed(.w)) {
        s.left_paddle_dir -= 1;
    }
    if (state.isPressed(.s)) {
        s.left_paddle_dir += 1;
    }

    s.right_paddle_dir = 0;
    if (state.isPressed(.up)) {
        s.right_paddle_dir -= 1;
    }
    if (state.isPressed(.down)) {
        s.right_paddle_dir += 1;
    }
}

pub fn init(s: *State) !void {
    try sdl.init(.{ .video = true });

    const window = try sdl.createWindow(
        "CHAPTER 1",
        .default,
        .default,
        WIDTH,
        HEIGHT,
        .{ .resizable = false },
    );
    s.window = window;
    s.is_running = true;
    s.left_paddle_pos = .{ .x = THINKNESS, .y = 384 };
    s.right_paddle_pos = .{ .x = WIDTH - THINKNESS, .y = 384 };
    s.ball_pos = [3]Vec2{ .{ .x = WIDTH / 2, .y = HEIGHT / 2 }, .{ .x = WIDTH / 2, .y = HEIGHT / 2 }, .{ .x = WIDTH / 2, .y = HEIGHT / 2 } };
    s.ball_vel = [3]Vec2{ .{ .x = -200, .y = 235 }, .{ .x = -200, .y = -235 }, .{ .x = 200, .y = 235 } };
    s.ticks_cnt = 0;

    const renderer = try sdl.createRenderer(window, null, .{ .accelerated = true, .present_vsync = false });
    s.renderer = renderer;
}

pub fn shutdown(s: *State) void {
    s.renderer.destroy();
    s.window.destroy();
    sdl.quit();
}
