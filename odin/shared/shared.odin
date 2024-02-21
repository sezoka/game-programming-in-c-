package shared

import "core:strings"
import sdl "vendor:sdl2"
import sdl_img "vendor:sdl2/image"

Vector2 :: struct {
	x: f32,
	y: f32,
}

Actor_State :: enum {
	Active,
	Paused,
	Dead,
}

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
