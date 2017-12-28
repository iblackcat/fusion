#version 300 es

precision mediump float;

in vec2 st;

uniform int         m_w;
uniform int         m_h;

uniform mat4        Trans;
uniform sampler2D   tex;

out vec4 FragColor;

void main() {
    
    float dx = float(1.0) / float(m_w);
    float dy = float(1.0) / float(m_h);
    
    vec4 m = Trans * vec4((st.x - dx/float(2.0)) * float(m_w), (st.y - dy/float(2.0)) * float(m_h), 1.0, 0.0);
    vec2 xy = vec2((m[0] / m[2]) / float(m_w) + dx/2.0, (m[1] / m[2]) / float(m_h) + dy/2.0);
    
    if (xy.x < 0.0 || xy.y < 0.0 || xy.x > 1.0 || xy.y > 1.0) {
        FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        FragColor = texture(tex, vec2(xy.x, xy.y));
    }
    
    //FragColor = texture(tex, st);
}

