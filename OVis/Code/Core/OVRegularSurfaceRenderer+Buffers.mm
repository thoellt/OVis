//
//	OVRegularSurfaceRenderer+Buffers.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>

// Custom Headers
#import "gl_general.h"
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVGLSLProgram.h"
#import "OVViewSettings.h"

// Local Header
#import "OVSurfaceRenderer+Buffers.h"
#import "OVRegularSurfaceRenderer+Buffers.h"

@implementation OVRegularSurfaceRenderer (Buffers)

- (void) releaseVertexBuffers
{
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	GetGLError();
	
/*	if( [[_appDelegate ensembleData] isVectorFieldAvailable] )
	{
		glDeleteBuffers(1, &_pathlineVertexBuffer);
		glDeleteBuffers(1, &_pathlineColorBuffer);
		GetGLError();
	}
*/  
	[super releaseVertexBuffers];
}

- (void) createVertexBuffers
{
    [super createVertexBuffers];
    
	EnsembleDimension *dim = _appDelegate.ensembleData.ensembleDimension;
	
	size_t vertexsize = dim->x * dim->y;
	size_t indexsize = vertexsize > 0 ? ( dim->x - 1 ) * ( dim->y - 1 ) * 6 : 0;
	_indexBufferSize = indexsize;
	
	//size_t max_side = MAX(dim->x, dim->y);
	
	float *vertices = new float[ vertexsize * 2 ];
	memset(vertices, 0, vertexsize * 2 * sizeof(float));
	GLuint *indices = new GLuint[ indexsize ];
	memset(indices, 0, indexsize * sizeof(GLuint));	
	
	for( int i = 0; i < dim->y; i++ ){
		for( int j = 0; j < dim->x; j++ ){
			
			int vtxidx = i * (int)dim->x + j;
			
			vertices[ vtxidx * 2	 ] = ( static_cast<float>(j) + 0.5f ) / dim->x;
			vertices[ vtxidx * 2 + 1 ] = ( static_cast<float>(i) + 0.5f ) / dim->y;
		}
	}
	
	for( int i = 0; i < dim->y - 1; i++ ){
		for( int j = 0; j < dim->x - 1; j++ ){
			
			int basevtxidx = i * (int)dim->x + j;
			int quadidx = i * ( (int)dim->x - 1 ) + j;
			
			indices[ quadidx * 6	 ] = basevtxidx;
			indices[ quadidx * 6 + 1 ] = basevtxidx + 1;
			indices[ quadidx * 6 + 2 ] = basevtxidx + (int)dim->x;
			
			indices[ quadidx * 6 + 3 ] = basevtxidx + 1;
			indices[ quadidx * 6 + 4 ] = basevtxidx + 1 + (int)dim->x;
			indices[ quadidx * 6 + 5 ] = basevtxidx + (int)dim->x;
		}
	}
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
	
	glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
	glBufferData(GL_ARRAY_BUFFER, vertexsize * 2 * sizeof(float), vertices, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexsize * sizeof(GLuint), indices, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	GetGLError();
	
/*	if( [[_appDelegate ensembleData] isVectorFieldAvailable] )
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

	delete [] vertices;
	delete [] indices;
    
	// Create a reference cl_mem object from GL buffer object
/*	cl_context clContext = [[_appDelegate clCompute] context];
	cl_command_queue clCommandQueue= [[_appDelegate clCompute] commandQueue];
    
	cl_int error;
	_vertexBufferCL = clCreateFromGLBuffer(clContext, CL_MEM_READ_WRITE, _vertexBuffer, &error);
	if( !_vertexBufferCL || error != CL_SUCCESS )
    {
        printf("Failed to create OpenCL buffer reference! Error code = %d.", error);
	}
	
	dispatch_sync([[_appDelegate clCompute] dispatchQueue], ^{
	
		// Acquire ownership of GL texture for OpenCL Image
		cl_int error = clEnqueueAcquireGLObjects(clCommandQueue, 1, &_vertexBufferCL, 0, 0, 0);
		if( error != CL_SUCCESS )
		{
			printf("Failed to acquire OpenGL buffer reference! Error code = %d.", error);
		}

		size_t workgroup_size;
		gcl_get_kernel_block_workgroup_info((__bridge void *)(test_kernel),
											CL_KERNEL_WORK_GROUP_SIZE,
											sizeof(workgroup_size), &workgroup_size, NULL);
		
		cl_ndrange range = { 1, {0, 0, 0}, {102400, 0, 0}, {workgroup_size, 0, 0} };
		
		test_kernel(&range, (cl_uint)(vertexsize * 2), (cl_float*)_vertexBufferCL);
		
		// Release ownership of GL texture for OpenCL Image
		error = clEnqueueReleaseGLObjects(clCommandQueue, 1, &_vertexBufferCL, 0, 0, 0);
		if( error != CL_SUCCESS )
		{
			printf("Failed to release OpenGL buffer reference! Error code = %d.", error);
		}

		// Force pending CL commands to get executed
		error = clFlush(clCommandQueue);
		if( error != CL_SUCCESS )
		{
			printf("Failed to flush OpenCL command queue! Error code = %d.", error);
		}
		
	});
 */
}

/*- (void) refreshVectorFieldVertexBuffer
{
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
    
    if( [[_appDelegate ensembleData] isVectorFieldAvailable] )
	{
		std::vector<Vector3> pathlines = [_appDelegate.ensembleData normalizedPathlines];
		std::vector<Vector4> colors = [_appDelegate.ensembleData pathlineColors];
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
}*/


- (void) createTextureBuffers
{
    [super createTextureBuffers];
    
	OVEnsembleData *ensemble = _appDelegate.ensembleData;
	EnsembleDimension *dim = ensemble.ensembleDimension;
	
	if( [ensemble isVectorFieldAvailable] )
	{
        if( _noiseTexture == 0 )
            glGenTextures(1, &_noiseTexture);
        GetGLError();
        glBindTexture(GL_TEXTURE_2D, _noiseTexture);
        GetGLError();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        GetGLError();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        GetGLError();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        GetGLError();
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        GetGLError();
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, (int)dim->x, (int)dim->y, 0, GL_RED, GL_FLOAT, NULL);
        GetGLError();
        glBindTexture(GL_TEXTURE_2D, 0);
        GetGLError();
        
		if( _vectorTexture == 0 )
			glGenTextures(1, &_vectorTexture);
		GetGLError();
		glBindTexture(GL_TEXTURE_2D, _vectorTexture);
		GetGLError();
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		GetGLError();
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		GetGLError();
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		GetGLError();
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		GetGLError();
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, (int)dim->x, (int)dim->y, 0, GL_RGB, GL_FLOAT, NULL);
		GetGLError();
		glBindTexture(GL_TEXTURE_2D, 0);
		GetGLError();
        
        if( _colormapTexture[1] == 0 )
            glGenTextures(1, &_colormapTexture[1]);
        GetGLError();
        glBindTexture(GL_TEXTURE_1D, _colormapTexture[1]);
        GetGLError();
        glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        GetGLError();
        glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        GetGLError();
        glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        GetGLError();
        glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        GetGLError();
        glTexImage1D(GL_TEXTURE_1D, 0, GL_RGB, 11, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
        GetGLError();
        glBindTexture(GL_TEXTURE_1D, 0);
        GetGLError();
	}
}

- (void) refreshTextureBuffers
{
	[super refreshTextureBuffers];
    
	if( [[_appDelegate ensembleData] isVectorFieldAvailable] ){
        
        [self refreshFlowColormapTextureBuffer];
        [self refreshVectorFieldTextureBuffers];
    }
}

- (void) refreshFlowColormapTextureBuffer
{
	assert( _colormapTexture[1] != 0 );
	
	OVColormap *colormap = [_viewSettings activeColormapForPathline];
	
	if( !colormap ) return;
	
	glBindTexture(GL_TEXTURE_1D, _colormapTexture[1]);
	GetGLError();
	glTexSubImage1D(GL_TEXTURE_1D, 0, 0, 11, GL_RGB, GL_UNSIGNED_BYTE, [colormap colormap]);
	GetGLError();
	glBindTexture(GL_TEXTURE_1D, 0);
	GetGLError();
}

- (void) refreshVectorFieldTextureBuffers
{
	assert( _noiseTexture != 0 );
	
	OVEnsembleData *ensemble = _appDelegate.ensembleData;
	EnsembleDimension *dim = [ensemble ensembleDimension];
	
	if( dim->x < 1 || dim->y < 1 ) return;
	
	size_t imageSize = dim->x * dim->y;
	float* noiseField = new float[ imageSize ];
	
	for( int i = 0; i < imageSize; i++ )
	{
	    float random = arc4random_uniform(1001) * 0.001f;
		noiseField[ i ] = random;
	}
	
	glBindTexture(GL_TEXTURE_2D, _noiseTexture);
	GetGLError();
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (int)dim->x, (int)dim->y, GL_RED, GL_FLOAT, noiseField);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, 0);
	GetGLError();
	
	delete[] noiseField;

	assert( _vectorTexture != 0 );
	
	float *vectorField = new float[ 3 * imageSize ];
	float *u = [ensemble uData];
	float *v = [ensemble vData];
	
	int t = [ensemble timeSingleId], m = [ensemble memberSingleId], z = 0;
	size_t offset = z * imageSize + m * imageSize * dim->z + t * imageSize * dim->z * dim->m;
	for( int i = 0; i < imageSize; i++ )
	{
		size_t index = offset + i;
		vectorField[ 3 * i     ] = u[index];
		vectorField[ 3 * i + 1 ] = v[index];
		vectorField[ 3 * i + 2 ] = 0.0f;
	}
	
	glBindTexture(GL_TEXTURE_2D, _vectorTexture);
	GetGLError();
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, (int)dim->x, (int)dim->y, GL_RGB, GL_FLOAT, vectorField);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, 0);
	GetGLError();
	
	delete[] vectorField;
}


@end
