//
//  StereoMatching.swift
//  AR
//
//  Created by jhw on 05/12/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import Foundation
import GLKit

class StereoMatching {
    
    var _renderer1: myGLRenderer! = nil
    var _renderer2: myGLRenderer! = nil
    var _renderer_depth: myGLRenderer! = nil
    var gl_error:  GLenum = 0
    
    init() {
        /*
        _renderer1 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_R32F), format: Int32(GL_RED), type: Int32(GL_FLOAT))
        _renderer1.setShaderFile(vshname: "default", fshname: "stereo_matching_SSD")
        
        _renderer1 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_R32F), format: Int32(GL_RED), type: Int32(GL_FLOAT))
        _renderer2.setShaderFile(vshname: "default", fshname: "stereo_matching_SSD")
        */
        
        _renderer1 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        _renderer1.setShaderFile(vshname: "default", fshname: "stereo_matching_SSD")
        
        _renderer2 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        _renderer2.setShaderFile(vshname: "default", fshname: "stereo_matching_SSD")
    }
    
    func disparityEstimation(tex1: GLuint!, tex2: GLuint!) -> (GLuint?, GLuint?) {
        //disparity estimation for image1
        _renderer1._program.use()
        
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "step")), GLint(1))
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "radius")), GLint(3))
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex1)
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "tex")), 0)
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex2)
        glUniform1i(GLint(_renderer1._program.uniformIndex(uniformName: "tex2")), 1)
        _renderer1.renderScene()
        
        //disparity estimation for image2
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "step")), GLint(-1))
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "radius")), GLint(3))
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex2)
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "tex")), 0)
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex1)
        glUniform1i(GLint(_renderer2._program.uniformIndex(uniformName: "tex2")), 1)
        _renderer2.renderScene()
        
        return (_renderer1._rtt._texture, _renderer2._rtt._texture)
    }
    
    func getUIImage() -> (img1: UIImage?, img2: UIImage?) {
        let img1 = _renderer1.getFramebufferImage()
        let img2 = _renderer2.getFramebufferImage()
        if img1 == nil {
            print("nani???")
        }
        
        return (img1, img2)
    }
}
