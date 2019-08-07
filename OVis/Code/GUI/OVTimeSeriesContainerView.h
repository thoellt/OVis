//
//  OVTimeSeriesContainerView.h
//  Ovis
//
//  Created by Thomas Höllt on 10/10/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OVTimeSeriesViewController;

@interface OVTimeSeriesContainerView : NSView
{
    OVTimeSeriesViewController* _viewController;
}

- (void)setViewController:(OVTimeSeriesViewController*)newController;

@end
