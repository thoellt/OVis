//
//	OVSurfaceRenderer+Buffers.mm
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

@implementation OVSurfaceRenderer (Buffers)

- (void) releaseBuffers
{
	[self releaseVertexBuffers];
	[self releaseTextureBuffers];
}

- (void) releaseVertexBuffers
{
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
	
	glDeleteBuffers(1, &_vertexBuffer);
	GetGLError();
	
	glDeleteBuffers(1, &_legendVertexBuffer);
	GetGLError();
	
	glDeleteBuffers(1, &_legendColorBuffer);
	GetGLError();
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	GetGLError();
	
	glDeleteBuffers(1, &_indexBuffer);
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
	[self createTextureBuffers];
}

- (void) createVertexBuffers
{
    if( _vertexArrayObject == 0 )
		glGenVertexArrays(1, &_vertexArrayObject);
	glBindVertexArray(_vertexArrayObject);
	GetGLError();
    
    if( _vertexBuffer == 0 )
		glGenBuffers(1, &_vertexBuffer);
    
    if( _indexBuffer == 0 )
		glGenBuffers(1, &_indexBuffer);
	
	if( _legendVertexBuffer == 0 )
		glGenBuffers(1, &_legendVertexBuffer);
	
	if( _legendColorBuffer == 0 )
		glGenBuffers(1, &_legendColorBuffer);
    
    glBindBuffer(GL_ARRAY_BUFFER, _legendVertexBuffer);
	GetGLError();
	glBufferData(GL_ARRAY_BUFFER, 48 * sizeof(float), NULL, GL_DYNAMIC_DRAW);
    GetGLError();
    glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
    
    glBindBuffer(GL_ARRAY_BUFFER, _legendColorBuffer);
	GetGLError();
	glBufferData(GL_ARRAY_BUFFER, 96 * sizeof(float), NULL, GL_DYNAMIC_DRAW);
    GetGLError();
    glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
	
	glBindVertexArray(0);
	GetGLError();
    
    [self refreshLegendVertexBuffer];
}

-(void) refreshLegendVertexBuffer
{
    if( ![_viewSettings isColormapLegendVisibleForView:_viewId] ) return;
    
    [_viewSettings setColormapLegendVisible:NO forView:_viewId];
    
    assert( _vertexArrayObject );
    
    int colMapSize = [[_viewSettings activeColormapForView:_viewId] size];
    BOOL isDiscrete = [_viewSettings isColormapDiscreteForView:_viewId];
    
    int numQuads = isDiscrete ? colMapSize : colMapSize - 1;
    assert( numQuads < 12 );
    
    float *vertices = new float[ ( numQuads + 1 ) * 4 ];
	memset(vertices, 0, ( numQuads + 1 ) * 4  * sizeof(float));
    
    float legendHeight = 130.0;
    
    float boxWidth = 30.0;
    float boxHeight = legendHeight / numQuads;
    
    float offsetRight = 15.0;
    float offsetTop = 25.0;
    
    for( int i = 0; i <= numQuads; i++ )
    {
        vertices[ 4 * i + 0 ] = ( _viewWidth  - (offsetRight +     boxWidth ) );
        vertices[ 4 * i + 1 ] = ( _viewHeight - (offsetTop   + i * boxHeight) );
        
        vertices[ 4 * i + 2 ] = ( _viewWidth  - (offsetRight                ) );
        vertices[ 4 * i + 3 ] = ( _viewHeight - (offsetTop   + i * boxHeight) );
    }

    assert( _legendVertexBuffer );
    
	glBindBuffer(GL_ARRAY_BUFFER, _legendVertexBuffer);
	GetGLError();
    glBufferSubData(GL_ARRAY_BUFFER, 0, ( numQuads + 1 ) * 4 * sizeof(float), vertices);
    GetGLError();
    glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
	
	delete[] vertices;
    
    if (!isDiscrete) [self refreshLegendColorBuffer];
    
    [_viewSettings setColormapLegendVisible:YES forView:_viewId];
}

-(void) refreshLegendColorBuffer
{    
    assert( _vertexArrayObject );
    
    OVColormap* colormap = [_viewSettings activeColormapForView:_viewId];
    
    int colMapSize = [colormap size];
    assert( colMapSize < 12 );
    
    int bufferSize = ( colMapSize+1 ) * 8;
    
    float *colors = new float[ bufferSize ];
	memset(colors, 0, bufferSize  * sizeof(float));
    
    for( int i = 0; i < colMapSize; i++ )
    {
        RGB col = [colormap colorAtIndex:colMapSize-1-i];
        
        colors[ 8 * i + 0 ] = col.r / 255.0;
        colors[ 8 * i + 1 ] = col.g / 255.0;
        colors[ 8 * i + 2 ] = col.b / 255.0;
        colors[ 8 * i + 3 ] = 1.0;
        
        colors[ 8 * i + 4 ] = col.r / 255.0;
        colors[ 8 * i + 5 ] = col.g / 255.0;
        colors[ 8 * i + 6 ] = col.b / 255.0;
        colors[ 8 * i + 7 ] = 1.0;
    }
    
    assert( _legendColorBuffer );
    
	glBindBuffer(GL_ARRAY_BUFFER, _legendColorBuffer);
	GetGLError();
    glBufferSubData(GL_ARRAY_BUFFER, 0, bufferSize * sizeof(float), colors);
    GetGLError();
    glBindBuffer(GL_ARRAY_BUFFER, 0);
	GetGLError();
	
	delete [] colors;
}


- (void) createTextureBuffers
{
	OVEnsembleData *ensemble = _appDelegate.ensembleData;
	EnsembleDimension *dim = ensemble.ensembleDimension;
    
    int w = [ensemble isStructured]  ? (int)dim->x : (int)dim->texX;
    int h = [ensemble isStructured]  ? (int)dim->y : (int)dim->texY;

	
	if( _surfaceTexture == 0 )
		glGenTextures(1, &_surfaceTexture);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _surfaceTexture);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	GetGLError();
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, w, h, 0, GL_RED, GL_FLOAT, NULL);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, 0);
	GetGLError();
	
	if( _statisticTexture[0] == 0 )
		glGenTextures(1, &_statisticTexture[0]);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _statisticTexture[0]);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	GetGLError();
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, w, h, 0, GL_RED, GL_FLOAT, NULL);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, 0);
	GetGLError();
	
	if( _statisticTexture[1] == 0 )
		glGenTextures(1, &_statisticTexture[1]);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, _statisticTexture[1]);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	GetGLError();
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	GetGLError();
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, w, h, 0, GL_RED, GL_FLOAT, NULL);
	GetGLError();
	glBindTexture(GL_TEXTURE_2D, 0);
	GetGLError();
	
	if( _colormapTexture[0] == 0 )
		glGenTextures(1, &_colormapTexture[0]);
	GetGLError();
	glBindTexture(GL_TEXTURE_1D, _colormapTexture[0]);
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

- (void) refreshTextureBuffers
{
	[self refreshColormapTextureBuffer];
	[self refreshStatisticTextureBuffer];
    [self refreshSecondaryStatisticTextureBuffer];
	[self refreshSurfaceTextureBuffer];
}

- (void) refreshColormapTextureBuffer
{
	assert( _colormapTexture[0] != 0 );
	
	OVColormap *colormap = [_viewSettings activeColormapForView:_viewId];
	
	if( !colormap ) return;
	
	glBindTexture(GL_TEXTURE_1D, _colormapTexture[0]);
	GetGLError();
	glTexSubImage1D(GL_TEXTURE_1D, 0, 0, 11, GL_RGB, GL_UNSIGNED_BYTE, [colormap colormap]);
	GetGLError();
	glBindTexture(GL_TEXTURE_1D, 0);
	GetGLError();
}

- (void) refreshStatisticTextureBuffer
{
	assert( _statisticTexture[0] != 0 );
	
	OVEnsembleData *ensemble = _appDelegate.ensembleData;
	EnsembleDimension *dim = [ensemble ensembleDimension];
    
    int w = [ensemble isStructured]  ? (int)dim->x : (int)dim->texX;
    int h = [ensemble isStructured]  ? (int)dim->y : (int)dim->texY;
	
	if( w < 1 || h < 1 ) return;
	
	float *data = [ensemble activePropertyForView:_viewId normalized:YES];
	
	if( data ){
	
		glBindTexture(GL_TEXTURE_2D, _statisticTexture[0]);
		GetGLError();
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_RED, GL_FLOAT, data);
		GetGLError();
		glBindTexture(GL_TEXTURE_2D, 0);
		GetGLError();
	}
}

- (void) refreshSecondaryStatisticTextureBuffer
{
	assert( _statisticTexture[1] != 0 );
	
	OVEnsembleData *ensemble = _appDelegate.ensembleData;
	EnsembleDimension *dim = [ensemble ensembleDimension];
    
    int w = [ensemble isStructured]  ? (int)dim->x : (int)dim->texX;
    int h = [ensemble isStructured]  ? (int)dim->y : (int)dim->texY;
	
	if( w < 1 || h < 1 ) return;
	
	float *data = [ensemble activeNoisePropertyForView:_viewId normalized:YES];
	
	if( data ){
        
		glBindTexture(GL_TEXTURE_2D, _statisticTexture[1]);
		GetGLError();
		glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_RED, GL_FLOAT, data);
		GetGLError();
		glBindTexture(GL_TEXTURE_2D, 0);
		GetGLError();
	}
}

- (void) refreshSurfaceTextureBuffer
{
	assert( _surfaceTexture != 0 );
	
	OVEnsembleData *ensemble = _appDelegate.ensembleData;
	EnsembleDimension *dim = [ensemble ensembleDimension];
    
    int w = [ensemble isStructured]  ? (int)dim->x : (int)dim->texX;
    int h = [ensemble isStructured]  ? (int)dim->y : (int)dim->texY;
	
	if( w < 1 || h < 1 ) return;
	
	float *data = [ensemble activeSurfaceForView:ViewId3D normalized:NO];
	
	if( data )
	{
        glBindTexture(GL_TEXTURE_2D, _surfaceTexture);
        GetGLError();
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_RED, GL_FLOAT, data);
        GetGLError();
        glBindTexture(GL_TEXTURE_2D, 0);
        GetGLError();
    }
}

@end
