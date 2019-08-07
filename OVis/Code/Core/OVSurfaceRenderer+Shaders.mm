//
//	OVSurfaceRenderer+Shaders.mm
//

// Custom Headers
#import "OVGLSLProgram.h"

// Local Header
#import "OVSurfaceRenderer+Shaders.h"

@implementation OVSurfaceRenderer (Shaders)

- (BOOL) releaseShaderPrograms
{
	_shadersLoaded = NO;
	
	[_glslProgramBasicGL releaseProgram];
	
	[_glslProgramBasicGLColorBuffer releaseProgram];
    
    return _shadersLoaded;
}

- (BOOL) loadShaderPrograms
{
	BOOL success = YES;
	
	_glslProgramBasicGL = [[OVGLSLProgram alloc] initFromVertexFile:@"glslProgramBasicGL"
                                                       geometryFile:nil
                                                       fragmentFile:@"glslProgramBasicGL"
                                                           withName:@"glslProgramBasicGL"];
	success *= (_glslProgramBasicGL != nil);
	
	_glslProgramBasicGLColorBuffer = [[OVGLSLProgram alloc] initFromVertexFile:@"glslProgramBasicGLColorBuffer"
                                                                  geometryFile:nil
                                                                  fragmentFile:@"glslProgramBasicGLColorBuffer"
                                                                      withName:@"glslProgramBasicGLColorBuffer"];
	success *= (_glslProgramBasicGLColorBuffer != nil);
	
	if( success )
	{
		_shadersLoaded = YES;
		
	} else
	{
		NSLog( @"Could not load shader programs for OVGLSurfaceRenderer." );
		[self releaseShaderPrograms];
	}
    
    return _shadersLoaded;
}

@end
