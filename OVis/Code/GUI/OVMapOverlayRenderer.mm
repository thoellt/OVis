//
//	OVMapOverlayView.mm
//

// Custom Headers
#import "OVAppDelegate.h"
#import "OVAppDelegateProtocol.h"
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVGLContextManager.h"
#import "OVMapOverlay.h"
#import "OVViewSettings.h"
#import "OVSurfaceRenderer.h"
#import "OVRegularSurfaceRenderer.h"
#import "OVUnstructuredSurfaceRenderer.h"

#import "gl_general.h"

// Local Header
#import "OVMapOverlayRenderer.h"

@implementation OVMapOverlayRenderer

- (id)initWithOverlay:(id<MKOverlay>)overlay {
	self = [super initWithOverlay:overlay];
	if (self) {

        _appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
        
		_imageRef = nil;
		
		for( int i = 0; i < 4; i++ )
			_rawImageData[i] = nil;
        
        _glContext = [[_appDelegate glContextManager] getGLContextForView:ViewId2D];
        _glRenderer = nil;
        _renderBuffer = 0;
        _FBO = 0;
        _bufferWidth = 0;
        _bufferHeight = 0;
        _currentRendererIsStructured = -1;
        
        _buffer = nil;
        
        [self rebuildRenderer];
	}
	return self;
}

- (void) rebuildRenderer
{
	[_glContext makeCurrentContext];
    
	CGLLockContext((CGLContextObj)[_glContext CGLContextObj]);
    
	[self createRenderer];
    
	if( _currentRendererIsStructured )[(OVRegularSurfaceRenderer*)(_glRenderer) rebuild];
	else [(OVUnstructuredSurfaceRenderer*)(_glRenderer) rebuild];
    
    [self createFBO];
    
	CGLUnlockContext((CGLContextObj)[_glContext CGLContextObj]);
}

- (void) refreshRenderer
{
	[_glContext makeCurrentContext];
    
	CGLLockContext((CGLContextObj)[_glContext CGLContextObj]);
    
	if( _currentRendererIsStructured )[(OVRegularSurfaceRenderer*)(_glRenderer) refreshData];
	else [(OVUnstructuredSurfaceRenderer*)(_glRenderer) refreshData];
	
	CGLUnlockContext((CGLContextObj)[_glContext CGLContextObj]);
}

- (void) createRenderer
{
	int dataIsStructured = [_appDelegate.ensembleData isStructured] ? 1 : 0;
	
	if( dataIsStructured && _currentRendererIsStructured != dataIsStructured )
		_glRenderer = [[OVRegularSurfaceRenderer alloc] initWithViewId:ViewId2D];
	else if( !dataIsStructured && _currentRendererIsStructured != dataIsStructured )
		_glRenderer = [[OVUnstructuredSurfaceRenderer alloc] initWithViewId:ViewId2D];
    
	_currentRendererIsStructured = dataIsStructured;
}

- (void) createFBO
{
    // TODO: get max buffer size from hardware and adjust
    // TODO: make buffer size user adjustable, to increase performance (?)
    
    if( _currentRendererIsStructured )
    {
        EnsembleDimension *dim = [[_appDelegate ensembleData] ensembleDimension];
        
        // Make shure buffer is at least 1 pixel per side
        _bufferWidth = MAX(1, 4 * (int)(dim->x));
        _bufferHeight = MAX(1, 4 * (int)(dim->y));
    
    } else {
        
        EnsembleLonLat *lonLat = [[_appDelegate ensembleData] ensembleLonLat];
        float lonExt = ABS(lonLat->lon_max - lonLat->lon_min);
        float latExt = ABS(lonLat->lat_max - lonLat->lat_min);
        float xScale = MIN(1.0, lonExt / latExt);
        float yScale = MIN(1.0, latExt / lonExt);
        
        _bufferWidth = 1024 * xScale;
        _bufferHeight = 1024 * yScale;
    }
    
    if( _buffer ) delete[] _buffer;
    _buffer = new unsigned char[ _bufferWidth * _bufferHeight * 4 ];
    
    // Render buffer
    if( _renderBuffer ) glDeleteRenderbuffers(1, &_renderBuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, _bufferWidth, _bufferHeight);
    GetGLError();
    
    if( _FBO ) glDeleteFramebuffers(1, &_FBO);
    glGenFramebuffers(1, &_FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    GetGLError();
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    GetGLError();
    
    assert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE );
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    GetGLError();
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)ctx
{
	MKMapRect theMapRect = [self.overlay boundingMapRect];
	CGRect theRect = [self rectForMapRect:theMapRect];
	
	CGContextDrawImage(ctx, theRect, _imageRef);
}

- (void) refreshImageDataForView:(OVViewId) viewId
{
    [self refreshRenderer];
	
	CGLLockContext((CGLContextObj)[_glContext CGLContextObj]);
    
    [_glContext makeCurrentContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
            
    glViewport(0, 0, _bufferWidth, _bufferHeight);
    GetGLError();
    
    if( _currentRendererIsStructured )
    {
        [(OVRegularSurfaceRenderer*)_glRenderer draw];
    } else {
        [(OVUnstructuredSurfaceRenderer*)_glRenderer draw];
    }
        
    glReadPixels(0, 0, _bufferWidth, _bufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, _buffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
	
	CGLUnlockContext((CGLContextObj)[_glContext CGLContextObj]);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    int bitsPerComponent = 8;
    CGContextRef contextRef = CGBitmapContextCreate(_buffer, _bufferWidth, _bufferHeight, bitsPerComponent, 4 * _bufferWidth, colorSpace, bitmapInfo);
    if(!contextRef)NSLog(@"Unable to create CGContextRef.");
    
    _imageRef = CGBitmapContextCreateImage(contextRef);
    if(!_imageRef)NSLog(@"Unable to create CGImageRef.");
}

- (void) dealloc
{
    glDeleteRenderbuffers(1, &_renderBuffer);
    glDeleteFramebuffers(1, &_FBO);
    
	for( int i = 0; i < 4; i++ )
	{
		if( _rawImageData[i] ){
			delete[] _rawImageData[i];
			_rawImageData[i] = nil;
		}
	}
    
    delete _buffer;
}

@end