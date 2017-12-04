//
//  FusionBrain.swift
//  AR
//
//  Created by jhw on 30/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
/*
extension matrix_float4x4 {
    
    func getCenter() -> float3 {
        var R: matrix_float3x3
        
        for i in 0...2 {
            for j in 0...2 {
                R[i][j] =
            }
        }
    }
    
    func size() -> Int {
        if self.count > 0 {
            return self.count * MemoryLayout.size(ofValue: self[0])
        }
        return 0;
    }
}
*/
class FusionFrame {
    var _image: UIImage!
    var _pose: CameraPose!
    
    init(image: UIImage, pose: CameraPose!) {
        _image = image
        _pose  = pose
    }
}

class FusionBrain: NSObject{
    
    override init() {
        
    }
    
    func newFrame(frame: FusionFrame) {
    
    }
    
}
