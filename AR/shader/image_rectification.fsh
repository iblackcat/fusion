
precision mediump float;

varying mediump vec2 st;

uniform int         m_w;
uniform int         m_h;
uniform mat4        Trans;
uniform sampler2D   tex;

void main() {
    
    float dx = float(1.0) / float(m_w);
    float dy = float(1.0) / float(m_h);
    
    vec4 m = Trans * vec4((st.x - dx/float(2.0)) * float(m_w), (st.y - dy/float(2.0)) * float(m_h), 1.0, 0.0);
    vec2 xy = vec2((m[0] / m[2]) / float(m_w) + dx/2.0, (m[1] / m[2]) / float(m_h) + dy/2.0);
    
    vec4 C;
    if (xy.x < 0.0 || xy.y < 0.0 || xy.x > 1.0 || xy.y > 1.0) {
        C = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        C = texture2D(tex, xy);
    }
    gl_FragColor = C;
}

