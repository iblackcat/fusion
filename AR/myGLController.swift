//
//  myGLController.swift
//  AR
//
//  Created by jhw on 27/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import UIKit
import AVFoundation

class myGLController: UIView {
    
    var avPlayer: AVPlayer?
    var avPlayerItem: AVPlayerItem?
    var avAsset: AVAsset?
    var output: AVPlayerItemVideoOutput?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        glClearColor(0.0, 1.0, 0.0, 1.0)
    }
    
    func dataSource() -> CVPixelBuffer? {
        let pixelBuffer: CVPixelBuffer? = output?.copyPixelBuffer(forItemTime: (avPlayerItem?.currentTime())!, itemTimeForDisplay: nil)
        
        return pixelBuffer
    }
    
    //func imagebufferFromImage(from image: )
    
    func pixelbufferFromImage(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
