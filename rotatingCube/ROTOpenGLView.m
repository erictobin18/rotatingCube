//
//  FunOpenGLView.m
//  openGLFun
//
//  Created by Eric Tobin on 1/14/14.
//  Copyright (c) 2014 omnisciendus. All rights reserved.
//

#import "ROTOpenGLView.h"
#import <OpenGL/glext.h>

#define BUFFER_OFFSET(offset) ((void *)(offset))


enum VAO_IDs { Triangles, NumVAOs };
enum Buffer_IDs { ArrayBuffer, NumBuffers };
enum Attrib_IDs {vPosition = 0};

GLuint  VAOs[NumVAOs];
GLuint  Buffers[NumBuffers];
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
    
    glBindVertexArray(VAOs[Triangles]);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    /*
     
     L_POINTS, GL_LINES, GL_LINE_STRIP, GL_LINE_LOOP, GL_TRIANGLES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, and GL_PATCHES.
     */
    glFlush();
}

- (void)prepareOpenGL
{
    sh = [[Shader alloc] initWithShadersInAppBundle:@"Shader"];
    programObject = [sh program];
    
    
    glGenVertexArrays(NumVAOs, VAOs);
    glBindVertexArray(VAOs[Triangles]);
    GLfloat  vertices[NumVertices][2] = {
        { -0.90, -0.90 },  // Triangle 1
        {  0.85, -0.90 },
        { -0.90,  0.85 },
        {  0.90, -0.85 },  // Triangle 2
        {  0.90,  0.90 },
        { -0.85,  0.90 }
    };
    glGenBuffers(NumBuffers, Buffers);
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[ArrayBuffer]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices),vertices, GL_STATIC_DRAW);
    
    
    
    glUseProgram(programObject);
    
    
    glVertexAttribPointer(vPosition, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(vPosition);
    

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    
    _isAnimating = TRUE;
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
