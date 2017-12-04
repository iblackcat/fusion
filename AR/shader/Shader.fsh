
varying mediump vec2 v_textureCoordinate;
uniform sampler2D tex;


void main() {
    gl_FragColor = texture2D(tex, v_textureCoordinate);//
    //gl_FragColor = vec4(v_textureCoordinate.xy, 0.0, 1.0);
    //vec4 hh = texture2D(tex, v_textureCoordinate);//
    //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
