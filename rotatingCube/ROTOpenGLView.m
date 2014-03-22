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
#define RESTART_CHAR 0xFFFFFFFF

const GLuint NumVertices = 6;

GLfloat vertices[8][3] = {
                            {.5,.5,.5},
                            {.5,.5,-.5},
                            {.5,-.5,.5},
                            {.5,-.5,-.5},
                            {-.5,.5,.5},
                            {-.5,.5,-.5},
                            {-.5,-.5,.5},
                            {-.5,-.5,-.5}
};
GLfloat colors[8][4] = {
                            {1,1,1,1.},
                            {1,1,0,1.},
                            {1,0,1,1.},
                            {1,0,0,1.},
                            {0,1,1,1.},
                            {0,1,0,1.},
                            {0,0,1,1.},
                            {0,0,0,1.},
};

GLuint indices[20] = {0,1,2,3,6,7,4,5,0,1,RESTART_CHAR,0,2,4,6,RESTART_CHAR,1,5,3,7};

GLfloat rotation = 0.0f;

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
        [[self openGLContext] setView:self];
    }
    if((_framesElapsed & 0x8) == 8)
        rotation += ((arc4random()/2147483648.) - .75f)/100.;
    
    GLfloat matrix[4][4] = {
                {cos(rotation),                             0,                          -sin(rotation),                         0.},
                {-sin(rotation)*sin(_framesElapsed/50.),    cos(_framesElapsed/50.),    -sin(_framesElapsed/50.)*cos(rotation), 0.},
                {sin(rotation)*cos(_framesElapsed/50.),     sin(_framesElapsed/50.),    cos(_framesElapsed/50.)*cos(rotation),  0.},
                {0.,                                        0.,                         0.,                                     1.}
    };
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(matrix), matrix, GL_DYNAMIC_DRAW);
    
    glVertexAttrib4fv(2, matrix[0]);
    glVertexAttrib4fv(3, matrix[1]);
    glVertexAttrib4fv(4, matrix[2]);
    glVertexAttrib4fv(5, matrix[3]);
    
    glBindVertexArray(VAOs[0]);
    
    glDrawElements(GL_TRIANGLE_STRIP, 20, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
    
    [[self openGLContext] flushBuffer];
}

- (void)prepareOpenGL
{
    sh = [[Shader alloc] initWithShadersInAppBundle:@"Shader"]; //create shader OBJ-C class, shader OpenGL object, compile, and link object to shader program
    programObject = [sh program]; //set programObject variable to shader program (not active in OpenGL yet)
    
    
    glGenVertexArrays(1, VAOs); //Frees 1 vertex array label and stores it in VAOs[0]
    glBindVertexArray(VAOs[0]); //Makes first element of VAOs the active vertex array object

    glGenBuffers(3, Buffers); //Frees 1 buffer label and stores it in Buffers[0]
    
    glBindBuffer(GL_ARRAY_BUFFER, Buffers[0]); //Binds the first element of Buffers to the GL_ARRAY_BUFFER target
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices) + sizeof(colors),vertices, GL_STATIC_DRAW); //loads vertices into the buffer currently bound to the GL_ARRAY_BUFFER target, which is the first element of Buffers
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(vertices), sizeof(colors), colors);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, Buffers[1]);
    
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(sizeof(vertices)));
    glEnableVertexAttribArray(1);
    
    
    glUseProgram(programObject); //activates the shader program
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f); //sets clear color
    glClearDepth(0.0f);
    
    glEnable(GL_PRIMITIVE_RESTART);
    glPrimitiveRestartIndex(RESTART_CHAR);
    
    _isAnimating = TRUE; //preparations complete!
    _isReadyForDrawing = TRUE;
    
    glEnable(GL_CULL_FACE);
    //glCullFace(GL_BACK);
    
    glDepthMask(GL_TRUE);
    
    //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    
    
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
        NSOpenGLPFADoubleBuffer,
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
