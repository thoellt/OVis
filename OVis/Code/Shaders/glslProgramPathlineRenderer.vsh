/*!	@header		glslProgramPathlineRenderer.vsh
	@discussion	Vertex shader program for rendering pathlines to texture.
	@author		Thomas Hoellt
	@updated	2014-06-23 */
#version 330

layout(location = 0) in vec4 position;		///< incoming value for the vertex position
layout(location = 1) in vec4 color;         ///< incoming value for the vertex position

out vec4 vertexColor;                       ///< outgoing value for the vertex color

uniform mat4 modelViewProjectionMatrix;		///< incoming value for the mvp matrix

/*!	@method		main
	@discussion	The main routine: sets the vertex color to the given color and
				transforms the given vertex position into view space using the
				Model View Projection matrix.*/
void main (void)
{
	vertexColor = color;
	
	gl_Position = modelViewProjectionMatrix * position;
}