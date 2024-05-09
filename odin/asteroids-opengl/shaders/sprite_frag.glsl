#version 330

out vec4 out_color;

in vec2 frag_tex_coord;

uniform sampler2D u_texture;

void main() {
  out_color = texture(u_texture, frag_tex_coord);
}


