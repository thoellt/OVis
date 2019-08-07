//
//	OVTimeSeriesRenderer+Buffers.mm
//
#define GL_SILENCE_DEPRECATION

// System Headers
#import <OpenGL/gl3.h>
#import <OpenGL/OpenGL.h>

// Custom Headers
#import "gl_general.h"
#import "OVColormap.h"
#import "OVEnsembleData.h"
#import "OVEnsembleData+Platforms.h"
#import "OVEnsembleData+Statistics.h"
#import "OVGLSLProgram.h"
#import "OVOffShorePlatform.h"
#import "OVViewSettings.h"
#import "OVVariable1D.h"

// Local Header
#import "OVTimeSeriesRenderer+Buffers.h"

@implementation OVTimeSeriesRenderer (Buffers)

- (void) releaseBuffers
{
	[self releaseVertexBuffers];
}

- (void) releaseVertexBuffers
{
	glBindBuffer(GL_ARRAY_BUFFER, 0);

    GetGLError();
    
    glDeleteBuffers(1, &_glyphVertexBuffer);
    GetGLError();
    
    glDeleteBuffers(1, &_boxplotVertexBuffer);
    GetGLError();
	
	glDeleteBuffers(1, &_linesVertexBuffer);
	GetGLError();
	
	glBindVertexArray(0);
	GetGLError();
	
	glDeleteVertexArrays(1, &_vertexArrayObject);
	GetGLError();
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
	
	glBindVertexArray(0);
	GetGLError();
	
	[self refreshVertexBuffers:YES];
}

- (void) refreshBuffers:(BOOL) includeGUI
{
	[self refreshVertexBuffers:includeGUI];
}

- (void) refreshVertexBuffers:(BOOL) includeGUI
{
	OVEnsembleData *ensemble = _appDelegate.ensembleData;
	
    NSInteger numTimeSteps = [ensemble numTimeStepsWithStride];//([ensemble timeRangeMax] - [ensemble timeRangeMin] + 1) / [ensemble timeStepStride];
    size_t glyphVertexSize = numTimeSteps * 2 * 2 * ensemble.histogramBins; // 2 vertices per bin, 2 sides
	
	float *glyphVertices = new float[ glyphVertexSize * 2 ];
    memset(glyphVertices, 0, glyphVertexSize * 2 * sizeof(float));
    
    size_t boxplotVertexSize = numTimeSteps * ( 3 + 2 ) * 2; // 3 lines (90 percentile, median, 10 percentile) + 2 vertices per t for background, 2 sides
    
    float *boxplotVertices = new float[ boxplotVertexSize * 2 ];
    memset(boxplotVertices, 0, boxplotVertexSize * 2 * sizeof(float));
	
	if( _riskColors ) delete[] _riskColors;
	_riskColors = new RGB[ numTimeSteps * 2 ];
    
    BOOL useRisk = YES;
    OVColormap *colormap = [_viewSettings activeColormapForView:ViewIdTS];
    BOOL discreteColormap = [_viewSettings isColormapDiscreteForView:ViewIdTS];
	
	NSString *activeItemTitle = [_appDelegate.viewSettings leftGlyphActiveItem];
	OVOffShorePlatform *p = nil;

	if( [activeItemTitle isEqualToString:@"Active"] )
		p = [ensemble getActivePlatform];
	else
		p = [ensemble getPlatformWithName:activeItemTitle];
    
    if( p )
    {        
        [ensemble updateKdesTimeSeriesAtLat:p.latitude Lon:p.longitude forGlyphSide:0 forVariable:[_viewSettings leftGlyphActiveVariable]];
        float *kdes = [ensemble kdesForGlyphSide:0];
        
        float *medians = [ensemble percentiles:5 ForGlyphSide:0];
        float *lowerPercentile = [ensemble percentiles:1 ForGlyphSide:0];
        float *upperPercentile = [ensemble percentiles:9 ForGlyphSide:0];
        float *minPercentile = [ensemble percentiles:0 ForGlyphSide:0];
        float *maxPercentile = [ensemble percentiles:10 ForGlyphSide:0];
        
        [ensemble updateRisksTimeSeriesAtLat:p.latitude Lon:p.longitude forGlyphSide:0];
        float *risks = [ensemble risksForGlyphSide:0];
        
        if( !colormap )
        {
            colormap = [_viewSettings colormapAtIndex:6];
            useRisk = NO;
        }
        
        // left side
        for( int t = 0; t < numTimeSteps; t++ )
        {
            int kdeOffset = t * ensemble.histogramBins;
            int vertexOffset = kdeOffset * 4;
            float rightX = (float)(t+0.5)/numTimeSteps;
            for( int k = 0; k < ensemble.histogramBins; k++ )
            {
                float leftX = (t + 0.5 - kdes[ kdeOffset + k ] * 0.475) / numTimeSteps;
                float y = (float)k / (ensemble.histogramBins - 1);
                
                glyphVertices[ vertexOffset + k * 4 + 0 ] = leftX;
                glyphVertices[ vertexOffset + k * 4 + 1 ] = y;
                glyphVertices[ vertexOffset + k * 4 + 2 ] = rightX;
                glyphVertices[ vertexOffset + k * 4 + 3 ] = y;
            }
            
            boxplotVertices[ ( numTimeSteps * 2 * 0 ) + ( t * 2 + 0 ) ] = rightX;
            boxplotVertices[ ( numTimeSteps * 2 * 0 ) + ( t * 2 + 1 ) ] = medians[t];
            boxplotVertices[ ( numTimeSteps * 2 * 1 ) + ( t * 2 + 0 ) ] = rightX;
            boxplotVertices[ ( numTimeSteps * 2 * 1 ) + ( t * 2 + 1 ) ] = minPercentile[t];
            boxplotVertices[ ( numTimeSteps * 2 * 2 ) + ( t * 2 + 0 ) ] = rightX;
            boxplotVertices[ ( numTimeSteps * 2 * 2 ) + ( t * 2 + 1 ) ] = maxPercentile[t];
            boxplotVertices[ ( numTimeSteps * 2 * 3 ) + ( t * 4 + 0 ) ] = rightX;
            boxplotVertices[ ( numTimeSteps * 2 * 3 ) + ( t * 4 + 1 ) ] = lowerPercentile[t];
            boxplotVertices[ ( numTimeSteps * 2 * 3 ) + ( t * 4 + 2 ) ] = rightX;
            boxplotVertices[ ( numTimeSteps * 2 * 3 ) + ( t * 4 + 3 ) ] = upperPercentile[t];
            
            if( useRisk )
            {
                _riskColors[t] = [colormap colorAtNormalizedIndex:risks[t] discrete:discreteColormap];
            } else {
                _riskColors[t] = [colormap colorAtNormalizedIndex:(t+0.5)/(float)numTimeSteps discrete:NO];
            }
        }
    }
    
    activeItemTitle = [_appDelegate.viewSettings rightGlyphActiveItem];
    p = nil;

    if( [activeItemTitle isEqualToString:@"Active"] )
        p = [ensemble getActivePlatform];
    else
        p = [ensemble getPlatformWithName:activeItemTitle];
    
    if( p )
    {
        [ensemble updateKdesTimeSeriesAtLat:p.latitude Lon:p.longitude forGlyphSide:1 forVariable:[_viewSettings rightGlyphActiveVariable]];
        float* kdes = [ensemble kdesForGlyphSide:1];
        
        float *medians = [ensemble percentiles:5 ForGlyphSide:1];
        float *lowerPercentile = [ensemble percentiles:1 ForGlyphSide:1];
        float *upperPercentile = [ensemble percentiles:9 ForGlyphSide:1];
        float *minPercentile = [ensemble percentiles:0 ForGlyphSide:1];
        float *maxPercentile = [ensemble percentiles:10 ForGlyphSide:1];
        
        [ensemble updateRisksTimeSeriesAtLat:p.latitude Lon:p.longitude forGlyphSide:1];
        float* risks = [ensemble risksForGlyphSide:1];
        
        // right side
        for( int t = 0; t < numTimeSteps; t++ )
        {
            NSInteger kdeOffset = t * ensemble.histogramBins;
            NSInteger vertexOffset = (t+numTimeSteps) * ensemble.histogramBins * 4;
            float leftX = (float)(t+0.5)/numTimeSteps;
            for( int k = 0; k < ensemble.histogramBins; k++ )
            {
                float rightX = (t + 0.5 + kdes[ kdeOffset + k ] * 0.475) / numTimeSteps;
                float y = (float)k / (ensemble.histogramBins - 1);
                
                glyphVertices[ vertexOffset + k * 4 + 0 ] = leftX;
                glyphVertices[ vertexOffset + k * 4 + 1 ] = y;
                glyphVertices[ vertexOffset + k * 4 + 2 ] = rightX;
                glyphVertices[ vertexOffset + k * 4 + 3 ] = y;
            }
            
            boxplotVertices[ ( numTimeSteps * 2 * 5 ) + ( t * 2 + 0 ) ] = leftX;
            boxplotVertices[ ( numTimeSteps * 2 * 5 ) + ( t * 2 + 1 ) ] = medians[t];
            boxplotVertices[ ( numTimeSteps * 2 * 6 ) + ( t * 2 + 0 ) ] = leftX;
            boxplotVertices[ ( numTimeSteps * 2 * 6 ) + ( t * 2 + 1 ) ] = minPercentile[t];
            boxplotVertices[ ( numTimeSteps * 2 * 7 ) + ( t * 2 + 0 ) ] = leftX;
            boxplotVertices[ ( numTimeSteps * 2 * 7 ) + ( t * 2 + 1 ) ] = maxPercentile[t];
            boxplotVertices[ ( numTimeSteps * 2 * 8 ) + ( t * 4 + 0 ) ] = leftX;
            boxplotVertices[ ( numTimeSteps * 2 * 8 ) + ( t * 4 + 1 ) ] = lowerPercentile[t];
            boxplotVertices[ ( numTimeSteps * 2 * 8 ) + ( t * 4 + 2 ) ] = leftX;
            boxplotVertices[ ( numTimeSteps * 2 * 8 ) + ( t * 4 + 3 ) ] = upperPercentile[t];
            
            if( useRisk )
            {
                _riskColors[t+numTimeSteps] = [colormap colorAtNormalizedIndex:risks[t] discrete:discreteColormap];
            } else {
                _riskColors[t+numTimeSteps] = [colormap colorAtNormalizedIndex:(t+0.5)/(float)numTimeSteps discrete:NO];
            }
        }
    }
    
    if( _glyphVertexBuffer == 0 )
        glGenBuffers(1, &_glyphVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _glyphVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, glyphVertexSize * 2 * sizeof(float), glyphVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    GetGLError();
    
    if( _boxplotVertexBuffer == 0 )
        glGenBuffers(1, &_boxplotVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _boxplotVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, boxplotVertexSize * 2 * sizeof(float), boxplotVertices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    GetGLError();
	
	delete [] glyphVertices;
    glyphVertices = nil;
    
    delete [] boxplotVertices;
    boxplotVertices = nil;
	
	if( includeGUI ){
        
		size_t guiVertexSize = numTimeSteps * 2 + 14;
	
		float* guiVertices = new float[ guiVertexSize * 2 ];
		memset(guiVertices, 0, guiVertexSize * 2 * sizeof(float));
	
		// timestep indicators
		for( int t = 0; t < numTimeSteps; t++ )
		{
			float x = (t+0.5)/(float)numTimeSteps;
			guiVertices[4 * t + 0] = x; guiVertices[4 * t + 1]	= 0.0;
			guiVertices[4 * t + 2] = x; guiVertices[4 * t + 3]	= 1.0;
		}
		NSInteger offset = numTimeSteps * 4;
	
		// height indicators
		for( int i = 0; i < 5; i++ )
		{
			float y = (float)i/4.0f;
			guiVertices[offset + 4 * i + 0] = 0.0; guiVertices[offset + 4 * i + 1]	= y;
			guiVertices[offset + 4 * i + 2] = 1.0; guiVertices[offset + 4 * i + 3]	= y;
		}
		offset += 5 * 4;
	
		// left arrow
		guiVertices[offset + 0] = 0.0; guiVertices[offset + 1]	= 0.0;
		guiVertices[offset + 2] = 0.0; guiVertices[offset + 3]	= 1.0;
	
		// crit indicator
        // TODO VAR
		float *dataRange = [ensemble isLoaded] ? [ensemble dataRangeForVariable:0] : NULL;
		float absMax = dataRange ? MAX( fabsf(dataRange[0]), fabsf(dataRange[1])) : 50.0;
		float critHeight = [ensemble riskHeightIsoValue];
		critHeight = (critHeight + absMax) / (2.0 * absMax);
		guiVertices[offset + 4] = 0.0; guiVertices[offset + 5]	= critHeight;
		guiVertices[offset + 6] = 1.0; guiVertices[offset + 7]	= critHeight;
	
	
		if( _linesVertexBuffer == 0 )
			glGenBuffers(1, &_linesVertexBuffer);
		glBindBuffer(GL_ARRAY_BUFFER, _linesVertexBuffer);
		glBufferData(GL_ARRAY_BUFFER, guiVertexSize * 2 * sizeof(float), guiVertices, GL_STATIC_DRAW);
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		GetGLError();
	
		delete [] guiVertices;
		guiVertices = nil;
	}
}

@end
