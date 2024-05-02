#version 330

uniform mat4 u_world_transform;
uniform mat4 u_view_proj;

in vec3 in_position;

void main() {
  vec4 pos = vec4(in_position, 1.0);
  gl_Position = pos * u_world_transform * u_view_proj;
  // gl_Position.x -= 1;
  // gl_Position.y -= 1;
}

