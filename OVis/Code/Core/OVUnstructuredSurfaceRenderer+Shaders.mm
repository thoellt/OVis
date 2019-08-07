//
//	OVUnstructuredSurfaceRenderer+Shaders.mm
//

// Custom Headers
#import "OVGLSLProgram.h"

// Local Header
#import "OVSurfaceRenderer+Shaders.h"
#import "OVUnstructuredSurfaceRenderer+Shaders.h"

@implementation OVUnstructuredSurfaceRenderer (Shaders)

- (BOOL) releaseShaderPrograms
{
    [super releaseShaderPrograms];
	
	[glslProgramUnstructuredSurfaceRenderer releaseProgram];
    
	_shadersLoaded = NO;
    
    return _shadersLoaded;
}

- (BOOL) loadShaderPrograms
{
	BOOL success = [super loadShaderPrograms];
	
	glslProgramUnstructuredSurfaceRenderer = [[OVGLSLProgram alloc] initFromVertexFile:@"glslProgramUnstructuredSurfaceRenderer"
                                                                          geometryFile:@"glslProgramUnstructuredSurfaceRenderer"
                                                                          fragmentFile:@"glslProgramUnstructuredSurfaceRenderer"
                                                                              withName:@"glslProgramUnstructuredSurfaceRenderer"];
	success *= (glslProgramUnstructuredSurfaceRenderer != nil);
	
	if( success )
	{
		_shadersLoaded = YES;
		
	} else
	{
		NSLog( @"Could not load shader programs for Unstructured Surface Renderer." );
		[self releaseShaderPrograms];
	}
    
    return success;
}

@end
