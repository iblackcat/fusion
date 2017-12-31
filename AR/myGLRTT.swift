//
//  myGLRTT.swift
//  AR
//
//  Created by jhw on 30/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import Foundation
import GLKit

class myGLRTT {
    var _width: GLsizei = 0
    var _height: GLsizei = 0
    
    var _framebuffer: GLuint = 0
    var _texture: GLuint = 0
    var _texture1: GLuint = 0
    var _lastfbo: GLint = 0
    
    var _internalformat: Int32 = 0
    var _format: Int32 = 0
    var _type: Int32 = 0
    
    init(width: GLsizei, height: GLsizei, internalformat: Int32, format: Int32, type: Int32, textures: Int = 1) {
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &_lastfbo)
        
        
        _width = width
        _height = height
        
        _internalformat = internalformat
        _format = format
        _type = type
        
        glGenFramebuffers(1, &_framebuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _framebuffer)
        
        glGenTextures(1, &_texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(_internalformat), width, height, 0, GLenum(_format), GLenum(_type), nil)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _framebuffer)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), _texture, 0)
        if (textures == 2) {
            /*
            glGenTextures(1, &_texture1)
            glBindTexture(GLenum(GL_TEXTURE_2D), _texture1)
            glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(_internalformat), width, height, 0, GLenum(_format), GLenum(_type), nil)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
            glBindTexture(GLenum(GL_TEXTURE_2D), 0)
            
            glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT1), GLenum(GL_TEXTURE_2D), _texture1, 0)
            */
            glDrawBuffers(GLsizei(2),[GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_COLOR_ATTACHMENT1)])
        }
        //glDrawBuffers(GLsizei(1),[GLenum(GL_COLOR_ATTACHMENT0)])
        //let bytes = [GLuint](repeating: 0, count: Int(4))
        //glClearBufferuiv(GLenum(GL_COLOR), 0, bytes)
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLenum(_lastfbo))
        checkFBOstatus()
    }
    
    func changeColorBuffer(tex: GLuint) {
        bind()
        _texture = tex
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), _texture, 0)
        unbind_to_lastfbo()
    }
    
    func changeColorBuffer(tex: GLuint, tex1: GLuint) {
        bind()
        _texture = tex
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), _texture, 0)
        
        _texture1 = tex1
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT1), GLenum(GL_TEXTURE_2D), _texture, 0)
        unbind_to_lastfbo()
    }
    
    func checkFBOstatus() {
        bind()
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        if status != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            print("status:", status)
            print("right: ", GLenum(GL_FRAMEBUFFER_COMPLETE))
            
            print("GL_FRAMEBUFFER_UNDEFINED:",GLenum(GL_FRAMEBUFFER_UNDEFINED))
            print("GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:",GLenum(GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT))
            print("GL_FRAMEBUFFER_UNSUPPORTED:",GLenum(GL_FRAMEBUFFER_UNSUPPORTED))
        }
        unbind_to_lastfbo()
    }
    
    func bind() {
        glGetIntegerv(GLenum(GL_FRAMEBUFFER_BINDING), &_lastfbo)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _framebuffer)
    }
    
    func unbind_to_lastfbo() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), GLenum(_lastfbo))
    }
    
    func unbind_to_0() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }
}
