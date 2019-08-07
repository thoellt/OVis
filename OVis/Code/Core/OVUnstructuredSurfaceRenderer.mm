//
//	OVUnstructuredSurfaceRenderer.mm
//

// Custom Headers
#import "gl_general.h"
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"

// Local Headers
#import "OVUnstructuredSurfaceRenderer.h"
#import "OVUnstructuredSurfaceRenderer+Buffers.h"
#import "OVUnstructuredSurfaceRenderer+Shaders.h"

@implementation OVUnstructuredSurfaceRenderer


- (id) init
{
    return [self initWithViewId:ViewId3D];
}

- (id) initWithViewId:(OVViewId) viewId
{
	self = [super initWithViewId:viewId];
	
	if( self ){
		
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
	OVGLSLProgram *shaderProgram = glslProgramUnstructuredSurfaceRenderer;

	[shaderProgram compileAndLink];
	
	GLuint modelViewProjectionMatrixUniform = [shaderProgram getUniformLocation:"modelViewProjectionMatrix"];
	GLuint heightmapSampler = [shaderProgram getSamplerLocation:"heightmap"];
	GLuint statisticSampler = [shaderProgram getSamplerLocation:"statistic" ];
	GLuint secondaryStatisticSampler = [shaderProgram getSamplerLocation:"secondaryStatistic"];
	GLuint colormapSampler = [shaderProgram getSamplerLocation:"colormap"];
	GLuint parametersUniform = [shaderProgram getUniformLocation:"colorParams"];
	GLuint noiseParametersUniform = [shaderProgram getUniformLocation:"noiseParams"];
	GLuint heightmapSizeUniform = [shaderProgram getUniformLocation:"heightmapSize"];
	GLuint surfaceParametersUniform = [shaderProgram getUniformLocation:"surfaceParams"];
	
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
	
	float colMapDiscrete = [_viewSettings isColormapDiscreteForView:_viewId] ? 1.0f : 0.0f;
    colMapDiscrete = [_viewSettings isColormapFlatForView:_viewId] ? colMapDiscrete + 2.0 : colMapDiscrete;
    OVEnsembleProperty activeSurface = _viewId == ViewId2D ? EnsemblePropertyNone : [_viewSettings activeSurface3D];
    OVEnsembleProperty activeProperty = EnsemblePropertyNone;
    if( !_offScreenNeedsRefresh ) activeProperty = _viewId == ViewId2D ? [_viewSettings activeProperty2D] : [_viewSettings activeProperty3D];
	float params[4] = {[[_viewSettings activeColormapForView:_viewId] size]/ 11.0f,
		static_cast<float>([_viewSettings activeColormapIndexForView:_viewId]),
		colMapDiscrete,
        static_cast<float>([[_viewSettings activeColormapForView:_viewId] size])
	};
	[shaderProgram setParameter4fv:parametersUniform V:params];
	GetGLError();
	
	EnsembleDimension *dim = [[_appDelegate ensembleData] ensembleDimension];
	
	[shaderProgram setParameter2i:heightmapSizeUniform X:(int)(dim->texX) Y:(int)(dim->texY)];
	GetGLError();
	
	[shaderProgram setParameter4f:surfaceParametersUniform
                                X:static_cast<float>(activeProperty)
                                Y:1.0
                                Z:activeSurface == EnsemblePropertyBathymetry ? 0.15 : 0.025
                                W:_viewId == ViewId2D ? 1.0 : 0.0];
	GetGLError();
    
    if( !_offScreenNeedsRefresh ) activeProperty = _viewId == ViewId2D ? [_viewSettings activeNoiseProperty2D] : [_viewSettings activeNoiseProperty3D];
    [shaderProgram setParameter4f:noiseParametersUniform
                                X:activeProperty
                                Y:1.0
                                Z:1.0
                                W:1.0];
	GetGLError();

	return shaderProgram;
}

- (void) draw
{
	[self setupMatrix];
    
    [self drawOffScreen];
    
    [self drawOnScreen];
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
    if( !_offScreenNeedsRefresh ) return;
    
    int width = _viewWidth;
    int height = _viewHeight;
    
    if( _viewId == ViewId2D )
    {
        width = _bufferWidth;
        height = _bufferHeight;
        
        glViewport(0, 0, width, height);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    GetGLError();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    GetGLError();
    
    glEnable(GL_DEPTH_TEST);
    GetGLError();
    
    OVGLSLProgram *shaderProgram = [self setupAndEnableShaderProgram];
    
    [super drawWithShaderProgram: shaderProgram];
    
    assert( width <= _bufferWidth && height <= _bufferHeight );
    
    if( _cpuBuffer ) delete[] _cpuBuffer;
    _cpuBuffer = new unsigned char [width * height * 4];
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, _cpuBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    if( _viewId == ViewId2D )
    {
        OVEnsembleData *ensemble = [_appDelegate ensembleData];
        [ensemble setIndexLookup:_cpuBuffer];
        [ensemble setIndexLookupWidth:width];
        [ensemble setIndexLookupHeight:height];
        
        //[self save:width:height];
    }
    
    _offScreenNeedsRefresh = NO;
}

- (void)save:(int)w :(int) h
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    int bitsPerComponent = 8;
    CGContextRef contextRef = CGBitmapContextCreate(_cpuBuffer, w, h, bitsPerComponent, 4 * w, colorSpace, bitmapInfo);
    if(!contextRef)NSLog(@"Unable to create CGContextRef.");
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    if(!imageRef)NSLog(@"Unable to create CGImageRef.");
    
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"png"]];
    [savePanel setDirectoryURL:[NSURL fileURLWithPath:@"/"]];
   
    [savePanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
           
            [savePanel orderOut:self];
            
            CFURLRef url = (__bridge CFURLRef)[savePanel URL];
            CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, nil);
            CGImageDestinationAddImage(destination, imageRef, nil);
            
            if (!CGImageDestinationFinalize(destination)) {
                NSLog(@"Failed to write image to %@", url);
            }
            
            //CFRelease(destination);
        }
    }];
}

- (void) dealloc
{
	[self releaseShaderPrograms];
	[self releaseBuffers];
}

@end
