/*!	@header		glslProgramUnstructuredSurfaceRenderer.gsh
    @discussion	Geometry shader program for the unstructured surface renderer.
                Used for nearest neighbor picking.
    @author		Thomas Hoellt
    @updated	2013-07-26 */
#version 150

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform vec4 colorParams;   ///< parameter for the colormap lookup: (colormapScale, colormapId, colormapDiscrete, statisticId)
uniform vec4 surfaceParams;   ///< parameter for the colormap lookup: (colormapScale, colormapId, colormapDiscrete, statisticId)

in	vec4 vertexColor[3];    ///< incoming value from the vertex shader, encodes the statistics value
in	vec4 statistics[3];     ///< incoming value from the vertex shader, encodes the statistics value
out	vec4 geometryColor;     ///< outgoing value to the fragment shader, encodes the statistics value
out	vec4 barycentricCoord;  ///< outgoing value to the fragment shader, encodes the statistics value
out	vec4 statisticsInterpolated;     ///< outgoing value to the fragment shader, encodes the statistics value

void main()
{
    vec4 vertexIds = vec4( vertexColor[0].x, vertexColor[1].x, vertexColor[2].x, 1.0 );
    
    for(int i = 0; i < gl_in.length(); i++)
    {
        vec4 vertColor = vertexColor[i];
        barycentricCoord = vec4( 0.0, 0.0, 0.0, 0.0 );
        
        if( surfaceParams.x < -0.5 || colorParams.z > 1.5 ){
            
            switch (i) {
                case 0:
                    barycentricCoord = vec4( 1.0, 0.0, 0.0, 0.0 );
                    break;
                case 1:
                    barycentricCoord = vec4( 0.0, 1.0, 0.0, 0.0 );
                    break;
                case 2:
                    barycentricCoord = vec4( 0.0, 0.0, 1.0, 0.0 );
                    break;
            }
            vertColor = vertexIds;
        }
        
        geometryColor = vertColor;
        statisticsInterpolated = statistics[i];
        gl_Position = gl_in[i].gl_Position;
        EmitVertex();
    }
    EndPrimitive();
}