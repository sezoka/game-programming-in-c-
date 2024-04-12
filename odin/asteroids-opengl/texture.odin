package asteroids

import "core:strings"
import sdl "vendor:sdl2"
import sdl_img "vendor:sdl2/image"

load_texture :: proc(renderer: ^sdl.Renderer, file_path: string) -> ^sdl.Texture {
	cstr_path := strings.clone_to_cstring(file_path)
	defer delete(cstr_path)
	surf := sdl_img.Load(cstring(cstr_path))
	if surf == nil {
		sdl.Log("Failed to load texture file %s", cstr_path)
		return nil
	}
	texture := sdl.CreateTextureFromSurface(renderer, surf)
	if texture == nil {
		sdl.Log("Failed to convert surface to texture for %s", cstr_path)
		return nil
	}
	return texture
}

get_texture :: proc(g: ^Game, file_path: string) -> ^sdl.Texture {
	texture, ok := g.textures[file_path]
	if ok {
		return texture
	}
	texture = load_texture(g.renderer, file_path)
	if texture != nil {
		g.textures[file_path] = texture
	}
	return texture
}
