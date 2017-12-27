#version 300 es

precision mediump float;

in vec2 st;

uniform int m_w;
uniform int max_diff;
uniform float baseline;
uniform float fx;
uniform sampler2D tex;
uniform sampler2D tex2;

out vec4 FragColor;

float my_abs(float a) {
	if (a < 0.0) return -a;
	else return a;
}

void main()  
{  
	vec4 i1, i2;
	float delta1, delta2;
	float dx = 1.0 / float(m_w);

	i1 = texture(tex, st);
	//delta1 = float((double(i1.r)*255.0 *256.0*256.0 + double(i1.g)*255.0 *256.0 + double(i1.b)*255.0 ) / (256*256));
	//if (i1.a < 1.0/255.0) delta1 = 0.0;
	delta1 = i1.r * 255.0;
	if (delta1*dx+st.x > 1.0) delta1 = (1.0-st.x)/dx;
	
	i2 = texture(tex2, vec2(st.x+delta1*dx, st.y));
	//i2 = texture2D(tex2, st);
	delta2 = i2.r * 255.0;
	//delta2 = float((double(i2.r)*255.0 *256.0*256.0 + double(i2.g)*255.0 *256.0 + double(i2.b)*255.0 ) / (256*256));
	//if (delta2 < 0.0) delta2 = 0.0;
	//if (delta2*dx > 1.0) delta2 = 1.0/dx;

	if (delta1 == 0.0 || delta2 == 0.0 || my_abs(delta1 - delta2) >= float(max_diff)) {
        FragColor = vec4(0.0, 0.0, 0.0, 0.0); //FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		float depth = baseline * fx / delta1;
		//double depth = delta1;
		//int test = int(depth * 256 * 256);
		//float A = float(1.0) / 255.0;
		//float B = float((test) % 256) / 255.0;
		//float G = float((test / 256) % 256) / 255.0;
		//float R = float(test / 256 / 256) / 255.0;
		
		//FragColor = vec4(R, G, B, A);
        //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        FragColor = vec4(depth/60.0, depth/60.0, depth/60.0, 1.0);
        //gl_FragColor = depth;
	}
}  
