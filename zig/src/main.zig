const std = @import("std");
const sdl = @import("sdl");

const first_game = @import("first_game.zig");

pub fn main() !void {
    try first_game.first_game_main();
}
