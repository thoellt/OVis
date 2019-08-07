//
//	OVTimeSeriesRenderer.mm
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
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"


// Local Header
#import "OVTimeSeriesRenderer.h"
#import "OVTimeSeriesRenderer+Buffers.h"
#import "OVTimeSeriesRenderer+Shaders.h"

@implementation OVTimeSeriesRenderer

- (id) init
{
	self = [super init];
	
	if( self ){
		
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
		
		_viewSettings = nil;
		if( _appDelegate ){
			_viewSettings = _appDelegate.viewSettings;
		}
		
		_viewWidth	= 100;
		_viewHeight	= 100;
		_viewAspect	= 1.0f;
		
		// Shaders
		_shadersLoaded = NO;
		_glslProgramBasicGL = nil;
		
		// Buffers
		_vertexArrayObject = 0;
		_glyphVertexBuffer = 0;
        _boxplotVertexBuffer = 0;
		_linesVertexBuffer = 0;
		
		_riskColors = nil;		
		
		[self loadShaderPrograms];
		[self rebuild];
	}
	return self;
}

- (void) draw
{
	glViewport(0, 0, _viewWidth, _viewHeight);
    
	float *clearColor = _viewSettings.tSViewBackgroundColor;
	
   glClearColor(clearColor[0], clearColor[1], clearColor[2], 1.0);
	GetGLError();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GetGLError();
    
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-0.0001, 1.0001, -0.0001, 1.0001, 0.0, 10000);
	
	OVGLSLProgram *shaderProgram = _glslProgramBasicGL;
	[shaderProgram compileAndLink];
	
	GLuint positionAttribute = [shaderProgram getAttributeLocation:"position"];
	GLuint modelViewProjectionMatrixUniform = [shaderProgram getUniformLocation:"modelViewProjectionMatrix"];
	GLuint colorUniform = [shaderProgram getUniformLocation:"color"];
	
	[shaderProgram bindAndEnable];
	GetGLError();
	
	[shaderProgram setParameter4x4fv:modelViewProjectionMatrixUniform M:projectionMatrix.m];
	GetGLError();
	
	[shaderProgram setParameter4f:colorUniform X:1.0 Y:0.0 Z:0.0 W:1.0];
	GetGLError();
	
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glEnableVertexAttribArray(positionAttribute);
	GetGLError();
	
	int bufferValid = 0;
	
	// UI
	glBindBuffer(GL_ARRAY_BUFFER, _linesVertexBuffer);
	GetGLError();
	glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, 0);
	GetGLError();
	
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    GetGLError();

	//glLineWidth(1.0f);
	//GetGLError();
	
	//OVColormap *colormap = [_viewSettings colormapAtIndex:[_viewSettings numColormaps] - 1];
    int timeSteps = (int)[_appDelegate.ensembleData numTimeStepsWithStride];//_appDelegate.ensembleData.timeRangeMax - _appDelegate.ensembleData.timeRangeMin + 1;
    // (int)(_appDelegate.ensembleData.ensembleDimension->t);
	for( int t = 0; t < timeSteps; t++ ){
		
		//RGB col = [colormap colorAtNormalizedIndex:(t+0.5)/(float)timeSteps discrete:NO];
        
        //[shaderProgram setParameter4f:colorUniform X:col.r/255.0f Y:col.g/255.0f Z:col.b/255.0f W:1.0];
        [shaderProgram setParameter4f:colorUniform X:0.8f Y:0.8f Z:0.8f W:1.0f];
		GetGLError();
		glDrawArrays(GL_LINES, t*2, 2);
		GetGLError();
	}
	
	int offset = timeSteps * 2;
	
	[shaderProgram setParameter4f:colorUniform X:0.85 Y:0.85 Z:0.85 W:1.0];
	GetGLError();
	glDrawArrays(GL_LINES, offset, 10);
	GetGLError();
	
	offset += 10;
	/*
	[shaderProgram setParameter4f:colorUniform X:0.25 Y:0.25 Z:0.25 W:1.0];
	GetGLError();
	glDrawArrays(GL_LINES, offset, 2);
    GetGLError();
    */
    
    // Boxplot
    glBindBuffer(GL_ARRAY_BUFFER, _boxplotVertexBuffer);
    GetGLError();
    
    glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferValid);
    if(bufferValid){
        
        glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, 0);
        GetGLError();
        
        [shaderProgram setParameter4f:colorUniform X:0.5f Y:0.5f Z:0.8f W:0.15f];
        GetGLError();
        
        glDrawArrays(GL_TRIANGLE_STRIP, timeSteps*3, timeSteps*2);
        GetGLError();
        
        [shaderProgram setParameter4f:colorUniform X:0.3f Y:0.7f Z:1.0f W:0.15f];
        GetGLError();
        
        glDrawArrays(GL_TRIANGLE_STRIP, timeSteps*8, timeSteps*2);
        GetGLError();
        
        [shaderProgram setParameter4f:colorUniform X:0.25f Y:0.25f Z:0.4f W:1.0f];
        GetGLError();
        
        glDrawArrays(GL_LINE_STRIP, timeSteps, timeSteps);
        GetGLError();
        
        glDrawArrays(GL_LINE_STRIP, timeSteps*2, timeSteps);
        GetGLError();
        
        [shaderProgram setParameter4f:colorUniform X:0.15f Y:0.55f Z:0.8f W:1.0f];
        GetGLError();
        
        glDrawArrays(GL_LINE_STRIP, timeSteps*6, timeSteps);
        GetGLError();
        
        glDrawArrays(GL_LINE_STRIP, timeSteps*7, timeSteps);
        
        [shaderProgram setParameter4f:colorUniform X:0.75f Y:0.1f Z:0.1f W:1.0f];
        GetGLError();
        
        glDrawArrays(GL_LINE_STRIP, 0, timeSteps);
        GetGLError();
        
        glDrawArrays(GL_LINE_STRIP, timeSteps*5, timeSteps);
        GetGLError();
    }
		
	
	// Glyphs
	int bins = _appDelegate.ensembleData.histogramBins;
	
	glBindBuffer(GL_ARRAY_BUFFER, _glyphVertexBuffer);
	GetGLError();
	
	glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferValid);
	if(bufferValid){

		glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, 0);
		GetGLError();
	
		//glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	
		for( int t = 0; t < timeSteps * 2; t++ ){
		
         if( /* DISABLES CODE */ (false) )
            {
                RGB color = _riskColors[t];
                [shaderProgram setParameter4f:colorUniform X:color.r/255.0f Y:color.g/255.0f Z:color.b/255.0f W:0.85f];
                GetGLError();
            }
            else
            {
                if( t == 0 )
                {
                   if([_viewSettings isDark])
                   {
                      [shaderProgram setParameter4f:colorUniform X:0.9f Y:0.1f Z:0.9f W:0.85f];
                   }
                   else
                   {
                      [shaderProgram setParameter4f:colorUniform X:0.25f Y:0.25f Z:0.4f W:0.85f];
                   }
                    GetGLError();
                }
                else if ( t == timeSteps )
                {
                    [shaderProgram setParameter4f:colorUniform X:0.15f Y:0.55f Z:0.8f W:0.85f];
                    GetGLError();
                }
            }
		
			glDrawArrays(GL_TRIANGLE_STRIP, t*bins*2, bins * 2);
            GetGLError();
        }
    }
    
	
	// Top UI
	glBindBuffer(GL_ARRAY_BUFFER, _linesVertexBuffer);
	GetGLError();
	
	glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferValid);
	if(bufferValid)
	{
		glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, 0);
		GetGLError();
	
		offset += 2;
	
		[shaderProgram setParameter4f:colorUniform X:0.75 Y:0.1 Z:0.1 W:1.0];
		GetGLError();
		glDrawArrays(GL_LINES, offset, 2);
		GetGLError();
	}
	
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    GetGLError();

	glBindBuffer(GL_ARRAY_BUFFER, 0);
    GetGLError();

	glDisableVertexAttribArray(positionAttribute);
    GetGLError();

	glBindVertexArray(0);
    GetGLError();

	[shaderProgram disable];
	GetGLError();
}

- (void) rebuild
{
	[self createBuffers];

	[self refreshData:YES];
}

- (void) refreshData:(BOOL) includeGUI
{
	[self refreshVertexBuffers:includeGUI];
}

- (void) resizeWithWidth:(GLuint)width height:(GLuint)height
{
	_viewWidth = width;
	_viewHeight = height;
	
	_viewAspect = fabsf((float)width / (float)height);
}

@end
