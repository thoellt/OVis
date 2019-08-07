//
//  OVNCLoaderController.h
//  OVis
//
//  Created by Thomas Höllt on 15/10/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"
#import "OVNetCDFLoader.h"
#import "SMDoubleSlider.h"

@interface OVNCLoaderController : NSWindowController <NSSplitViewDelegate>
{
    NSModalSession _modalSession;
    
    id<OVAppDelegateProtocol> _appDelegate;
    
    OVNetCDFLoader* _ncdLoader;
    
    NSMutableArray *_activeVariables4D;
    NSMutableArray *_activeVariables5D;
    NSMutableArray *_activeAttributes;
    NSMutableArray *_activeDimensions;
    
	IBOutlet NSWindow *_netCDFLoaderSheet;
    IBOutlet NSSplitView *_splitView;
    
    IBOutlet NSButton *_loadButton;
    IBOutlet NSButton *_cancelButton;
    
    IBOutlet NSPopUpButton *_variablesPopUpButton;
    
    IBOutlet NSButton *_flowFieldsCheckBox;
    IBOutlet NSPopUpButton *_uVariablePopUpButton;
    IBOutlet NSPopUpButton *_vVariablePopUpButton;
    
    IBOutlet NSPopUpButton *_xDimPopUpButton;
    IBOutlet NSPopUpButton *_yDimPopUpButton;
    IBOutlet NSPopUpButton *_zDimPopUpButton;
    IBOutlet NSPopUpButton *_tDimPopUpButton;
    IBOutlet NSPopUpButton *_mDimPopUpButton;
    
    IBOutlet NSTextField *_xDimIDLabel;
    IBOutlet NSTextField *_yDimIDLabel;
    IBOutlet NSTextField *_zDimIDLabel;
    IBOutlet NSTextField *_tDimIDLabel;
    IBOutlet NSTextField *_mDimIDLabel;
    
    IBOutlet NSPopUpButton *_invalidValuePopUpButton;
    IBOutlet NSTextField *_invalidValueLabel;
    
    IBOutlet NSView *_xRangeView;
    IBOutlet NSTextField *_xRangeLowerTextField;
    IBOutlet NSStepper *_xRangeLowerStepper;
    IBOutlet SMDoubleSlider *_xRangeDoubleSlider;
    IBOutlet NSTextField *_xRangeUpperTextField;
    IBOutlet NSStepper *_xRangeUpperStepper;
    
    IBOutlet NSView *_yRangeView;
    IBOutlet NSTextField *_yRangeLowerTextField;
    IBOutlet NSStepper *_yRangeLowerStepper;
    IBOutlet SMDoubleSlider *_yRangeDoubleSlider;
    IBOutlet NSTextField *_yRangeUpperTextField;
    IBOutlet NSStepper *_yRangeUpperStepper;
    
    IBOutlet NSView *_zRangeView;
    IBOutlet NSTextField *_zRangeLowerTextField;
    IBOutlet NSStepper *_zRangeLowerStepper;
    IBOutlet SMDoubleSlider *_zRangeDoubleSlider;
    IBOutlet NSTextField *_zRangeUpperTextField;
    IBOutlet NSStepper *_zRangeUpperStepper;
    
    IBOutlet NSView *_tRangeView;
    IBOutlet NSTextField *_tRangeLowerTextField;
    IBOutlet NSStepper *_tRangeLowerStepper;
    IBOutlet SMDoubleSlider *_tRangeDoubleSlider;
    IBOutlet NSTextField *_tRangeUpperTextField;
    IBOutlet NSStepper *_tRangeUpperStepper;
    
    IBOutlet NSView *_mRangeView;
    IBOutlet NSTextField *_mRangeLowerTextField;
    IBOutlet NSStepper *_mRangeLowerStepper;
    IBOutlet SMDoubleSlider *_mRangeDoubleSlider;
    IBOutlet NSTextField *_mRangeUpperTextField;
    IBOutlet NSStepper *_mRangeUpperStepper;
    
    BOOL _isDataInitialized;
    
    NSInteger _numFiles;
    
    int _sshIdx;
    
    int _uIdx;
    int _vIdx;
    
    int _xDimIdx;
    int _yDimIdx;
    int _zDimIdx;
    int _tDimIdx;
    int _mDimIdx;
    
    float _invalidValue;
    int _invalidValueIdx;
    
    EnsembleDimension _dataRangeLower;
    EnsembleDimension _dataRangeUpper;
    
    EnsembleDimension _rangeLower;
    EnsembleDimension _rangeUpper;
}

- (void) addFiles: (NSArray*) fileList;

- (void) initData;
- (void) initVariableData;
- (void) initFlowVariableData;
- (void) initInvalidValue;
- (void) initDimensionData;
- (void) initRangeData;

- (void) refreshGUI;
- (void) refreshVariableGUI;
- (void) refreshFlowVariableGUI;
- (void) triggerFlowVariableGUIActive;
- (void) refreshInvalidValueGUI;
- (void) refreshDimensionGUI;
- (void) refreshRangeGUI;
- (void) refreshRangeGUIIncludingBounds: (BOOL) includeBounds;
- (void) refreshXRangeGUI;
- (void) refreshYRangeGUI;
- (void) refreshZRangeGUI;
- (void) refreshTRangeGUI;
- (void) refreshMRangeGUI;
- (void) refreshXRangeGUIIncludingBounds: (BOOL) includeBounds;
- (void) refreshYRangeGUIIncludingBounds: (BOOL) includeBounds;
- (void) refreshZRangeGUIIncludingBounds: (BOOL) includeBounds;
- (void) refreshTRangeGUIIncludingBounds: (BOOL) includeBounds;
- (void) refreshMRangeGUIIncludingBounds: (BOOL) includeBounds;

- (IBAction)setSSHVariable:(id)sender;

- (IBAction)checkFlowFields:(id)sender;
- (IBAction)setUVariable:(id)sender;
- (IBAction)setVVariable:(id)sender;

- (IBAction)setLongitudeDimension:(id)sender;
- (IBAction)setLatitudeDimension:(id)sender;
- (IBAction)setDepthDimension:(id)sender;
- (IBAction)setTimeDimension:(id)sender;
- (IBAction)setMemberDimension:(id)sender;

- (IBAction)setInvalidVariable:(id)sender;

- (IBAction) setRange:(id)sender;
- (IBAction) setRangeFromSlider:(id)sender;

- (IBAction)showSheet:(id)sender;

- (IBAction)dismissSheet:(id)sender;

@end
