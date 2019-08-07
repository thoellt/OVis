/*!	@header		glslProgramUnstructuredSurfaceRenderer.fsh
	@discussion	Fragment shader program for the unstructured surface renderer.
				Used for texturing the heighfield.
	@author		Thomas Hoellt
	@updated	2013-07-26 */
#version 150

uniform sampler1D colormap;	///< the colormap texture, used to convert the raw value to color
uniform vec4 colorParams;	///< parameter for the colormap lookup: (colormapScale, colormapId, colormapDiscrete, numColorMapEntries)
uniform vec4 noiseParams;   ///< parameter for noise and the secondary property: (statisticId, ?, ?, ?)
uniform vec4 surfaceParams; ///< misc parameters (statisticId, 1.0, zScale, discardZ)

uniform ivec2 heightmapSize;	///< uniform vector for the heightmap size to allow proper lookups
uniform sampler2D statistic;	///< the statisitc texture, used to look up raw data at each position
uniform sampler2D secondaryStatistic;///< the secondary statistic texture, used to look up raw data at each position

in	vec4 geometryColor;     ///< incoming value from the vertex shader, encodes the statistics value
in  vec4 barycentricCoord;
in	vec4 statisticsInterpolated;     ///< outgoing value to the fragment shader, encodes the statistics value
out vec4 fragmentColor;		///< outgoing value for the fragment color

float snoise(vec2 v);

/*!	@method		main
	@discussion	The main routine: sets the height value for the vertex. In contrast
				to the structured glsl program here only the colormapping is carried out in the fragment stage.*/
void main(void)
{
    vec4 vertexColor = geometryColor;
    
	float val = vertexColor.a;
	vec4 col = vec4( 0.0 );

    float nearestId = 0.0;
    
	if( surfaceParams.x < -0.5 || colorParams.z > 1.5  ){
        
        if( barycentricCoord.x > barycentricCoord.y && barycentricCoord.x > barycentricCoord.z )
            nearestId = geometryColor.x;
        else if( barycentricCoord.y > barycentricCoord.x && barycentricCoord.y > barycentricCoord.z )
            nearestId = geometryColor.y;
        else if( barycentricCoord.z > barycentricCoord.x && barycentricCoord.z > barycentricCoord.y )
            nearestId = geometryColor.z;
    }
    
    vec2 texIndex = vec2(0.0);
    if( colorParams.z > 1.5 ){
        
        texIndex.x = mod(nearestId, heightmapSize.x) + 0.5;
        texIndex.y = floor(nearestId / heightmapSize.x) + 0.5;
        texIndex /= heightmapSize;
    }
    
    if( surfaceParams.x < -0.5 ) {
        col.x = nearestId / ( 256 * 256 );
        col.y = floor(nearestId / 256);
        col.z = mod( nearestId, 256.0 );
        col.w = 255.0;
        
        col /= 255.0;
    
    } else {
        
        if( colorParams.z > 1.5 ){
            
            val = texture( statistic, texIndex ).r;
            if( surfaceParams.x > 5.5 ) val = abs(val);
        }
 
        if( colorParams.y > -0.5 )
        {
            float scale = colorParams.y < -0.5 ? 1.0 : colorParams.x;
            float num = colorParams.w;
     
            if( mod(int(colorParams.z),2) == 1 )
            {
                val = ( floor( val * (num-1.0) ) + 0.5 ) / num;
            }
            else
            {
                val = (val * (num-1.0) + 0.5) / num;
            }
            
            col = texture( colormap, val * colorParams.x ).rgbr;
        }
        else
        {
            if( mod(int(colorParams.z),2) == 1 )
            {
                val = ( floor( val * 9.0 ) + 0.5 ) / 10.0;
            }
            
            col = vec4( val );
        }
    }
	col.a = 1.0;
    
    if( noiseParams.x > -0.5 ){ // noise overlay enabled
        
        vec3 noise = vec3(0.0);
        if( colorParams.z > 1.5 ){
            
            val = texture( secondaryStatistic, texIndex ).r;
            if( surfaceParams.x > 5.5 ) val = abs(val);
            noise = vec3(snoise(texIndex*300.0*val));

        } else {
            val = statisticsInterpolated.y;
            noise = vec3(snoise(vertexColor.yz*300.0*val));
        }
        
        noise = (( noise - 0.5 ) * val ) + 0.5;
        //col.rgb = vec3(val);
        col.rgb = mix( col.rgb, noise, clamp( val, 0.0, 0.35 ) );
    }
	
	fragmentColor = col;
}


//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    
    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                     + i.x + vec3(0.0, i1.x, 1.0 ));
    
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    
    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

