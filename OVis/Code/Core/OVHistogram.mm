//
//  OVHistogram.mm
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "general.h"

#import "OVHistogram.h"

@implementation OVHistogram

@synthesize data = _data;
@synthesize size = _size;
@synthesize isDirty = _isDirty;

@synthesize kde = _kde;
@synthesize kdeSize = _kdeSize;
@synthesize isKdeDirty = _isKdeDirty;


- (id) init
{
	self = [super init];
	
	if( self )
    {
        _data = nil;
        _size = 0;
        _isDirty = YES;
        
        _kde = nil;
        _kdeSize = 0;
         _isKdeDirty = YES;
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
        
        if( _kde )
        {
            delete[] _kde;
            _kde = nil;
        }
        _size = size;
        _kdeSize = size;
    }
    
    if( !_data )
    {
        _data = new int[_size];
    }
    
    if( !_kde )
    {
        _kde = new float[_kdeSize];
    }
    
    memset( _data, 0, _size * sizeof(int) );
    memset( _kde, 0, _size * sizeof(float) );
}

- (void) dealloc
{
    delete[] _data;
    delete[] _kde;
}

@end
