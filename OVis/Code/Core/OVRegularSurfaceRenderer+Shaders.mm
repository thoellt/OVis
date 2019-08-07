//
//	OVRegularSurfaceRenderer+Shaders.mm
//

// Custom Headers
#import "OVGLSLProgram.h"

// Local Headers
#import "OVSurfaceRenderer+Shaders.h"
#import "OVRegularSurfaceRenderer+Shaders.h"

@implementation OVRegularSurfaceRenderer (Shaders)

- (BOOL) releaseShaderPrograms
{
    [super releaseShaderPrograms];
	
	[_glslProgramRegularSurfaceRenderer releaseProgram];
    
	_shadersLoaded = NO;
    
    return _shadersLoaded;
}

- (BOOL) loadShaderPrograms
{
	BOOL success = [super loadShaderPrograms];
	
	_glslProgramRegularSurfaceRenderer = [[OVGLSLProgram alloc] initFromVertexFile:@"glslProgramRegularSurfaceRenderer"
                                                                      geometryFile:nil
																	  fragmentFile:@"glslProgramRegularSurfaceRenderer"
																		  withName:@"glslProgramRegularSurfaceRenderer"];
	success *= (_glslProgramRegularSurfaceRenderer != nil);
	
	if( success )
	{
		_shadersLoaded = YES;
		
	} else
	{
		NSLog( @"Could not load shader programs for Regular Surface Renderer." );
		[self releaseShaderPrograms];
	}
    
    return success;
}

@end
