//
//  OVRawFilePresenter.h
//  OVis
//
//  Created by Thomas Höllt on 30/10/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OVRawFilePresenter : NSObject <NSFilePresenter>
{
    NSURL *_primaryFileURL;
    NSURL *_secondaryFileURL;
}

- (id) initWithPrimaryURL:(NSURL*) primaryFileURL secondaryURL:(NSURL*) secondaryFileURL;

@end