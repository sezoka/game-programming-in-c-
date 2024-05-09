package asteroids

import "core:log"
import "core:strings"
// import sdl "vendor:sdl2"
// import stb_img "vendor:sdl2/image"
import gl "vendor:OpenGL"
import stb_img "vendor:stb/image"

Texture :: struct {
	width:      i32,
	height:     i32,
	texture_id: u32,
}

create_texture :: proc() -> Texture {
	return Texture{}
}

load_texture :: proc(t: ^Texture, file_name: cstring) -> bool {
	channels, w, h: i32
	image := stb_img.load(file_name, &w, &h, &channels, 0)
	if image == nil {
		log.errorf("Can't load image using file path '%s'", file_name)
		return false
	}
	defer stb_img.image_free(image)

	format: i32 = channels == 4 ? gl.RGB : gl.RGBA
	gl.GenTextures(1, &t.texture_id)
	gl.BindTexture(gl.TEXTURE_2D, t.texture_id)
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		format,
		t.width,
		t.height,
		0,
		u32(format),
		gl.UNSIGNED_BYTE,
		image,
	)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	return true
}

unload_texture :: proc(t: ^Texture) {
	gl.DeleteTextures(1, (^u32)(&t.texture_id))
}

set_active_texture :: proc(t: ^Texture) {
	gl.BindTexture(gl.TEXTURE_2D, t.texture_id)
}

get_texture :: proc(g: ^Game, file_path: cstring) -> ^Texture {
	texture, ok := &g.textures[file_path]
	if ok {
		return texture
	}
  new_texture := create_texture()
	ok = load_texture(&new_texture, file_path)
	if ok {
		g.textures[file_path] = new_texture
	}
	return &g.textures[file_path]

}


// destroy_texture :: proc(t: ^Texture) {
// }


// get_texture_width :: proc() {

// }

// get_texture_height :: proc() {

// }
