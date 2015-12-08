//
//  Shader.swift
//  SwiftGL
//
//  Created by Scott Bennett on 2014-06-08.
//  Copyright (c) 2014 Scott Bennett. All rights reserved.
//

#if os(OSX)
import Cocoa
import OpenGL
#else
import Foundation
import OpenGLES

func glProgramUniform1i(program: GLuint, location: GLint, x: GLint)                                       {return glProgramUniform1iEXT(program, location, x)}
func glProgramUniform2i(program: GLuint, location: GLint, x: GLint, y: GLint)                             {return glProgramUniform2iEXT(program, location, x, y)}
func glProgramUniform3i(program: GLuint, location: GLint, x: GLint, y: GLint, z: GLint)                   {return glProgramUniform3iEXT(program, location, x, y, z)}
func glProgramUniform4i(program: GLuint, location: GLint, x: GLint, y: GLint, z: GLint, w: GLint)         {return glProgramUniform4iEXT(program, location, x, y, z, w)}

func glProgramUniform1iv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLint>)   {return glProgramUniform1ivEXT(program, location, count, value)}
func glProgramUniform2iv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLint>)   {return glProgramUniform2ivEXT(program, location, count, value)}
func glProgramUniform3iv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLint>)   {return glProgramUniform3ivEXT(program, location, count, value)}
func glProgramUniform4iv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLint>)   {return glProgramUniform4ivEXT(program, location, count, value)}

func glProgramUniform1f(program: GLuint, location: GLint, x: GLfloat)                                     {return glProgramUniform1fEXT(program, location, x)}
func glProgramUniform2f(program: GLuint, location: GLint, x: GLfloat, y: GLfloat)                         {return glProgramUniform2fEXT(program, location, x, y)}
func glProgramUniform3f(program: GLuint, location: GLint, x: GLfloat, y: GLfloat, z: GLfloat)             {return glProgramUniform3fEXT(program, location, x, y, z)}
func glProgramUniform4f(program: GLuint, location: GLint, x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat) {return glProgramUniform4fEXT(program, location, x, y, z, w)}

func glProgramUniform1fv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLfloat>) {return glProgramUniform1fvEXT(program, location, count, value)}
func glProgramUniform2fv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLfloat>) {return glProgramUniform2fvEXT(program, location, count, value)}
func glProgramUniform3fv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLfloat>) {return glProgramUniform3fvEXT(program, location, count, value)}
func glProgramUniform4fv(program: GLuint, location: GLint, count: GLsizei, value: UnsafePointer<GLfloat>) {return glProgramUniform4fvEXT(program, location, count, value)}

func glProgramUniformMatrix4fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: UnsafePointer<GLfloat>) {
    return glProgramUniformMatrix4fvEXT(program, location, count, transpose, value)
}

#endif
    
public class Shader {
    public typealias GLprogram = GLuint
    public typealias GLattrib  = GLint
    public typealias GLuniform = GLint
    
    public var id: GLprogram = 0
    
    public init()
    {
        
    }
    
    public init(vertexSource: String, fragmentSource: String) {
        compile(vertexSource, fragmentSource)
    }
    
    public init(vertexSource: String, fragmentSource: String, bindAttibutes: (GLprogram) -> ()) {
        compile(vertexSource, fragmentSource, bindAttibutes)
    }
    
    public init(vertexFile: String, fragmentFile: String) {
        load(vertexFile, fragmentFile)
    }
    
    public init(vertexFile: String, fragmentFile: String, bindAttibutes: (GLprogram) -> ()) {
        load(vertexFile, fragmentFile, bindAttibutes)
    }
    
    deinit {
        glDeleteProgram(id)
    }
    
    /// @return true on success
    public func compile(vertexSource: String, _ fragmentSource: String) -> Bool {
        glDeleteProgram(id)
        id = glCreateProgram();
        
        let vertexShader   = Shader.compile(GL_VERTEX_SHADER,   vertexSource)
        let fragmentShader = Shader.compile(GL_FRAGMENT_SHADER, fragmentSource)
        
        // Attach the shaders to our id
        glAttachShader(id, vertexShader)
        glAttachShader(id, fragmentShader)
        
        // Delete the shaders since they are now attached to the id, which will retain a reference to them
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        glLinkProgram(id)
        
        return Shader.verify(id)
    }
    
    /// @return true on success
    public func compile(vertexSource: String, _ fragmentSource: String, _ bindAttibutes: (GLprogram) -> ()) -> Bool {
        glDeleteProgram(id)
        id = glCreateProgram();
        
        let vertexShader   = Shader.compile(GL_VERTEX_SHADER,   vertexSource)
        let fragmentShader = Shader.compile(GL_FRAGMENT_SHADER, fragmentSource)
        
        // Call the external function to bind all of the default shader attributes
        bindAttibutes(id)
        
        // Attach the shaders to our id
        glAttachShader(id, vertexShader)
        glAttachShader(id, fragmentShader)
        
        // Delete the shaders since they are now attached to the id, which will retain a reference to them
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        glLinkProgram(id)
        
        return Shader.verify(id)
    }
    
    /// @return true on success
    public func load(shader: String) -> Bool {
        do {
            let vertexSource = try String(contentsOfFile: shader + ".vsh",   encoding: NSASCIIStringEncoding)
            do {
                let fragmentSource = try String(contentsOfFile: shader + ".fsh", encoding: NSASCIIStringEncoding)
                return self.compile(vertexSource, fragmentSource)
            } catch _ {
            }
        } catch _ {
        }
        
        return false
    }
    
    /// @return true on success
    public func load(vertexFile: String, _ fragmentFile: String) -> Bool {
        do {
            let vertexSource = try String(contentsOfFile: vertexFile,   encoding: NSASCIIStringEncoding)
            do {
                let fragmentSource = try String(contentsOfFile: fragmentFile, encoding: NSASCIIStringEncoding)
                return self.compile(vertexSource, fragmentSource)
            } catch _ {
            }
        } catch _ {
        }
        
        return false
    }
    
    /// @return true on success
    public func load(vertexFile: String, _ fragmentFile: String, _ bindAttibutes: (GLprogram) -> ()) -> Bool {
        do {
            let vertexSource = try String(contentsOfFile: vertexFile,   encoding: NSASCIIStringEncoding)
            do {
                let fragmentSource = try String(contentsOfFile: fragmentFile, encoding: NSASCIIStringEncoding)
                return self.compile(vertexSource, fragmentSource, bindAttibutes)
            } catch _ {
            }
        } catch _ {
        }
        
        return false
    }
    
    public func useProgram() {
        glUseProgram(id)
    }
    
    public func attribute(name: String) -> GLint {
        return glGetAttribLocation(id, UnsafePointer<CChar>(name.cStringUsingEncoding(NSASCIIStringEncoding)!))
    }
    
    public func uniform(name: String) -> GLuniform {
        let iLoc = glGetUniformLocation(id, UnsafePointer<CChar>(name.cStringUsingEncoding(NSASCIIStringEncoding)!))
        return iLoc
    }
    
    // Bind Uniforms using Uniform Location
    public func bind(uniform: GLuniform, _ x: Float) {glProgramUniform1f(id, location: uniform, x: x)}
    public func bind(uniform: GLuniform, _ x: Float, _ y: Float) {glProgramUniform2f(id, location: uniform, x: x, y: y)}
    public func bind(uniform: GLuniform, _ x: Float, _ y: Float, _ z: Float) {glProgramUniform3f(id, location: uniform, x: x, y: y, z: z)}
    public func bind(uniform: GLuniform, _ x: Float, _ y: Float, _ z: Float, _ w: Float) {glProgramUniform4f(id, location: uniform, x: x, y: y, z: z, w: w)}
    public func bind(uniform: GLuniform, _ v: Vec2) {glProgramUniform2fv(id, location: uniform, count: 1, value: UnsafePointer([v]))}
    public func bind(uniform: GLuniform, _ v: Vec3) {glProgramUniform3fv(id, location: uniform, count: 1, value: UnsafePointer([v]))}
    public func bind(uniform: GLuniform, _ v: Vec4) {glProgramUniform4fv(id, location: uniform, count: 1, value: UnsafePointer([v]))}
    
    public func bind(uniform: GLuniform, _ m: Mat4, transpose: GLboolean = GL_FALSE) {glProgramUniformMatrix4fv(id, location: uniform, count: 1, transpose: transpose, value: UnsafePointer([m]))}
    
    public func bind(uniform: GLuniform, _ texture: Texture, index: GLint = 0) {
        glProgramUniform1i(id, location: uniform, x: index)
        glActiveTexture(GL_TEXTURE0 + GLenum(index))
        glBindTexture(GL_TEXTURE_2D, texture.id)
    }
    
    // Bind Uniforms using String
    public func bind(uniform: String, _ x: Float) {glProgramUniform1f(id, location: self.uniform(uniform), x: x)}
    public func bind(uniform: String, _ x: Float, _ y: Float) {glProgramUniform2f(id, location: self.uniform(uniform), x: x, y: y)}
    public func bind(uniform: String, _ x: Float, _ y: Float, _ z: Float) {glProgramUniform3f(id, location: self.uniform(uniform), x: x, y: y, z: z)}
    public func bind(uniform: String, _ x: Float, _ y: Float, _ z: Float, _ w: Float) {glProgramUniform4f(id, location: self.uniform(uniform), x: x, y: y, z: z, w: w)}
    public func bind(uniform: String, _ v: Vec2) {glProgramUniform2fv(id, location: self.uniform(uniform), count: 1, value: UnsafePointer([v]))}
    public func bind(uniform: String, _ v: Vec3) {glProgramUniform3fv(id, location: self.uniform(uniform), count: 1, value: UnsafePointer([v]))}
    public func bind(uniform: String, _ v: Vec4) {glProgramUniform4fv(id, location: self.uniform(uniform), count: 1, value: UnsafePointer([v]))}
    
    public func bind(uniform: String, _ m: Mat4, transpose: GLboolean = GL_FALSE) {glProgramUniformMatrix4fv(id, location: self.uniform(uniform), count: 1, transpose: transpose, value: UnsafePointer([m]))}
    
    public func bind(uniform: String, _ texture: Texture, index: GLint = 0) {
        glProgramUniform1i(id, location: self.uniform(uniform), x: index)
        glActiveTexture(GL_TEXTURE0 + GLenum(index))
        glBindTexture(GL_TEXTURE_2D, texture.id)
        
    }
    
    private class func ptr <T> (ptr: UnsafePointer<T>) -> UnsafePointer<T> {return ptr}
    
    private class func compile(type: GLenum, _ source: String) -> GLprogram {
        if let csource: [GLchar] = source.cStringUsingEncoding(NSASCIIStringEncoding) {
            var cptr = ptr(csource)
            
            let shader = glCreateShader(type)
            glShaderSource(shader, 1, &cptr, nil)
            glCompileShader(shader)
            
            var logLength: GLint = 0
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                let log = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                glGetShaderInfoLog(shader, logLength, &logLength, log)
                print("Shader compile log: \(String(CString: log, encoding: NSASCIIStringEncoding)!)")
                free(log)
            }
            
            var status: GLint = 0
            glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
            if status == GLint(GL_FALSE) {
                print("Failed to compile shader: \(csource)")
                return 0
            }
            
            return shader
        }
        
        return 0
    }
    
    private class func verify(program: GLprogram) -> Bool {
//        #if DEBUG
        // Assert that the program was successfully linked
        var logLength: GLint = 0
        glGetProgramiv(program, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        
        if logLength > 0 {
            let log = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
            glGetProgramInfoLog(program, logLength, &logLength, log)
            print("Program link log:\n\(String(CString: log, encoding: NSASCIIStringEncoding)!)")
            free(log)
        }
//        #endif
        
        var status: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status)
        
        if status == 0 {
            print("Failed to link shader program")
            return false
        }
        
        return true
    }
}
