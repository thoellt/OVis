//
//  OVVariable1D.h
//  Ovis
//
//  Created by Thomas Höllt on 14/09/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "OVVariable.h"

#import <Foundation/Foundation.h>

@class OVStatistic;
@class OVHistogram;

@interface OVVariable1D : OVVariable
{
    Vector2 _position;
    
    NSString* _identifier;
}

/*!	@property	position
    @brief		the x,y position of the 1D variable.*/
@property (nonatomic) Vector2 position;

/*!	@property	identifier
    @brief		The identifier of the variable (e.g. the name of of the well, not the variable).*/
@property (nonatomic) NSString* identifier;

@end
