const std = @import("std");
const pong = @import("./pong.zig");

pub fn main() !void {
    try pong.main();
}
