/*!	@header		OVPathlineRenderer+Shaders.h
	@discussion	Shaders Category for OVPathlineRenderer. Handles GLSL
				Shaders for the Pathline Renderer.
	@author		Thomas Höllt
	@updated	2014-06-23 */

#import "OVPathlineRenderer.h"

@interface OVPathlineRenderer (Shaders)

/*!	@method		releaseShaderPrograms
	@discussion	Releases OpenGL shader program data.*/
- (void) releaseShaderPrograms;

/*!	@method		loadShaderPrograms
	@discussion	Loads and creates OpenGL shader programs.*/
- (void) loadShaderPrograms;

@end
