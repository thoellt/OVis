/*!	@header		OVTimeSeriesRenderer.h
	@discussion	Renderer for the time series view.
	@author		Thomas Höllt
	@updated	2013-07-26 */

// System Headers
#import <Foundation/Foundation.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class OVViewSettings;
@class OVGLSLProgram;

/*!	@class		OVTimeSeriesRenderer
	@discussion	Renderer for the time series view.*/
@interface OVTimeSeriesRenderer : NSObject {
	
	id<OVAppDelegateProtocol> _appDelegate;
	
	int _viewWidth;
	int _viewHeight;
	
	float _viewAspect;
	
	OVViewSettings *_viewSettings;
	
	// Shaders
	BOOL _shadersLoaded;
	OVGLSLProgram *_glslProgramBasicGL;
	
	// Buffers
    GLuint _vertexArrayObject;
    GLuint _glyphVertexBuffer;
    GLuint _boxplotVertexBuffer;
	GLuint _linesVertexBuffer;
	
	RGB *_riskColors;
}

/*!	@method		draw
	@discussion	Draw call. Sets up view matrix, shader and draws.*/
- (void) draw;

/*!	@method		rebuild
	@discussion	Rebuilds the renderer from the ground up without the need to
				destroy and recreate a renderer object. Call this after loading
				a new dataset*/
- (void) rebuild;

/*!	@method		refreshData
	@discussion	Refreshes the renderer data, like textures. Call this when
				the derived data of the active dataset changes, for example, when
				changing the statistic or parameter range.
	@param	includeGUI	BOOL flag indicating whether or not to include the GUI part
				of the buffer data (e.g. height markers). Should be YES when the
				renderer is beeing rebuild.*/
- (void) refreshData:(BOOL) includeGUI;

/*!	@method		resizeWithWidth
	@discussion	Resizes the renderer, should be called when the view containing
				the renderer is resized.
	@param	width	The new width in points.
	@param	height	The new height in points.*/
- (void) resizeWithWidth:(GLuint)width height:(GLuint)height;

@end