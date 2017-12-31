#version 300 es

precision mediump float;

in vec2 st;

uniform int m_w;
uniform int m_h;
uniform int step;
uniform int radius; // patch = (2*radius+1)x(2*radius+1)
uniform sampler2D tex;
uniform sampler2D tex2;

int d_max = 64;
float MAX_FLOAT = float(1000000);
float pC[64];

out float FragColor;

void main()  
{  
	vec4 i1, i2;
	i1 = texture(tex, st);
	i2 = texture(tex2, st);
	float gray1 = 0.0, gray2 = 0.0;

	float dx = 1.0 / float(m_w);
	float dy = 1.0 / float(m_h); 
	float x = st.x, y = st.y;
	float xx, yy, x0;
	
	int n = 0;
	float delta = 0.0;
	float C, min_C = MAX_FLOAT;
    if (i1.a == 0.0 || (i1.r == 0.0 && i1.g == 0.0 && i1.b == 0.0)) FragColor = 0.0;//vec4(0.0, 0.0, 0.0, 0.0);
	else {
        
		delta = 0.0;
		for (int k=0; k<d_max; k++) {
			x += dx * float(step);
			if (x < 0.0 || x > 1.0) break;
			n = 0; C = 0.0; 
			for (int i=-radius; i<=radius; i++) {
				for (int j=-radius; j<=radius; j++) {
					xx = x + float(i)*dx;
					yy = y + float(j)*dy;
					x0 = st.x + float(i)*dx;
					if (xx < 0.0 || xx > 1.0 || yy < 0.0 || yy > 1.0 || x0 < 0.0 || x0 > 1.0) continue;
					i1 = texture(tex,  vec2(x0, yy));
					i2 = texture(tex2, vec2(xx, yy));
					gray1 = i1.r*0.299 + i1.g*0.587 + i1.b*0.114;
					gray2 = i2.r*0.299 + i2.g*0.587 + i2.b*0.114;

					if (i1.a != 0.0 && i2.a != 0.0) {
						C += (gray1 - gray2) * (gray1 - gray2);
						n++;
					} 
				}
			}
			pC[k] = C;

			if (C < min_C) {
				min_C = C;
				delta = float(k+1);
			}
		}
		
		int iDelta = int(delta);
		if (delta >= 2.0 && delta <= float(d_max)-1.0 && pC[iDelta-1] != MAX_FLOAT && pC[iDelta-2] != MAX_FLOAT && pC[iDelta] != MAX_FLOAT) {
			float d = delta;
			float y0 = pC[iDelta-2], y1 = pC[iDelta-1], y2 = pC[iDelta];
			float a = y2 / 2.0 - y1 + y0 / 2.0;
			float b = y2 - y1 - a - 2.0 * a*d;
			if (a > 0.0) {
				delta = -b / (2.0 * a);
			}
		}
		
        if (delta == 0.0) {
            FragColor = 0.0;//vec4(0.0, 0.0, 0.0, 0.0);
        }
		else {
			//int test = int(double(delta) * 256.0 * 256.0);
			//float A = float(1.0) / 255.0;
			//float B = float((test) % 256) / 255.0;
			//float G = float((test / 256) % 256) / 255.0;
			//float R = float(test / 256 / 256) / 255.0;

			//gl_FragColor = delta;
            FragColor = delta;//vec4(delta/255.0, delta/255.0, delta/255.0, 1.0);
		}
        //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	}

}  
