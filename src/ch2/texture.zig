const std = @import("std");
const sdl = @import("sdl");

pub fn load_texture(renderer: *sdl.Renderer, file_name: []const u8) ?sdl.Texture {
    const surface = sdl.img.load(file_name) orelse {
        std.err("Failed to load texture file {s}", .{file_name});
        return null;
    };
    defer sdl.freeSurface(surface);

    return sdl.createTextureFromSurface(renderer, surface) orelse {
        std.err("Failed to convert surface to texture for {s}", .{file_name});
        return null;
    };
}
