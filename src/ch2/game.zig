const std = @import("std");
const actor = @import("actor.zig");
const sdl = @import("sdl");
const component = @import("component.zig");
const texture = @import("texture.zig");

pub const Texture_Map = std.StringHashMap(sdl.Texture);

pub const Game = struct {
    updating_actors: bool,
    actors: std.ArrayList(*actor.Actor),
    pending_actors: std.ArrayList(*actor.Actor),
    ticks_count: u32,
    running: bool,
    renderer: sdl.Renderer,
    texture_map: Texture_Map,
    ally: std.mem.Allocator,
};

pub fn init(ally: std.mem.Allocator) !Game {
    sdl.init(.{ .video = true }) catch {
        std.log.err("Unable to initialize SDL: {s}", .{sdl.getError().?});
        return error.InitError;
    };
    errdefer sdl.quit();

    const window = sdl.createWindow(
        "Game programming in C++ (Chapter 2)",
        .default,
        .default,
        1024,
        768,
        .{},
    ) catch {
        std.log.err("Failed to create window: {s}", .{sdl.getError().?});
        return error.InitError;
    };
    errdefer window.destroy();

    const renderer = sdl.createRenderer(window, null, .{ .accelerated = true, .present_vsync = true }) catch {
        std.log.err("Failed to create renderer: {s}", .{sdl.getError().?});
        return error.InitError;
    };

    try sdl.image.init(.{ .png = true });

    var g = Game{
        .updating_actors = false,
        .actors = std.ArrayList(*actor.Actor).init(ally),
        .pending_actors = std.ArrayList(*actor.Actor).init(ally),
        .ticks_count = sdl.getTicks(),
        .renderer = renderer,
        .running = true,
        .texture_map = Texture_Map.init(ally),
        .ally = ally,
    };

    load_data(&g);
}

pub fn deinit(g: *Game) void {
    while (g.actors.items.len != 0) {
        actor.deinit(g.actors.getLast());
    }
    sdl.quit();
}

pub fn add_actor(g: *Game, a: *actor.Actor) !void {
    if (g.updating_actors) {
        try g.pending_actors.append(a);
    } else {
        try g.actors.append(a);
    }
}

pub fn remove_actor(g: *Game, a: *actor.Actor) !void {
    if (g.updating_actors) {
        for (g.pending_actors.items, 0..) |item, i| {
            if (item == a) {
                g.pending_actors.swapRemove(i);
                return;
            }
        }
    }

    for (g.actors.items, 0..) |item, i| {
        if (item == a) {
            g.actors.swapRemove(i);
            return;
        }
    }
}

pub fn update(g: *Game) !void {
    defer g.ticks_count = sdl.getTicks();
    var delta_time = @as(f32, @floatFromInt(sdl.getTicks() - g.ticks_count)) / 1000.0;

    g.updating_actors = true;
    for (g.actors.items) |a| {
        actor.update(a, delta_time);
    }
    g.updating_actors = false;

    for (g.pending_actors.items) |a| {
        try g.actors.append(a);
    }
    g.pending_actors.clearRetainingCapacity();

    var dead_actors = std.ArrayList(*actor.Actor).init(g.ally);
    defer dead_actors.deinit();

    for (g.actors.items) |a| {
        if (a.state == .dead) {
            try dead_actors.append(a);
        }
    }

    for (dead_actors.items) |a| {
        actor.deinit(a);
    }
}

fn get_texture(g: *Game, name: []const u8) sdl.Texture {
    if (g.texture_map.contains(name)) {
        return g.texture_map.get();
    }

    return texture.load_texture(g.renderer, name);
}

fn load_data(g: *Game) void {
    _ = g;
}

fn add_sprite(sprite: *component.Component) void {
    const draw_order = sprite.data.sprite.draw_order;
}
