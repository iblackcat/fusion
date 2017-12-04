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
    var _textureInfo: GLKTextureInfo!
    
    var lastTexture: GLuint! = nil
    var lastPose: CameraPose! = nil
    
    override init() {
        super.init()
        _renderer = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        _renderer.setShaderFile(vshname: "default", fshname: "image_rectification")
        //_renderer.setShaderFile(vshname: "Shader", fshname: "Shader")
        
        //_tex = _renderer.createTexture(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
    }
    
    func getRectifiedPose(p1: CameraPose, p2: CameraPose) -> (p1_rec: CameraPose?, p2_rec: CameraPose?) {
        var p1_rec: CameraPose? = nil
        var p2_rec: CameraPose? = nil
        
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
 
    func imageRectification(inputimage: UIImage!, inputpose: CameraPose!) -> (img1: UIImage?, img2: UIImage?) {
        var img1: UIImage? = nil
        var img2: UIImage? = nil
        
        _textureInfo = try! GLKTextureLoader.texture(with: inputimage.cgImage!, options: nil)
        _texture = _textureInfo!.name
        
        if lastTexture != nil && lastPose != nil {
            var p1rec: CameraPose? = nil
            var p2rec: CameraPose? = nil
            (p1rec, p2rec) = self.getRectifiedPose(p1: inputpose, p2: lastPose)
            let rect_tran1: matrix_float3x3 = inputpose.Q * p1rec!.Q.inverse
            let rect_tran2: matrix_float3x3 = lastPose.Q * p2rec!.Q.inverse
            
            var trans1 = [Float32](repeating: 0.0, count: Int(16))
            var trans2 = [Float32](repeating: 0.0, count: Int(16))
            
            for i in 0...3 {
                for j in 0...3 {
                    if i == 3 && j == 3 {
                        trans1[i*4+j] = Float32(1.0)
                        trans2[i*4+j] = Float32(1.0)
                    } else if (i == 3 || j == 3) {
                        trans1[i*4+j] = Float32(0.0)
                        trans2[i*4+j] = Float32(0.0)
                    } else {
                        trans1[i*4+j] = rect_tran1[i][j]
                        trans2[i*4+j] = rect_tran2[i][j]
                    }
                }
            }
            
            //rectification for image1
            glUniform1i(GLint(_renderer._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
            glUniform1i(GLint(_renderer._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
            glUniformMatrix4fv(GLint(_renderer._program!.uniformIndex(uniformName: "Trans")), 1, GLboolean(GL_FALSE), trans1)
            glUniform1i(GLint(_renderer._program.uniformIndex(uniformName: "tex")), 0)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
            _renderer.renderScene()
            img1 = _renderer.getFramebufferImage()
            
            //rectification for image2
            glUniform1i(GLint(_renderer._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
            glUniform1i(GLint(_renderer._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
            glUniformMatrix4fv(GLint(_renderer._program!.uniformIndex(uniformName: "Trans")), 1, GLboolean(GL_FALSE), trans2)
            glUniform1i(GLint(_renderer._program.uniformIndex(uniformName: "tex")), 0)
            glBindTexture(GLenum(GL_TEXTURE_2D), lastTexture)
            _renderer.renderScene()
            img2 = _renderer.getFramebufferImage()
        } else {
            print("first frame")
        }
 
        lastTexture = _texture
        lastPose = inputpose
        
        _textureInfo = nil
        _texture = nil
        
        return (img1, img2)
    }
    
    
}
