//
//	OV3DView.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import <QuartzCore/CVDisplayLink.h>

// Custom Headers
#import "OVEnsembleData.h"
#import "OVEnsembleData+Pathlines.h"
#import "OVGLContextManager.h"
#import "OVSurfaceRenderer.h"
#import "OVRegularSurfaceRenderer.h"
#import "OVRegularSurfaceRenderer+Buffers.h"
#import "OVUnstructuredSurfaceRenderer.h"
#import "OVViewSettings.h"

#import "gl_general.h"

// Local Header
#import "OV3DView.h"

@implementation OV3DView

- (void) awakeFromNib
{
	[super awakeFromNib];
    
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self visibleRect]
                                                                options: NSTrackingMouseMoved | NSTrackingInVisibleRect |NSTrackingActiveAlways
                                                                  owner: self
                                                               userInfo: nil];
	
	[self addTrackingArea:trackingArea];
    
	[self setOpenGLContext:[[_appDelegate glContextManager] getGLContextForView:ViewId3D]];

	_renderer = nil;
	_currentRendererIsStructured = -1;
    
    _mouseState = 0;
}

- (void) rebuildRenderer
{
	[super rebuildRenderer];
	
	[self createRenderer];

	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
	if( _currentRendererIsStructured )[(OVRegularSurfaceRenderer*)(_renderer) rebuild];
	else [(OVUnstructuredSurfaceRenderer*)(_renderer) rebuild];
   
   [_renderer resizeWithWidth:self.frame.size.width height:self.frame.size.height];
    
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) refreshRenderer
{
	[super refreshRenderer];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	//CGLContextObj context = CGLGetCurrentContext();
	//NSLog(@"Context for 3D: %ld, active Context: %ld.", (CGLContextObj)[[self openGLContext] CGLContextObj], context);
	
	if( _currentRendererIsStructured )[(OVRegularSurfaceRenderer*)(_renderer) refreshData];
	else [(OVUnstructuredSurfaceRenderer*)(_renderer) refreshData];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) refreshOpenGLUI
{
    [[self openGLContext] makeCurrentContext];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	[_renderer refreshLegendVertexBuffer];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) refreshPathlineBuffers
{
//remove    [[self openGLContext] makeCurrentContext];
//
//    CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
//
//    if( _currentRendererIsStructured )[(OVRegularSurfaceRenderer*)(_renderer) refreshVectorFieldVertexBuffer];
//
//    CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}


- (void) mouseMoved:(NSEvent *)event
{
    NSPoint viewLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    
    iVector2 surfacePosition = [_renderer surfacePositionForScreenCoordinateX:(int)(ceilf(viewLocation.x))
                                                                            Y:(int)(ceilf(viewLocation.y))];
    
    if( _mouseState == 0 ){
        [[_appDelegate viewSettings] setHistogramPosition:surfacePosition];
        [_appDelegate refreshViewFromData:ViewIdHistogram];
    }
}

- (void) mouseDown:(NSEvent *)event
{
    _mouseState = 1;
	[_renderer initLocation:[self convertPoint:[event locationInWindow] fromView:nil]];
}

- (void) mouseDragged:(NSEvent *)event
{
    _mouseState = -1;
	[_renderer updateLocation:[self convertPoint:[event locationInWindow] fromView:nil]];
}

- (void) mouseUp:(NSEvent *)event
{
    if( [[_appDelegate viewSettings] isPathlineTracingEnabled] && _currentRendererIsStructured && _mouseState > 0 )
    {
        NSPoint viewLocation = [self convertPoint:[event locationInWindow] fromView:nil];
        iVector2 surfacePosition = [_renderer surfacePositionForScreenCoordinateX:(int)(ceilf(viewLocation.x))
                                                                                Y:(int)(ceilf(viewLocation.y))];
        NSLog( @"Picked Position: (%d,%d)", surfacePosition.x, surfacePosition.y );
        
        OVEnsembleData* ensemble = [_appDelegate ensembleData];
        if( [ensemble isVectorFieldAvailable] ) [ensemble computePathlineFromX:surfacePosition.x Y:surfacePosition.y Z:0];
    }
    _mouseState = 0;
}

- (void) rightMouseDown:(NSEvent *)event
{
    _mouseState = 1;
	_rightStartDrag = [self convertPoint:[event locationInWindow] fromView:nil];
}

- (void) rightMouseUp:(NSEvent *)event
{
    _mouseState = 0;
}

- (void) rightMouseDragged:(NSEvent *)event
{
	NSPoint newPos = [self convertPoint:[event locationInWindow] fromView:nil];
	[_renderer translateInX:newPos.x - _rightStartDrag.x Y:newPos.y - _rightStartDrag.y];
	_rightStartDrag = newPos;
}

- (void) keyDown:(NSEvent *)event
{
	NSString *str = [event charactersIgnoringModifiers];
	unsigned char key = [str characterAtIndex:0];
	
	switch (key) {
		case 'r':
			[_renderer resetLocation];
			break;
		case 'c':
            [[_appDelegate viewSettings] toggleColormapLegendForView:ViewId3D];
            [self refreshOpenGLUI];
			break;
		default:
			break;
	}
}

- (void) scrollWheel:(NSEvent *)event
{
	[_renderer setZoom:[event deltaY]];
}

- (void) initGL
{
	[super initGL];
	
	[self createRenderer];
}

- (void) createRenderer
{    
	int dataIsStructured = [_appDelegate.ensembleData isStructured] ? 1 : 0;
	
	if( dataIsStructured && _currentRendererIsStructured != dataIsStructured )
		_renderer = [[OVRegularSurfaceRenderer alloc] initWithViewId:ViewId3D];
	else if( !dataIsStructured && _currentRendererIsStructured != dataIsStructured )
		_renderer = [[OVUnstructuredSurfaceRenderer alloc] initWithViewId:ViewId3D];
	
	_currentRendererIsStructured = dataIsStructured;
}

- (void) reshape
{
	[super reshape];
	
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    [[self openGLContext] makeCurrentContext];
	
	NSRect rect = [self bounds];
	[_renderer resizeWithWidth:rect.size.width height:rect.size.height];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) drawView
{
   if(!_renderer) return;
   
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously	when resizing
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
    
    [[self openGLContext] makeCurrentContext];
	
	if( _currentRendererIsStructured == 1 )[(OVRegularSurfaceRenderer*)(_renderer) draw];
	else if( _currentRendererIsStructured == 0 ) [(OVUnstructuredSurfaceRenderer*)(_renderer) draw];
	
	CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) dealloc
{
}

@end
