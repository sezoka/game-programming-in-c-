const actor = @import("./actor.zig");
const sdl = @import("sdl");

pub const Component_Kind = enum {
    sprite,
};

pub const Component_Data = union {
    sprite: Sprite,
};

pub const Sprite = struct {
    texture: sdl.Texture,
    draw_order: i32,
    tex_width: u32,
    tex_height: u32,
};

pub const Component = struct {
    owner: *actor.Actor,
    update_order: i32,
    kind: Component_Kind,
    data: Component_Data,
};

pub const Sprite_Component = struct {
    meta: Component,
    texture: sdl.Texture,
};

pub fn deinit(c: *Component) void {
    _ = c;
}

pub fn update(c: *Component, delta_time: f32) void {
    _ = c;
    _ = delta_time;
}

pub fn init_sprite(a: *actor.Actor, draw_order: i32) Component {
    return .{
        .kind = .sprite,
        .data = .{
            .sprite = undefined,
            .draw_order = draw_order,
            .tex_width = 0,
            .tex_height = 0,
        },
        .owner = a,
        .update_order = draw_order,
    };
}
