//
//  FramePool.swift
//  AR
//
//  Created by jhw on 04/12/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import Foundation
import GLKit

public var MAX_FRAME_NUM: Int = 10

class Frame: NSObject {
    var _texture: GLuint!
    var _pose: CameraPose!
    
    init(texture: GLuint, pose: CameraPose) {
        _texture = texture
        _pose = pose
    }
    
    init(image: UIImage, pose: CameraPose) {
        let textureInfo = try! GLKTextureLoader.texture(with: image.cgImage!, options: nil)
        _texture = textureInfo.name
        _pose = pose
    }
}

class FramePool: NSObject {
    var frames = [Frame?](repeating: nil, count: Int(MAX_FRAME_NUM))
    
    var head: Int = 0
    var rear: Int = 0
    
    override init() {
        super.init()
        head = 0
        rear = 0
    }
    
    func addFrame(newframe: Frame) {
        frames[head] = newframe
        head = head + 1
        if head == MAX_FRAME_NUM {head = 0}
        if rear < MAX_FRAME_NUM {rear = rear + 1}
    }
    
    func keyframeSelection(frame: Frame) -> Frame? {
        if rear == 0 {
            return nil
        }
    
        //?!
        return frames[(head-3+10)%10]
        
        
        var bestScore: Float = framePairScore(frame1: frame, frame2: frames[0]!)
        var bestFrame: Frame? = frames[0]
        
        for i in 1..<rear {
            let score = framePairScore(frame1: frame, frame2: frames[i]!)
            if score > bestScore {
                bestScore = score
                bestFrame = frames[i]
            }
        }
        
        return bestFrame
    }
    
    func framePairScore(frame1: Frame, frame2: Frame) -> Float{
        var delta_max: Float = 0.0
        let (rect_pose1, rect_pose2) = ImageRectification.getRectifiedPose(p1: frame1._pose, p2: frame2._pose)
        for i in 0..<8 {
            let world_coord: float3 = Cube.Pose.R.inverse * Cube.Vertices[i] - Cube.Pose.R.inverse * Cube.Pose.t
            let delta: Float = fabsf(
                (rect_pose1!.R * world_coord + rect_pose1!.t)[0] - (rect_pose2!.R * world_coord + rect_pose2!.t)[0]
            )
            if delta > delta_max {delta_max = delta}
        }
        
        let S1k: Float = fabsf(length((rect_pose1?.center)! - (rect_pose2?.center)!)) / 1000
        let S2k: Float = -fabsf(1.0 - delta_max / d_max)
        
        return S1k + S2k
    }
}
