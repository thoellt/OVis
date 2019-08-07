/*!	@header		OVMapOverlayView.h
	@discussion Renderer for the OVMapOverlay.
	@author		Thomas Höllt
	@updated	2013-09-11 */

// System Headers
#import <AppKit/AppKit.h>
#import <MapKit/MapKit.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class OVEnsembleData;
@class OVSurfaceRenderer;

/*!	@class		OVGLView
	@discussion	Renderer for the OVapOverlay.*/
@interface OVMapOverlayRenderer : MKOverlayRenderer {

    id<OVAppDelegateProtocol> _appDelegate;
    
	CGImageRef _imageRef;
	
	Byte *_rawImageData[4];
    
    OVSurfaceRenderer *_glRenderer;
    NSOpenGLContext *_glContext;
    
    GLuint _renderBuffer;
    GLuint _FBO;
    
    int _bufferWidth;
    int _bufferHeight;
	
	int _currentRendererIsStructured;
    
    unsigned char* _buffer;
}

/*!	@method		refreshImageDataForView
	@discussion	Refreshes the overlay image to render.
	@param	viewId The id for the View (in case several 2D views exist) for which
				to re-render the overlay.*/
- (void) refreshImageDataForView:(OVViewId) viewId;

/*!	@method		rebuildRenderer
    @discussion	Rebuilds the renderer from the ground up without the need to
    destroy and recreate a renderer object. Call this after loading
    a new dataset.*/
- (void) rebuildRenderer;

/*!	@method		refreshRenderer
    @discussion	Refreshes the renderer data, like textures. Call this when
    the derived data of the active dataset changes, for example, when
    changing the statistic or parameter range.*/
- (void) refreshRenderer;

/*!	@method		createRenderer
    @discussion	Creates a new structured or unstructured renderer from scratch.*/
- (void) createRenderer;

/*!	@method		createFBO
    @discussion	Creates a new Framebuffer Object for offscreen OpenGL rendering
    of the overlay.*/
- (void) createFBO;

@end