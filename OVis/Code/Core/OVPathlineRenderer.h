/*!	@header		OVPathlineRenderer.h
	@discussion	Offline rendererfor pathlines to texture.
	@author		Thomas Höllt
	@updated	2014-06-23 */

// System Headers
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class OVViewSettings;
@class OVGLSLProgram;

/*!	@class		OVPathlineRenderer
	@discussion	(Offline) Renderer for the pathlines.*/
@interface OVPathlineRenderer : NSObject {
	
	id<OVAppDelegateProtocol> _appDelegate;
	
	int _viewWidth;
	int _viewHeight;
	
	OVViewSettings *_viewSettings;
	
	// Shaders
	BOOL _shadersLoaded;
	OVGLSLProgram *_glslProgramPathlineRenderer;
	OVGLSLProgram *_glslProgramPathlineRendererFilter;
	
	// Buffers
	GLuint _vertexArrayObject;
	GLuint _pathlineVertexBuffer;
	GLuint _pathlineColorBuffer;
    GLuint _fullScreenQuadVertexBuffer;

	GLKMatrix4 _mvp;
}

/*!	@method		setupMatrix
    @discussion	Sets the View Matrix (Model View Projection) according to the
                current settings (zoom, rotation, etc.).*/
- (void) setupMatrix;

/*!	@method		draw
	@discussion	Draw call. Sets up view matrix, shader and draws.*/
- (void) draw;

/*!	@method		draw
    @discussion	Draw call. Sets up view matrix, shader and draws.*/
- (void) filterTexture: (GLuint) texture withWidth: (int)width Height: (int)height;

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
- (void) refreshData;

@end