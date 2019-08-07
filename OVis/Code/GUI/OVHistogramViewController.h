//
//  OVHistogramWindowController.h
//  OVis
//
//  Created by Thomas Höllt on 25/09/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

@class OVHistogramController;

@interface OVHistogramViewController : NSViewController {
    
    id<OVAppDelegateProtocol> _appDelegate;
    
    IBOutlet OVHistogramController *_histogramController;
    
    NSInteger _leftSelectedVariable;
    NSInteger _rightSelectedVariable;
    
    IBOutlet NSPopUpButton *_leftVariableSelector;
    IBOutlet NSPopUpButton *_rightVariableSelector;
}

- (void) refreshGUI;

- (IBAction) selectLeftVariable:(id)sender;

- (IBAction) selectRightVariable:(id)sender;

/*!	@method		refreshFromData
    @discussion	Refreshes the controlled graph view by reloading the data. Should
                be called everytime the parameters, colormap, statistics, etc. change.
    @param	newData	BOOL value indicating if new data was loaded. Call with YES
                after loading a new dataset, with NO otherwise.*/
- (void) refreshFromData:(BOOL) newData;

@end
