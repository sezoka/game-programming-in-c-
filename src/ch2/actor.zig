const std = @import("std");
const math = @import("./math.zig");
const component = @import("./component.zig");
const game = @import("./game.zig");

pub const ActorState = enum {
    active,
    paused,
    dead,
};

pub const ActorKind = enum {};

pub const Actor = struct {
    kind: ActorKind,
    state: ActorState,
    position: math.Vec2,
    scale: f32,
    rotation: f32,
    components: std.ArrayList(*component.Component),
    game: *game.Game,
};

pub fn init(g: *game.Game) Actor {
    return .{
        .kind = .{},
        .state = .active,
        .position = .{ .x = 0, .y = 0 },
        .scale = 0.0,
        .rotation = 0.0,
        .components = std.ArrayList(*component.Component).init(game.ally),
        .game = g,
    };
}

pub fn deinit(a: *Actor) void {
    _ = a;
}

pub fn update(a: *Actor, delta_time: f32) void {
    _ = a;
    _ = delta_time;
}

pub fn update_components(a: *Actor, delta_time: f32) void {
    _ = a;
    _ = delta_time;
}

pub fn update_actor(a: *Actor, delta_time: f32) void {
    _ = a;
    _ = delta_time;
}

pub fn add_component(a: *Actor, c: *component.Component) void {
    _ = a;
    _ = c;
}

pub fn remove_component(a: *Actor, c: *component.Component) void {
    _ = a;
    _ = c;
}
