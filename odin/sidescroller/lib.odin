package sidescroller

import "../shared"
import sdl "vendor:sdl2"

get_texture :: proc(g: ^Game, file_path: string) -> ^sdl.Texture {
	texture, ok := g.textures[file_path]
	if ok {
		return texture
	}
	texture = shared.load_texture(g.renderer, file_path)
	if texture != nil {
		g.textures[file_path] = texture
	}
	return texture
}
