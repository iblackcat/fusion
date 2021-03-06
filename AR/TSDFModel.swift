//
//  TSDFModel.swift
//  AR
//
//  Created by jhw on 06/12/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import Foundation
import GLKit

public let ModelTexSize = 4096
public let ModelSize = 256


public let viewx = matrix_float3x3(float3(1,0,0),float3(0,-1,0),float3(0,0,-1))
public let viewz = matrix_float3x3(float3(-1,0,0),float3(0,-1,0),float3(0,0,1))
public let view_x = matrix_float3x3(float3(-1,0,0),float3(0,1,0),float3(0,0,1))

class TSDFModel {
    
    var _renderer_updating: myGLRenderer! = nil
    var _last_model_texture: myGLTexture2D! = nil
    var _last_model_texture1: myGLTexture2D! = nil
    
    var _renderer_raytracing: myGLRenderer! = nil
    
    var gl_error:  GLenum = 0
    
    let m_axis = [
        float3( 1.0,  0.0,  0.0),
        float3(-1.0,  0.0,  0.0),
        float3( 0.0,  1.0,  0.0),
        float3( 0.0, -1.0,  0.0),
        float3( 0.0,  0.0,  1.0),
        float3( 0.0,  0.0, -1.0)
    ]
    
    init() {
        //model updating init
        _renderer_updating = myGLRenderer.init(width: GLsizei(ModelTexSize), height: GLsizei(ModelTexSize), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE), textures: 2)
        _renderer_updating.setShaderFile(vshname: "default", fshname: "model_updating")
        
        _last_model_texture = myGLRenderer.createTexture(width: GLsizei(ModelTexSize), height: GLsizei(ModelTexSize), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        _last_model_texture1 = myGLRenderer.createTexture(width: GLsizei(ModelTexSize), height: GLsizei(ModelTexSize), internalformat: Int32(GL_R8), format: Int32(GL_RED), type: Int32(GL_UNSIGNED_BYTE))
        //swapModelTextures()
        //_renderer_updating._rtt.checkFBOstatus()
        
        model_init()
        
        //ray tracing init
        _renderer_raytracing = myGLRenderer.init(width: GLsizei(g_width), height: GLsizei(g_height), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE), textures: 3)
        _renderer_raytracing.setShaderFile(vshname: "default", fshname: "ray_tracing")
    }
    
    func model_init() {
        _renderer_updating._program.use()
        
        var trans = [GLfloat](repeating: GLfloat(0.0), count: Int(16))
        
        for i in 0...3 {
            for j in 0...3 {
                trans[i*4+j] = GLfloat(0.0)
            }
        }
        
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "m_w")), GLint(0))
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "m_h")), GLint(0))
        glUniform1f(GLint(_renderer_updating._program.uniformIndex(uniformName: "edgeLength")), GLfloat(0.1*Cube.Scale))
        glUniformMatrix4fv(GLint(_renderer_updating._program.uniformIndex(uniformName: "Q")), 1, GLboolean(GL_FALSE), &trans)
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), _last_model_texture1._textureid)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "tex_image")), 0)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "tex_depth")), 0)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "model")), 0)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "model1")), 0)
        _renderer_updating.renderScene()
        
        swapModelTextures()
    }
    
    func ray_tracing(pose: CameraPose!, tag: Bool = true) {
        _renderer_raytracing._program.use()
        
        var R: matrix_float3x3
        var t: float3
        
        if tag {
            R = pose.R * Cube.Pose.R.inverse
            t = pose.t - pose.R * Cube.Pose.R.inverse * Cube.Pose.t
        } else {
            R = pose.R
            t = pose.t
        }
        //let R: matrix_float3x3 = pose.R.inverse*Cube.Pose.R//pose.R * Cube.Pose.R.inverse
        //let t: float3 = pose.R.inverse*Cube.Pose.t - pose.R.inverse*pose.t//pose.t - pose.R * Cube.Pose.R.inverse * Cube.Pose.t
        //let transform = matrix_float4x4([float4(R[0][0], R[0][1], R[0][2], Float(0)), float4(R[1][0], R[1][1], R[1][2], Float(0)), float4(R[2][0], R[2][1], R[2][2], Float(0)), float4(t[0], t[1], t[2], Float(0))])
        
        //let T = CameraPose.init(A: g_intrinsics, trans: transform)
        //let T = CameraPose.init(A: g_intrinsics, R: view_x*matrix_float3x3.init(float3(1,0,0),float3(0,1,0),float3(0,0,1)), t: view_x*float3(0,0,-0.5))
        //let T = CameraPose.init(A: g_intrinsics, R: view_x*R*view_x, t: view_x*t)
        //let T = CameraPose.init(A: g_intrinsics, R: viewx*R, t: viewx*t)
        let T = CameraPose.init(A: g_intrinsics, R: R, t: t)
        let invQ: matrix_float3x3 = T.Q.inverse
        
        var iQ = [GLfloat](repeating: GLfloat(0.0), count: Int(9))
        for i in 0...2 {
            for j in 0...2 {
                iQ[i*3+j] = GLfloat(invQ[j][i])
            }
        }
        
        var tmp = Float(0.0)
        var axis_tmp = Int(0)
        for i in 0..<6 {
            if dot(R.transpose[2], m_axis[i]) > tmp {
                tmp = dot(R.transpose[2], m_axis[i])
                axis_tmp = i
            }
        }
        //print("axis: ", axis_tmp)
        //print("R: ", R)
        //print("t: ", t)
        
        glUniform1i(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
        glUniform1i(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
        glUniform1f(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "edgeLength")), GLfloat(0.1*Cube.Scale))
        glUniform1i(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "flag")), GLint(0)) //C
        glUniform1i(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "Axis")), GLint(axis_tmp))
        glUniformMatrix3fv(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "invQ")), 1, GLboolean(GL_FALSE), &iQ)
        glUniform3f(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "q")), GLfloat(T.q[0]), GLfloat(T.q[1]), GLfloat(T.q[2]))
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), _last_model_texture._textureid)
        glUniform1i(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "model")), 0)
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), _last_model_texture1._textureid)
        glUniform1i(GLint(_renderer_raytracing._program.uniformIndex(uniformName: "model1")), 1)
        
        _renderer_raytracing.renderScene()
    }
    
    func model_updating(tex_color: GLuint!, tex_depth: GLuint!, pose: CameraPose!) {
        _renderer_updating._program.use()
        
        //let R: matrix_float3x3 = pose.R.inverse*Cube.Pose.R//pose.R * Cube.Pose.R.inverse
        //let t: float3 = pose.R.inverse*Cube.Pose.t - pose.R.inverse*pose.t//pose.t - pose.R * Cube.Pose.R.inverse * Cube.Pose.t
        
        let R: matrix_float3x3 = pose.R * Cube.Pose.R.inverse
        let t: float3 = pose.t - pose.R * Cube.Pose.R.inverse * Cube.Pose.t
        //let pose: CameraPose = CameraPose.init(A: g_intrinsics, R: viewx*R, t: viewx*t)
        let pose: CameraPose = CameraPose.init(A: g_intrinsics, R: R, t: t)
        
        var trans = [GLfloat](repeating: GLfloat(0.0), count: Int(16))
        
        for i in 0..<3 {
            for j in 0..<3 {
                trans[i*4+j] = GLfloat(pose.Q[i][j])
            }
            trans[3*4+i] = GLfloat(pose.q[i])
            trans[i*4+3] = GLfloat(0.0)
        }
        trans[3*4+3] = GLfloat(1.0)
        
        //gl_error = glGetError()
        //print("glerror1:", gl_error)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "m_w")), GLint(g_width))
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "m_h")), GLint(g_height))
        //gl_error = glGetError()
        //print("glerror2:", gl_error)
        glUniform1f(GLint(_renderer_updating._program.uniformIndex(uniformName: "edgeLength")), GLfloat(0.1*Cube.Scale))
        //gl_error = glGetError()
        //print("glerror3:", gl_error)
        glUniformMatrix4fv(GLint(_renderer_updating._program.uniformIndex(uniformName: "Q")), 1, GLboolean(GL_FALSE), &trans)
        //gl_error = glGetError()
        //print("glerror4:", gl_error)
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex_color)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "tex_image")), 0)
        glActiveTexture(GLenum(GL_TEXTURE1))
        glBindTexture(GLenum(GL_TEXTURE_2D), tex_depth)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "tex_depth")), 1)
        glActiveTexture(GLenum(GL_TEXTURE2))
        glBindTexture(GLenum(GL_TEXTURE_2D), _last_model_texture._textureid)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "model")), 2)
        glActiveTexture(GLenum(GL_TEXTURE3))
        glBindTexture(GLenum(GL_TEXTURE_2D), _last_model_texture1._textureid)
        glUniform1i(GLint(_renderer_updating._program.uniformIndex(uniformName: "model1")), 3)
        //gl_error = glGetError()
        //print("glerror5:", gl_error)
        
        
        _renderer_updating.renderScene()
        //gl_error = glGetError()
        //print("glerror6:", gl_error)
        
        swapModelTextures()
        _renderer_updating._rtt.checkFBOstatus()
    }
    
    func swapModelTextures() {
        let swap_texture = _renderer_updating._rtt._texture
        let swap_texture1 = _renderer_updating._rtt._texture1
        _renderer_updating._rtt.changeColorBuffer(tex: _last_model_texture._textureid, tex1: _last_model_texture1._textureid)
        _last_model_texture._textureid = swap_texture
        _last_model_texture1._textureid = swap_texture1
        
        /*
        let _swap_texture = _last_model_texture._textureid
        _last_model_texture._textureid = _renderer_updating._rtt._texture
        _renderer_updating._rtt._texture = _swap_texture
        */
    }
    
    func getUIImage() -> UIImage? {
        let img = _renderer_raytracing.getFramebufferImage()
        
        return img
    }
    
    func getAllImage() -> (UIImage?, UIImage?, UIImage?) {
        let (i1, i2, i3) = _renderer_raytracing.getFramebuffer3Images()
        
        return (i1, i2, i3)
    }
    
    func getModelUIImage() -> UIImage? {
        let img = _renderer_updating.getFramebufferImage()
        
        return img
    }
}
