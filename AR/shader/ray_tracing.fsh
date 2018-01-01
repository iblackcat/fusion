#version 300 es

precision mediump float;

in vec2 st;
out vec4 FragColor;

uniform int m_w;
uniform int m_h;

uniform float edgeLength;
uniform int Axis;
uniform int flag;
uniform mat3 invQ;
uniform vec3 q;

uniform sampler2D model;
uniform sampler2D model1;

int ModelSize = 256;
int ModelTexSize = 4096;
int Mu = 4;

float MAX_FLOAT = 10000000.0;


vec3 WorldCoord(float x, float y, float z) {
    //return vec3(0.0, 0.0, 0.0);
    return vec3((x/float(ModelSize-1) - 0.5) * edgeLength, (y/float(ModelSize-1) - 0.5) * edgeLength, (z/float(ModelSize-1) - 0.5) * edgeLength);
    //return vec3((x - float(ModelSize) / 2)*size / float(ModelSize), (y - float(ModelSize) / 2)*size / float(ModelSize), (z - float(ModelSize) / 2)*size / float(ModelSize));
}

float WorldAxis(float tmp) {
    return (tmp/float(ModelSize-1) - 0.5) * edgeLength;
}

float LocalAxis(float tmp) {
    return (tmp/edgeLength + 0.5) * float(ModelSize - 1);
}

float vec3Multi(vec3 a, vec3 b) {
    return a.x*b.x + a.y*b.y + a.z*b.z;
}

void main()
{
    int SmallSize = ModelTexSize / ModelSize;
    
    float tmp = float(ModelSize);
    vec4 C = vec4(0.0, 0.0, 0.0, 0.0);
    vec4 SW = vec4(0.0, 0.0, 0.0, 0.0);
    vec4 last_C = vec4(0.0, 0.0, 0.0, 0.0);
    vec4 last_SW = vec4(0.0, 0.0, 0.0, 0.0);
    float depth = 0.0, last_depth = 0.0;
    
    float dx = 1.0 / float(m_w);
    float dy = 1.0 / float(m_h);
    
    float j = (st.x-dx/2.0) * float(m_w);
    float i = (st.y-dy/2.0) * float(m_h);
    
    
    float xx, yy, weight;
    float weight_tmp = 0.0;
    
    int start, end, step;
    if (Axis % 2 == 0) {start = 0; end = ModelSize; step = 1;}
    else {start = ModelSize-1; end = -1; step = -1;}
    
    float x, y, z, xm, ym, zm, test;
    
    FragColor = vec4(0.5, 0.5, 0.5, 1.0);
    int tag = 0;
    
    for (int k = start; k != end; k += step)
    {
        if (Axis / 2 == 0) {x = WorldAxis(float(k)); test = x;}
        else if (Axis / 2 == 1) {y = WorldAxis(float(k)); test = y;}
        else {z = WorldAxis(float(k)); test = z;}
        
        zm = (test + vec3Multi(invQ[Axis/2], q)) / vec3Multi(invQ[Axis/2], vec3(j, i, 1.0));
        xm = j * zm;
        ym = i  * zm;
        
        x = vec3Multi(invQ[0], vec3(xm, ym, zm)) - vec3Multi(invQ[0], q); x = LocalAxis(x);
        y = vec3Multi(invQ[1], vec3(xm, ym, zm)) - vec3Multi(invQ[1], q); y = LocalAxis(y);
        z = vec3Multi(invQ[2], vec3(xm, ym, zm)) - vec3Multi(invQ[2], q); z = LocalAxis(z);
        
        float s_tmp = float(ModelSize);
        //20170531
        if (x < 0.0 || x > float(ModelSize)-1.0 || y < 0.0 || y > float(ModelSize)-1.0 || z < 0.0 || z > float(ModelSize)-1.0) s_tmp = float(ModelSize);
        else {
            /*
             if (y < 5.0 && z < 5.0) {
             FragColor = vec4(1.0, 0.0, 0.0, 1.0);
             tag = 1;
             } else if (x < 5.0 && z < 5.0) {
             FragColor = vec4(0.0, 1.0, 0.0, 1.0);
             tag = 1;
             } else if (x < 5.0 && y < 5.0) {
             FragColor = vec4(0.0, 0.0, 1.0, 1.0);
             tag = 1;
             } else {
             FragColor = vec4(0.8, 0.8, 0.2, 1.0);
             tag = 1;
             }*/
            //FragColor = vec4(x/float(ModelSize-1), y/float(ModelSize-1), z/float(ModelSize-1), 1.0);
            
            xx = (float(int(z)%SmallSize) * float(ModelSize) + x + 0.5) / float(ModelTexSize);
            yy = (float(int(z)/SmallSize) * float(ModelSize) + y + 0.5) / float(ModelTexSize);
            float xx1 = (float((int(z)+1)%SmallSize) * float(ModelSize) + x + 0.5) / float(ModelTexSize);
            float yy1 = (float((int(z)+1)/SmallSize) * float(ModelSize) + y + 0.5) / float(ModelTexSize);
            
            float tmp_z = z - floor(z);
            last_SW = SW;
            last_C  = C ;
            C  = texture(model , vec2(xx, yy)) * (1.0 - tmp_z) + texture(model , vec2(xx1, yy1)) * tmp_z;
            SW = texture(model1, vec2(xx, yy)) * (1.0 - tmp_z) + texture(model1, vec2(xx1, yy1)) * tmp_z;
            
            s_tmp = SW.r*255.0 - 128.0;
            weight = C.a*255.0;
            /*
            if (SW.r*255.0 > 128.0) {
                FragColor = C;
                tag = 1;
            }
            */
            //vec4 p = Rot * vec4(WorldCoord(x,y,z), 1.0);
            last_depth = depth;
            //depth = p.z;
            depth = zm;
            
            if (C.a == 0.0) {
                s_tmp = float(ModelSize);
            }
            
        }
        if ((tmp > 0.0 && s_tmp <= 0.0) && (tmp < float(Mu) && s_tmp > -float(Mu))) {// && tmp < Mu && s_tmp > -Mu)) { //|| (tmp < 0.0 && s_tmp >= 0.0 && s_tmp < Mu)) {
            
            if (tmp < 0.0 || weight/2.0 < weight_tmp || weight < 5.0) {tmp = s_tmp; continue; }
            
            if (flag == 0) { //I
                if (tmp != float(ModelSize) && s_tmp != 0.0) {
                    FragColor = (vec4(C.rgb, 1.0)*(-tmp) + vec4(last_C.rgb, 1.0)*(s_tmp)) / (s_tmp-tmp);
                    //FragColor = vec4(1.0,0.0,0.0,1.0);
                }
                else FragColor = vec4(C.rgb, 1.0);
                
            }
            //FragColor = vec4(1.0, 0.0, 0.0, 1.0);
            
            
            /*
             else if (flag == 1) { //Y
             if (tmp != float(ModelSize) && s_tmp != 0.0) {
             FragColor = (vec4(SW.b, SW.b, SW.b, 1.0)*(-tmp) + vec4(last_SW.b, last_SW.b, last_SW.b, 1.0)*(s_tmp)) / (s_tmp-tmp);
             }
             else FragColor = vec4(SW.b, SW.b, SW.b, 1.0);
             }
             else { //D
             float dinter = depth;
             if (tmp != float(ModelSize) && s_tmp != 0.0) {
             dinter = (depth*(-tmp) + last_depth*(s_tmp) ) / (s_tmp - tmp);
             }
             int test = int(dinter * 256.0 * 256.0);
             float A = float(1.0) / 255.0;
             float B = float((test) % 256) / 255.0;
             float G = float((test/ 256) % 256) / 255.0;
             float R = float(test / 256 / 256) / 255.0;
             FragColor = vec4(R, G, B, A);
             }
             */
            weight_tmp = weight;
            return ;
        }
        //else if (tmp < 0.0 && s_tmp >= 0.0 && s_tmp < Mu) {
        //return ;
        //}
        tmp = s_tmp;
        if (tag == 1) break;
    }
    
    
}
