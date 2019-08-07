/*!	@header		OVUnstructuredSurfaceRenderer.h
	@discussion	Renderer for unstructured surface data.
	@author		Thomas Höllt
	@updated	2013-07-26 */

// System Headers
#import <GLKit/GLKit.h>

// Custom Headers
#import "OVSurfaceRenderer.h"
#import "OVSurfaceRenderer+Buffers.h"
#import "OVSurfaceRenderer+Shaders.h"

// Friend Classes
@class OVGLSLProgram;

/*!	@class		 OVUnstructuredSurfaceRenderer
	@discussion	Renderer for unstructured surface data.*/
@interface OVUnstructuredSurfaceRenderer : OVSurfaceRenderer {
	
	OVGLSLProgram *glslProgramUnstructuredSurfaceRenderer;
}

/*!	@method		rebuild
	@discussion	Rebuilds the renderer from the ground up without the need to
				destroy and recreate a renderer object. Call this after loading
				a new dataset.*/
- (void) rebuild;

/*!	@method		draw
	@discussion	Draw call. Sets up view matrix, shader and draws.*/
- (void) draw;

/*!	@method		drawOnScreen
    @discussion	Draw call for onscreen rendering.*/
- (void) drawOnScreen;

/*!	@method		drawOffscreen
    @discussion	Draw call for offscreen rendering. Only executes in proper views and when needed.*/
- (void) drawOffScreen;

/*!	@method		refreshData
	@discussion	Refreshes the renderer data, like textures. Call this when
				the derived data of the active dataset changes, for example, when
				changing the statistic or parameter range.*/
- (void) refreshData;

@end
