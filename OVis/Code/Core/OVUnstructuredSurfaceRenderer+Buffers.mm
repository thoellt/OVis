//
//	OVUnstructuredSurfaceRenderer+Buffers.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <OpenGL/gl3.h>
#import <OpenGL/OpenGL.h>

// Custom Headers
#import "gl_general.h"
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"

// Local Header
#import "OVSurfaceRenderer+Buffers.h"
#import "OVUnstructuredSurfaceRenderer+Buffers.h"

@implementation OVUnstructuredSurfaceRenderer (Buffers)

- (void) createVertexBuffers
{
    [super createVertexBuffers];
    
	OVEnsembleData *ensemble = [_appDelegate ensembleData];
	EnsembleLonLat *lonLat = [ensemble ensembleLonLat];
	
	size_t numVertices = [ensemble numNodes];
	_indexBufferSize = [ensemble numTriangles] * 3;
	
	float latOffset = lonLat->lat_min;
	float lonOffset = lonLat->lon_min;
	float latScale = 1.0f / ABS( lonLat->lat_max - lonLat->lat_min );
	float lonScale = 1.0f / ABS( lonLat->lon_max - lonLat->lon_min );
	
	float *nodes = [ensemble nodes];
	
	float *vertices = new float[ numVertices * 2 ];
	memset(vertices, 0, numVertices * 2 * sizeof(float));
	
	for( int i = 0; i < numVertices; i++ )
	{
		//NSLog(@"x:%f, y:%f",(nodes[ i * 2 + 1 ] - lonOffset) * lonScale, (nodes[ i * 2	 ] - latOffset) * latScale );
		vertices[ i * 2	 ] = (nodes[ i * 2	 ] - lonOffset) * lonScale;
		vertices[ i * 2 + 1 ] = (nodes[ i * 2 + 1 ] - latOffset) * latScale;
	}
	
	GLuint *indices = [ensemble gridIndices];
	
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, numVertices * 2 * sizeof(float), vertices, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, _indexBufferSize * sizeof(GLuint), indices, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	GetGLError();
	
	glBindVertexArray(0);
	GetGLError();
	
	delete [] vertices;
}

@end
