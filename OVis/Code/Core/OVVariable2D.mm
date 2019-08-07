//
//  OVVariable2D.mm
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "OVStatistic.h"
#import "OVHistogram.h"

#import "OVVariable2D.h"

@implementation OVVariable2D

- (id) init
{
	self = [super init];
	
	if( self )
    {
        _dimensionality = 2;
    }
    
    return self;
}

- (void)dealloc
{
}

@end
