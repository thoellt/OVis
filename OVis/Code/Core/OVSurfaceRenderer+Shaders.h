/*!	@header		OVSurfaceRenderer+Shaders.h
	@discussion	Shaders Category for OVSurfaceRenderer Superclass. Handles GLSL
				Shaders for the Surface Renderer.
	@author		Thomas Höllt
	@updated	2014-02-20 */

#import "OVSurfaceRenderer.h"

@interface OVSurfaceRenderer (Shaders)

/*!	@method		releaseShaderPrograms
	@discussion	Releases OpenGL shader program data.*/
- (BOOL) releaseShaderPrograms;

/*!	@method		loadShaderPrograms
	@discussion	Loads and creates OpenGL shader programs.*/
- (BOOL) loadShaderPrograms;

@end
