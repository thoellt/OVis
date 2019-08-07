//
//  OVTimeSeriesContainerView.m
//  Ovis
//
//  Created by Thomas Höllt on 10/10/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "OVTimeSeriesViewController.h"

#import "OVTimeSeriesContainerView.h"

@implementation OVTimeSeriesContainerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setViewController:(OVTimeSeriesViewController*)newController
{
    if (_viewController)
    {
        NSResponder *controllerNextResponder = [_viewController nextResponder];
        [super setNextResponder:controllerNextResponder];
        [_viewController setNextResponder:nil];
    }
    
    _viewController = newController;
    
    if (newController)
    {
        NSResponder *ownNextResponder = [self nextResponder];
        [super setNextResponder: _viewController];
        [_viewController setNextResponder:ownNextResponder];
    }
}

- (void)setNextResponder:(NSResponder *)newNextResponder
{
    if (_viewController)
    {
        [_viewController setNextResponder:newNextResponder];
        return;
    }
    
    [super setNextResponder:newNextResponder];
}

- (void) viewDidEndLiveResize
{
    [super viewDidEndLiveResize];
    
    [_viewController refreshTimeLabels];
}

@end
