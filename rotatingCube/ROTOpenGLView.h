//
//  FunOpenGLView.h
//  openGLFun
//
//  Created by Eric Tobin on 1/14/14.
//  Copyright (c) 2014 omnisciendus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import "Shader.h"

@interface ROTOpenGLView : NSOpenGLView
{
    GLuint programObject;
    Shader *sh;
    
    NSImage *textureImage;
    
    GLuint VAOs[1];
    GLuint Buffers[2];
    GLuint Textures[3];
    
    GLubyte *texSide;
    GLubyte *texTop;
    GLubyte *texBot;
    
    
}
@property BOOL isReadyForDrawing, isAnimating, verbose;
@property GLuint framesElapsed;

- (void) prepareOpenGL;
- (void) awakeFromNib;
- (void) reportError;

@end
