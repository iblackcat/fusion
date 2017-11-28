//
//  myGenVertices.c
//  AR
//
//  Created by jhw on 27/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//


#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "myGenVertices.h"

#pragma mark - Generate vertices

int myGenVertices(float **vertices, float **texCoords, short **indices, int *verts) {
    
    int numVertices = 4;
    int numTriangles = 2;
    
    if (vertices != NULL) {
        *vertices = malloc(sizeof(float)*3*numVertices);
    }
    
    if (texCoords != NULL) {
        *texCoords = malloc(sizeof(float)*2*numVertices);
    }
    
    if (indices != NULL) {
        *indices = malloc(sizeof(uint16_t)*3*numTriangles);
    }
    
    (*vertices)[0] = -1.0f; (*vertices)[1] =  1.0f; (*vertices)[2] = 0.0f;
    (*vertices)[3] =  1.0f; (*vertices)[4] =  1.0f; (*vertices)[5] = 0.0f;
    (*vertices)[6] = -1.0f; (*vertices)[7] = -1.0f; (*vertices)[8] = 0.0f;
    (*vertices)[9] =  1.0f; (*vertices)[10]= -1.0f; (*vertices)[11]= 0.0f;
    
    (*texCoords)[0] = 0.0f; (*texCoords)[1] = 1.0f;
    (*texCoords)[2] = 1.0f; (*texCoords)[3] = 1.0f;
    (*texCoords)[4] = 0.0f; (*texCoords)[5] = 0.0f;
    (*texCoords)[6] = 1.0f; (*texCoords)[7] = 0.0f;
    
    (*indices)[0] = 0; (*indices)[1] = 1; (*indices)[2] = 2;
    (*indices)[3] = 1; (*indices)[4] = 3; (*indices)[5] = 2;
    
    *verts = numVertices;
    return numTriangles;
}
