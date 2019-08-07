/*!	@header		OVTimeSeriesRenderer+Buffers.h
	@discussion	Buffers Category for OVTimeSeriesRenderer. Handles OpenGL
				Buffers for the Time Series Renderer.
	@author		Thomas Höllt
	@updated	2013-07-26 */


#import "OVTimeSeriesRenderer.h"

@interface OVTimeSeriesRenderer (Buffers)

/*!	@method		releaseBuffers
	@discussion	Release OpenGL buffers, calls releaseVertexBuffers and
				releaseTextureBuffers.*/
- (void) releaseBuffers;

/*!	@method		releaseVertexBuffers
	@discussion	Release OpenGL vertex buffer data.*/
- (void) releaseVertexBuffers;

/*!	@method		createBuffers
	@discussion	Create OpenGL buffers, calls createVertexBuffers.*/
- (void) createBuffers;

/*!	@method		createVertexBuffers
	@discussion	Create OpenGL vertex buffer data.*/
- (void) createVertexBuffers;

/*!	@method		refreshBuffers
	@discussion	Refreshes data in all buffers. Calls refreshVertexBuffers.
	@param	includeGUI	BOOL flag indicating whether or not to include the GUI part
				of the buffer data (e.g. height markers). Should be YES when the
				renderer is beeing rebuild.*/
- (void) refreshBuffers:(BOOL) includeGUI;

/*!	@method		refreshVertexBuffers
	@discussion	Refreshes data in all vertex buffers, i.e. Glyphs and GUI.
	@param	includeGUI	BOOL flag indicating whether or not to include the GUI part
				of the buffer data (e.g. height markers). Should be YES when the
				renderer is beeing rebuild.*/
- (void) refreshVertexBuffers:(BOOL) includeGUI;

@end