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
    
    var _renderer1: myGLRenderer!
    var _renderer2: myGLRenderer!
    
    var gl_error: GLenum = 0
    
    override init() {
        super.init()
        _renderer1 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        _renderer1.setShaderFile(vshname: "default", fshname: "image_rectification")
        
        _renderer2 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        _renderer2.setShaderFile(vshname: "default", fshname: "image_rectification")
    }
    
    static func getRectifiedPose(p1: CameraPose, p2: CameraPose) -> (p1_rec: CameraPose?, p2_rec: CameraPose?) {
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
 
    func imageRectification(frame1: Frame, frame2: Frame) -> (Frame?, Frame?, Float?) {
        var frame1_rec: Frame? = nil
        var frame2_rec: Frame? = nil
        
        var p1rec: CameraPose? = nil
        var p2rec: CameraPose? = nil
        (p1rec, p2rec) = ImageRectification.getRectifiedPose(p1: frame1._pose, p2: frame2._pose)
        let rect_tran1: matrix_float3x3 = frame1._pose.Q * p1rec!.Q.inverse
        let rect_tran2: matrix_float3x3 = frame2._pose.Q * p2rec!.Q.inverse
        
        var trans1 = [GLfloat](repeating: GLfloat(0.0), count: Int(16))
        var trans2 = [GLfloat](repeating: GLfloat(0.0), count: Int(16))
            
        for i in 0...3 {
            for j in 0...3 {
                if i == 3 && j == 3 {
                    trans1[i*4+j] = GLfloat(1.0)
                    trans2[i*4+j] = GLfloat(1.0)
                } else if (i == 3 || j == 3) {
                    trans1[i*4+j] = GLfloat(0.0)
                    trans2[i*4+j] = GLfloat(0.0)
                } else {
                    trans1[i*4+j] = GLfloat(rect_tran1[i][j])
                    trans2[i*4+j] = GLfloat(rect_tran2[i][j])
                }
            }
        }
        
        //rectification for image1
        _renderer1._program.use()
        
        gl_error = glGetError()
        print("glerrori1:", gl_error)
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
        glUniformMatrix4fv(GLint(_renderer1._program!.uniformIndex(uniformName: "Trans")), 1, GLboolean(GL_FALSE), &trans1)
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), frame1._texture)
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "tex")), 0)
        gl_error = glGetError()
        print("glerrori2:", gl_error)
        _renderer1.renderScene()
        gl_error = glGetError()
        print("glerrori3:", gl_error)
        
        //rectification for image2
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
        glUniformMatrix4fv(GLint(_renderer2._program!.uniformIndex(uniformName: "Trans")), 1, GLboolean(GL_FALSE), &trans2)
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "tex")), 0)
        glBindTexture(GLenum(GL_TEXTURE_2D), frame2._texture)
        _renderer2.renderScene()
        
        frame1_rec = Frame.init(texture: _renderer1._rtt._texture, pose: p1rec!)
        frame2_rec = Frame.init(texture: _renderer2._rtt._texture, pose: p2rec!)
        let bl = fabsf(length(p1rec!.center - p2rec!.center))
        
        return (frame1_rec, frame2_rec, bl)
    }
    
    func getUIImage() -> (img1: UIImage?, img2: UIImage?) {
        let img1 = _renderer1.getFramebufferImage()
        let img2 = _renderer2.getFramebufferImage()
        
        return (img1, img2)
    }
    
    func getUIImage1() -> UIImage? {
        return _renderer1.getFramebufferImage()
    }
}
