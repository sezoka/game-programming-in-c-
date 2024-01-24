const std = @import("std");
const sdl = @import("sdl");

const Vec2 = struct {
    x: f32,
    y: f32,
};

const THINKNESS = 15.0;

const PADDLE_HEIGHT = THINKNESS * 8.0;

const State = struct {
    is_running: bool,
    window: sdl.Window,
    renderer: sdl.Renderer,
    ticks_cnt: u32,
    paddle_pos: Vec2,
    paddle_dir: f32,
    ball_pos: Vec2,
    ball_vel: Vec2,
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

    if (s.paddle_dir != 0) {
        s.paddle_pos.y += s.paddle_dir * 300.0 * delta_time;

        if (s.paddle_pos.y < (PADDLE_HEIGHT / 2.0 + THINKNESS)) {
            s.paddle_pos.y = PADDLE_HEIGHT / 2.0 + THINKNESS;
        } else if ((768.0 - PADDLE_HEIGHT / 2.0 - THINKNESS) < s.paddle_pos.y) {
            s.paddle_pos.y = 768.0 - PADDLE_HEIGHT / 2.0 - THINKNESS;
        }
    }

    s.ball_pos.x += s.ball_vel.x * delta_time;
    s.ball_pos.y += s.ball_vel.y * delta_time;

    if (s.ball_pos.y <= THINKNESS and s.ball_vel.y < 0.0) {
        s.ball_vel.y *= -1;
    }

    if (768.0 - THINKNESS <= s.ball_pos.y and 0.0 < s.ball_vel.y) {
        s.ball_vel.y *= -1;
    }

    if (s.ball_pos.x <= THINKNESS and s.ball_vel.x < 0.0) {
        s.ball_vel.x *= -1;
    }

    if (1024.0 - THINKNESS <= s.ball_pos.x and 0.0 < s.ball_vel.x) {
        s.ball_vel.x *= -1;
    }

    const diff = @abs(s.ball_pos.y - s.paddle_pos.y);
    if (diff <= PADDLE_HEIGHT / 2.0 and s.ball_pos.x <= 25.0 and s.ball_pos.x >= 20.0 and s.ball_vel.x < 0.0) {
        s.ball_vel.x *= -1.0;
    }
}

fn generate_output(s: *State) !void {
    s.renderer.setColorRGB(0, 0, 0) catch undefined;
    s.renderer.clear() catch undefined;

    s.renderer.setColorRGB(128, 128, 128) catch undefined;

    const ball_rect = sdl.Rectangle{
        .x = @intFromFloat(s.ball_pos.x - THINKNESS / 2.0),
        .y = @intFromFloat(s.ball_pos.y - THINKNESS / 2.0),
        .width = @intFromFloat(THINKNESS),
        .height = @intFromFloat(THINKNESS),
    };
    try s.renderer.fillRect(ball_rect);

    const paddle_rect = sdl.Rectangle{
        .x = @intFromFloat(s.paddle_pos.x - THINKNESS / 2.0),
        .y = @intFromFloat(s.paddle_pos.y - THINKNESS * 8.0 / 2.0),
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

    s.paddle_dir = 0;
    if (state.isPressed(.w)) {
        s.paddle_dir -= 1;
    }
    if (state.isPressed(.s)) {
        s.paddle_dir += 1;
    }
}

pub fn init(s: *State) !void {
    try sdl.init(.{ .video = true });

    const window = try sdl.createWindow(
        "CHAPTER 1",
        .default,
        .default,
        1024,
        768,
        .{ .resizable = false },
    );
    s.window = window;
    s.is_running = true;
    s.paddle_pos = .{ .x = THINKNESS, .y = 384 };
    s.ball_pos = .{ .x = 512, .y = 384 };
    s.ball_vel = .{ .x = -200, .y = 235 };
    s.ticks_cnt = 0;

    const renderer = try sdl.createRenderer(window, null, .{ .accelerated = true, .present_vsync = false });
    s.renderer = renderer;
}

pub fn shutdown(s: *State) void {
    s.renderer.destroy();
    s.window.destroy();
    sdl.quit();
}
