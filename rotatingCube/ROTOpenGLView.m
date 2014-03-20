//
//  FunOpenGLView.m
//  openGLFun
//
//  Created by Eric Tobin on 1/14/14.
//  Copyright (c) 2014 omnisciendus. All rights reserved.
//

#import "ROTOpenGLView.h"
#import <OpenGL/glext.h>
#include <math.h>

#define BUFFER_OFFSET(offset) ((void *)(offset))

const GLuint NumVertices = 6;

@implementation ROTOpenGLView

-(void)animationTimer
{
    if (_isAnimating)
    {
        _framesElapsed++;
        [self drawRect:[self bounds]];
        //NSLog(@"Frames: %d",_framesElapsed);
    }
}

-(void)drawRect:(NSRect)dirtyRect
{
    if (_framesElapsed < 1) //this needs to be called any time the window resizes.
    {
        //NSLog(@"drawRect at 0 frames!");
        [[self openGLContext] setView:self];
    }
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[0]);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(0);
    
    glVertexAttrib1d(1, cos(_framesElapsed/100.));
    glVertexAttrib1d(2, sin(_framesElapsed/100.));
    
    NSLog(@"%f",_framesElapsed/100.);
    
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    /*
     
     L_POINTS, GL_LINES, GL_LINE_STRIP, GL_LINE_LOOP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, and GL_PATCHES.
     */
    glFlush();
}

- (void)prepareOpenGL
{
    sh = [[Shader alloc] initWithShadersInAppBundle:@"Shader"]; //create shader OBJ-C class, shader OpenGL object, compile, and link object to shader program
    programObject = [sh program]; //set programObject variable to shader program (not active in OpenGL yet)
    
    
    glGenVertexArrays(1, VAOs); //Frees 1 vertex array label and stores it in VAOs[0]
    glBindVertexArray(VAOs[0]); //Makes first element of VAOs the active vertex array object

    glGenBuffers(6, Buffers); //Frees 6 buffer labels and stores them in Buffers
    
    GLfloat a[4][3] = {{1,1,1},{1,1,-1},{1,-1,1},{1,-1,-1}};
    GLfloat b[4][3] = {{1,-1,1},{1,-1,-1},{-1,-1,1},{-1,-1,-1}};
    GLfloat c[4][3] = {{-1,-1,1},{-1,-1,-1},{-1,1,1},{-1,1,-1}};
    GLfloat d[4][3] = {{-1,1,1},{-1,1,-1},{1,1,1},{1,1,-1}};
    GLfloat e[4][3] = {{1,1,1},{1,-1,1},{-1,-1,1},{-1,1,1}};
    GLfloat f[4][3] = {{1,1,-1},{1,-1,-1},{-1,-1,-1},{-1,1,-1}};
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[0]); //Binds the first element of Buffers to the GL_ARRAY_BUFFER target
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(a),a, GL_STATIC_DRAW); //loads vertices into the buffer currently bound to the GL_ARRAY_BUFFER target, which is the first element of Buffers
    
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(b),b, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(c),c, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[3]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(d),d, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[4]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(e),e, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[5]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(f),f, GL_STATIC_DRAW);
    
    
    
    glUseProgram(programObject); //activates the shader program
    
    
    
    

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f); //sets clear color
    
    _isAnimating = TRUE; //preparations complete!
    _isReadyForDrawing = TRUE;
    
    
}

-(void)awakeFromNib
{
    _framesElapsed = 0;
    _isAnimating = FALSE;
    _isReadyForDrawing = FALSE;
    [self use3_2Profile];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0f/60.0f target:self selector:@selector(animationTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
}

-(void)use3_2Profile
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        //NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 24,
        // Must specify the 3.2 Core Profile to use OpenGL 3.2
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,
        0
    };
    //this is a change
    
    NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    
    if (!pf)
    {
        NSLog(@"No OpenGL pixel format");
    }
    
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:nil];
    
    CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
    
    //[self setPixelFormat:pf];
    
    [self setOpenGLContext:context];
    [[self openGLContext] makeCurrentContext];
    //[context setView:self];

}

@end
