/*!	@header		glslProgramPathlineRendererFilter.vsh
	@discussion	Vertex shader program for postprocessing pathlines texture.
	@author		Thomas Hoellt
	@updated	2014-07-01 */
#version 330

layout(location = 0) in vec4 position;		///< incoming value for the vertex position

out vec4 textureCoordinate;                 ///< outgoing value for the texture coordinate

uniform mat4 modelViewProjectionMatrix;		///< incoming value for the mvp matrix

/*!	@method		main
	@discussion	The main routine: sets the vertex color to the given color and
				transforms the given vertex position into view space using the
				Model View Projection matrix.*/
void main (void)
{
    textureCoordinate = position;
    
	gl_Position = modelViewProjectionMatrix * position;
}