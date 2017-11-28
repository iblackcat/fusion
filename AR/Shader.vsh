
attribute vec3 position;
attribute vec2 texCoord;

varying vec2 v_textureCoordinate;

//uniform mat4 modelViewProjectionMatrix;

void main() {
    v_textureCoordinate = texCoord;
    gl_Position = vec4(position.xyz, 1.0);
}
