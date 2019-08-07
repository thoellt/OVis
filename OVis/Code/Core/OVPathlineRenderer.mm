//
//	OVPathlineRenderer.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <GLKit/GLKit.h>
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <OpenGL/OpenGL.h>

// Custom Headers
#import "gl_general.h"
#import "OVAppDelegate.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"

// Local Header
#import "OVPathlineRenderer.h"
#import "OVPathlineRenderer+Buffers.h"
#import "OVPathlineRenderer+Shaders.h"

@implementation OVPathlineRenderer

- (id) init
{
	self = [super init];
	
	if( self ){
		
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
		
		_viewSettings = nil;
		if( _appDelegate ){
			_viewSettings = _appDelegate.viewSettings;
		}
		
		// Shaders
		_shadersLoaded = NO;
		_glslProgramPathlineRenderer = nil;
		
		// Buffers
        _vertexArrayObject = 0;
		_pathlineVertexBuffer = 0;
        _pathlineColorBuffer = 0;
        _fullScreenQuadVertexBuffer = 0;
		
		[self loadShaderPrograms];
		[self rebuild];
	}
	return self;
}

- (void) setupMatrix
{
    _mvp = GLKMatrix4MakeOrtho(0.0, 1.0, 0.0, 1.0, 0.0, 10000);
}

- (void) draw
{
    if( !_pathlineVertexBuffer || !_pathlineColorBuffer ) return;
    
    [self setupMatrix];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    GetGLError();

    glClear(GL_COLOR_BUFFER_BIT);
    GetGLError();
    
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	OVGLSLProgram *shaderProgram = _glslProgramPathlineRenderer;
	[shaderProgram compileAndLink];
	
	GLuint positionAttribute = [shaderProgram getAttributeLocation:"position"];
	GLuint modelViewProjectionMatrixUniform = [shaderProgram getUniformLocation:"modelViewProjectionMatrix"];
	GLuint colorAttribute = [shaderProgram getAttributeLocation:"color"];
	
	[shaderProgram bindAndEnable];
	GetGLError();
	
	[shaderProgram setParameter4x4fv:modelViewProjectionMatrixUniform M:_mvp.m];
	GetGLError();
	
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glEnableVertexAttribArray(positionAttribute);
	GetGLError();
	
	glBindBuffer(GL_ARRAY_BUFFER, _pathlineVertexBuffer);
	GetGLError();
    
    int bufferValid = 0;
    glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferValid);
	GetGLError();
    if(bufferValid)
    {
        glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, 0, 0);
        GetGLError();
        
        glEnableVertexAttribArray(colorAttribute);
        GetGLError();
        glBindBuffer(GL_ARRAY_BUFFER, _pathlineColorBuffer);
        GetGLError();
        glVertexAttribPointer(colorAttribute, 4, GL_FLOAT, GL_FALSE, 0, 0);
        GetGLError();
        
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        GetGLError();
        
        size_t segments = [_appDelegate.ensembleData numberOfPathlineSegments];
        
        glDrawArrays(GL_LINES, 0, (GLint)segments*3);
        //glDrawArrays(GL_TRIANGLES, 0, (GLint)12);
        GetGLError();
    }
    
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
    
	glDisableVertexAttribArray(positionAttribute);
	GetGLError();
    
    glDisableVertexAttribArray(colorAttribute);
    GetGLError();
	
	glBindVertexArray(0);
	GetGLError();
	
	[shaderProgram disable];
    
    glDisable(GL_BLEND);
}

- (void) filterTexture: (GLuint) texture withWidth: (int)width Height: (int)height
{
    if( !_fullScreenQuadVertexBuffer ) return;
    
    [self setupMatrix];
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    GetGLError();
    
    glClear(GL_COLOR_BUFFER_BIT);
    GetGLError();
    
	OVGLSLProgram *shaderProgram = _glslProgramPathlineRendererFilter;
	[shaderProgram compileAndLink];
	
	GLuint positionAttribute = [shaderProgram getAttributeLocation:"position"];
    
	GLuint modelViewProjectionMatrixUniform = [shaderProgram getUniformLocation:"modelViewProjectionMatrix"];
	GLuint pathlineSampler = [shaderProgram getUniformLocation:"pathlineTexture"];
	GLuint parametersUniform = [shaderProgram getUniformLocation:"textureParameters"];
	
	[shaderProgram bindAndEnable];
	GetGLError();
	
	[shaderProgram setParameter4x4fv:modelViewProjectionMatrixUniform M:_mvp.m];
	GetGLError();
	
	[shaderProgram setParameter4f:parametersUniform X:1.0/width Y:1.0/height Z:width W:height];
	GetGLError();
    
    [shaderProgram setParameter1i:pathlineSampler X:0];
	GetGLError();
	glActiveTexture(GL_TEXTURE0);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, texture);
	GetGLError();
	
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glEnableVertexAttribArray(positionAttribute);
	GetGLError();
	
	glBindBuffer(GL_ARRAY_BUFFER, _fullScreenQuadVertexBuffer);
	GetGLError();
    
    int bufferValid = 0;
    glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferValid);
	GetGLError();
    if(bufferValid)
    {
        glVertexAttribPointer(positionAttribute, 3, GL_FLOAT, GL_FALSE, 0, 0);
        GetGLError();
        
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        GetGLError();
        
        glDrawArrays(GL_TRIANGLES, 0, (GLint)6);
        GetGLError();
    }
    
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
    
	glDisableVertexAttribArray(positionAttribute);
	GetGLError();
	
	glBindVertexArray(0);
	GetGLError();
	
	[shaderProgram disable];
}

- (void) rebuild
{
	[self createBuffers];

	[self refreshData];
}

- (void) refreshData
{
	[self refreshBuffers];
}

@end
