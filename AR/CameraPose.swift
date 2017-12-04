//
//  CameraPose.swift
//  AR
//
//  Created by jhw on 30/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import Foundation
import ARKit

class CameraPose: NSObject {
    
    var transform: matrix_float4x4
    var R: matrix_float3x3
    var t: float3
    var Q: matrix_float3x3
    var q: float3
    
    var center: float3
    var intrinsics: matrix_float3x3
    
    init(A: matrix_float3x3, trans: matrix_float4x4) {
        self.intrinsics = A
        
        self.transform = trans
        self.R = matrix_float3x3([float3(trans[0][0], trans[0][1], trans[0][2]), float3(trans[1][0], trans[1][1], trans[1][2]), float3(trans[2][0], trans[2][1], trans[2][2])])
        self.t = float3(trans[3][0], trans[3][1], trans[3][2])
        
        self.Q = self.intrinsics * R
        self.q = self.intrinsics * t
        
        self.center = -(R.inverse * t)
    }
    
    init(A: matrix_float3x3, R: matrix_float3x3, t: float3) {
        self.intrinsics = A
        
        self.R = R
        self.t = t
        self.transform = matrix_float4x4([float4(R[0][0], R[0][1], R[0][2], Float(0)), float4(R[1][0], R[1][1], R[1][2], Float(0)), float4(R[2][0], R[2][1], R[2][2], Float(0)), float4(t[0], t[1], t[2], Float(0))])
        
        self.Q = self.intrinsics * self.R
        self.q = self.intrinsics * self.t
        
        self.center = -(R.inverse * t)
    }
}

