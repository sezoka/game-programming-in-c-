const std = @import("std");
const game = @import("game.zig");

pub fn run() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const ally = gpa.allocator();

    var g = try game.init(ally);
    defer game.deinit(&g);

    while (g.running) {
        try game.update(&g);
    }
}
