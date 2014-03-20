//---------------------------------------------------------------------------------
//
//	File: Shader.m
//
//  Abstract: Rudimentary class to instantiate a shader object
//            NOTE: This class does not validate the program object
// 			 
//
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------

#import "Shader.h"

//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------

#pragma mark -- Compiling shaders & linking a program object --

//---------------------------------------------------------------------------------

static GLuint LoadShader(GLenum theShaderType,
							  const GLcharARB **theShader,
							  GLint *theShaderCompiled) 
{
	GLuint shaderObject = 0;
	
	if( theShader != NULL ) 
	{
		GLint infoLogLength = 0;
		
		shaderObject = glCreateShader(theShaderType);
		
		glShaderSource(shaderObject, 1, theShader, NULL);
		glCompileShader(shaderObject);
		
		glGetShaderiv(shaderObject,GL_OBJECT_INFO_LOG_LENGTH_ARB,&infoLogLength);
		
		if( infoLogLength > 0 ) 
		{
			GLcharARB *infoLog = (GLcharARB *)malloc(infoLogLength);
			
			if( infoLog != NULL )
			{
				glGetShaderInfoLog(shaderObject,
								infoLogLength, 
								&infoLogLength, 
								infoLog);
				
				NSLog(@">> Shader compile log:\n%s\n", infoLog);
				
				free(infoLog);
			} // if
		} // if
		
		glGetShaderiv(shaderObject,GL_OBJECT_COMPILE_STATUS_ARB,theShaderCompiled);
		
		if( *theShaderCompiled == 0 )
		{
			NSLog(@">> Failed to compile shader %s\n", *theShader);
		} // if
	} // if
	else 
	{
		*theShaderCompiled = 1;
	} // else
	
	return shaderObject;
} // LoadShader

//---------------------------------------------------------------------------------

static void LinkProgram(GLuint program,
						GLint *theProgramLinked) 
{
	GLint  infoLogLength = 0;
	
	glLinkProgram(program);
	
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLogLength);
	
	if( infoLogLength >  0 ) 
	{
		GLcharARB *infoLog = (GLcharARB *)malloc(infoLogLength);
		
		if( infoLog != NULL)
		{
			glGetProgramInfoLog(program,
							infoLogLength, 
							&infoLogLength, 
							infoLog);
			
			NSLog(@">> Program link log:\n%s\n", infoLog);
			
			free(infoLog);
		} // if
	} // if
	
	glGetProgramiv(program, GL_LINK_STATUS, theProgramLinked);
	
	if( *theProgramLinked == 0 )
	{
		NSLog(@">> Failed to link program 0x%u\n", (GLuint)&program);
	} // if
} // LinkProgram

//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------

@implementation Shader

//---------------------------------------------------------------------------------

#pragma mark -- Get shaders from resource --

//---------------------------------------------------------------------------------

- (GLcharARB *) getShaderSourceFromResource:(NSString *)theShaderResourceName 
								  extension:(NSString *)theExtension
{
	NSBundle  *appBundle = [NSBundle mainBundle];
    
    //NSLog(@"%@", [appBundle pathForResource:theShaderResourceName ofType:theExtension]);
    
	NSString  *shaderTempSource = [appBundle pathForResource:theShaderResourceName 
													  ofType:theExtension];
	GLcharARB *shaderSource = NULL;
	
	shaderTempSource = [NSString stringWithContentsOfFile:shaderTempSource encoding:NSASCIIStringEncoding error:NULL];
	shaderSource     = (GLcharARB *)[shaderTempSource cStringUsingEncoding:NSASCIIStringEncoding];
	
	return  shaderSource;
} // getShaderSourceFromResource

//---------------------------------------------------------------------------------

- (void) getFragmentShaderSourceFromResource:(NSString *)theFragmentShaderResourceName
{
	fragmentShaderSource = [self getShaderSourceFromResource:theFragmentShaderResourceName 
												   extension:@"fs" ];
} // getFragmentShaderSourceFromResource

//---------------------------------------------------------------------------------

- (void) getVertexShaderSourceFromResource:(NSString *)theVertexShaderResourceName
{
	vertexShaderSource = [self getShaderSourceFromResource:theVertexShaderResourceName 
												 extension:@"vs" ];
} // getVertexShaderSourceFromResource

//---------------------------------------------------------------------------------

- (GLuint) loadShader:(GLenum)theShaderType
			  shaderSource:(const GLcharARB **)theShaderSource
{
	GLint       shaderCompiled = 0;
	GLuint shaderHandle   = LoadShader(theShaderType,
											theShaderSource, 
											&shaderCompiled);
	
	if( !shaderCompiled ) 
	{
		if( shaderHandle ) 
		{
			glDeleteShader(shaderHandle);
			shaderHandle = 0;
		} // if
	} // if
	
	return shaderHandle;
} // loadShader

//---------------------------------------------------------------------------------

- (BOOL) newProgramObject:(GLuint)theVertexShader
	 fragmentShaderHandle:(GLuint)theFragmentShader
{
	GLint programLinked = 0;
	
	// Create a program object and link both shaders
	
	program = glCreateProgram();
	
	glAttachShader(program, theVertexShader);
	//glDeleteShader(theVertexShader);   // Release
	
	glAttachShader(program, theFragmentShader);
	//glDeleteShader(theFragmentShader); // Release
    
	LinkProgram(program, &programLinked);
    
	if( !programLinked ) 
	{
		glDeleteShader(program);
		
		program = 0;
		
		return NO;
	} // if
	
	return YES;
} // newProgramObject

//---------------------------------------------------------------------------------

- (BOOL) setProgramObject
{
	BOOL  programObjectSet = NO;
	
	// Load and compile both shaders
	
	GLuint vertexShader = [self loadShader:GL_VERTEX_SHADER_ARB
								   shaderSource:&vertexShaderSource];
	
	// Ensure vertex shader compiled
	
	if( vertexShader != 0 )
	{
		GLuint fragmentShader = [self loadShader:GL_FRAGMENT_SHADER_ARB
										 shaderSource:&fragmentShaderSource];
		
		// Ensure fragment shader compiled
		
		if( fragmentShader != 0 )
		{
			// Create a program object and link both shaders
			
			programObjectSet = [self newProgramObject:vertexShader 
								 fragmentShaderHandle:fragmentShader];
		} // if
	} // if
	
	return  programObjectSet;
} // setProgramObject

//---------------------------------------------------------------------------------

#pragma mark -- Designated Initializer --

//---------------------------------------------------------------------------------

- (id) initWithShadersInAppBundle:(NSString *)theShadersName
{
	self = [super init];
	
	if( self)
	{
		BOOL  loadedShaders = NO;
		
		// Load vertex and fragment shader
		
		[self getVertexShaderSourceFromResource:theShadersName];
		
		if( vertexShaderSource != NULL )
		{
			[self getFragmentShaderSourceFromResource:theShadersName];
			
			if( fragmentShaderSource != NULL )
			{
                //NSLog(@"%s",vertexShaderSource);
                //NSLog(@"%s",fragmentShaderSource);
				loadedShaders = [self setProgramObject];
				
				if( !loadedShaders)
				{
					NSLog(@">> WARNING: Failed to load GLSL \"%@\" fragment & vertex shaders!\n", 
						  theShadersName);
				} // if
			} // if
		} // if
	} // if
	
	return self;
} // initWithShadersInAppBundle

//---------------------------------------------------------------------------------

#pragma mark -- Deallocating Resources --

//---------------------------------------------------------------------------------

//- (void) dealloc
//{
//	// Delete OpenGL resources
//	
//	if( programObject )
//	{
//		glDeleteObjectARB(programObject);
//		
//		programObject = NULL;
//	} // if
//	
//	//Dealloc the superclass
//	
//	[super dealloc];
//} // dealloc

//---------------------------------------------------------------------------------

#pragma mark -- Accessors --

//---------------------------------------------------------------------------------

- (GLuint) program
{
	return  program;
} // programObject

//---------------------------------------------------------------------------------

#pragma mark -- Utilities --

//---------------------------------------------------------------------------------

- (GLint) getUniformLocation:(const GLcharARB *)theUniformName
{
	GLint uniformLoacation = glGetUniformLocation(program,theUniformName);
	
	if( uniformLoacation == -1 ) 
	{
		NSLog( @">> WARNING: No such uniform named \"%s\"\n", theUniformName );
	} // if
	
	return uniformLoacation;
} // getUniformLocation

//---------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------

