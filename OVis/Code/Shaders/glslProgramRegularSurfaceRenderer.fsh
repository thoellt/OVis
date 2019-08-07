/*!	@header		glslProgramRegularSurfaceRenderer.fsh
	@discussion	Fragment shader program for the regular surface renderer.
				Used for texturing the heighfield.
	@author		Thomas Hoellt
	@updated	2013-08-08 */
#version 150

uniform sampler2D statistic;///< the statistic texture, used to look up raw data at each position
uniform sampler2D secondaryStatistic;///< the secondary statistic texture, used to look up raw data at each position 
uniform sampler1D colormap;	///< the colormap texture, used to convert the raw value to color
uniform sampler1D pathlineColormap;	///< the colormap texture, used to convert the raw value to color for pathlines

// LIC
uniform sampler2D noisemap;	///< the texture containing the noise for LIC
uniform sampler2D vectormap;///< the vector data

uniform sampler2D pathlines;///< the pathline data

uniform vec4 colorParams;	///< parameter for the colormap lookup: (colormapScale, colormapId, colormapDiscrete, statisticId)
uniform vec4 noiseParams;   ///< parameter for noise and the secondary property: (statisticId, ?, ?, ?)
uniform vec4 surfaceParams; ///< the size of a texel (1/dimx, 1/dimy, 1/dimz, discardZ)
uniform vec4 pathlineParams;///< parameters for the pathline rendering: (enabled, tf scaling, alpha scaling, colormapScale)

in float invalid;			///< incoming value from the vertex shader, > 0 if fragment is invalid
in	vec4 vertexColor;		///< incoming value from the vertex shader, encodes the position for the texture lookup
out vec4 fragmentColor;		///< outgoing value for the fragment color

float cnoise(vec2 v);

/*!	@method		main
	@discussion	The main routine: textures the surface depending on the applications
				settings. Gets the lookup position for the statistic texture from
				the vertex program via the vertex color.*/
void main(void)
{
	if( invalid > 0.00000001 ) discard;
	
	vec4 col = vec4( 0.0 );
	
	if( colorParams.w < -0.5 ){
		
		col = vertexColor.rgba;
		col.b = 0.0;
	
	} else if( colorParams.w < 6.5 ){
		
		float scale = 1.0;
		if( colorParams.y > -0.5 ) scale = colorParams.x;
		float num = 11.0 * scale;
		
		float val = texture( statistic, vertexColor.xy ).r;
		if( colorParams.z > 0.0 ){ val = ( floor( clamp( val * num, 0.0, num-1 ) ) + 0.5 ) / num; }
	
		if( colorParams.y > -0.5 ){ col = texture( colormap, val * colorParams.x ).rgbr; }
		else{ col = vec4( val ); }
	
	} else {
		
		int licSamples = 75;
		float licScale = 1.0 / ( 2 * licSamples + 1);
		
		vec2 position = vertexColor.xy;
		vec2 direction = vec2( 0.0 );
		
		col = texture( noisemap, position ).rrrr * licScale;
		
		for( int i = 0; i < licSamples; i++ )
		{
			position = clamp( position - direction, 0.0, 1.0 );
			
			col += texture( noisemap, position ).rrrr * licScale;
			
			direction = texture( vectormap, position ).rg * surfaceParams.xy;
		}
		
		position = vertexColor.xy;
		direction = vec2( 0.0 );
		
		for( int i = 0; i < licSamples; i++ )
		{
			position = clamp( position + direction, 0.0, 1.0 );
			
			col += texture( noisemap, position ).rrrr * licScale;
			
			direction = texture( vectormap, position ).rg * surfaceParams.xy;
		}
        
        col.b = 1.0;
        col.g = col.g - 0.15;
        col.r = col.r - 0.5;
	}
	
	col.a = 1.0;
    
    if( pathlineParams.x > 0.0 ){ // pathline overlay enabled
        
        vec4 pathlineOverlay = texture( pathlines, vertexColor.xy );
        
        if( pathlineOverlay.a > 0.0 ){
            
            float colormapIndex =  clamp( pathlineOverlay.a, 0.0, 0.005 * pathlineParams.y ) * (200.0/pathlineParams.y);//pathlineOverlay.a;
        
            pathlineOverlay.rgb = texture( pathlineColormap, colormapIndex * pathlineParams.w ).rgb;
        
            //float alpha = 1.0;//pathlineOverlay.a;
            float alpha = clamp( pathlineOverlay.a * pathlineParams.z, 0.1, 1.0 );
            //pathlineOverlay.a = 1.0;
        
            col.rgb = mix( col.rgb, pathlineOverlay.rgb, alpha );
        }
    }
    
    if( noiseParams.x > -0.5 ){ // noise overlay enabled
    
        float val = texture( secondaryStatistic, vertexColor.xy ).r;
        //val *= val;
        
        //float noise = snoise( vertexColor.xy * 200.0 * val );
        float noise = cnoise( vertexColor.xy * 200.0 * val );
        noise = (( noise - 0.5 ) * val * val ) + 0.5;
        //col.rgb = vec3(noise);
        col.rgb = mix( col.rgb, vec3(noise), clamp( val * val, 0.0, 0.25 ) );
        //col.rgb += vec3(noise);// * 0.1;
    }

	fragmentColor = col;
}


//
// GLSL textureless classic 2D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-08-22
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/ashima/webgl-noise
//

vec4 mod289(vec4 x)
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
    return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

vec2 fade(vec2 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float cnoise(vec2 P)
{
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    
    vec4 i = permute(permute(ix) + iy);
    
    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    
    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}

// Classic Perlin noise, periodic variant
float pnoise(vec2 P, vec2 rep)
{
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
    Pi = mod289(Pi);        // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    
    vec4 i = permute(permute(ix) + iy);
    
    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    
    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}