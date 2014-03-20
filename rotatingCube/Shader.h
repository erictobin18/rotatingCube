//-------------------------------------------------------------------------
//
//	File: Shader.h
//
//  Abstract: Rudimentary class to instantiate a shader object
//            NOTE: This class does not validate the program object
// 			 
//-------------------------------------------------------------------------
//
// Required Includes
//
//-------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl3.h>
#import <OpenGL/glext.h>

//-------------------------------------------------------------------------
//
// GLSL Shader
//
//-------------------------------------------------------------------------

@interface Shader : NSObject
{
	@private
		const GLcharARB    *fragmentShaderSource;		// the GLSL source for the fragment Shader
		const GLcharARB    *vertexShaderSource;			// the GLSL source for the vertex Shader
		GLuint             program;                    // the program
} // Shader

- (id) initWithShadersInAppBundle:(NSString *)theShadersName;

- (GLuint) program;

- (GLint) getUniformLocation:(const GLcharARB *)theUniformName;

@end

//-------------------------------------------------------------------------

