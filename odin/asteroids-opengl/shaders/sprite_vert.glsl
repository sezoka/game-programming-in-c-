#version 330

out vec2 frag_tex_coord;

uniform mat4 u_world_transform;
uniform mat4 u_view_proj;

layout(location=0) in vec3 in_position;
layout(location=1) in vec2 in_tex_coord;

void main() {
  vec4 pos = vec4(in_position, 1.0);
  gl_Position = pos * u_world_transform * u_view_proj;
  frag_tex_coord = in_tex_coord;
  // gl_Position.x -= 1;
  // gl_Position.y -= 1;
}

