#version 300 es

precision mediump float;

in vec2 st;

uniform int m_w;
uniform int m_h;
uniform int step;
uniform int radius; // patch = (2*radius+1)x(2*radius+1)
uniform sampler2D tex;
uniform sampler2D tex2;

out float FragColor;

int d_max = 64;
float MAX_FLOAT = 1000000.0;
float pC[64];

float dx, dy;
float avg_i1p, avg_i2p, sig_i1p, sig_i2p, C1, C2, min_C;

float rgba2gray(vec4 i) {
	return i.r*0.299 + i.g*0.587 + i.b*0.114;
}
/*
vec4 float2depth_rgba(float value) {
	int ivalue = int(double(value) * 256.0 * 256.0);
	float A = float(1.0) / 255.0;
	float B = float((ivalue) % 256) / 255.0;
	float G = float((ivalue / 256) % 256) / 255.0;
	float R = float(ivalue / 256 / 256) / 255.0;

	return vec4(R, G, B, A);
} ;*/

int compute_avgs(float x, float y) {
	float xx, yy, x0;
	vec4 i1, i2;
	float gray1, gray2;
	int n = 0;
	
	avg_i1p = 0.0;
	avg_i2p = 0.0;
	for (int i=-radius; i<=radius; i++) {
		for (int j=-radius; j<=radius; j++) {
			xx = x + float(i)*dx;
			yy = y + float(j)*dy;
			x0 = st.x + float(i)*dx;
			if (xx < 0.0 || xx > 1.0 || yy < 0.0 || yy > 1.0 || x0 < 0.0 || x0 > 1.0) continue;
			i1 = texture(tex,  vec2(x0, yy));
			i2 = texture(tex2, vec2(xx, yy));
			gray1 = rgba2gray(i1);
			gray2 = rgba2gray(i2);
			
			if (i1.a != 0.0 && i2.a != 0.0) {
				avg_i1p += gray1;
				avg_i2p += gray2;
				n++;
			} 
		}
	}
	
	if (n != 0) {
		avg_i1p /= float(n);
		avg_i2p /= float(n);
	}
	return n;
}

float compute_sigs(float x, float y) {
	float xx, yy, x0;
	vec4 i1, i2;
	float gray1, gray2;
	float C = 0.0;
	
	sig_i1p = 0.0;
	sig_i2p = 0.0;
	for (int i=-radius; i<=radius; i++) {
		for (int j=-radius; j<=radius; j++) {
			xx = x + float(i)*dx;
			yy = y + float(j)*dy;
			x0 = st.x + float(i)*dx;
			if (xx < 0.0 || xx > 1.0 || yy < 0.0 || yy > 1.0 || x0 < 0.0 || x0 > 1.0) continue;
			i1 = texture(tex,  vec2(x0, yy));
			i2 = texture(tex2, vec2(xx, yy));
			gray1 = rgba2gray(i1);
			gray2 = rgba2gray(i2);
			
			if (i1.a != 0.0 && i2.a != 0.0) {
				sig_i1p += (gray1 - avg_i1p) * (gray1 - avg_i1p);
				sig_i2p += (gray2 - avg_i2p) * (gray2 - avg_i2p);
				C += (gray1 - avg_i1p) * (gray2 - avg_i2p);
			}
		}
	}
	return C;
}

void main()  
{
    
	vec4 i1, i2;
	i1 = texture(tex, st);
	i2 = texture(tex2, st);
	float gray1 = rgba2gray(i1);
	float gray2 = rgba2gray(i2);

	dx = 1.0 / float(m_w);
	dy = 1.0 / float(m_h);
	
	float x = st.x, y = st.y;
	
	int n = 0;
	float C = 0.0;
	float delta = 0.0;
	min_C = MAX_FLOAT;
	
	//invalid value
	if (i1.a == 0.0 || gray1 == 0.0) FragColor = 0.0; //vec4(0.0, 0.0, 0.0, 0.0);
	else {
		delta = 0.0;
		for (int k=0; k<d_max; k++) {
			x += dx*float(step);
			if (x < 0.0 || x > 1.0) break;
			
			n = compute_avgs(x, y);
			if (n == 0) continue;
			C = compute_sigs(x, y);
			
			if (sig_i1p == 0.0 || sig_i2p == 0.0) {
				if (C <= 0.0) continue;
				else if (1.0 < min_C) 
				{
					min_C = 1.0;
					delta = float(k+1);
					pC[k] = 1.0;
					continue;
				} else {
					delta = float(k+1);
					break;
				}
			}
			sig_i1p = sqrt(sig_i1p / float(n));
			sig_i2p = sqrt(sig_i2p / float(n));
			C = -C / (sig_i1p * sig_i2p);
			pC[k] = C;

			if (C < min_C) {
				min_C = C;
				delta = float(k+1);
			}
		}
		
		//sub-pixel accuracy
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
     
		//else {
		//	delta = 100.0;
		//}
		
		if (delta == 0.0) FragColor = 0.0; //vec4(0.0, 0.0, 0.0, 0.0);
		else {
			FragColor = delta; //float2depth_rgba(delta);
		}
	}
    FragColor = 0.0;
}  
