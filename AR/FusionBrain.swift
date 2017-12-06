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
import GLKit
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

class Cube: NSObject{
    static var Scale: Float = 0.0
    static var Pose: CameraPose! = nil
    static var Vertices = [
        float3(-0.5,-0.5, 0.5),
        float3( 0.5,-0.5, 0.5),
        float3(-0.5,-0.5,-0.5),
        float3( 0.5,-0.5,-0.5),
        float3(-0.5, 0.5, 0.5),
        float3( 0.5, 0.5, 0.5),
        float3(-0.5, 0.5,-0.5),
        float3( 0.5, 0.5,-0.5)
    ]
}

public var d_max: Float = 64

class FusionBrain: NSObject{
    
    var framePool: FramePool! = nil
    var imageRect: ImageRectification! = nil
    var stereoMatch: StereoMatching! = nil
    
    override init() {
        super.init()
        framePool = FramePool.init()
        stereoMatch = StereoMatching.init()
        imageRect = ImageRectification.init()
    }
    
    func newFrame(image: UIImage, pose: CameraPose) -> (UIImage?, UIImage?){
        let frame = Frame.init(image: image, pose: pose)
        let frame2 = framePool.keyframeSelection(frame: frame)
        
        var outimage1: UIImage? = nil
        var outimage2: UIImage? = nil
        
        if frame2 != nil {
            let (tex1, tex2) = imageRect.imageRectification(frame1: frame, frame2: frame2!)
            let (tex3, tex4) = stereoMatch.disparityEstimation(tex1: tex1, tex2: tex2)
            (outimage1, outimage2) = stereoMatch.getUIImage()
        }
        
        framePool.addFrame(newframe: frame)
        return (outimage1, outimage2)
    }
}
