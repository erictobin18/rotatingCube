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
#import "Shader.h"

@interface FunOpenGLView : NSOpenGLView
{
    GLuint programObject;
    Shader *sh;
}
@property BOOL isReadyForDrawing, isAnimating;
@property GLuint framesElapsed;

- (void) prepareOpenGL;
- (void) awakeFromNib;

@end
