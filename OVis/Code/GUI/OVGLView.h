/*!	@header		OVGLView.h
	@discussion	Custom OpenGL View for OVis derived from NSOpenGLView. Functions
				as base class for OV3DView and OVTimeSeriesView.
	@author		Thomas Höllt
	@updated	2013-07-29 */

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class CVDisplayLink;

/*!	@class		OVGLView
 @discussion	Custom OpenGL View for OVis derived from NSOpenGLView. Functions
				as base class for OV3DView and OVTimeSeriesView.*/
@interface OVGLView : NSOpenGLView{
	
	id<OVAppDelegateProtocol> _appDelegate;
	
	CVDisplayLinkRef _displayLink;
}

/*!	@method		initGL
	@discussion	Initializes the OpenGL context for the encapsuled view.*/
- (void) initGL;

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

@end