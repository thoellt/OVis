//
//  OVPreferencesWindowController.h
//  Ovis
//
//  Created by Thomas Höllt on 17/02/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "OVAppDelegateProtocol.h"

#import <Cocoa/Cocoa.h>

@class OVEnsembleData;
@class SMDoubleSlider;

@interface OVPreferencesWindowController : NSWindowController {
    
    id<OVAppDelegateProtocol> _appDelegate;
	OVEnsembleData *_ensembleData;
    
	IBOutlet NSTextField *histogramBinsTextField;
	IBOutlet NSStepper *histogramBinsStepper;
	IBOutlet NSSlider *histogramBinsSlider;
    
	IBOutlet NSTextField *meanRangeLoTextField;
	IBOutlet NSTextField *meanRangeHiTextField;
	IBOutlet NSStepper *meanRangeLoStepper;
	IBOutlet NSStepper *meanRangeHiStepper;
	IBOutlet SMDoubleSlider *meanRangeDoubleSlider;
    
	IBOutlet NSTextField *medianRangeLoTextField;
	IBOutlet NSTextField *medianRangeHiTextField;
	IBOutlet NSStepper *medianRangeLoStepper;
	IBOutlet NSStepper *medianRangeHiStepper;
	IBOutlet SMDoubleSlider *medianRangeDoubleSlider;
    
	IBOutlet NSTextField *rangeRangeLoTextField;
	IBOutlet NSTextField *rangeRangeHiTextField;
	IBOutlet NSStepper *rangeRangeLoStepper;
	IBOutlet NSStepper *rangeRangeHiStepper;
	IBOutlet SMDoubleSlider *rangeRangeDoubleSlider;
    
	IBOutlet NSTextField *stddevRangeLoTextField;
	IBOutlet NSTextField *stddevRangeHiTextField;
	IBOutlet NSStepper *stddevRangeLoStepper;
	IBOutlet NSStepper *stddevRangeHiStepper;
	IBOutlet SMDoubleSlider *stddevRangeDoubleSlider;
    
	IBOutlet NSTextField *varianceRangeLoTextField;
	IBOutlet NSTextField *varianceRangeHiTextField;
	IBOutlet NSStepper *varianceRangeLoStepper;
	IBOutlet NSStepper *varianceRangeHiStepper;
	IBOutlet SMDoubleSlider *varianceRangeDoubleSlider;
    
	IBOutlet NSPopUpButton *pathlineResolutionPopUp;
	IBOutlet NSTextField *pathlineAlphaTextField;
	IBOutlet NSTextField *pathlineProgressionTextField;
	IBOutlet NSTextField *assimilationCycleTextField;
}

/*!	@method		refreshHistogramBinsControls
    @discussion	Refreshes GUI for the Histogram Bins.*/
- (void) refreshHistogramBinsControls;


/*!	@method		setHistogramBinsValue
    @discussion	Sets the number of Histogram Bins.
    @param	sender	The sender of the event.*/
- (IBAction) setHistogramBinsValue:(id)sender;

/*!	@method		initRangeControls
    @discussion	Inits boundaries for the colormap ranges.*/
- (void) initRangeControls;

/*!	@method		initPathlineControls
    @discussion	Inits pathline part of the GUI.*/
- (void) initPathlineControls;

/*!	@method		refreshMeanRangeControls
    @discussion	Refreshes GUI for the Mean colormap range.*/
- (void) refreshMeanRangeControls;

/*!	@method		setMeanRange
    @discussion	Sets lower and upper boundaries for the Mean colormap via the
                NSSteppers and NSTextFields.
    @param	sender	The sender of the event.*/
- (IBAction) setMeanRange:(id)sender;

/*!	@method		setMeanRangeFromSlider
    @discussion	Sets lower and upper boundaries for the Mean colormap via the NSSLider.
    @param	sender	The sender of the event.*/
- (IBAction) setMeanRangeFromSlider:(id)sender;

/*!	@method		refreshMedianRangeControls
    @discussion	Refreshes GUI for the Median colormap range.*/
- (void) refreshMedianRangeControls;

/*!	@method		setMedianRange
    @discussion	Sets lower and upper boundaries for the Median colormap via the
                NSSteppers and NSTextFields.
    @param	sender	The sender of the event.*/
- (IBAction) setMedianRange:(id)sender;

/*!	@method		setMedianRangeFromSlider
    @discussion	Sets lower and upper boundaries for the Median colormap via the NSSLider.
    @param	sender	The sender of the event.*/
- (IBAction) setMedianRangeFromSlider:(id)sender;

/*!	@method		refreshRangeRangeControls
    @discussion	Refreshes GUI for the Range colormap range.*/
- (void) refreshRangeRangeControls;

/*!	@method		setRangeRange
    @discussion	Sets lower and upper boundaries for the Range colormap via the
                NSSteppers and NSTextFields.
    @param	sender	The sender of the event.*/
- (IBAction) setRangeRange:(id)sender;

/*!	@method		setRangeRangeFromSlider
    @discussion	Sets lower and upper boundaries for the Range colormap via the NSSLider.
    @param	sender	The sender of the event.*/
- (IBAction) setRangeRangeFromSlider:(id)sender;

/*!	@method		refreshStddevRangeControls
    @discussion	Refreshes GUI for the Stddev colormap range.*/
- (void) refreshStddevRangeControls;

/*!	@method		setStddevRange
    @discussion	Sets lower and upper boundaries for the Stddev colormap via the
                NSSteppers and NSTextFields.
    @param	sender	The sender of the event.*/
- (IBAction) setStddevRange:(id)sender;

/*!	@method		setStddevRangeFromSlider
    @discussion	Sets lower and upper boundaries for the Stddev colormap via the NSSLider.
    @param	sender	The sender of the event.*/
- (IBAction) setStddevRangeFromSlider:(id)sender;

/*!	@method		refreshVarianceRangeControls
    @discussion	Refreshes GUI for the Variance colormap range.*/
- (void) refreshVarianceRangeControls;

/*!	@method		setVarianceRange
    @discussion	Sets lower and upper boundaries for the Variance colormap via the
                NSSteppers and NSTextFields.
    @param	sender	The sender of the event.*/
- (IBAction) setVarianceRange:(id)sender;

/*!	@method		setVarianceRangeFromSlider
    @discussion	Sets lower and upper boundaries for the Variance colormap via the NSSLider.
    @param	sender	The sender of the event.*/
- (IBAction) setVarianceRangeFromSlider:(id)sender;

/*!	@method		setPathlineResolution
    @discussion	Sets resolution for binning used for pathline tracing
    @param	sender	The sender of the event.*/
- (IBAction) setPathlineResolution:(id)sender;

/*!	@method		setPathlineAlpha
    @discussion	Sets alpha factor for probability for rendering pathlines (requires retracing)
    @param	sender	The sender of the event.*/
- (IBAction) setPathlineAlpha:(id)sender;

/*!	@method		setPathlineProgression
    @discussion	Sets scaling factor/step size for pathline tracing
    @param	sender	The sender of the event.*/
- (IBAction) setPathlineProgression:(id)sender;

/*!	@method		setAssimilationCycleTime
    @discussion	Sets the time step of an assimilation cycle, needed when not loaded from file meta data
    @param	sender	The sender of the event.*/
- (IBAction) setAssimilationCycleTime:(id)sender;

@end
