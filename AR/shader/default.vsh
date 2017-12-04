
attribute vec3 position;
attribute vec2 texCoord;

varying vec2 st;

void main() {
    gl_Position = vec4(position, 1.0);
    st = texCoord;
}
