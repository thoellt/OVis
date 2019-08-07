//
//	OVGLView.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import <QuartzCore/CVDisplayLink.h>

// Custom Headers
#import "gl_general.h"
#import "OVGLContextManager.h"

// Local Header
#import "OVGLView.h"

@interface OVGLView (PrivateMethods)
- (void) initGL;
- (void) drawView;
- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime;

@end

// This is the renderer output callback function
static CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext);
static CVReturn displayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
	CVReturn result = [(__bridge OVGLView*)displayLinkContext getFrameForTime:outputTime];
	return result;
}

@implementation OVGLView

- (void) rebuildRenderer
{
	[[self openGLContext] makeCurrentContext];
}

- (void) refreshRenderer
{
	[[self openGLContext] makeCurrentContext];
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{	
	[self drawView];
	return kCVReturnSuccess;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
	
	[self setPixelFormat:[[_appDelegate glContextManager] glPixelFormat]];
}

- (void) prepareOpenGL
{
	[super prepareOpenGL];
	
	// Make all the OpenGL calls to setup rendering
	// and build the necessary rendering objects
	[self initGL];
	
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(_displayLink, displayCallback, (__bridge void*)self);
	
	// Set the display link for the current renderer
	CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
	
	// Activate the display link
	CVDisplayLinkStart(_displayLink);
}

- (void) initGL
{
	// Make this openGL context current to the thread
	// (i.e. all openGL on this thread calls will go to this context)
	[[self openGLContext] makeCurrentContext];
	
	// Synchronize buffer swaps with vertical refresh rate
	GLint swapInt = 1;
	[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
}

- (void) reshape
{
	[super reshape];
}

- (void) drawView
{
}

- (void) dealloc
{
	// Stop the display link BEFORE releasing anything in the view
	// otherwise the display link thread may call into the view and crash
	// when it encounters something that has been released
	CVDisplayLinkStop(_displayLink);
	CVDisplayLinkRelease(_displayLink);
}

@end
