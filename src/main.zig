const std = @import("std");
// const pong = @import("./ch1/pong.zig");
const ch_2 = @import("./ch2/run.zig");

pub fn main() !void {
    // try pong.main();
    try ch_2.run();
}
