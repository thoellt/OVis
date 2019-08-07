//
//	OVRegularSurfaceRenderer.mm
//

// System Headers

// Custom Headers
#import "gl_general.h"
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"

// Local Headers
#import "OVRegularSurfaceRenderer.h"
#import "OVRegularSurfaceRenderer+Buffers.h"
#import "OVRegularSurfaceRenderer+Shaders.h"

@implementation OVRegularSurfaceRenderer

- (id) init
{
    return [self initWithViewId:ViewId3D];
}

- (id) initWithViewId:(OVViewId) viewId
{
	self = [super initWithViewId:viewId];
	
	if( self ){
		
		_includeLIC = YES;
        
//        _pathlineVertexBuffer = 0;
//        _pathlineColorBuffer = 0;
		
		[self loadShaderPrograms];
		[self rebuild];
	}
	
	return self;
}

- (void) rebuild
{
	[super rebuild];
	
	[self createBuffers];
	
	[self refreshData];
    
    if( _viewId == ViewId2D )
    {
        _offScreenNeedsRefresh = YES;
        [self setupMatrix];
        [self drawOffScreen];
    }
}

- (void) refreshData
{
	[super refreshData];
	
	[self refreshTextureBuffers];
}

- (void) setupMatrix
{
    if( _viewId == ViewId3D ){
        
        [super setupMatrix];
    
    } else {
        
        _mvp = GLKMatrix4MakeOrtho(0.0, 1.0, 0.0, 1.0, 0.0, 10000);
    }
}

- (OVGLSLProgram *) setupAndEnableShaderProgram
{
	OVGLSLProgram *shaderProgram = _glslProgramRegularSurfaceRenderer;
	
	[shaderProgram compileAndLink];
	
	GLuint modelViewProjectionMatrixUniform = [shaderProgram getUniformLocation:"modelViewProjectionMatrix"];
	GLuint parametersUniform = [shaderProgram getUniformLocation:"colorParams"];
	GLuint noiseParametersUniform = [shaderProgram getUniformLocation:"noiseParams"];
	GLuint heightmapSampler = [shaderProgram getSamplerLocation:"heightmap"];
	GLuint statisticSampler = [shaderProgram getSamplerLocation:"statistic"];
	GLuint secondaryStatisticSampler = [shaderProgram getSamplerLocation:"secondaryStatistic"];
	GLuint colormapSampler = [shaderProgram getSamplerLocation:"colormap"];
	GLuint pathlineColormapSampler = [shaderProgram getSamplerLocation:"pathlineColormap"];
	GLuint noiseSampler = [shaderProgram getSamplerLocation:"noisemap"];
	GLuint vectorSampler = [shaderProgram getSamplerLocation:"vectormap"];
	GLuint pathlineSampler = [shaderProgram getSamplerLocation:"pathlines"];
	GLuint surfaceParametersUniform = [shaderProgram getUniformLocation:"surfaceParams"];
	GLuint pathlineParametersUniform = [shaderProgram getUniformLocation:"pathlineParams"];
	
	[shaderProgram bindAndEnable];
	GetGLError();
	
	[shaderProgram setParameter4x4fv:modelViewProjectionMatrixUniform M:_mvp.m];
	GetGLError();
	
	[shaderProgram setParameter1i:heightmapSampler X:0];
	GetGLError();
	glActiveTexture(GL_TEXTURE0);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _surfaceTexture);
	GetGLError();
	
	[shaderProgram setParameter1i:statisticSampler X:1];
	GetGLError();
	glActiveTexture(GL_TEXTURE1);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _statisticTexture[0]);
	GetGLError();
	
	[shaderProgram setParameter1i:secondaryStatisticSampler X:2];
	GetGLError();
	glActiveTexture(GL_TEXTURE2);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _statisticTexture[1]);
	GetGLError();
	
	[shaderProgram setParameter1i:colormapSampler X:3];
	GetGLError();
	glActiveTexture(GL_TEXTURE3);
	GetGLError();
	glBindTexture(GL_TEXTURE_1D, _colormapTexture[0]);
	GetGLError();
	
	[shaderProgram setParameter1i:pathlineColormapSampler X:4];
	GetGLError();
	glActiveTexture(GL_TEXTURE4);
	GetGLError();
	glBindTexture(GL_TEXTURE_1D, _colormapTexture[1]);
	GetGLError();
	
	[shaderProgram setParameter1i:noiseSampler X:5];
	GetGLError();
	glActiveTexture(GL_TEXTURE5);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _noiseTexture);
	GetGLError();
	
	[shaderProgram setParameter1i:vectorSampler X:6];
	GetGLError();
	glActiveTexture(GL_TEXTURE6);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _vectorTexture);
	GetGLError();
	
	[shaderProgram setParameter1i:pathlineSampler X:7];
	GetGLError();
	glActiveTexture(GL_TEXTURE7);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, [[_appDelegate ensembleData] pathlineTexture]);
	GetGLError();
	
	float colMapDiscrete = [_viewSettings isColormapDiscreteForView:_viewId] ? 1.0f : -1.0f;
    OVEnsembleProperty activeProperty = _offScreenNeedsRefresh ? EnsemblePropertyNone : [_viewSettings activeProperty3D];
    if( _viewId == ViewId2D ) activeProperty = [_viewSettings activeProperty2D];
	float params[4] = {[[_viewSettings activeColormapForView:_viewId] size]/ 11.0f,
		static_cast<float>([_viewSettings activeColormapIndexForView:_viewId]),
		colMapDiscrete,
		static_cast<float>(activeProperty)
	};
	[shaderProgram setParameter4fv:parametersUniform V:params];
	GetGLError();
    
    [shaderProgram setParameter4f:noiseParametersUniform
                                X:_viewId == ViewId2D ? [_viewSettings activeNoiseProperty2D] : [_viewSettings activeNoiseProperty3D]
                                Y:1.0
                                Z:1.0
                                W:1.0];
	GetGLError();
	
	EnsembleDimension *dim = [[_appDelegate ensembleData] ensembleDimension];
	[shaderProgram setParameter4f:surfaceParametersUniform X:1.0/dim->x Y:1.0/dim->y Z:1.0/dim->z W:_viewId == ViewId2D ? 1.0f : 0.0f];
	GetGLError();
    
    float enablePathlines = ( !_offScreenNeedsRefresh && [_viewSettings isPathlineTracingEnabled] && [_viewSettings isPathlineTraceAvailable] ) ? 1.0f : -1.0f;
    float pathlineScale = (float) [_viewSettings pathlineScale];
    float alphaScale = (float) [_viewSettings pathlineAlpha];
    
    float colormapScale = 0.0f;
    if( [_viewSettings activeColormapForPathline] )
    {
        colormapScale = [[_viewSettings activeColormapForPathline] size] / 11.0f;
    }
    
    [shaderProgram setParameter4f:pathlineParametersUniform X:enablePathlines Y:pathlineScale Z:alphaScale W:colormapScale];
    GetGLError();

	return shaderProgram;
}

- (void) draw
{
   [self setupMatrix];
    
   [self drawOffScreen];
    
   [self drawOnScreen];
	
//	if( [[_appDelegate ensembleData] isVectorFieldAvailable] ) [self drawPathlines];
}

- (void) drawOnScreen
{
    if( _viewId == ViewId3D )
    {
        glViewport(0, 0, _viewWidth, _viewHeight);
        
        float *clearColor = [[_appDelegate viewSettings] threeDViewBackgroundColor];
	
        glClearColor(clearColor[0], clearColor[1], clearColor[2], 1.0);
        GetGLError();
    }
    else{
        
        glClearColor(0.0, 0.0, 0.0, 0.0);
        GetGLError();
    }
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	GetGLError();
	
	glEnable(GL_DEPTH_TEST);
	GetGLError();
	
	OVGLSLProgram *shaderProgram = [self setupAndEnableShaderProgram];
	
	[super drawWithShaderProgram: shaderProgram];
    
    [super drawLegend];
}

- (void) drawOffScreen
{
    if( _viewId != ViewId3D || !_offScreenNeedsRefresh ) return;
    
    OVGLSLProgram *shaderProgram = [self setupAndEnableShaderProgram];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    GetGLError();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GetGLError();
	
	glEnable(GL_DEPTH_TEST);
	GetGLError();
    
    [super drawWithShaderProgram: shaderProgram];
    
    assert( _viewWidth <= _bufferWidth && _viewHeight <= _bufferHeight );

    if( _cpuBuffer ) delete[] _cpuBuffer;
    _cpuBuffer = new unsigned char [_viewWidth * _viewHeight * 4];
    glReadPixels(0, 0, _viewWidth, _viewHeight, GL_RGBA, GL_UNSIGNED_BYTE, _cpuBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    _offScreenNeedsRefresh = NO;
}
/*
- (void) drawPathlines
{
    if( !_pathlineVertexBuffer || !_pathlineColorBuffer ) return;
    
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	OVGLSLProgram *shaderProgram = _glslProgramBasicGLColorBuffer;
	[shaderProgram compileAndLink];
	
	GLuint positionAttribute = [shaderProgram getAttributeLocation:"position"];
	GLuint modelViewProjectionMatrixUniform = [shaderProgram getUniformLocation:"modelViewProjectionMatrix"];
	GLuint colorAttribute = [shaderProgram getAttributeLocation:"color"];
	
	[shaderProgram bindAndEnable];
	GetGLError();
	
	[shaderProgram setParameter4x4fv:modelViewProjectionMatrixUniform M:_mvp.m];
	GetGLError();
	
	//[shaderProgram setParameter4f:colorUniform X:1.0 Y:0.0 Z:0.0 W:0.25];
	//GetGLError();
	
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glEnableVertexAttribArray(positionAttribute);
	GetGLError();
	
	// UI
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
*/
- (void) dealloc
{
	[self releaseShaderPrograms];
	[self releaseBuffers];
}

@end
