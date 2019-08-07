//
//	OVTimeSeriesView.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import <QuartzCore/CVDisplayLink.h>

// Custom Headers
#import "OVGLContextManager.h"
#import "OVTimeSeriesRenderer.h"

#import "gl_general.h"

// Local Header
#import "OVTimeSeriesView.h"

@implementation OVTimeSeriesView

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	[self setOpenGLContext:[[_appDelegate glContextManager] getGLContextForView:ViewIdTS]];
	
	_renderer = nil;
}

- (void) rebuildRenderer
{
	[super rebuildRenderer];
   
   _renderer = [[OVTimeSeriesRenderer alloc] init];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
   
	[_renderer rebuild];
   
   [_renderer resizeWithWidth:self.frame.size.width height:self.frame.size.height];
   
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) refreshRenderer
{
	[super refreshRenderer];
	
	CGLLockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
	
	//CGLContextObj context = CGLGetCurrentContext();
	//NSLog(@"Context for TS: %ld, active Context: %ld.", (CGLContextObj)[[self openGLContext] CGLContextObj], context);
	
	[_renderer refreshData:YES];
	[_renderer draw];
	
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) initGL
{
	[super initGL];
	_renderer = [[OVTimeSeriesRenderer alloc] init];
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
	[_renderer draw];
	
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
	
	[_renderer draw];
	
	CGLFlushDrawable((CGLContextObj)[[self openGLContext] CGLContextObj]);
	CGLUnlockContext((CGLContextObj)[[self openGLContext] CGLContextObj]);
}

- (void) dealloc
{
}

@end
