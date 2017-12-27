//
//  myGLKView.swift
//  AR
//
//  Created by jhw on 26/11/2017.
//  Copyright © 2017 zju.gaps. All rights reserved.
//

import UIKit
import GLKit
import CoreGraphics

class myGLKView: GLKView, GLKViewDelegate {

    var vertexShader: GLuint = 0
    var fragmentShader: GLuint = 0
    var numIndices: Int = 0
    var vertexIndicesBufferID: GLuint = 0
    var vertexBufferID: GLuint = 0
    var vertexTexCoordID: GLuint = 0
    var vertexTexCoordAttributeIndex: GLuint = 0
    
    
    var uniform_model_view_projection_matrix: GLuint = 0
    var uniform_y: GLuint = 0
    var uniform_uv: GLuint = 0
    var uniform_color_conversion_martrix: GLuint = 0
    
    let sphereSliceNum = 200
    let sphereRadius = 1.0
    let sphereScale = 300
    
    var fingerRotationX: Float = 0
    var fingerRotationY: Float = 0
    
    //var glkDelegate: myGLController?
    
    var program: myGLProgram?
    var texture: GLuint = 0
    
    var testTexture: GLKTextureInfo? = nil
    //var texture: VKGLTexture?
    
    var _rtt: myGLRTT!
    
    var anUIImage: UIImage!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        //glkDelegate = myGLController.init(frame: frame)
        
        self.configureGLKView()
        /*
        self.configureProgram()
        self.configureTexture()
        self.configureBuffer()
        self.configureUniform()
        self.configureDisplayLink()
        
        _rtt = myGLRTT.init(width: GLsizei(240*UIScreen.main.scale), height: GLsizei(180*UIScreen.main.scale), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        
        render_to_fbo()
        */
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        //glkDelegate = myGLController.init(coder: aDecoder)
        
        self.configureGLKView()
        /*
        self.configureProgram()
        self.configureTexture()
        self.configureBuffer()
        self.configureUniform()
        self.configureDisplayLink()
        
        _rtt = myGLRTT.init(width: GLsizei(240*UIScreen.main.scale), height: GLsizei(180*UIScreen.main.scale), internalformat: Int32(GL_RGBA), format: Int32(GL_RGBA), type: Int32(GL_UNSIGNED_BYTE))
        
        render_to_fbo()
        */
    }
    
    
    internal func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    func render_to_fbo() {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glClearColor(1.0, 0.0, 0.0, 1.0)
        
        glViewport(0, 0, GLsizei(240*UIScreen.main.scale), GLsizei(180*UIScreen.main.scale))
        _rtt.bind()
        
        glUniform1i(GLint(program!.uniformIndex(uniformName: "tex")), 0)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(numIndices*3), GLenum(GL_UNSIGNED_SHORT), nil);
        
        _rtt.unbind_to_lastfbo()
        
        let byteLength = Int(_rtt._width * _rtt._height)
        //var bytes: UnsafeMutableRawPointer? = malloc(byteLength*2)
        var bytes = [UInt32](repeating: 0, count: Int(byteLength))
        //print("byte:", bytes.)
        
        //glPixelStorei(GLuint(GL_PACK_ALIGNMENT), 4)
        //glBindTexture(GLenum(GL_TEXTURE_2D), _rtt._texture)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), _rtt._framebuffer)
        glReadPixels(0, 0, _rtt._width, _rtt._height, GLenum(_rtt._format), GLenum(_rtt._type), &bytes)
        print("read pixels result:", glGetError())
        print("bytes:",bytes[0], bytes[1], bytes[2])
        
        anUIImage = getUIImagefromRGBABuffer(src_buffer: &bytes, width: Int(_rtt._width), height: Int(_rtt._height))
    
        if anUIImage == nil {
            fatalError("image = nil")
        }
        /*
        let pixelData: UnsafePointer = (UnsafeRawPointer(bytes)?.assumingMemoryBound(to: UInt8.self))!
        let cfdata: CFData = CFDataCreate(kCFAllocatorDefault, pixelData, byteLength * MemoryLayout<GLubyte>.size)
        
        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let iref: CGImage? = CGImage(width: Int(_rtt._width), height: Int(_rtt._height), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: Int(_rtt._width)*4, space: colorspace, bitmapInfo: CGBitmapInfo.byteOrder32Big, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        UIGraphicsBeginImageContext(CGSize(width: CGFloat(_rtt._width), height: CGFloat(_rtt._height)))
        let cgcontext: CGContext? = UIGraphicsGetCurrentContext()
        cgcontext!.setBlendMode(CGBlendMode.copy)
        cgcontext!.draw(iref!, in: CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(_rtt._width), height: CGFloat(_rtt._height)))
        
        
        
        anUIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        
        
        if anUIImage == nil {
            fatalError("image = nil")
        }
        UIGraphicsEndImageContext()
 
        */
        
        
        /*
        if bytes == nil {
            fatalError("get pixel failure")
        }
        
        let releaseData: CGDataProviderReleaseDataCallback = {(info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            return
        }
        let dataProvider: CGDataProvider? = CGDataProvider(dataInfo: nil, data: bytes!, size: byteLength, releaseData: releaseData)
        
        if dataProvider == nil {
            fatalError("data provider equal to nil")
        }
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)]
        
        let aCGImage = CGImage.init(width: Int(_rtt._width), height: Int(_rtt._height), bitsPerComponent: 8, bitsPerPixel: 4, bytesPerRow: Int(4*_rtt._width), space: colorspace, bitmapInfo: bitmapInfo, provider: dataProvider!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        if aCGImage == nil {
            fatalError("cg image create failure")
        }
        
        anUIImage = UIImage.init(cgImage: aCGImage!)
        */
    }
    
    override func draw(_ rect: CGRect) {
        /*
        glClearColor(1.0, 1.0, 1.0, 1.0)
        
        //var buffer: CVPixelBuffer? = glkDelegate!.dataSource()
        
        //if buffer == nil {
        //    return
        //}
        
        //texture?.refreshTextureWithPixelBuffer(pixelBuffer: buffer)
        
        //var matrix: GLKMatrix4 = GLKMatrix4Identity
        //var success: Bool  = matrixWithSize(size:self.bounds.size, matrix:&matrix)
        //if success {
        
        
        glUniform1i(GLint(program!.uniformIndex(uniformName: "tex")), 0)
        //glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), _rtt._texture)
        
        glViewport(0, 0, GLsizei(rect.width*UIScreen.main.scale), GLsizei(rect.height*UIScreen.main.scale))
            
            //glUniformMatrix4fv(GLint(uniform_model_view_projection_matrix), 1, GLboolean(GL_FALSE), matrix.array)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(numIndices*3), GLenum(GL_UNSIGNED_SHORT), nil);
        
        //}
        */
    }
    
    func configureGLKView() {
        
        self.drawableDepthFormat = GLKViewDrawableDepthFormat.formatNone
        self.contentScaleFactor = UIScreen.main.scale
        self.delegate = self
        self.context = EAGLContext.init(api: EAGLRenderingAPI.openGLES3)!
        EAGLContext.setCurrent(self.context)
        glClearColor(0, 0, 0, 1)
        
    }
    
    func configureProgram() {
        
        self.program = myGLProgram(vshname: "Shader", fshname: "Shader")
        self.program!.addAttribute(attributeName: "position")
        self.program!.addAttribute(attributeName: "texCoord")
        
        if !self.program!.link() {
            program = nil
            print("failure")
        }
        
        vertexTexCoordAttributeIndex = program!.attributeIndex(attributeName: "texCoord")
        
        //uniform_model_view_projection_matrix = program!.uniformIndex(uniformName: "modelViewProjectionMatrix")
        //uniform_y = program!.uniformIndex(uniformName: "SamplerY")
        //uniform_uv = program!.uniformIndex(uniformName: "SamplerUV")
        //uniform_color_conversion_martrix = program!.uniformIndex(uniformName: "colorConversionMatrix")
        program!.use()
        
    }
    
    func configureTexture() {
        
        testTexture = try! GLKTextureLoader.texture(with: (UIImage(named: "texture")!.cgImage)!, options: nil)
        texture = testTexture!.name
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
    }
    /*
    func matrixWithSize(size: CGSize, matrix: inout GLKMatrix4) -> Bool {
        
        var modelViewMatrix: GLKMatrix4  = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, -(Float)(fingerRotationX));
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, Float(fingerRotationY));
        
        var aspect: Float = fabs(Float(size.width) / Float(size.height))
        var mvpMatrix: GLKMatrix4  = GLKMatrix4Identity;
        var projectionMatrix: GLKMatrix4 = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1, 400.0)
        var viewMatrix: GLKMatrix4  = GLKMatrix4MakeLookAt(0, 0, 0.0, 0, 0, -1000, 0, 1, 0);
        mvpMatrix = GLKMatrix4Multiply(projectionMatrix, viewMatrix);
        mvpMatrix = GLKMatrix4Multiply(mvpMatrix, modelViewMatrix);
        
        matrix = mvpMatrix;
        
        return true;
        
    }
    */
    
    func configureBuffer() {
        
        var vertices: UnsafeMutablePointer<Float>?
        var textCoord:UnsafeMutablePointer<Float>?
        var indices: UnsafeMutablePointer<Int16>?
        var numVertices: Int32? = 0
        
        numIndices = Int(GLuint(myGenVertices(&vertices, &textCoord, &indices, &numVertices!)))
        
        // Indices
        var tempVertexIndicesBufferID: GLuint = 0
        glGenBuffers(1, &tempVertexIndicesBufferID)
        vertexIndicesBufferID = tempVertexIndicesBufferID
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vertexIndicesBufferID)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), numIndices*3*MemoryLayout<GLushort>.size, indices, GLenum(GL_STATIC_DRAW))
        
        // Vertex
        var tempVertexBufferID: GLuint = 0
        glGenBuffers(1, &tempVertexBufferID)
        vertexBufferID = tempVertexBufferID
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Int(numVertices!)*3*MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*3), nil)
        
        // Texture Coordinates
        var tempVertexTexCoordID: GLuint = 0
        glGenBuffers(1, &tempVertexTexCoordID)
        vertexTexCoordID = tempVertexTexCoordID
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexTexCoordID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Int(numVertices!)*2*MemoryLayout<GLfloat>.size, textCoord, GLenum(GL_DYNAMIC_DRAW))
        
        glEnableVertexAttribArray(vertexTexCoordAttributeIndex);
        glVertexAttribPointer(vertexTexCoordAttributeIndex, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*2), nil);
        
    }
    
    func configureUniform() {
        
        //var conversion: UnsafePointer<GLfloat>!
        
        //var array: [GLfloat] = [1.164, 1.164, 1.164, 0.0, -0.213, 2.112, 1.793, -0.533, 0.0]
        //var arrayPtr = UnsafeMutableBufferPointer<GLfloat>(start: &array, count: array.count)
        // baseAddress 是第一个元素的指针
        //var basePtr = arrayPtr.baseAddress as UnsafePointer<GLfloat>!
        
        //glUniform1i(GLint(uniform_y), 0);
        //glUniform1i(GLint(uniform_uv), 1);
        //glUniformMatrix3fv(GLint(uniform_color_conversion_martrix), 1, GLboolean(GL_FALSE), &array);
        
    }
    
    func configureDisplayLink() {
        let displayLink = CADisplayLink.init(target: self, selector: #selector(displayLinkAction))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    @objc
    func displayLinkAction() {
        self.display()
    }

}

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}
