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

GLfloat vertices[8][3] = {{1,1,1},{1,1,-1},{1,-1,1},{1,-1,-1},{-1,1,1},{-1,1,-1},{-1,-1,1},{-1,-1,-1}};
GLuint indices[24] = {0,1,2,3,2,3,6,7,6,7,4,5,4,5,0,1,0,2,6,4,1,3,7,5};

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
    
    glBindVertexArray(VAOs[0]);
    
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(16));
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(32));
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(48));
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(64));
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(80));
    
    
    //glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
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

    glGenBuffers(2, Buffers); //Frees 1 buffer label and stores it in Buffers[0]
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[0]); //Binds the first element of Buffers to the GL_ARRAY_BUFFER target
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices),vertices, GL_STATIC_DRAW); //loads vertices into the buffer currently bound to the GL_ARRAY_BUFFER target, which is the first element of Buffers
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, Buffers[1]);
    
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(0);
    
    
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
