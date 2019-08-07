/*!	@header		glslProgramUnstructuredSurfaceRenderer.vsh
	@discussion	Vertex shader program for the regular surface renderer.
				Used for setting up the height information of the heighfield.
	@author		Thomas Hoellt
	@updated	2013-07-26 */
#version 150

uniform sampler2D heightmap;	///< the heightmap as a 2D texture for looking up height values per vertex
uniform mat4 modelViewProjectionMatrix;	///< incoming value for the mvp matrix

uniform ivec2 heightmapSize;	///< uniform vector for the heightmap size to allow proper lookups
uniform vec4 surfaceParams;     ///< misc parameters (statisticId, 1.0, zScale, discardZ)

uniform sampler2D statistic;	///< the statisitc texture, used to look up raw data at each position
uniform sampler2D secondaryStatistic;///< the secondary statistic texture, used to look up raw data at each position

in vec4 position;				///< incoming position attribute

out vec4 vertexColor;           ///< outgoing vertex color, encoding the gathered statistics for colormapping in the fragment stage
out vec4 statistics;            ///< outgoing value, encoding the gathered statistics


/*!	@method		main
	@discussion	The main routine: sets the height value for the vertex. In contrast
				to the structured glsl program here the data lookup needs to be
				done in the vertex stage to allow proper interpolation.
				Instead of attaching the lookup position to the vertex color here
				the vertex color holds the actual raw data at this position which is
				then colorcoded in the fragment stage.*/
void main (void)
{
	vec4 p = position;
    float zScale = surfaceParams.z;
    
    statistics = vec4( 0.0 );
	
	float vertexId = gl_VertexID;
	vec2 texIndex = vec2(0.0);
	texIndex.x = mod(vertexId, heightmapSize.x) + 0.5;
	texIndex.y = floor(vertexId / heightmapSize.x) + 0.5;
	texIndex /= heightmapSize;
	
	float height = texture( heightmap, texIndex ).r;

	// for unstructured we have to define the color in the vertexshader to avoid wrong interpolation
	vec4 col = vec4( 0.0 );
	if( surfaceParams.x < -0.5 ){
		
		col = vec4( vertexId, p.xy, 1.0 );
		
	} else {
		
        col = vec4( vertexId, p.xy, 1.0 );
		float val = texture( statistic, texIndex ).r;
		if( surfaceParams.x > 5.5 ) val = abs(val);
		col.a = val;
        
        statistics.x = val;
        statistics.y = texture( secondaryStatistic, texIndex ).r;;
	}
	
	vertexColor = col;
	if(surfaceParams.w < 0.5) p.z = height * zScale * 2.0;
	
	gl_Position = modelViewProjectionMatrix * p;
}