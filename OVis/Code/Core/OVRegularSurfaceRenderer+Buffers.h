/*!	@header		OVRegularSurfaceRenderer+Buffers.h
	@discussion	Buffers Category for OVRegularSurfaceRenderer. Handles OpenGL
				Buffers for the Regular Surface Renderer.
	@author		Thomas Höllt
	@updated	2013-07-26 */

#import "OVRegularSurfaceRenderer.h"

#import "OVSurfaceRenderer+Buffers.h"

@interface OVRegularSurfaceRenderer (Buffers)

/*!	@method		refreshVectorFieldVertexBuffer
    @discussion	Refresh OpenGL vertex buffer data for Vector Field Path Lines.*/
//- (void) refreshVectorFieldVertexBuffer;

/*!	@method		refreshFlowColormapTextureBuffer
 @discussion	Refreshes data in the colormap texture buffers for vector visualization.*/
- (void) refreshFlowColormapTextureBuffer;

/*!	@method		refreshVectorFieldTextureBuffers
    @discussion	Refreshes data in texture buffers for vector visualization.*/
- (void) refreshVectorFieldTextureBuffers;

@end
