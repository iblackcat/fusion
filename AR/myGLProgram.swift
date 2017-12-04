//
//  myGLProgram.swift
//  AR
//
//  Created by jhw on 27/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import UIKit

class myGLProgram: NSObject {
    
    var attributes: NSMutableArray = []
    var uniforms: NSMutableArray = []
    
    var program: GLuint = 0
    var vertexShader: GLuint = 0
    var fragmentShader: GLuint = 0
    
    init(vshname: String, fshname: String) {
        super.init()
        self.configureShader(vshname: vshname, fshname: fshname)
    }
    
    func configureShader(vshname: String, fshname: String) {
        program = glCreateProgram()
        
        if !self.compileShader(&vertexShader, type: GLenum(GL_VERTEX_SHADER), file: Bundle.main.path(forResource: vshname, ofType: "vsh")!) {
            print("vertex shader failure")
        }
        
        if !self.compileShader(&fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), file: Bundle.main.path(forResource: fshname, ofType: "fsh")!) {
            print("fragment shader failure")
        }
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
    }
    
    func addAttribute(attributeName: String) {
        if self.attributes.contains(attributeName) {return}
        
        self.attributes.add(attributeName)
        glBindAttribLocation(self.program, GLuint(self.attributes.index(of: attributeName)), NSString.init(string: attributeName).utf8String)
    }
    
    func attributeIndex(attributeName: String) -> GLuint {
        return GLuint(self.attributes.index(of: attributeName))
    }
    
    func uniformIndex(uniformName: String) -> GLuint {
        return GLuint(glGetUniformLocation(self.program, NSString.init(string: uniformName).utf8String))
    }
    
    func link() -> Bool {
        var status: GLint = 0
        glLinkProgram(self.program)
        
        glGetProgramiv(self.program, GLenum(GL_LINK_STATUS), &status)
        
        if status == GL_FALSE {
            return false
        }
        if self.vertexShader > 0 {
            glDeleteShader(self.vertexShader)
            self.vertexShader = 0
        }
        if self.fragmentShader > 0 {
            glDeleteShader(self.fragmentShader)
            self.fragmentShader = 0
        }
        
        return true
    }
    
    func use() {
        glUseProgram(self.program)
    }
    
    func compileShader(_ shader: inout GLuint, type: GLenum, file: String) -> Bool {
        var status: GLint = 0
        var source: UnsafePointer<Int8>
        
        do{
            source = try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue).utf8String!
        } catch {
            print("Failed to load vertex shader!")
            return false
        }
        
        var castSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
        
        shader = glCreateShader(type)
        glShaderSource(shader, 1, &castSource, nil)
        glCompileShader(shader)
        
        
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        if status == 0 {
            glDeleteShader(shader)
            return false
        }
        
        return true
    }
}
