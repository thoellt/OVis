/*!	@header		OVPathlineRenderer+Buffers.h
	@discussion	Buffers Category for OVPathlineRenderer. Handles OpenGL
				Buffers for the Pathline Renderer.
	@author		Thomas Höllt
	@updated	2014-06-23 */


#import "OVPathlineRenderer.h"

@interface OVPathlineRenderer (Buffers)

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
	@discussion	Create OpenGL buffers, calls createVertexBuffers.*/
- (void) createBuffers;

/*!	@method		createVertexBuffers
	@discussion	Create OpenGL vertex buffer data.*/
- (void) createVertexBuffers;

/*!	@method		createTextureBuffers
    @discussion	Create OpenGL texture buffer data.*/
- (void) createTextureBuffers;

/*!	@method		refreshBuffers
	@discussion	Refreshes data in all buffers. Calls refreshVertexBuffers.*/
- (void) refreshBuffers;

/*!	@method		refreshVertexBuffers
	@discussion	Refreshes data in all vertex buffers, i.e. Glyphs and GUI.*/
- (void) refreshVertexBuffers;

/*!	@method		refreshTextureBuffers
    @discussion	Refreshes data in all texture buffers.*/
- (void) refreshTextureBuffers;

@end