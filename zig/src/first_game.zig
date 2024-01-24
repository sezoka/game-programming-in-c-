const std = @import("std");
const sdl = @import("sdl");

const Struct = struct {
    is_running: bool,
};

pub fn first_game_main() !void {
    var s = Struct{ .is_running = true };
    init(&s);
}

pub fn run_loop(s: *Struct) !void {
    while (s.is_running) {
        process_input(s);
        update_game(s);
        generate_output(s);
    }
}

fn process_input(s: *Struct) !void {

    while (sdl.pollEvent()) |ev| {
        switch (ev) {
            .quit => {
                s.is_running = false;
            },
        }
    }

    var state = sdl.getKeyboardState();
}

pub fn init() !void {
    try sdl.init(.{.video});

    const window = try sdl.createWindow(
        "CHAPTER 1",
        100,
        100,
        1024,
        768,
        .{ .resizable = true },
    );
    defer window.destroy();
}

pub fn shutdown() void {
    sdl.quit();
}
