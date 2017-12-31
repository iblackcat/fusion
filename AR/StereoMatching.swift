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
        
        //todo 2path to 1path
        _renderer1 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_R16F_EXT), format: Int32(GL_RED), type: Int32(GL_HALF_FLOAT_OES))
        _renderer1.setShaderFile(vshname: "default", fshname: "stereo_matching_SSD")
        
        _renderer2 = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_R16F_EXT), format: Int32(GL_RED), type: Int32(GL_HALF_FLOAT_OES))
        _renderer2.setShaderFile(vshname: "default", fshname: "stereo_matching_SSD")
        
        _renderer_depth = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_R16F_EXT), format: Int32(GL_RED), type: Int32(GL_HALF_FLOAT_OES))
        _renderer_depth.setShaderFile(vshname: "default", fshname: "lrcheck_and_triangulation")
    }
    
    func depthEstimation(tex1: GLuint!, tex2: GLuint!, baseline: Float) -> GLuint? {
        _renderer_depth._program.use()
        
        glUniform1i(GLint(_renderer_depth._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
        glUniform1i(GLint(_renderer_depth._program.uniformIndex(uniformName: "max_diff")), GLint(5))
        glUniform1f(GLint(_renderer_depth._program.uniformIndex(uniformName: "baseline")), GLfloat(baseline))
        glUniform1f(GLint(_renderer_depth._program.uniformIndex(uniformName: "fx")), GLfloat(g_intrinsics[0][0]))
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex1)
        glUniform1i(GLint(_renderer_depth._program.uniformIndex(uniformName: "tex")), 0)
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex2)
        glUniform1i(GLint(_renderer_depth._program.uniformIndex(uniformName: "tex2")), 1)
        _renderer_depth.renderScene()
        
        return _renderer_depth._rtt._texture
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
        return (img1, img2)
    }
    
    func getDepthUIImage() -> UIImage? {
        return _renderer_depth.getFramebufferImageGray()
    }
}
