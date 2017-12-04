//
//  ImageRectification.swift
//  AR
//
//  Created by jhw on 30/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import Foundation
import GLKit
import ARKit

class ImageRectification: NSObject {
    
    var _renderer: myGLRenderer!
    var _tex: myGLTexture2D!
    
    var testImage: UIImage!
    var _texture: GLuint!
    var testTexture: GLKTextureInfo!
    
    var lastTexture: GLuint! = nil
    var lastPose: CameraPose! = nil
    
    override init() {
        super.init()
        _renderer = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        //_renderer.setShaderFile(vshname: "default", fshname: "image_rectification")
        _renderer.setShaderFile(vshname: "Shader", fshname: "Shader")
        
        //_tex = _renderer.createTexture(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
    }
    
    func getRectifiedPose(p1: CameraPose, p2: CameraPose) -> (p1_rec: CameraPose, p2_rec: CameraPose) {
        var p1_rec: CameraPose
        var p2_rec: CameraPose
        
        if p1.center == p2.center {
            p1_rec = p1
            p2_rec = p2
            return (p1_rec, p2_rec)
        }
        
        //?! A
        let A = g_intrinsics
        let v1 = p1.center - p2.center
        let v2 = cross(p1.R.transpose[2], v1)
        let v3 = cross(v1, v2)
        
        let R = matrix_float3x3([normalize(v1),normalize(v2),normalize(v3)]).transpose
        let t1 = -(R * p1.center)
        p1_rec = CameraPose.init(A: A, R: R, t: t1)
        
        let t2 = -(R * p2.center)
        p2_rec = CameraPose.init(A: A, R: R, t: t2)
        
        return (p1_rec, p2_rec)
    }
 
    func imageRectification(inputimage: UIImage!, inputpose: CameraPose!) {
        /*
        if lastTexture != nil && lastPose != nil {
            
        }
        */
        testTexture = nil
        testTexture = try! GLKTextureLoader.texture(with: inputimage.cgImage!, options: nil)
        _texture = testTexture!.name
        
        glUniform1i(GLint(_renderer._program.uniformIndex(uniformName: "tex")), 0)
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
        //_renderer.setTexSub2D(tex_name: "tex", tex: _tex, num: 0, texture_num: GL_TEXTURE0, value: inputimage)
        
        _renderer.renderScene()
        testImage = _renderer.getFramebufferImage()
        
        
    }
    
    
}
