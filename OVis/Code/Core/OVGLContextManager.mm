//
//  OVGLContextManager.mm
//

#import "OVGLContextManager.h"

@implementation OVGLContextManager

@synthesize glPixelFormat= _glPixelFormat;

@synthesize glContextDummy = _glContextDummy;
@synthesize glContext2D = _glContext2D;
@synthesize glContext3D = _glContext3D;
@synthesize glContextTimeSeries = _glContextTimeSeries;

- (id) init
{
	self = [super init];
	
	if( self )
	{
		NSOpenGLPixelFormatAttribute attrib[] =
		{
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFAColorSize, 24,
			NSOpenGLPFAAlphaSize, 8,
			NSOpenGLPFADepthSize, 24,
			//NSOpenGLPFAAcceleratedCompute,
			NSOpenGLPFAOpenGLProfile,
			NSOpenGLProfileVersion4_1Core,
			0
		};
		
		// Initialize the global pixel format for all contexts.
		_glPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrib];
		
		if (!_glPixelFormat)
		{
			NSLog(@"Could not create OpenGL pixel format");
		}
		
		// Dummy context is created upon init to make sure it can be shared with openCL.
		_glContextDummy = [[NSOpenGLContext alloc] initWithFormat:_glPixelFormat shareContext:nil];
		
		// Actual contexts are created only upon request.
		_glContext3D = nil;
		_glContextTimeSeries = nil;
	}
	
	return self;
}

- (NSOpenGLContext*) getGLContextForView: (OVViewId) viewId
{
	NSOpenGLContext* context = nil;
	
	switch (viewId) {
		case ViewId2D:
			context = _glContext2D;
			break;
		case ViewId3D:
			context = _glContext3D;
			break;
		case ViewIdTS:
			context = _glContextTimeSeries;
			break;
        case ViewIdHistogram:
            return nil;
		default:
			// Context is only provided for 2D, 3D and TimeSeries Views.
			return nil;
	}
	
	// Create context if not already done.
	if( !context ) context = [[NSOpenGLContext alloc] initWithFormat:_glPixelFormat shareContext:_glContextDummy];
	
	return context;
}
@end
