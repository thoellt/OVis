/*!	@header		OVTimeSeriesRenderer+Shaders.h
	@discussion	Shaders Category for OVTimeSeriesRenderer. Handles GLSL
				Shaders for the Time Series Renderer.
	@author		Thomas Höllt
	@updated	2013-07-26 */

#import "OVTimeSeriesRenderer.h"

@interface OVTimeSeriesRenderer (Shaders)

/*!	@method		releaseShaderPrograms
	@discussion	Releases OpenGL shader program data.*/
- (void) releaseShaderPrograms;

/*!	@method		loadShaderPrograms
	@discussion	Loads and creates OpenGL shader programs.*/
- (void) loadShaderPrograms;

@end
