//
//  OVEnsembleData+Pathlines.mm
//

// System Headers
#import	<vector>

// Custom Headers
#import "OVColormap.h"
#import "OVViewSettings.h"
#import "OVPathlineRenderer.h"

#import "OVGLContextManager.h"
#import "gl_general.h"

// Local Header
#import "OVEnsembleData+Pathlines.h"

//#define _M 25
//#define _T 10

@implementation OVEnsembleData (Pathlines)

- (void) computePathlineFromX: (int) x Y:(int) y Z:(int) z
{
    // TODO: z
    _pathlineStartX = x;
    _pathlineStartY = y;
    _pathlineStartZ = z;
    
    [self computePathline];
}

- (void) computePathline
{
    _normalizedPathlines.clear();
    _pathlineColors.clear();
    
    //[self computePathlineBruteForce];
    [self computePathlineBinned];
    
    [self renderPathlines];
    
    [_appDelegate refreshGLBuffers:ViewId3D];
}

- (void) computePathlineBruteForce
{
    int x = _pathlineStartX;
    int y = _pathlineStartY;
    int z = _pathlineStartZ;
    
	Vector3 position = {.x = static_cast<float>(x), .y = static_cast<float>(y), .z = static_cast<float>(z)};
		
	// Euler
	int eulerIntegration = 1;
	if( eulerIntegration ){
		
		for( int member = 0; member < _ensembleDimension->m; member++ )
		{
			[self advancePathlineFromX:position.x Y:position.y Z:position.z inTimestep:0 forMember:0 withStepSize:5.0];
		}
	} else { // Runge Kutta
		
/*		// while in bounds
		while( t < _ensembleDimension->t &&
			   position.x < _ensembleDimension->x && position.x >= 0 &&
			   position.y < _ensembleDimension->y && position.y >= 0 &&
			   position.z < _ensembleDimension->z && position.z >= 0 ){
			
			pathline.push_back( position );
			pathlineNorm.push_back( positionNorm );
			
			// do a half euler step
			Vector3 temp = [self advancePathlineFromX:position.x Y:position.y Z:position.z inTimestep:0 forMember:0 withStepSize:2.5];
			
			//break if vector is to small or sample seems to loop endlessly
			//if( length( tmp ) < 0.05f || streamline.size() > 500 ) break;
			
			// temporary position at halfstep
			temp.x += position.x;
			temp.y += position.y;
			temp.z += position.z;
			
			// lookup vector at halfstep
			Vector3 advanced = [self advancePathlineFromX:temp.x Y:temp.y Z:temp.z inTimestep:0 forMember:0 withStepSize:5.0];
			t++;
			
			//if( length( tmp ) < 0.1f ) break;
			
			// add vector from halfstep position to original position
			position.x += advanced.x;
			position.y += advanced.y;
			position.z += advanced.z;
			
			positionNorm.x = position.x / _ensembleDimension->x;
			positionNorm.y = position.y / _ensembleDimension->y;
			positionNorm.z = position.z / _ensembleDimension->z;
			
			pathline.push_back( position );
			pathlineNorm.push_back( positionNorm );
		}
*/	}
	
	//_normalizedPathlines.push_back(pathlineNorm);
}

- (void) advancePathlineFromX: (float) x Y:(float) y Z:(float) z inTimestep:(int) t forMember: (int) m withStepSize: (float) s
{
	if( t >= _ensembleDimension->t ) return;
	
	Vector3 intPosition = { .x = static_cast<float>(static_cast<int>(x+0.5)),
						 .y = static_cast<float>(static_cast<int>(y+0.5)),
						 .z = static_cast<float>(static_cast<int>(z+0.5))};
	
	//vec2 frac = { pos.x - (int)(pos.x), pos.y - (int)(pos.y) };
	
	Vector3 result = { .x = 0.f, .y = 0.f, .z = 0.f };
	Vector3 normResult = { .x = 0.f, .y = 0.f, .z = 0.f };
    
	Vector4 color = { .x = 1.f, .y = 0.f, .z = 0.f, .w = 0.02f };
	
	if( intPosition.x < _ensembleDimension->x && intPosition.x >= 0 &&
	    intPosition.y < _ensembleDimension->y && intPosition.y >= 0 &&
	    intPosition.z < _ensembleDimension->z && intPosition.z >= 0 )
	{
		normResult.x = x / _ensembleDimension->x;
		normResult.y = y / _ensembleDimension->y;
		//normResult.z = z / _ensembleDimension->z;
		normResult.z = 0.01f;
		
        _normalizedPathlines.push_back(normResult);
        _pathlineColors.push_back(color);
		
		//float weight[ 4 ] = { (1.0 - frac.x)*(1.0 - frac.y), (frac.x)*(1.0 - frac.y), (1.0 - frac.x)*(frac.y), (frac.x)*(frac.y) };
			
		size_t idx = (size_t)intPosition.x
				   + (size_t)intPosition.y * _ensembleDimension->x
				   + (size_t)intPosition.z * _ensembleDimension->x * _ensembleDimension->y
                   + (size_t)m			   * _ensembleDimension->x * _ensembleDimension->y * _ensembleDimension->z;
//				   + (size_t)t			   * _ensembleDimension->x * _ensembleDimension->y * _ensembleDimension->z * _ensembleDimension->m;
		
		float u = _uData[idx];
		float v = _vData[idx];
	
		//vec3 val[ 4 ];
		//val[ 0 ] = vector_array[ idx ];
		//val[ 1 ] = vector_array[ idx + 1 ];
		//val[ 2 ] = vector_array[ idx + vol_dim[ 0 ] ];
		//val[ 3 ] = vector_array[ idx + vol_dim[ 0 ] + 1 ];
		
		//result.x = ( weight[ 0 ] * val[ 0 ].x + weight[ 1 ] * val[ 1 ].x + weight[ 2 ] * val[ 2 ].x + weight[ 3 ] * val[ 3 ].x ) * step_size;
		//result.y = ( weight[ 0 ] * val[ 0 ].y + weight[ 1 ] * val[ 1 ].y + weight[ 2 ] * val[ 2 ].y + weight[ 3 ] * val[ 3 ].y ) * step_size;
		
		result.x = u * s;
		result.y = v * s;
		
		result.x += x;
		result.y += y;
		//result.z += z
		result.z += 0.0f;
		
		// scale
		normResult.x = result.x / _ensembleDimension->x;
		normResult.y = result.y / _ensembleDimension->y;
		//normResult.z = result.z / _ensembleDimension->z;
		normResult.z = 0.01f;
		
		_normalizedPathlines.push_back(normResult);
        _pathlineColors.push_back(color);
        
		t++;
		
		for( int member = 0; member < _ensembleDimension->m; member++ )
		{
			[self advancePathlineFromX:result.x Y:result.y Z:result.z inTimestep:t forMember:member withStepSize:s];
		}
	}
}

- (void) computePathlineBinned
{
    int x = _pathlineStartX;
    int y = _pathlineStartY;
    int z = _pathlineStartZ;
    
    // TODO: 3D
    z = 0;
    
	int minM = _memberShowSingle ? _memberSingleId : _memberRangeMin;
	int maxM = _memberShowSingle ? _memberSingleId : _memberRangeMax;
    
    int scale = _pathlineResolution;
    float alpha = _pathlineAlphaScale;
    
    float stepsPerCycle = _pathlinepPogressionFactor;
    
    // TODO real grid res
    float gridResInMeters = 11000.0 / scale;
    float cycleInSeconds = _assimilationCycleLength * 3600.0;
    
    // roughly scale to 1 grid cell per integration step
    float stepSize = (cycleInSeconds / gridResInMeters) / stepsPerCycle;
    
    size_t dX = _ensembleDimension->x;
    size_t dY = _ensembleDimension->y;
    
    size_t dimX = dX * scale;
    size_t dimY = dY * scale;
    
    size_t mapSize = dimX * dimY;
    
    float* inputMap = new float[mapSize];
    float* accumulationMap = new float[mapSize];
    
    memset(inputMap, 0, mapSize * sizeof(float));
    memset(accumulationMap, 0, mapSize * sizeof(float));
    
    inputMap[ x * scale + y * scale * dimX + z * scale * dimX * dimY ] = 1.0f;
    
    OVViewSettings *viewSettings = [_appDelegate viewSettings];
    OVColormap *colormap = [viewSettings colormapAtIndex:[viewSettings numColormaps] - 1];
    
    for( int t = _timeRangeMin; t <= _timeRangeMax; t++ )
    {
        // advance all positions
        for( y = 0; y < dimY; y++ )
        {
            for( x = 0; x < dimX; x++ )
            {
                float p = inputMap[ x + y * dimX + z * dimX * dimY ];
                
                if( p < 0.00003 ) continue;
                
                //NSLog(@"prob at [%d,%d,%d,%d]: %f.", x, y, z, t, p);
                
                RGB col = [colormap colorAtNormalizedIndex:((float)(t - _timeRangeMin)+0.5)/(float)(_timeRangeMax - _timeRangeMin + 1) discrete:NO];
                Vector4 color = { .x = static_cast<float>(col.r/255.0),
                                  .y = static_cast<float>(col.g/255.0),
                                  .z = static_cast<float>(col.b/255.0),
                                  .w = MIN( 1.0f, alpha*p )//static_cast<float>(sqrt(p))
                                };
                
                p /= (float)(maxM - minM + 1);
                
                for( int m = minM; m <= maxM; m++ )
                {
                    //NSLog(@"tracing member %d", m);
                    
                    Vector3 p0 = { .x = static_cast<float>(x), .y = static_cast<float>(y), .z = 0.0f };
                    Vector3 p1 = { .x = static_cast<float>(x), .y = static_cast<float>(y), .z = 0.0f };
                    
                    BOOL earlyOut = NO;
                    
                    for( int s = 0; s < stepsPerCycle - 1; s++ )
                    {
                        //NSLog(@"Step %d.",s);
                        Vector2 velocity = [self velocityForX:p0.x/scale
                                                            Y:p0.y/scale
                                                            Z:p0.z
                                                   inTimestep:t
                                                    forMember:m];
                        
                        if( velocity.x > 9998.0 )
                        {
                            earlyOut = YES;
                            break;
                        }
                        
                        p1.x = p0.x + (velocity.x * stepSize);
                        p1.y = p0.y + (velocity.y * stepSize);
                        
                       // NSLog(@"P0 = [%f,%f], P1 = [%f,%f], velocity = [%f,%f] with stepSize  %f.", p0.x, p0.y, p1.x, p1.y, velocity.x, velocity.y, stepSize);

                        
                        Vector3 p0Norm = { .x = (float)p0.x/dimX, .y = (float)p0.y/dimY, .z = p0.z };
                        Vector3 p1Norm = { .x = (float)p1.x/dimX, .y = (float)p1.y/dimY, .z = p1.z };
                        
                        _normalizedPathlines.push_back(p0Norm);
                        _normalizedPathlines.push_back(p1Norm);
                        
                        _pathlineColors.push_back(color);
                        _pathlineColors.push_back(color);
                        
                        p0.x = p1.x;
                        p0.y = p1.y;
                    }
                    
                    if( earlyOut ) continue;
                    
                    Vector2 velocity = [self velocityForX:p0.x/scale
                                                        Y:p0.y/scale
                                                        Z:p0.z
                                               inTimestep:t
                                                forMember:m];
                    
                    if( velocity.x > 9998.0 ) continue;
                    
                    p1.x = (int)(p0.x + (velocity.x * stepSize) + 0.5);
                    p1.y = (int)(p0.y + (velocity.y * stepSize) + 0.5);
                    
                    Vector3 p0Norm = { .x = (float)p0.x/dimX, .y = (float)p0.y/dimY, .z = p0.z };
                    Vector3 p1Norm = { .x = (float)p1.x/dimX, .y = (float)p1.y/dimY, .z = p1.z };
                    
                    _normalizedPathlines.push_back(p0Norm);
                    _normalizedPathlines.push_back(p1Norm);
                    
                    _pathlineColors.push_back(color);
                    _pathlineColors.push_back(color);
                    
                    int finalX = (int)(p1.x);
                    int finalY = (int)(p1.y);
                    
                    if( finalX >= 0 && finalX < dimX && finalY >= 0 && finalY < dimY )
                    {
                        accumulationMap[finalX + finalY * dimX] += p;
                    }
                }
            }
        }
        
        float* tmp = inputMap;
        inputMap = accumulationMap;
        accumulationMap = tmp;
        
        memset(accumulationMap, 0, mapSize * sizeof(float));
    }
}

-(Vector2) velocityForX: (float) x  Y:(float) y Z:(float) z inTimestep:(int) t forMember: (int) m
{
    Vector2 velocity = { .x = 9999.0, .y = 9999.0 };

    size_t dX = _ensembleDimension->x;
    size_t dY = _ensembleDimension->y;
    size_t dZ = _ensembleDimension->z;
    size_t dM = _ensembleDimension->m;

    if( (int)x + 1 >= dX || (int)y + 1 >= dY ) return velocity;

    size_t idx = (int)x + (int)y * dX + (int)z * dX * dY + m * dX * dY * dZ + t * dX * dY * dZ * dM;

    float u[4] = { _uData[idx], _uData[idx + 1], _uData[idx + dX], _uData[idx + 1 + dX] };
    float v[4] = { _vData[idx], _vData[idx + 1], _vData[idx + dX], _vData[idx + 1 + dX] };

    for( int i = 0; i < 4; i++ )
    {
        if( u[i] > 9999.0 || v[i] > 9999.0 ) return velocity;
    }

    float fracX = x - (int)x;
    float fracY = y - (int)y;

    velocity.x = (1.0 - fracY) * ((1.0 - fracX) * u[0] + fracX * u[1]) + fracY * ((1.0 - fracX) * u[2] + fracX * u[3]);
    velocity.y = (1.0 - fracY) * ((1.0 - fracX) * v[0] + fracX * v[1]) + fracY * ((1.0 - fracX) * v[2] + fracX * v[3]);

    return velocity;
}

- (void) renderPathlines
{
    NSOpenGLContext* glContext = [[_appDelegate glContextManager] getGLContextForView:ViewId3D];
    
    [glContext makeCurrentContext];
	CGLLockContext((CGLContextObj)[glContext CGLContextObj]);
    
    if( !_pathlineRenderer ) _pathlineRenderer = [[OVPathlineRenderer alloc] init];
    
    [_pathlineRenderer refreshData];
    
    // TODO: get max hardware buffer size
    int oversamplingFactor = 10;//4096 / MAX( _ensembleDimension->x, _ensembleDimension->y );
    NSLog(@"Oversampling Factor = %d.", oversamplingFactor );
    //int oversamplingFactor = 8;
    
    int width = (int)_ensembleDimension->x * oversamplingFactor;
    int height = (int)_ensembleDimension->y * oversamplingFactor;
    
    GLuint FBO = 0;
    glGenFramebuffers(1, &FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, FBO);
    GetGLError();
    
    glViewport(0, 0, width, height);
    GetGLError();
    
    GLuint firstPassTexture = 0;
    
    glGenTextures(1, &firstPassTexture);
    GetGLError();
    
    //glBindTexture(GL_TEXTURE_2D_MULTISAMPLE, _pathlineTexture);
    glBindTexture(GL_TEXTURE_2D, firstPassTexture);
    GetGLError();
    
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGBA, width, height, 0 ,GL_RGBA, GL_FLOAT, 0);
    //glTexImage2DMultisample(GL_TEXTURE_2D_MULTISAMPLE, 8,GL_RGBA, (int)_ensembleDimension->x*oversamplingFactor, (int)_ensembleDimension->y*oversamplingFactor, 0);
    GetGLError();
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    GetGLError();
    
    // Set "renderedTexture" as our colour attachement #0
    glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, firstPassTexture, 0);
    
    // Set the list of draw buffers.
    GLenum DrawBuffers[1] = {GL_COLOR_ATTACHMENT0};
    glDrawBuffers(1, DrawBuffers); // "1" is the size of DrawBuffers
    GetGLError();
    
    assert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE );
    
    //glEnable( GL_MULTISAMPLE );
    
    glEnable( GL_BLEND );
    glBlendFunc(GL_ONE, GL_ONE);
    
    [_pathlineRenderer draw];
    
    glDisable( GL_BLEND );
    //glDisable( GL_MULTISAMPLE );
    
    glDeleteFramebuffers(1, &FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    GetGLError();
    
    
    glGenFramebuffers(1, &FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, FBO);
    GetGLError();
    
    glViewport(0, 0, width, height);
    GetGLError();
    
    if( !_pathlineTexture ) glGenTextures(1, &_pathlineTexture);
    GetGLError();
    
    glBindTexture(GL_TEXTURE_2D, _pathlineTexture);
    GetGLError();
    
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGBA, width, height, 0 ,GL_RGBA, GL_FLOAT, 0);
    GetGLError();
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    GetGLError();
    
    // Set "renderedTexture" as our colour attachement #0
    glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, _pathlineTexture, 0);
    
    // Set the list of draw buffers.
    DrawBuffers[0] = GL_COLOR_ATTACHMENT0;
    glDrawBuffers(1, DrawBuffers); // "1" is the size of DrawBuffers
    GetGLError();
    
    assert( glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE );
    
    [_pathlineRenderer filterTexture:firstPassTexture withWidth:width Height:height];
    
    glDeleteFramebuffers(1, &FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    GetGLError();
    
    glDeleteTextures(1, &firstPassTexture);
    
    
	CGLUnlockContext((CGLContextObj)[glContext CGLContextObj]);
    
    [[_appDelegate viewSettings] setIsPathlineTraceAvailable:YES];
}

@end
