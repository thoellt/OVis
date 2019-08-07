//
//	OVPathlineRenderer+Shaders.mm
//

// Custom Headers
#import "OVGLSLProgram.h"

// Local Header
#import "OVPathlineRenderer+Shaders.h"

@implementation OVPathlineRenderer (Shaders)

- (void) releaseShaderPrograms
{
	_shadersLoaded = NO;
	
	[_glslProgramPathlineRenderer releaseProgram];
}

- (void) loadShaderPrograms
{
	BOOL success = YES;
	
	_glslProgramPathlineRenderer = [[OVGLSLProgram alloc] initFromVertexFile:@"glslProgramPathlineRenderer"
                                                                geometryFile:nil
                                                                fragmentFile:@"glslProgramPathlineRenderer"
                                                                    withName:@"glslProgramPathlineRenderer"];
	success *= (_glslProgramPathlineRenderer != nil);
	
	_glslProgramPathlineRendererFilter = [[OVGLSLProgram alloc] initFromVertexFile:@"glslProgramPathlineRendererFilter"
                                                                      geometryFile:nil
                                                                      fragmentFile:@"glslProgramPathlineRendererFilter"
                                                                          withName:@"glslProgramPathlineRendererFilter"];
	success *= (_glslProgramPathlineRenderer != nil);
	
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