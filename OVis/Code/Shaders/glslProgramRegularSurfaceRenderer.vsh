/*!	@header		glslProgramRegularSurfaceRenderer.vsh
	@discussion	Vertex shader program for the regular surface renderer.
				Used for setting up the height information of the heighfield.
	@author		Thomas Hoellt
	@updated	2013-07-26 */
#version 150

uniform sampler2D heightmap;	///< the heightmap as a 2D texture for looking up height values per vertex
uniform mat4 modelViewProjectionMatrix;	///< incoming value for the mvp matrix

uniform vec4 surfaceParams; ///< the size of a texel (1/dimx, 1/dimy, 1/dimz, discardZ)

in vec4 position;			///< incoming position attribute

out vec4 vertexColor;		///< outgoing vertex color, encoding the model x,y coords for tex lookup in the fragment stage
out float invalid;			///< outgoing float value set to 999999.9 if the vertex is invalid

/*!	@method		main
	@discussion	The main routine: marks invalid vertices and sets the height value for the vertex
				as well as the data lookup positions for the fragment stage.*/
void main (void)
{
	vec4 p = position;
	
	float height = texture( heightmap, p.xy ).r;
	invalid = 0.0;
	
	if( height > 999.9 ){
		
		invalid = 999999.9;
		height = 0.0;
	
	} else {
		
	}
	
	vertexColor = vec4(p.xyz, 1.0);
	if(surfaceParams.w < 0.5) p.z = height * 0.1;
	
	gl_Position = modelViewProjectionMatrix * p;
}