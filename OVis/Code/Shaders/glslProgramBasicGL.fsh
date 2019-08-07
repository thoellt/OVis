/*!	@header		glslProgramBasicGL.fsh
	@discussion	Fragment shader program for basic drawing without lighting etc.
	@author		Thomas Hoellt
	@updated	2013-07-26 */
#version 150

in	vec4 vertexColor;	///< incoming value for the vertex color
out vec4 fragmentColor;	///< outgoing value for the fragment color

/*!	@method		main
	@discussion	The main routine: does nothing but pass on the interpolated vertex color.*/
void main(void)
{
	fragmentColor = vertexColor;
}