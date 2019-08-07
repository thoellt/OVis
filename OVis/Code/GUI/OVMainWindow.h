//
//  OVMainWindow.h
//  OVis
//
//  Created by Thomas Höllt on 17/10/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OVMainWindow : NSWindow
{
    BOOL _needsEnableUpdate;
}

-(void)disableUpdatesUntilFlush;

@end
