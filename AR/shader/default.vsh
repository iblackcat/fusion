#version 300 es

precision mediump float;

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texCoord;

out vec2 st;

void main() {
    gl_Position = vec4(position, 1.0);
    st = texCoord;
}
