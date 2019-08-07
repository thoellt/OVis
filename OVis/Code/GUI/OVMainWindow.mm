//
//  OVMainWindow.m
//  OVis
//
//  Created by Thomas Höllt on 17/10/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

#import "OVMainWindow.h"

@implementation OVMainWindow

-(void)disableUpdatesUntilFlush
{
    if(!_needsEnableUpdate)
    {
        NSDisableScreenUpdates();
        _needsEnableUpdate = YES;
    }
}

-(void)flushWindow
{
    [super flushWindow];
    if(_needsEnableUpdate)
    {
        NSEnableScreenUpdates();
        _needsEnableUpdate = NO;
    }
}

@end
