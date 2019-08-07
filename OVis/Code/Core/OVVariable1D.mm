//
//  OVVariable1D.mm
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "OVStatistic.h"
#import "OVHistogram.h"

#import "OVVariable1D.h"

@implementation OVVariable1D

@synthesize position = _position;
@synthesize identifier = _identifier;

- (id) init
{
	self = [super init];
	
	if( self )
    {
        _dimensionality = 1;
        
        _position.x = 0.0;
        _position.y = 0.0;
        
        _identifier = nil;
    }
    
    return self;
}

- (void)dealloc
{
}

@end
