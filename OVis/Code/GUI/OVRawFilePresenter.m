//
//  OVRawFilePresenter.m
//  OVis
//
//  Created by Thomas Höllt on 30/10/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//


// Local Header
#import "OVRawFilePresenter.h"

@implementation OVRawFilePresenter

#pragma mark NSFilePresenter Protocol
@synthesize primaryPresentedItemURL = _primaryFileURL;
@synthesize presentedItemURL = _secondaryFileURL;

- (id) init
{
    return [self initWithPrimaryURL: nil secondaryURL: nil];
}

- (id) initWithPrimaryURL:(NSURL*) primaryFileURL secondaryURL:(NSURL*) secondaryFileURL
{
    self = [super init];
	
	if( !self ) return nil;
    
    _primaryFileURL = primaryFileURL;
    _secondaryFileURL = secondaryFileURL;
    
    return self;
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

@end