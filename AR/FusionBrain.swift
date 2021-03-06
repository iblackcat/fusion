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
public let rot_y = matrix_float3x3(float3(0.998027,0,-0.0627905),float3(0,1,0),float3(0.0627905,0,0.998027))

class Cube: NSObject{
    static var Scale: Float = 1.0
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
    var tsdfModel: TSDFModel! = nil
    var gl_error: GLenum = 0
    
    var frame_num: Int = 0
    var last_R: matrix_float3x3 = matrix_float3x3(float3(1,0,0),float3(0,1,0),float3(0,0,1))
    
    override init() {
        super.init()
        framePool = FramePool.init()
        imageRect = ImageRectification.init()
        stereoMatch = StereoMatching.init()
        tsdfModel = TSDFModel.init()
        gl_error = glGetError()
        print("glerrorf0:", gl_error)
    }
    
    func newFrame(image: UIImage, pose: CameraPose) -> (UIImage?, UIImage?, UIImage?){
        let frame = Frame.init(image: image, pose: pose)
        let frame2 = framePool.keyframeSelection(frame: frame)
        
        var outimage1: UIImage? = nil
        var outimage2: UIImage? = nil
        var outimage3: UIImage? = nil
        
        if frame2 != nil {
            let (frame1_rec, frame2_rec, bl) = imageRect.imageRectification(frame1: frame, frame2: frame2!)
            let (tex3, tex4) = stereoMatch.disparityEstimation(tex1: frame1_rec?._texture, tex2: frame2_rec?._texture)
            let tex_depth = stereoMatch.depthEstimation(tex1: tex3, tex2: tex4, baseline: bl!)
            //outimage1 = stereoMatch.getDepthUIImage()
            //(outimage1, outimage2) = stereoMatch.getUIImage()
            tsdfModel.model_updating(tex_color: frame1_rec?._texture, tex_depth: tex_depth, pose: frame1_rec?._pose)
            tsdfModel.ray_tracing(pose: pose)
            //tsdfModel.ray_tracing(pose: frame1_rec?._pose)
            /*if (frame_num % 5) == 0 {
                outimage1 = tsdfModel.getModelUIImage()
            }*/
            //outimage1 = tsdfModel.getUIImage()
            (outimage1, outimage2, outimage3) = tsdfModel.getAllImage()
        }
        
        frame_num = (frame_num+1) % 400
 
        //tsdfModel.model_updating()
        
        framePool.addFrame(newframe: frame)
        return (outimage1, outimage2, outimage3)
    }
    
    func FusionDone() -> (UIImage?, UIImage?, UIImage?) {
        var outimage1: UIImage? = nil
        var outimage2: UIImage? = nil
        var outimage3: UIImage? = nil
        
        last_R = rot_y * last_R
        let pose = CameraPose.init(A: g_intrinsics, R: last_R, t: float3(0,0,0.2*Cube.Scale))
        
        tsdfModel.ray_tracing(pose: pose, tag: false)
        //outimage2 = tsdfModel.getUIImage()
        (outimage1, outimage2, outimage3) = tsdfModel.getAllImage()
        
        frame_num = (frame_num+1) % 100
        
        return (outimage1, outimage2, outimage3)
    }
}
