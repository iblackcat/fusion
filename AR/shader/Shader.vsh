#version 300 es

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texCoord;

out vec2 v_textureCoordinate;

//uniform mat4 modelViewProjectionMatrix;

void main() {
    v_textureCoordinate = texCoord;
    gl_Position = vec4(position.xyz, 1.0);
}
