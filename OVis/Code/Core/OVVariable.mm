//
//  OVVariable.mm
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "OVStatistic.h"
#import "OVHistogram.h"

#import "OVVariable.h"

@implementation OVVariable

@synthesize dimensionality = _dimensionality;

@synthesize data = _data;
@synthesize dataRange = _dataRange;

@synthesize name = _name;
@synthesize unit = _unit;

@synthesize dimension = _dimension;

@synthesize histogram = _histogram;
@synthesize mean = _mean;
@synthesize median = _median;
@synthesize maximumMode = _maximumMode;
@synthesize range = _range;
@synthesize standardDeviation = _standardDeviation;
@synthesize variance = _variance;
@synthesize risk = _risk;

- (id) init
{
	self = [super init];
	
	if( self )
    {
        _dimensionality = 0;
        
        _data = nil;
        
        _dataRange = new float[2];
        _dataRange[0] = -9999999.9;
        _dataRange[1] = 9999999.9;
        
        _dimension = new VariableDimension;
        _size = 0;
        
        _name = nil;
        _unit = nil;

        _histogram = [[OVHistogram alloc] init];
        _mean = [[OVStatistic alloc] init];
        _median = [[OVStatistic alloc] init];
        _maximumMode = [[OVStatistic alloc] init];
        _range = [[OVStatistic alloc] init];
        _standardDeviation = [[OVStatistic alloc] init];
        _variance = [[OVStatistic alloc] init];
        _risk = [[OVStatistic alloc] init];
    }
    
    return self;
}

- (void) invalidate
{
    _histogram.isDirty = YES;
    _histogram.isKdeDirty = YES;
    
    _mean.isDirty = YES;
    _median.isDirty = YES;
    _maximumMode.isDirty = YES;
    _range.isDirty = YES;
    _standardDeviation.isDirty = YES;
    _variance.isDirty = YES;
}

-(BOOL) isTimeStatic
{
    assert(_dimension);
    
    return (_dimension->t == 1);
}

-(BOOL) isMemberStatic
{
    assert(_dimension);
    
    return (_dimension->m == 1);
}

-(void) setDimensionsX:(size_t) dimX Y:(size_t) dimY Z:(size_t) dimZ M:(size_t) dimM T:(size_t) dimT
{
    assert(_dimension);
    
    _dimension->x = dimX;
    _dimension->y = dimY;
    _dimension->z = dimZ;
    _dimension->m = dimM;
    _dimension->t = dimT;
    
    _size = _dimension->x * _dimension->y * _dimension->z * _dimension->m * _dimension->t;
}

-(void) scanRange
{
    _dataRange[0] = -9999999.9;
    _dataRange[1] = 9999999.9;
    
    for( int i = 0; i < _size; i++ )
    {
        float v = _data[i];
        if( v > _dataRange[0] ) _dataRange[0] = v;
        if( v < _dataRange[1] ) _dataRange[1] = v;
    }
}


-(void) dealloc
{
    if( _data )
    {
        delete[] _data;
        _data = nil;
    }
    delete[] _dataRange;
}

@end
