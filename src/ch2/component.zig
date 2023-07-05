const actor = @import("./actor.zig");

pub const Component = struct {
    owner: *actor.Actor,
    update_order: i32,
};

pub fn init(a: *actor.Actor, update_order: i32) Component {
    return .{ .owner = a, .update_order = update_order };
}

pub fn deinit(c: *Component) void {
    _ = c;
}

pub fn update(c: *Component, delta_time: f32) void {
    _ = c;
    _ = delta_time;
}
