//
//  OVPreferencesWindowController.mm
//  Ovis
//
//  Created by Thomas Höllt on 17/02/14.
//  Copyright (c) 2014 Thomas Höllt. All rights reserved.
//

#import "SMDoubleSlider.h"

#import "OVAppDelegateProtocol.h"
#import "OVEnsembleData.h"
#import "OVEnsembleData+Statistics.h"
#import "OVEnsembleData+Pathlines.h"

#import "OVPreferencesWindowController.h"

@interface OVPreferencesWindowController ()

- (int) UIIntfromFloat: (float) val;

@end

@implementation OVPreferencesWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
		_ensembleData = [_appDelegate ensembleData];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self initRangeControls];
}

#pragma mark GUI

- (void) initRangeControls
{
    // TODO VAR
    float* range = [_ensembleData meanRangeForVariable:0];
	int v = [self UIIntfromFloat:range[1]];
	
	[meanRangeLoStepper setMinValue:v];
	[meanRangeHiStepper setMinValue:v];
	[meanRangeDoubleSlider setMinValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[meanRangeLoStepper setMaxValue:v];
	[meanRangeHiStepper setMaxValue:v];
	[meanRangeDoubleSlider setMaxValue:v];
    
    [meanRangeLoStepper setIncrement:1.0];
    [meanRangeHiStepper setIncrement:1.0];
    
    // TODO VAR
    range = [_ensembleData medianRangeForVariable:0];
    v = [self UIIntfromFloat:range[1]];
	
	[medianRangeLoStepper setMinValue:v];
	[medianRangeHiStepper setMinValue:v];
	[medianRangeDoubleSlider setMinValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[medianRangeLoStepper setMaxValue:v];
	[medianRangeHiStepper setMaxValue:v];
	[medianRangeDoubleSlider setMaxValue:v];
    
    [medianRangeLoStepper setIncrement:1.0];
    [medianRangeHiStepper setIncrement:1.0];
    
    // TODO VAR
    range = [_ensembleData rangeRangeForVariable:0];
    v = [self UIIntfromFloat:range[1]];
	
	[rangeRangeLoStepper setMinValue:v];
	[rangeRangeHiStepper setMinValue:v];
	[rangeRangeDoubleSlider setMinValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[rangeRangeLoStepper setMaxValue:v];
	[rangeRangeHiStepper setMaxValue:v];
	[rangeRangeDoubleSlider setMaxValue:v];
    
    [rangeRangeLoStepper setIncrement:1.0];
    [rangeRangeHiStepper setIncrement:1.0];
    
    // TODO VAR
    range = [_ensembleData standardDeviationRangeForVariable:0];
    v = [self UIIntfromFloat:range[1]];
	
	[stddevRangeLoStepper setMinValue:v];
	[stddevRangeHiStepper setMinValue:v];
	[stddevRangeDoubleSlider setMinValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[stddevRangeLoStepper setMaxValue:v];
	[stddevRangeHiStepper setMaxValue:v];
	[stddevRangeDoubleSlider setMaxValue:v];
    
    [stddevRangeLoStepper setIncrement:1.0];
    [stddevRangeHiStepper setIncrement:1.0];
    
    // TODO VAR
    range = [_ensembleData varianceRangeForVariable:0];
    v = [self UIIntfromFloat:range[1]];
	
	[varianceRangeLoStepper setMinValue:v];
	[varianceRangeHiStepper setMinValue:v];
	[varianceRangeDoubleSlider setMinValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[varianceRangeLoStepper setMaxValue:v];
	[varianceRangeHiStepper setMaxValue:v];
	[varianceRangeDoubleSlider setMaxValue:v];
    
    [varianceRangeLoStepper setIncrement:1.0];
    [varianceRangeHiStepper setIncrement:1.0];
    
    [self refreshMeanRangeControls];
    [self refreshMedianRangeControls];
    [self refreshRangeRangeControls];
    [self refreshStddevRangeControls];
    [self refreshVarianceRangeControls];
    
    [_appDelegate refreshAllViewsFromData];
}

- (void) initPathlineControls
{
    float alpha = [_ensembleData pathlineAlphaScale];
    [pathlineAlphaTextField setFloatValue:alpha];
    
    int resolution = [_ensembleData pathlineResolution];
    [pathlineResolutionPopUp selectItemWithTag:resolution];
    
    float progressionFactor = [_ensembleData pathlinepPogressionFactor];
    [pathlineProgressionTextField setFloatValue:progressionFactor];
    
    float assimilationCycleSize = [_ensembleData assimilationCycleLength];
    [assimilationCycleTextField setFloatValue:assimilationCycleSize];
}

- (void) refreshHistogramBinsControls
{
	int v = [_ensembleData histogramBins];
	
	[histogramBinsStepper setIntValue:v];
	[histogramBinsTextField setIntValue:v];
	[histogramBinsSlider setIntValue:v];
}

- (void) refreshMeanRangeControls
{
    // TODO VAR
    float* range = [_ensembleData meanLimitsForVariable:0];
    
	int v = [self UIIntfromFloat:range[1]];
	
	[meanRangeLoTextField setFloatValue:v*0.01];
	[meanRangeLoStepper setIntValue:v];
	[meanRangeDoubleSlider setIntLoValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[meanRangeHiTextField setFloatValue:v*0.01];
	[meanRangeHiStepper setIntValue:v];
	[meanRangeDoubleSlider setIntHiValue:v];
    
    [_appDelegate refreshAllViewsFromData];
}

- (void) refreshMedianRangeControls
{
    // TODO VAR
    float* range = [_ensembleData medianLimitsForVariable:0];
    
	int v = [self UIIntfromFloat:range[1]];
	
	[medianRangeLoTextField setFloatValue:v*0.01];
	[medianRangeLoStepper setIntValue:v];
	[medianRangeDoubleSlider setIntLoValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[medianRangeHiTextField setFloatValue:v*0.01];
	[medianRangeHiStepper setIntValue:v];
	[medianRangeDoubleSlider setIntHiValue:v];
    
    [_appDelegate refreshAllViewsFromData];
}

- (void) refreshRangeRangeControls
{
    // TODO VAR
    float* range = [_ensembleData rangeLimitsForVariable:0];
    
	int v = [self UIIntfromFloat:range[1]];
	
	[rangeRangeLoTextField setFloatValue:v*0.01];
	[rangeRangeLoStepper setIntValue:v];
	[rangeRangeDoubleSlider setIntLoValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[rangeRangeHiTextField setFloatValue:v*0.01];
	[rangeRangeHiStepper setIntValue:v];
	[rangeRangeDoubleSlider setIntHiValue:v];
    
    [_appDelegate refreshAllViewsFromData];
}

- (void) refreshStddevRangeControls
{
    // TODO VAR
    float* range = [_ensembleData standardDeviationLimitsForVariable:0];
    
	int v = [self UIIntfromFloat:range[1]];
	
	[stddevRangeLoTextField setFloatValue:v*0.01];
	[stddevRangeLoStepper setIntValue:v];
	[stddevRangeDoubleSlider setIntLoValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[stddevRangeHiTextField setFloatValue:v*0.01];
	[stddevRangeHiStepper setIntValue:v];
	[stddevRangeDoubleSlider setIntHiValue:v];
    
    [_appDelegate refreshAllViewsFromData];
}

- (void) refreshVarianceRangeControls
{
    // TODO VAR
    float* range = [_ensembleData varianceLimitsForVariable:0];
    
	int v = [self UIIntfromFloat:range[1]];
	
	[varianceRangeLoTextField setFloatValue:v*0.01];
	[varianceRangeLoStepper setIntValue:v];
	[varianceRangeDoubleSlider setIntLoValue:v];
	
	v = [self UIIntfromFloat:range[0]];
	
	[varianceRangeHiTextField setFloatValue:v*0.01];
	[varianceRangeHiStepper setIntValue:v];
	[varianceRangeDoubleSlider setIntHiValue:v];
    
    [_appDelegate refreshAllViewsFromData];
}

#pragma mark IBActions

- (IBAction) setHistogramBinsValue:(id)sender
{
	int v = [sender intValue];
    
    int res = v % 20;
    
    if( res < 10 ) v -= res;
    else v += ( 20 - res );
	
	// sanitize textfield input
	if( !(v < [histogramBinsStepper minValue] || v > [histogramBinsStepper maxValue] ) )
	{
		[_ensembleData setHistogramBins:v];
	}
	
	[self refreshHistogramBinsControls];
    
    [_ensembleData invalidateStatisticsWithUpdate:NO];
	
	[_appDelegate refreshViewFromData:ViewIdHistogram includingGUI:YES];
    [_appDelegate refreshAllViewsFromData];
}

- (IBAction) setMeanRange:(id)sender
{
	if( sender == meanRangeLoStepper || sender == meanRangeLoTextField )
	{
		float v = [sender floatValue];
        if( sender == meanRangeLoTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [meanRangeLoStepper minValue] || iv > [meanRangeLoStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setMeanLowerLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshMeanRangeControls];
	}
	else if( sender == meanRangeHiStepper || sender == meanRangeHiTextField )
	{
		float v = [sender floatValue];
        if( sender == meanRangeHiTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [meanRangeHiStepper minValue] || iv > [meanRangeHiStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setMeanUpperLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshMeanRangeControls];
	}
}

- (IBAction) setMeanRangeFromSlider:(id)sender
{
    // TODO VAR
	[_ensembleData setMeanLowerLimit:[sender floatLoValue] * 0.01 ForVariable:0];
    // TODO VAR
	[_ensembleData setMeanUpperLimit:[sender floatHiValue] * 0.01 ForVariable:0];
	
	[self refreshMeanRangeControls];
}

- (IBAction) setMedianRange:(id)sender
{
	if( sender == medianRangeLoStepper || sender == medianRangeLoTextField )
	{
		float v = [sender floatValue];
        if( sender == medianRangeLoTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [medianRangeLoStepper minValue] || iv > [medianRangeLoStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setMedianLowerLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshMedianRangeControls];
	}
	else if( sender == medianRangeHiStepper || sender == medianRangeHiTextField )
	{
		float v = [sender floatValue];
        if( sender == medianRangeHiTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [medianRangeHiStepper minValue] || iv > [medianRangeHiStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setMedianUpperLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshMedianRangeControls];
	}
}

- (IBAction) setMedianRangeFromSlider:(id)sender
{
    // TODO VAR
	[_ensembleData setMedianLowerLimit:[sender floatLoValue] * 0.01 ForVariable:0];
    // TODO VAR
	[_ensembleData setMedianUpperLimit:[sender floatHiValue] * 0.01 ForVariable:0];
	
	[self refreshMedianRangeControls];
}

- (IBAction) setRangeRange:(id)sender
{
	if( sender == rangeRangeLoStepper || sender == rangeRangeLoTextField )
	{
		float v = [sender floatValue];
        if( sender == rangeRangeLoTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [rangeRangeLoStepper minValue] || iv > [rangeRangeLoStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setRangeLowerLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshRangeRangeControls];
	}
	else if( sender == rangeRangeHiStepper || sender == rangeRangeHiTextField )
	{
		float v = [sender floatValue];
        if( sender == rangeRangeHiTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [rangeRangeHiStepper minValue] || iv > [rangeRangeHiStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setRangeUpperLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshRangeRangeControls];
	}
}

- (IBAction) setRangeRangeFromSlider:(id)sender
{
    // TODO VAR
	[_ensembleData setRangeLowerLimit:[sender floatLoValue] * 0.01 ForVariable:0];
    // TODO VAR
	[_ensembleData setRangeUpperLimit:[sender floatHiValue] * 0.01 ForVariable:0];
	
	[self refreshRangeRangeControls];
}

- (IBAction) setStddevRange:(id)sender
{
	if( sender == stddevRangeLoStepper || sender == stddevRangeLoTextField )
	{
		float v = [sender floatValue];
        if( sender == stddevRangeLoTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [stddevRangeLoStepper minValue] || iv > [stddevRangeLoStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setStandardDeviationLowerLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshStddevRangeControls];
	}
	else if( sender == stddevRangeHiStepper || sender == stddevRangeHiTextField )
	{
		float v = [sender floatValue];
        if( sender == stddevRangeHiTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [stddevRangeHiStepper minValue] || iv > [stddevRangeHiStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setStandardDeviationUpperLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshStddevRangeControls];
	}
}

- (IBAction) setStddevRangeFromSlider:(id)sender
{
    // TODO VAR
	[_ensembleData setStandardDeviationLowerLimit:[sender floatLoValue] * 0.01 ForVariable:0];
    // TODO VAR
	[_ensembleData setStandardDeviationUpperLimit:[sender floatHiValue] * 0.01 ForVariable:0];
	
	[self refreshStddevRangeControls];
}

- (IBAction) setVarianceRange:(id)sender
{
	if( sender == varianceRangeLoStepper || sender == varianceRangeLoTextField )
	{
		float v = [sender floatValue];
        if( sender == varianceRangeLoTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [varianceRangeLoStepper minValue] || iv > [varianceRangeLoStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setVarianceLowerLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshVarianceRangeControls];
	}
	else if( sender == varianceRangeHiStepper || sender == varianceRangeHiTextField )
	{
		float v = [sender floatValue];
        if( sender == varianceRangeHiTextField ) v *= 100.0;
        
        int iv = sender == meanRangeLoTextField ? [self UIIntfromFloat:v] : (int)v;
		
		// sanitize textfield input
		if( !( iv < [varianceRangeHiStepper minValue] || iv > [varianceRangeHiStepper maxValue] ) )
		{
            // TODO VAR
			[_ensembleData setVarianceUpperLimit:iv*0.01 ForVariable:0];
		}
		
		[self refreshVarianceRangeControls];
	}
}

- (IBAction) setVarianceRangeFromSlider:(id)sender
{
    // TODO VAR
	[_ensembleData setVarianceLowerLimit:[sender floatLoValue] * 0.01 ForVariable:0];
    // TODO VAR
	[_ensembleData setVarianceUpperLimit:[sender floatHiValue] * 0.01 ForVariable:0];
	
	[self refreshVarianceRangeControls];
}

- (IBAction) setPathlineResolution:(id)sender
{
    int resolution = (int)[sender selectedTag];
    
    [_ensembleData setPathlineResolution:resolution];
    [_ensembleData computePathline];
}

- (IBAction) setPathlineAlpha:(id)sender
{
    float alpha = [sender floatValue];
    
    [_ensembleData setPathlineAlphaScale:alpha];
    [_ensembleData computePathline];
}

- (IBAction) setPathlineProgression:(id)sender
{
    float progressionFactor = [sender floatValue];
    
    [_ensembleData setPathlinepPogressionFactor:progressionFactor];
    [_ensembleData computePathline];
}

- (IBAction) setAssimilationCycleTime:(id)sender
{
    float length = [sender floatValue];
    
    [_ensembleData setAssimilationCycleLength:length];
    [_ensembleData computePathline];
}

#pragma mark Helpers

// ----------------------------------------------------------------------------
- (int) UIIntfromFloat: (float) val
{
    float off = val < 0.0 ? -0.5 : 0.5;
    
    return (int)(val * 100.0 + off);
}

@end
