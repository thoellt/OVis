/*!	@header		OVSurfaceRenderer+Buffers.h
	@discussion	Buffers Category for OVSurfaceRenderer Superclass. Handles OpenGL
				Buffers for the Surface Renderer.
	@author		Thomas Höllt
	@updated	2014-02-20 */

#import "OVSurfaceRenderer.h"

@interface OVSurfaceRenderer (Buffers)

/*!	@method		releaseBuffers
	@discussion	Release OpenGL buffers, calls releaseVertexBuffers and
				releaseTextureBuffers.*/
- (void) releaseBuffers;

/*!	@method		releaseVertexBuffers
	@discussion	Release OpenGL vertex buffer data.*/
- (void) releaseVertexBuffers;

/*!	@method		releaseTextureBuffers
	@discussion	Release OpenGL texture buffer data.*/
- (void) releaseTextureBuffers;

/*!	@method		createBuffers
	@discussion	Create OpenGL buffers, calls createVertexBuffers and
				createTextureBuffers.*/
- (void) createBuffers;

/*!	@method		createVertexBuffers
	@discussion	Create OpenGL vertex buffer data.*/
- (void) createVertexBuffers;

/*!	@method		refreshLegendVertexBuffer
 @discussion	Refreshes data in legend vertex buffer.*/
- (void) refreshLegendVertexBuffer;

/*!	@method		refreshLegendColorBuffer
    @discussion	Refreshes data in legend color buffer.*/
- (void) refreshLegendColorBuffer;

/*!	@method		createTextureBuffers
	@discussion	Create OpenGL texture buffer data.*/
- (void) createTextureBuffers;

/*!	@method		refreshTextureBuffers
	@discussion	Refreshes data in all texture buffers.*/
- (void) refreshTextureBuffers;

/*!	@method		refreshColormapTextureBuffer
	@discussion	Refreshes data in colormap texture buffer.*/
- (void) refreshColormapTextureBuffer;

/*!	@method		refreshStatisticTextureBuffer
	@discussion	Refreshes data in statistic texture buffer.*/
- (void) refreshStatisticTextureBuffer;

/*!	@method		refreshSecondaryStatisticTextureBuffer
    @discussion	Refreshes data in secondary statistic texture buffer.*/
- (void) refreshSecondaryStatisticTextureBuffer;

/*!	@method		refreshSurfaceTextureBuffer
	@discussion	Refreshes data in surface texture buffer.*/
- (void) refreshSurfaceTextureBuffer;

@end
