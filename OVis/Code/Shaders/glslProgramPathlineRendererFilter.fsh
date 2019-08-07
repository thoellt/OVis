/*!	@header		glslProgramPathlineRendererFilter.fsh
	@discussion	Fragment shader program for postprocessing pathlines texture.
	@author		Thomas Hoellt
	@updated	2014-07-01 */

#version 330

in	vec4 textureCoordinate;             ///< incoming value for the vertex color

layout(location = 0) out vec4 color;	///< outgoing value for the fragment color

uniform sampler2D pathlineTexture;      ///< the pathline data
uniform vec4 textureParameters;         ///< params for data acces ( texelSize.x, texelSize.y, ?, ? )


/*!	@method		main
	@discussion	The main routine: does nothing but pass on the interpolated vertex color.*/
void main(void)
{
    float gaussian[4] = float[4](0.383, 0.242, 0.061, 0.006);
    
    vec4 bla = vec4( 0.0 );
    
    for( int x = -3; x < 4; x++ )
    {
        for( int y = -3; y < 4; y++ )
        {
            vec2 coord = textureCoordinate.xy + vec2( x, y ) * textureParameters.xy;// * 0; /// ATTENTION, Debug * 0
            bla += texture( pathlineTexture, coord ).rgba * gaussian[abs(x)] * gaussian[abs(y)];
        }
    }
 
    color = bla;//vec4(1.0, 0.0, 0.0, 0.1);//vertexColor.rgba;
}