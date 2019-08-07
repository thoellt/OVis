//
//  OVHistogramWindowController.m
//  OVis
//
//  Created by Thomas Höllt on 25/09/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

// Custom Headers
#import "OVAppDelegate.h"
#import "OVEnsembleData.h"

// Local Header
#import "OVHistogramController.h"
#import "OVHistogramViewController.h"

@implementation OVHistogramViewController

#pragma mark View Creation

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    
    if (self)
    {
        _appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
        
        _leftSelectedVariable = -1;
        _rightSelectedVariable = -1;
    }
    return self;
}

#pragma mark GUI

-(void)updateViewConstraints
{
   [super updateViewConstraints];
   
   [_histogramController refreshTheme];
}

- (void) refreshGUI
{
    if( ![_appDelegate.ensembleData isLoaded] ) return;
    
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    NSArray* variables2D = [ensemble variables2D];
    
    _leftSelectedVariable = [_leftVariableSelector selectedTag];
    _rightSelectedVariable = [_rightVariableSelector selectedTag];
    
    [_leftVariableSelector removeAllItems];
    [_rightVariableSelector removeAllItems];
    for( int i = 0; i < [variables2D count]; i++ )
    {
        [_leftVariableSelector addItemWithTitle:[variables2D[i] name]];
        [[_leftVariableSelector itemAtIndex:i] setTag:i];
        
        [_rightVariableSelector addItemWithTitle:[variables2D[i] name]];
        [[_rightVariableSelector itemAtIndex:i] setTag:i];
    }
    
    _leftSelectedVariable = MAX( 0, _leftSelectedVariable );
    _rightSelectedVariable = MAX( 0, _rightSelectedVariable );
    
    if( _leftSelectedVariable < [variables2D count] )
    {
        [_leftVariableSelector selectItemWithTag:_leftSelectedVariable];
        [_histogramController setLeftVariable:variables2D[_leftSelectedVariable]];
    }
    
    if( _rightSelectedVariable < [variables2D count] )
    {
        [_rightVariableSelector selectItemWithTag:_rightSelectedVariable];
        [_histogramController setRightVariable:variables2D[_rightSelectedVariable]];
    }
    
}

- (IBAction) selectLeftVariable:(id)sender
{
    NSInteger selectedTag = [[sender selectedCell] tag];
    
    if( _leftSelectedVariable == selectedTag ) return;
    
    _leftSelectedVariable = selectedTag;
    
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    
    assert( ensemble );
    
    NSMutableArray* variables = [ensemble variables2D];
    
    assert( variables && [variables count] > selectedTag );
    
    OVVariable* variable = variables[selectedTag];
    
    assert( variable );
    
    [_histogramController setLeftVariable:variable];
    
    [self refreshFromData:YES];
}

- (IBAction) selectRightVariable:(id)sender
{
    NSInteger selectedTag = [[sender selectedCell] tag];
    
    if( _rightSelectedVariable == selectedTag ) return;
    
    _rightSelectedVariable = selectedTag;
    
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    
    assert( ensemble );
    
    NSMutableArray* variables = [ensemble variables2D];
    
    assert( variables && [variables count] > selectedTag );
    
    OVVariable* variable = variables[selectedTag];
    
    assert( variable );
    
    [_histogramController setRightVariable:variable];
    
    [self refreshFromData:YES];
}

#pragma mark Data

- (void) refreshFromData:(BOOL) newData
{
	if( newData )
    {
        [self refreshGUI];
        [_histogramController rebuildGraph];
    }
	else
    {
        [_histogramController refresh];
    }
}



@end
