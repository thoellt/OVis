/*!	@header		glslProgramBasicGL.vsh
	@discussion	Vertex shader program for basic drawing without lighting etc.
	@author		Thomas Hoellt
	@updated	2013-07-26 */
#version 150

uniform mat4 modelViewProjectionMatrix;		///< incoming value for the mvp matrix
uniform vec4 color;		///< uniform value for the vertex color

in vec4 position;		///< incoming value for the vertex position
out vec4 vertexColor;	///< outgoing value for the vertex color

/*!	@method		main
	@discussion	The main routine: sets the vertex color to the given color and
				transforms the given vertex position into view space using the
				Model View Projection matrix.*/
void main (void)
{
	vertexColor = color;
	
	gl_Position = modelViewProjectionMatrix * position;
}