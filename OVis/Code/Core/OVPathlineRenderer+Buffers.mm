//
//	OVPathlineRenderer+Buffers.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <OpenGL/gl3.h>
#import <OpenGL/OpenGL.h>

// Custom Headers
#import "gl_general.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"

// Local Header
#import "OVPathlineRenderer+Buffers.h"

@implementation OVPathlineRenderer (Buffers)

- (void) releaseBuffers
{
	[self releaseVertexBuffers];
	[self releaseTextureBuffers];
}

- (void) releaseVertexBuffers
{
	glBindBuffer(GL_ARRAY_BUFFER, 0);

	GetGLError();
	
	glDeleteBuffers(1, &_pathlineVertexBuffer);
	GetGLError();
	
	glDeleteBuffers(1, &_pathlineColorBuffer);
	GetGLError();
	
	glBindVertexArray(0);
	GetGLError();
	
	glDeleteVertexArrays(1, &_vertexArrayObject);
	GetGLError();
}

- (void) releaseTextureBuffers
{
	
}

- (void) createBuffers
{
	[self createVertexBuffers];
}

- (void) createVertexBuffers
{
	if( _vertexArrayObject == 0 )
		glGenVertexArrays(1, &_vertexArrayObject);
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
    
    float fullScreenQuad[18] = { 0.0, 0.0, 0.0,
                                 1.0, 0.0, 0.0,
                                 0.0, 1.0, 0.0,
                                 0.0, 1.0, 0.0,
                                 1.0, 0.0, 0.0,
                                 1.0, 1.0, 0.0,
                                };
    
    glGenBuffers(1, &_fullScreenQuadVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _fullScreenQuadVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, 18 * sizeof(float), &fullScreenQuad[0], GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    GetGLError();
    
/*    if( [[_appDelegate ensembleData] isVectorFieldAvailable] )
	{
		std::vector<Vector3> pathlines = [_appDelegate.ensembleData normalizedPathlines];
        std::vector<Vector4> pathlineColors = [_appDelegate.ensembleData pathlineColors];
		if( pathlines.size() > 0 ){
            
			if( _pathlineVertexBuffer == 0 )
				glGenBuffers(1, &_pathlineVertexBuffer);
			glBindBuffer(GL_ARRAY_BUFFER, _pathlineVertexBuffer);
			glBufferData(GL_ARRAY_BUFFER, pathlines.size() * sizeof(Vector3), &pathlines[0], GL_STATIC_DRAW);
			glBindBuffer(GL_ARRAY_BUFFER, 0);
			GetGLError();
            
            if( _pathlineColorBuffer == 0 )
                glGenBuffers(1, &_pathlineColorBuffer);
			glBindBuffer(GL_ARRAY_BUFFER, _pathlineColorBuffer);
			glBufferData(GL_ARRAY_BUFFER, pathlineColors.size() * sizeof(Vector4), &pathlineColors[0], GL_STATIC_DRAW);
			glBindBuffer(GL_ARRAY_BUFFER, 0);
			GetGLError();
            
		}
	}
 */
	glBindVertexArray(0);
	GetGLError();
	
	[self refreshVertexBuffers];
}

- (void) createTextureBuffers
{
}

- (void) refreshBuffers
{
	[self refreshVertexBuffers];
}

- (void) refreshVertexBuffers
{
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
    
    if( [[_appDelegate ensembleData] isVectorFieldAvailable] )
	{
		std::vector<Vector3> pathlines = [_appDelegate.ensembleData normalizedPathlines];
		std::vector<Vector4> colors = [_appDelegate.ensembleData pathlineColors];
        /*std::vector<Vector3> pathlines;
        pathlines.push_back({.x = 0.0, .y = 0.0, .z = 0.0});
        pathlines.push_back({.x = 0.75, .y = 0.0, .z = 0.0});
        pathlines.push_back({.x = 0.0, .y = 0.75, .z = 0.0});
        pathlines.push_back({.x = 0.0, .y = 0.75, .z = 0.0});
        pathlines.push_back({.x = 0.75, .y = 0.0, .z = 0.0});
        pathlines.push_back({.x = 0.75, .y = 0.75, .z = 0.0});
        pathlines.push_back({.x = 0.25, .y = 0.25, .z = 0.0});
        pathlines.push_back({.x = 1.0, .y = 0.25, .z = 0.0});
        pathlines.push_back({.x = 0.25, .y = 1.0, .z = 0.0});
        pathlines.push_back({.x = 0.25, .y = 1.0, .z = 0.0});
        pathlines.push_back({.x = 1.0, .y = 0.25, .z = 0.0});
        pathlines.push_back({.x = 1.0, .y = 1.0, .z = 0.0});
        
        std::vector<Vector4> colors;
        colors.push_back({.x = 0.0, .y = 1.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 0.0, .y = 1.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 0.0, .y = 1.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 0.0, .y = 1.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 0.0, .y = 1.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 0.0, .y = 1.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 1.0, .y = 0.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 1.0, .y = 0.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 1.0, .y = 0.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 1.0, .y = 0.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 1.0, .y = 0.0, .z = 0.0, .w = 0.5});
        colors.push_back({.x = 1.0, .y = 0.0, .z = 0.0, .w = 0.5});
         */

		if( pathlines.size() > 0 ){
            
			if( _pathlineVertexBuffer == 0 )
				glGenBuffers(1, &_pathlineVertexBuffer);
			glBindBuffer(GL_ARRAY_BUFFER, _pathlineVertexBuffer);
			glBufferData(GL_ARRAY_BUFFER, pathlines.size() * sizeof(Vector3), &pathlines[0], GL_STATIC_DRAW);
			glBindBuffer(GL_ARRAY_BUFFER, 0);
			GetGLError();
            
			if( _pathlineColorBuffer == 0 )
				glGenBuffers(1, &_pathlineColorBuffer);
			glBindBuffer(GL_ARRAY_BUFFER, _pathlineColorBuffer);
			glBufferData(GL_ARRAY_BUFFER, colors.size() * sizeof(Vector4), &colors[0], GL_STATIC_DRAW);
			glBindBuffer(GL_ARRAY_BUFFER, 0);
			GetGLError();
		}
	}
	
	glBindVertexArray(0);
	GetGLError();
}

- (void) refreshTextureBuffers
{
	
}

@end
