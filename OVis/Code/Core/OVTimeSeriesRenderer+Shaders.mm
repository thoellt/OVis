//
//	OVTimeSeriesRenderer+Shaders.mm
//

// Custom Headers
#import "OVGLSLProgram.h"

// Local Header
#import "OVTimeSeriesRenderer+Shaders.h"

@implementation OVTimeSeriesRenderer (Shaders)

- (void) releaseShaderPrograms
{
	_shadersLoaded = NO;
	
	[_glslProgramBasicGL releaseProgram];
}

- (void) loadShaderPrograms
{
	BOOL success = YES;
	
	_glslProgramBasicGL = [[OVGLSLProgram alloc] initFromVertexFile:@"glslProgramBasicGL"
                                                       geometryFile:nil
                                                       fragmentFile:@"glslProgramBasicGL"
                                                           withName:@"glslProgramBasicGL"];
	success *= (_glslProgramBasicGL != nil);
	
	if( success )
	{
		_shadersLoaded = YES;
		
	} else
	{
		NSLog( @"Could not load shader programs." );
		[self releaseShaderPrograms];
	}
}

@end