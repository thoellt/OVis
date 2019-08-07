/*!	@header		OV3DView.h
	@discussion	Custom 3D View for OVis derived from OVGLView.
	@author		Thomas Höllt
	@updated	2013-07-29 */

// System Headers
#import "OVGLView.h"

// Friend Classes
@class OVSurfaceRenderer;

/*!	@class		OV3DView
	@discussion	Custom 3D View for OVis derived from OVGLView.*/
@interface OV3DView : OVGLView {
	
	OVSurfaceRenderer *_renderer;
	
	int _currentRendererIsStructured;
    
    int _mouseState;
	
	NSPoint _rightStartDrag;
}

/*!	@method		createRenderer
    @discussion	Creates a new structured or unstructured renderer from scratch.*/
- (void) createRenderer;


/*!	@method		refreshOpenGLUI
    @discussion	refreshes the UI part of the view that is drawn in OpenGL, i.e. the Legend.*/
- (void) refreshOpenGLUI;


/*!	@method		refreshPathlineBuffers
    @discussion	refreshes the pathline part of the view that is drawn in OpenGL.*/
- (void) refreshPathlineBuffers;


@end
