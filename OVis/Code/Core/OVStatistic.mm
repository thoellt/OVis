//
//  OVStatistic.m
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "general.h"

#import "OVStatistic.h"

@implementation OVStatistic

@synthesize data = _data;
@synthesize dataNormalized = _dataNormalized;
@synthesize size = _size;
@synthesize range = _range;
@synthesize limits = _limits;
@synthesize isDirty = _isDirty;

- (id) init
{
	self = [super init];
	
	if( self )
    {
        _data = nil;
        _dataNormalized = nil;
        _size = 0;
        _range = new float[2];
        _range[0] = -999999.9;
        _range[1] = 999999.9;
        _limits = new float[2];
        _limits[0] = -999999.9;
        _limits[1] = 999999.9;
        _isDirty = YES;
    }
    
    return self;
}

- (void) rebuildDataWithSize: (size_t) size
{
    if( _size != size )
    {
        if( _data )
        {
            delete[] _data;
            _data = nil;
        }
        
        if( _dataNormalized )
        {
            delete[] _dataNormalized;
            _dataNormalized = nil;
        }
        _size = size;
    }
    
    if( !_data )
    {
        _data = new float[_size];
    }
    
    if( !_dataNormalized )
    {
        _dataNormalized = new float[_size];
    }
    
	memset( _data, 0, _size * sizeof(float) );
	memset( _dataNormalized, 0, _size * sizeof(float) );
}

- (void) normalize
{
    float scale = (_limits[0] - _limits[1]);
	if( scale != 0.0 ) scale = 1.0f/scale;
	
   dispatch_apply(_size, dispatch_get_global_queue(0, 0), ^(size_t i)
    //for( int i = 0; i < surfaceSize; i++ )
    {
        float v = ( self->_data[i] - self->_limits[1] ) * scale;
        self->_dataNormalized[i] = OVClamp(0.0f, v, 1.0f);
    }
   );
}

- (void) dealloc
{
    delete[] _data;
    delete[] _dataNormalized;
    delete[] _range;
    delete[] _limits;
}

@end
