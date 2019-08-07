//
//	OVSurfaceRenderer.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <GLKit/GLKit.h>
#import <OpenGL/gl3.h>
#import <OpenGL/gl3ext.h>
#import <OpenGL/OpenGL.h>

// Custom Headers
#import "gl_general.h"
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"

// Local Header
#import "OVSurfaceRenderer.h"
#import "OVSurfaceRenderer+Buffers.h"
#import "OVSurfaceRenderer+Shaders.h"

@implementation OVSurfaceRenderer

- (id) init
{
    return [self initWithViewId:ViewId3D];
}

- (id) initWithViewId:(OVViewId) viewId
{
	self = [super init];
	
	if( self ){
		
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
		
        _viewId = viewId;
        
		_viewSettings = nil;
		if( _appDelegate ){
			_viewSettings = _appDelegate.viewSettings;
		}
		
		_viewWidth	= 100;
		_viewHeight	= 100;
		_viewAspect	= 1.0f;
		
		_includeLIC = NO;
		
		_vertexArrayObject = 0;
		_vertexBuffer = 0;
		_indexBuffer = 0;
		_indexBufferSize = 0;
        
        _legendVertexBuffer = 0;
        _legendColorBuffer = 0;
        
        _glslProgramBasicGL = nil;
		
		//_vertexBufferCL = 0;
		
		_surfaceTexture = 0;
		_statisticTexture[0] = 0;
		_statisticTexture[1] = 0;
		_colormapTexture[0] = 0;
		_colormapTexture[1] = 0;

        _offScreenNeedsRefresh = YES;
        
        _renderBuffer = 0;
        _depthBuffer = 0;
        _FBO = 0;
        
        _bufferWidth = 0;
        _bufferHeight = 0;
        
        _cpuBuffer = nil;
		
		_zoomLevel = 1.0f;
		
		_translate[0] = 0.0f;
		_translate[1] = 0.0f;
		
		_zoomStep = 0.0f;
		
		_translateStep[0] = 0.0f;
		_translateStep[1] = 0.0f;
		
		_lerpSpeed = 0.05f;
		
		[self initArcBall];
	}
	
	return self;
}

- (void) rebuild
{
	[self resetLocation];
    
    [self createFBO];
}

- (void) refreshData
{
    [self refreshLegendVertexBuffer];
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}


- (void) resizeWithWidth:(GLuint)width height:(GLuint)height
{
	_viewWidth = width;
	_viewHeight = height;
	
	_viewAspect = fabsf((float)_viewWidth / (float)_viewHeight);
    
    [self refreshLegendVertexBuffer];
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

- (void) createFBO
{
    // TODO: get screensize or max value for GPU here
    _bufferWidth = 4096;
    _bufferHeight = 4096;
    
    // Render buffer
    if( _renderBuffer ) glDeleteRenderbuffers(1, &_renderBuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, _bufferWidth, _bufferHeight);
    GetGLError();
    
    if( _depthBuffer ) glDeleteRenderbuffers(1, &_depthBuffer);
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, _bufferWidth, _bufferHeight);
    GetGLError();
    
    if( _FBO ) glDeleteFramebuffers(1, &_FBO);
    glGenFramebuffers(1, &_FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    GetGLError();
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    GetGLError();
    assert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE );
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    GetGLError();
    assert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE );
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    GetGLError();
}

- (void) setupMatrix
{	
	GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(55.0f), _viewAspect, 0.01f, 100.0f);
	
	if (_slerping) {
		
		_slerpCur += _lerpSpeed;
		float slerpAmt = _slerpCur / _slerpMax;
		if (slerpAmt > 1.0) {
			slerpAmt = 1.0;
			_slerping = NO;
		}
		_zoomLevel -= _zoomStep;
		_translate[0] -= _translateStep[0];
		_translate[1] -= _translateStep[1];
		
		_quaternion = GLKQuaternionSlerp(_slerpStart, _slerpEnd, slerpAmt);
	}
	
	EnsembleLonLat *lonLat = [[_appDelegate ensembleData] ensembleLonLat];
	float latExt = ABS(lonLat->lat_max - lonLat->lat_min);
	float lonExt = ABS(lonLat->lon_max - lonLat->lon_min);
	float maxDim = MAX(latExt, lonExt);
	
	GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -1.0f);
	modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, GLKMatrix4MakeWithQuaternion(_quaternion));
	modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, lonExt / maxDim * _zoomLevel, latExt / maxDim * _zoomLevel, _zoomLevel );
	modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, -0.5 + _translate[0], -0.5 + _translate[1], -0.0);
	
	_mvp = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}

- (void) drawWithShaderProgram: (OVGLSLProgram*) shaderProgram
{
	GLuint positionAttribute = [shaderProgram getAttributeLocation:"position"];
	
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glEnableVertexAttribArray(positionAttribute);
	GetGLError();
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	GetGLError();
	
	int bufferValid = 0;
	glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferValid);
	if(bufferValid)
	{
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
		GetGLError();
		
		glGetBufferParameteriv(GL_ELEMENT_ARRAY_BUFFER, GL_BUFFER_SIZE, &bufferValid);
		if(bufferValid)
		{
			
			glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, 0);
			GetGLError();
			
			if( !_offScreenNeedsRefresh && _viewId == ViewId3D && [_viewSettings renderAsWireframe3D] )glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
            else glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
			
			glDrawElements(GL_TRIANGLES, (int)_indexBufferSize, GL_UNSIGNED_INT, NULL);
			GetGLError();
			
			glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
            GetGLError();
		}
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        GetGLError();

	}
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
	glDisableVertexAttribArray(positionAttribute);
    GetGLError();

	glBindVertexArray(0);
    GetGLError();

	[shaderProgram disable];
	GetGLError();
}

- (void) drawLegend
{
    if( ![_viewSettings isColormapLegendVisibleForView:_viewId] ) return;
    
    BOOL isDiscrete = [_viewSettings isColormapDiscreteForView:_viewId];
    
    OVColormap* colormap = [_viewSettings activeColormapForView:_viewId];
        
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, _viewWidth, 0, _viewHeight, 0.0, 10000);
    
	OVGLSLProgram *shaderProgram = isDiscrete ? _glslProgramBasicGL : _glslProgramBasicGLColorBuffer;
	[shaderProgram compileAndLink];
	
	GLuint positionAttribute = [shaderProgram getAttributeLocation:"position"];
	GLuint colorAttribute = 0;
	GLuint modelViewProjectionMatrixUniform = [shaderProgram getUniformLocation:"modelViewProjectionMatrix"];
    
    if( isDiscrete )
    {
        colorAttribute = [shaderProgram getUniformLocation:"color"];
    }
    else
    {
        colorAttribute = [shaderProgram getAttributeLocation:"color"];
    }
	
	[shaderProgram bindAndEnable];
	GetGLError();
	
	[shaderProgram setParameter4x4fv:modelViewProjectionMatrixUniform M:projectionMatrix.m];
	GetGLError();
	
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glEnableVertexAttribArray(positionAttribute);
	GetGLError();
	glBindBuffer(GL_ARRAY_BUFFER, _legendVertexBuffer);
	GetGLError();
	glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, GL_FALSE, 0, 0);
	GetGLError();
	
    if( !isDiscrete )
    {
        glEnableVertexAttribArray(colorAttribute);
        GetGLError();
        glBindBuffer(GL_ARRAY_BUFFER, _legendColorBuffer);
        GetGLError();
        glVertexAttribPointer(colorAttribute, 4, GL_FLOAT, GL_FALSE, 0, 0);
        GetGLError();
    }
	
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	GetGLError();
	
	int numQuads = [[_viewSettings activeColormapForView:_viewId] size];
    if( !isDiscrete ) numQuads--;
    
    
    for( int i = 0; i < numQuads; i++ )
    {
        if( isDiscrete )
        {
            RGB col = [colormap colorAtIndex:numQuads-1-i];
            
            [shaderProgram setParameter4f:colorAttribute X:col.r/255.0 Y:col.g/255.0 Z:col.b/255.0 W:1.0];
            GetGLError();
        }
        
        glDrawArrays(GL_TRIANGLE_STRIP, 2*i, (GLint)4);
        GetGLError();
    }
    
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    GetGLError();

	glDisableVertexAttribArray(positionAttribute);
    GetGLError();
	
    if( !isDiscrete )
    {
        
        glDisableVertexAttribArray(colorAttribute);
        GetGLError();
    }

	glBindVertexArray(0);
    GetGLError();
	
	[shaderProgram disable];
	GetGLError();
}

- (iVector2) surfacePositionForScreenCoordinateX:(int) x Y:(int) y
{
    assert( x < _bufferWidth && y < _bufferHeight );
    
    int width = _viewWidth;
    int height = _viewHeight;
    
    if( _viewId == ViewId2D && ![[_appDelegate ensembleData] isStructured] )
    {
        width = _bufferWidth;
        height = _bufferHeight;
    }
    
    iVector2 position = {.x = 0, .y = 0};
    
    if( x < 0 || x >= width || y < 0 || y >= height )
    {
        //NSLog(@"Warning tried to access coordinate outside of the screen: (%d,%d).", x, y);
        return position;
    }
    
    size_t offset = (x + y * width) * 4;
    
    EnsembleDimension* dim = [[_appDelegate ensembleData] ensembleDimension];
    
    int r = (int)(_cpuBuffer[offset]);
    int g = (int)(_cpuBuffer[offset+1]);
    int b = (int)(_cpuBuffer[offset+2]);
    
    //NSLog(@"Color: (%d, %d, %d).", r, g, b);
    
    if( [[_appDelegate ensembleData] isStructured] )
    {
        position.x = (r/255.0) * dim->x;
        position.y = (g/255.0) * dim->y;
    } else {
        position.x = r * 256 * 256 + g * 256 + b;
    }
    
    //NSLog(@"Color: (%d,%d).", position.x, position.y);
    
    return position;
}

- (void) initArcBall
{
	_rotationMatrix = GLKMatrix4Identity;
	
	_quaternion = GLKQuaternionMake(0.0f, 0.0f, 0.0f, 1.0f);
	_initQuaternion = GLKQuaternionMake(0.0f, 0.0f, 0.0f, 1.0f);
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

- (GLKVector3) projectOntoSurface:(GLKVector3) clickedPosition
{
	float radius = _viewWidth/3;
	GLKVector3 center = GLKVector3Make(_viewWidth/2, _viewHeight/2, 0);
	GLKVector3 P = GLKVector3Subtract(clickedPosition, center);
	
	// Flip the y-axis because pixel coords increase toward the bottom.
	P = GLKVector3Make(P.x, P.y * -1, P.z);
	
	float radius2 = radius * radius;
	float length2 = P.x*P.x + P.y*P.y;
	
	if (length2 <= radius2)
		P.z = sqrt(radius2 - length2);
	else
	{
		P.z = radius2 / (2.0 * sqrt(length2));
		float length = sqrt(length2 + P.z * P.z);
		P = GLKVector3DivideScalar(P, length);
	}
	
	return GLKVector3Normalize(P);
}

- (void) initLocation:(CGPoint)location
{
	_anchorLocation = GLKVector3Make(location.x, location.y, 0);
	_anchorLocation = [self projectOntoSurface:_anchorLocation];
	
	_currentLocation = _anchorLocation;
	_initQuaternion = _quaternion;
	
	_initialLocation = location;
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

- (void) resetLocation
{
	_slerping = YES;
	_slerpCur = 0;
	_slerpMax = 1.0;
	_slerpStart = _quaternion;
	_slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
	
	_zoomStep = (_zoomLevel - 1.0) * _lerpSpeed;
	_translate[0] = _translate[0] * _lerpSpeed;
	_translate[1] = _translate[1] * _lerpSpeed;
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

- (void) setZoom:(float) zoom
{
	_zoomLevel -= zoom * 0.05 * _zoomLevel;
	_zoomLevel = MIN( 500.0f, MAX(_zoomLevel, 0.1f));
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

- (void) translateInX:(int) deltaX Y:(int) deltaY
{
	_translate[0] += (float)(deltaX) / _viewWidth;
	_translate[1] += (float)(deltaY) / _viewHeight;
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

- (void)computeIncremental {
	
	GLKVector3 axis = GLKVector3CrossProduct(_anchorLocation, _currentLocation);
	axis.y = - axis.y;
	float dot = GLKVector3DotProduct(_anchorLocation, _currentLocation);
	float angle = acosf(dot);
	
	GLKQuaternion Q_rot = GLKQuaternionMakeWithAngleAndVector3Axis(-angle * 2.0f, axis);
	Q_rot = GLKQuaternionNormalize(Q_rot);
	
	_quaternion = GLKQuaternionMultiply(Q_rot, _initQuaternion);
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

- (void)updateLocation:(CGPoint) newLocation
{
	CGPoint diff = CGPointMake(_initialLocation.x - newLocation.x, _initialLocation.y - newLocation.y);
	
	float rotX = -1 * GLKMathDegreesToRadians(diff.y / 2.0);
	float rotY = -1 * GLKMathDegreesToRadians(diff.x / 2.0);
	
	bool isInvertible;
	GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotationMatrix, &isInvertible), GLKVector3Make(1, 0, 0));
	_rotationMatrix = GLKMatrix4Rotate(_rotationMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
	GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotationMatrix, &isInvertible), GLKVector3Make(0, 1, 0));
	_rotationMatrix = GLKMatrix4Rotate(_rotationMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
	
	_currentLocation = GLKVector3Make(newLocation.x, newLocation.y, 0);
	_currentLocation = [self projectOntoSurface:_currentLocation];
	
	[self computeIncremental];
	
	_initialLocation = newLocation;
    
    if( _viewId != ViewId2D )_offScreenNeedsRefresh = YES;
}

@end
