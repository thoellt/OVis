/*!	@header		glslProgramPathlineRenderer.fsh
	@discussion	Fragment shader program for rendering pathlines to texture.
	@author		Thomas Hoellt
	@updated	2014-06-23 */
#version 330

in	vec4 vertexColor;	///< incoming value for the vertex color
//out vec4 fragmentColor;	///< outgoing value for the fragment color
layout(location = 0) out vec4 color;

/*!	@method		main
	@discussion	The main routine: does nothing but pass on the interpolated vertex color.*/
void main(void)
{
	//glFragData[0] = vertexColor;
    color = clamp( vertexColor.aaaa, 0.0, 1.0 );
}