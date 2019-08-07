//
//  OVNCLoaderController.m
//  OVis
//
//  Created by Thomas Höllt on 15/10/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//


#import "OVNCLoaderController.h"
#import "OVAppDelegate.h"
#import "OVAppDelegateProtocol.h"

@interface OVNCLoaderController ()

@end

@implementation OVNCLoaderController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
        _ncdLoader = nil;
        _isDataInitialized = NO;
    }
    return self;
}

- (void) addFiles:(NSArray *)fileList
{
    _ncdLoader = [[OVNetCDFLoader alloc] initWithFileList:fileList];
    
    _numFiles = [fileList count];
    
    [self initData];
    [self refreshGUI];
}

- (void) initData
{
    if( _ncdLoader == nil ) return;
    
    [self initVariableData];
    [self initFlowVariableData];
    [self initInvalidValue];
    [self initDimensionData];
    [self initRangeData];
    
    _isDataInitialized = YES;
}

- (void) initVariableData
{
    _sshIdx = 0;
    
    _activeVariables4D = [_ncdLoader inquireVariablesWithDimensionality:4];
    
    if( [_activeVariables4D count] < 1 ) return;
    
    // try to find ssh variable automatically
    for( int i = 0; i < [_activeVariables4D count]; i++ )
    {
        netCDFVariable ncdVar;
        [[_activeVariables4D objectAtIndex:i] getValue:&ncdVar];
        NSString *variableName = [NSString stringWithFormat:@"%s", ncdVar.name];
        
        if( [variableName isEqualToString:@"Eta"] )
        {
            _sshIdx = i;
        }
    }
}

- (void) initFlowVariableData
{
    _uIdx = 0;
    _vIdx = 0;
    
    _activeVariables5D = [_ncdLoader inquireVariablesWithDimensionality:5];
    
    if( [_activeVariables5D count] < 1 ) return;
    
    // try to find ssh variable automatically
    for( int i = 0; i < [_activeVariables5D count]; i++ )
    {
        netCDFVariable ncdVar;
        [[_activeVariables5D objectAtIndex:i] getValue:&ncdVar];
        NSString *variableName = [NSString stringWithFormat:@"%s", ncdVar.name];
        
        if( [variableName isEqualToString:@"U"] )
        {
            _uIdx = i;
        }
        
        if( [variableName isEqualToString:@"V"] )
        {
            _vIdx = i;
        }
    }
}

- (void) initInvalidValue
{
    netCDFVariable sshVar;
    [[_activeVariables4D objectAtIndex:_sshIdx] getValue:&sshVar];
    
    _activeAttributes = [_ncdLoader inquireAttributesByVariableID:sshVar.id];
    
    if( [_activeAttributes count] < 1 ) return;
    
    // try to find invalid value attribute automatically
    for (int i = 0; i < [_activeAttributes count]; i++)
    {
        netCDFAttribute ncdAtt;
        [[_activeAttributes objectAtIndex:i] getValue:&ncdAtt];
        
        NSString *name = [NSString stringWithFormat:@"%s", ncdAtt.name];
        
        // Assuming standard value for invalid value to be _FillValue
        if( [name isEqualToString:@"_FillValue"] )
        {
            _invalidValueIdx = i;
        }
    }
}

- (void) initDimensionData
{
    _xDimIdx = 0;
    _yDimIdx = 0;
    _zDimIdx = 0;
    _tDimIdx = 0;
    _mDimIdx = 0;

    _activeDimensions = [_ncdLoader dimensions];
    
    if( [_activeDimensions count] < 1 ) return;
    
    // try to find dimensions automatically
    for (int i = 0; i < [_activeDimensions count]; i++)
    {
        netCDFDimension ncdDim;
        [[_activeDimensions objectAtIndex:i] getValue:&ncdDim];
        
        NSString *name = [NSString stringWithFormat:@"%s", ncdDim.name];
        
        // Assuming standard values for dimensions as follows:
        // X centroids: XC
        if( [name isEqualToString:@"XC"] )
        {
            _xDimIdx = i;
            
        // Y centroids: YC
        } else if( [name isEqualToString:@"YC"] )
        {
            _yDimIdx = i;
            
        // Z centroids: ZC
        } else if( [name isEqualToString:@"ZC"] )
        {
            _zDimIdx = i;
            
        // Time: time
        } else if( [name isEqualToString:@"time"] )
        {
            _tDimIdx = i;
            
        // Member: member
        } else if( [name isEqualToString:@"copy"] )
        {
            _mDimIdx = i;
        }
    }
    
    if( _numFiles > 1 )
    {
        _tDimIdx = -1;
    }
}

- (void) initRangeData
{
    _rangeLower = {.x = 0, .y = 0, .z = 0, .m = 0, .t = 0 };
    _rangeUpper = {.x = 0, .y = 0, .z = 0, .m = 0, .t = 0 };
    _dataRangeLower = {.x = 0, .y = 0, .z = 0, .m = 0, .t = 0 };
    _dataRangeUpper = {.x = 0, .y = 0, .z = 0, .m = 0, .t = 0 };
    
    if( [_activeDimensions count] < 1 ) return;
    
    netCDFDimension ncdDim;
    
    [[_activeDimensions objectAtIndex:_xDimIdx] getValue:&ncdDim];
    _dataRangeUpper.x = (int)(ncdDim.size) - 1;
    _rangeUpper.x = _dataRangeUpper.x;
    
    [[_activeDimensions objectAtIndex:_yDimIdx] getValue:&ncdDim];
    _dataRangeUpper.y = (int)(ncdDim.size) - 1;
    _rangeUpper.y = _dataRangeUpper.y;
    
    [[_activeDimensions objectAtIndex:_zDimIdx] getValue:&ncdDim];
    _dataRangeUpper.z = (int)(ncdDim.size) - 1;
    _rangeUpper.z = _dataRangeUpper.z;
    
    if( _tDimIdx == -1 )
    {
        _dataRangeUpper.t = _numFiles - 1;
        _rangeUpper.t = _dataRangeUpper.t;
    }
    else
    {
        [[_activeDimensions objectAtIndex:_tDimIdx] getValue:&ncdDim];
        _dataRangeUpper.t = (int)(ncdDim.size) - 1;
        _rangeUpper.t = _dataRangeUpper.t;
    }
    
    [[_activeDimensions objectAtIndex:_mDimIdx] getValue:&ncdDim];
    _dataRangeUpper.m = (int)(ncdDim.size) - 1;
    _rangeUpper.m = _dataRangeUpper.m;
}

- (void) awakeFromNib
{
    [self refreshGUI];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self refreshGUI];
}

#pragma mark data GUI

- (void)refreshGUI
{
    if( !_isDataInitialized ) return;
    
    if( _netCDFLoaderSheet == nil ) return;
    
    [self refreshVariableGUI];
    
    [self refreshFlowVariableGUI];
    
    [self triggerFlowVariableGUIActive];
    
    [self refreshInvalidValueGUI];
    
    [self refreshDimensionGUI];
    
    [self refreshRangeGUIIncludingBounds:YES];
}

- (void)refreshVariableGUI
{
    assert( _variablesPopUpButton );
    
    [_variablesPopUpButton removeAllItems];
    
    if( [_activeVariables4D count] < 1 ) return;
    
    // Set Variable
    for( int i = 0; i < [_activeVariables4D count]; i++ )
    {
        netCDFVariable ncdVar;
        [[_activeVariables4D objectAtIndex:i] getValue:&ncdVar];
        NSString *variableName = [NSString stringWithFormat:@"%s", ncdVar.longName];
        
        // fall back to short name if no long name is stored for this variable.
        if( !variableName || [variableName length] == 0 )[NSString stringWithFormat:@"%s", ncdVar.name];
        
        [_variablesPopUpButton addItemWithTitle:variableName];
        [[_variablesPopUpButton itemWithTitle:variableName] setTag:ncdVar.id];
        
        if( i == _sshIdx ) [_ncdLoader setSshVariableId:ncdVar.id];
    }
    
    [_variablesPopUpButton selectItemAtIndex:_sshIdx];
}

- (void)refreshFlowVariableGUI
{
    assert( _uVariablePopUpButton );
    assert( _vVariablePopUpButton );
    
    [_uVariablePopUpButton removeAllItems];
    [_vVariablePopUpButton removeAllItems];
    
    if( [_activeVariables5D count] < 1 ) return;
    
    // Set Variable
    for( int i = 0; i < [_activeVariables5D count]; i++ )
    {
        netCDFVariable ncdVar;
        [[_activeVariables5D objectAtIndex:i] getValue:&ncdVar];
        NSString *variableName = [NSString stringWithFormat:@"%s", ncdVar.longName];
        
        // fall back to short name if no long name is stored for this variable.
        if( !variableName || [variableName length] == 0 )[NSString stringWithFormat:@"%s", ncdVar.name];
        
        [_uVariablePopUpButton addItemWithTitle:variableName];
        [[_uVariablePopUpButton itemWithTitle:variableName] setTag:ncdVar.id];
        
        if( i == _uIdx ) [_ncdLoader setUVariableId:ncdVar.id];
        
        [_vVariablePopUpButton addItemWithTitle:variableName];
        [[_vVariablePopUpButton itemWithTitle:variableName] setTag:ncdVar.id];
        
        if( i == _vIdx ) [_ncdLoader setVVariableId:ncdVar.id];
        
    }
    
    [_uVariablePopUpButton selectItemAtIndex:_uIdx];
    [_vVariablePopUpButton selectItemAtIndex:_vIdx];
}


- (void)triggerFlowVariableGUIActive
{
    BOOL active = [_flowFieldsCheckBox state] != NSControlStateValueOff;
    
    [_uVariablePopUpButton setEnabled:active];
    [_vVariablePopUpButton setEnabled:active];
    
    [_zDimPopUpButton setEnabled:active];
    
    [_zRangeLowerTextField setEnabled:active];
    [_zRangeLowerStepper setEnabled:active];
    [_zRangeDoubleSlider setEnabled:active];
    [_zRangeUpperTextField setEnabled:active];
    [_zRangeUpperStepper setEnabled:active];
}

- (void)refreshInvalidValueGUI
{
    [_invalidValueLabel setFloatValue:0.0];
    [_invalidValuePopUpButton removeAllItems];
    
    netCDFVariable sshVar;
    [[_activeVariables4D objectAtIndex:_sshIdx] getValue:&sshVar];
    
    _activeAttributes = [_ncdLoader inquireAttributesByVariableID:sshVar.id];
    
    if( [_activeAttributes count] < 1 ) return;
    
    // try to find invalid value attribute automatically
    for (int i = 0; i < [_activeAttributes count]; i++)
    {
        netCDFAttribute ncdAtt;
        [[_activeAttributes objectAtIndex:i] getValue:&ncdAtt];
        
        NSString *name = [NSString stringWithFormat:@"%s", ncdAtt.name];
        
        [_invalidValuePopUpButton addItemWithTitle:name];
        
        if( i == _invalidValueIdx )
        {
            _invalidValue = [_ncdLoader loadFloatAttribute:ncdAtt forVariable:sshVar];
            [_ncdLoader setInvalidValue:_invalidValue];
            [_invalidValueLabel setFloatValue:_invalidValue];
        }
    }
    
    [_invalidValuePopUpButton selectItemAtIndex:_invalidValueIdx];
}

- (void)refreshDimensionGUI
{
    // Add dimensions to GUI and
    // try to find dimensions of dataset automatically
    [_xDimIDLabel setIntValue:0];
    [_yDimIDLabel setIntValue:0];
    [_zDimIDLabel setIntValue:0];
    [_tDimIDLabel setIntValue:0];
    [_mDimIDLabel setIntValue:0];
    
    [_xDimPopUpButton removeAllItems];
    [_yDimPopUpButton removeAllItems];
    [_zDimPopUpButton removeAllItems];
    [_tDimPopUpButton removeAllItems];
    [_mDimPopUpButton removeAllItems];
    
    netCDFVariable sshVar;
    [[_activeVariables4D objectAtIndex:_sshIdx] getValue:&sshVar];
    NSMutableArray *sshDims = [_ncdLoader inquireDimensionsByVariableID:sshVar.id];
    
    netCDFVariable uVar;
    [[_activeVariables5D objectAtIndex:_uIdx] getValue:&uVar];
    NSMutableArray *uDims = [_ncdLoader inquireDimensionsByVariableID:uVar.id];
    
    netCDFVariable vVar;
    [[_activeVariables5D objectAtIndex:_vIdx] getValue:&vVar];
    NSMutableArray *vDims = [_ncdLoader inquireDimensionsByVariableID:vVar.id];
    
    assert( [sshDims count] == 4 && [uDims count] == 5 && [vDims count] == 5 );
    assert([_activeDimensions count] > 0 );
    
    if( [_activeDimensions count] < 1 ) return;
    
    int sshDimIds[4];
    int flowDimIds[5];
    for( int i = 0; i < 4; i++ )
    {
        netCDFDimension sshDim;
        [[sshDims objectAtIndex:i] getValue:&sshDim];
        sshDimIds[i] = sshDim.id;
    }
    
    for( int i = 0; i < 5; i++ )
    {
        netCDFDimension uDim;
        [[uDims objectAtIndex:i] getValue:&uDim];
        
        netCDFDimension vDim;
        [[vDims objectAtIndex:i] getValue:&vDim];
        
        //assert( vDim.id == uDim.id );
        
        flowDimIds[i] = uDim.id;
    }
    
    
    [_tDimPopUpButton addItemWithTitle:@"File List"];
    [[_tDimPopUpButton itemWithTitle:@"File List"] setTag:-1];
    for (int i = 0; i < [_activeDimensions count]; i++)
    {
        netCDFDimension ncdDim;
        [[_activeDimensions objectAtIndex:i] getValue:&ncdDim];
        
        BOOL isActiveFor4D = NO;
        BOOL isActiveFor5D = NO;
        
        for( int j = 0; j < 4; j++)
        {
            isActiveFor4D = isActiveFor4D || (sshDimIds[j] == i);
        }
        for( int j = 0; j < 5; j++)
        {
            isActiveFor5D = isActiveFor5D || (flowDimIds[j] == i);
        }
        
        NSString *name = [NSString stringWithFormat:@"%s", ncdDim.longName];
        
        if( isActiveFor4D )
        {
            [_xDimPopUpButton addItemWithTitle:name];
            [[_xDimPopUpButton itemWithTitle:name] setTag:ncdDim.id];
            [_yDimPopUpButton addItemWithTitle:name];
            [[_yDimPopUpButton itemWithTitle:name] setTag:ncdDim.id];
            [_tDimPopUpButton addItemWithTitle:name];
            [[_tDimPopUpButton itemWithTitle:name] setTag:ncdDim.id];
            [_mDimPopUpButton addItemWithTitle:name];
            [[_mDimPopUpButton itemWithTitle:name] setTag:ncdDim.id];
            
            if( i == _xDimIdx ) [_xDimIDLabel setIntValue:ncdDim.id];
            if( i == _yDimIdx ) [_yDimIDLabel setIntValue:ncdDim.id];
            if( i == _tDimIdx ) [_tDimIDLabel setIntValue:ncdDim.id];
            if( i == _mDimIdx ) [_mDimIDLabel setIntValue:ncdDim.id];
        }
        
        if( isActiveFor5D )
        {
            [_zDimPopUpButton addItemWithTitle:name];
            [[_zDimPopUpButton itemWithTitle:name] setTag:ncdDim.id];
            if( i == _zDimIdx ) [_zDimIDLabel setIntValue:ncdDim.id];
        }
    }
    
    netCDFDimension ncdDim;
    [[_activeDimensions objectAtIndex:_xDimIdx] getValue:&ncdDim];
    [_xDimPopUpButton selectItemWithTag:ncdDim.id];
    [[_activeDimensions objectAtIndex:_yDimIdx] getValue:&ncdDim];
    [_yDimPopUpButton selectItemWithTag:ncdDim.id];
    [[_activeDimensions objectAtIndex:_zDimIdx] getValue:&ncdDim];
    [_zDimPopUpButton selectItemWithTag:ncdDim.id];
    if( _tDimIdx == -1 )
    {
        [_tDimPopUpButton selectItemWithTag:-1];
    }
    else
    {
        [[_activeDimensions objectAtIndex:_tDimIdx] getValue:&ncdDim];
        [_tDimPopUpButton selectItemWithTag:ncdDim.id];
    }
    [[_activeDimensions objectAtIndex:_mDimIdx] getValue:&ncdDim];
    [_mDimPopUpButton selectItemWithTag:ncdDim.id];
}

- (void) refreshRangeGUI
{
    [self refreshRangeGUIIncludingBounds:NO];
}

- (void) refreshRangeGUIIncludingBounds: (BOOL) includeBounds
{
    [self refreshXRangeGUIIncludingBounds:includeBounds];
    [self refreshYRangeGUIIncludingBounds:includeBounds];
    [self refreshZRangeGUIIncludingBounds:includeBounds];
    [self refreshTRangeGUIIncludingBounds:includeBounds];
    [self refreshMRangeGUIIncludingBounds:includeBounds];
}

- (void) refreshXRangeGUI
{
    [self refreshXRangeGUIIncludingBounds:NO];
}

- (void) refreshYRangeGUI
{
    [self refreshYRangeGUIIncludingBounds:NO];
}

- (void) refreshZRangeGUI
{
    [self refreshZRangeGUIIncludingBounds:NO];
}

- (void) refreshTRangeGUI
{
    [self refreshTRangeGUIIncludingBounds:NO];
}

- (void) refreshMRangeGUI
{
    [self refreshMRangeGUIIncludingBounds:NO];
}

- (void) refreshXRangeGUIIncludingBounds: (BOOL) includeBounds
{
    if( includeBounds )
    {
        [_xRangeLowerStepper setMinValue:_dataRangeLower.x];
        [_xRangeLowerStepper setMaxValue:_dataRangeUpper.x];
        [_xRangeUpperStepper setMinValue:_dataRangeLower.x];
        [_xRangeUpperStepper setMaxValue:_dataRangeUpper.x];
        
        [_xRangeDoubleSlider setNumberOfTickMarks:(_dataRangeUpper.x - _dataRangeLower.x)];
        [_xRangeDoubleSlider setTickMarkPosition:NSTickMarkPositionBelow];
        [_xRangeDoubleSlider setAllowsTickMarkValuesOnly:YES];
        [_xRangeDoubleSlider setMinValue:_dataRangeLower.x];
        [_xRangeDoubleSlider setMaxValue:_dataRangeUpper.x];
    }
    
    [_xRangeLowerTextField setIntegerValue:_rangeLower.x];
    [_xRangeUpperTextField setIntegerValue:_rangeUpper.x];
    
    [_xRangeLowerStepper setIntegerValue:_rangeLower.x];
    [_xRangeUpperStepper setIntegerValue:_rangeUpper.x];
    
	[_xRangeDoubleSlider setIntegerLoValue:_rangeLower.x];
	[_xRangeDoubleSlider setIntegerHiValue:_rangeUpper.x];
}

- (void) refreshYRangeGUIIncludingBounds: (BOOL) includeBounds
{
    if( includeBounds )
    {
        [_yRangeLowerStepper setMinValue:_dataRangeLower.y];
        [_yRangeLowerStepper setMaxValue:_dataRangeUpper.y];
        [_yRangeUpperStepper setMinValue:_dataRangeLower.y];
        [_yRangeUpperStepper setMaxValue:_dataRangeUpper.y];
        
        [_yRangeDoubleSlider setNumberOfTickMarks:(_dataRangeUpper.y - _dataRangeLower.y)];
        [_yRangeDoubleSlider setTickMarkPosition:NSTickMarkPositionBelow];
        [_yRangeDoubleSlider setAllowsTickMarkValuesOnly:YES];
        [_yRangeDoubleSlider setMinValue:_dataRangeLower.y];
    }
    
    [_yRangeLowerTextField setIntegerValue:_rangeLower.y];
    [_yRangeUpperTextField setIntegerValue:_rangeUpper.y];
    
    [_yRangeLowerStepper setIntegerValue:_rangeLower.y];
    [_yRangeUpperStepper setIntegerValue:_rangeUpper.y];
    
	[_yRangeDoubleSlider setMaxValue:(int)_dataRangeUpper.y];
	[_yRangeDoubleSlider setIntegerLoValue:_rangeLower.y];
	[_yRangeDoubleSlider setIntegerHiValue:_rangeUpper.y];
}

- (void) refreshZRangeGUIIncludingBounds: (BOOL) includeBounds
{
    if( includeBounds )
    {
        [_zRangeLowerStepper setMinValue:_dataRangeLower.z];
        [_zRangeLowerStepper setMaxValue:_dataRangeUpper.z];
        [_zRangeUpperStepper setMinValue:_dataRangeLower.z];
        [_zRangeUpperStepper setMaxValue:_dataRangeUpper.z];
        
        [_zRangeDoubleSlider setNumberOfTickMarks:(_dataRangeUpper.z - _dataRangeLower.z)];
        [_zRangeDoubleSlider setTickMarkPosition:NSTickMarkPositionBelow];
        [_zRangeDoubleSlider setAllowsTickMarkValuesOnly:YES];
        [_zRangeDoubleSlider setMinValue:_dataRangeLower.z];
        [_zRangeDoubleSlider setMaxValue:_dataRangeUpper.z];
    }
    
    [_zRangeLowerTextField setIntegerValue:_rangeLower.z];
    [_zRangeUpperTextField setIntegerValue:_rangeUpper.z];
    
    [_zRangeLowerStepper setIntegerValue:_rangeLower.z];
    [_zRangeUpperStepper setIntegerValue:_rangeUpper.z];
    
	[_zRangeDoubleSlider setIntegerLoValue:_rangeLower.z];
	[_zRangeDoubleSlider setIntegerHiValue:_rangeUpper.z];
}

- (void) refreshTRangeGUIIncludingBounds: (BOOL) includeBounds
{
    if( includeBounds )
    {
        [_tRangeLowerStepper setMinValue:_dataRangeLower.t];
        [_tRangeLowerStepper setMaxValue:_dataRangeUpper.t];
        [_tRangeUpperStepper setMinValue:_dataRangeLower.t];
        [_tRangeUpperStepper setMaxValue:_dataRangeUpper.t];
        
        [_tRangeDoubleSlider setNumberOfTickMarks:(_dataRangeUpper.t - _dataRangeLower.t)];
        [_tRangeDoubleSlider setTickMarkPosition:NSTickMarkPositionBelow];
        [_tRangeDoubleSlider setAllowsTickMarkValuesOnly:YES];
        [_tRangeDoubleSlider setMinValue:_dataRangeLower.t];
        [_tRangeDoubleSlider setMaxValue:_dataRangeUpper.t];
    }
    
    [_tRangeLowerTextField setIntegerValue:_rangeLower.t];
    [_tRangeUpperTextField setIntegerValue:_rangeUpper.t];
    
    [_tRangeLowerStepper setIntegerValue:_rangeLower.t];
    [_tRangeUpperStepper setIntegerValue:_rangeUpper.t];
    
	[_tRangeDoubleSlider setIntegerLoValue:_rangeLower.t];
	[_tRangeDoubleSlider setIntegerHiValue:_rangeUpper.t];
}

- (void) refreshMRangeGUIIncludingBounds: (BOOL) includeBounds
{
    if( includeBounds )
    {
        [_mRangeLowerStepper setMinValue:_dataRangeLower.m];
        [_mRangeLowerStepper setMaxValue:_dataRangeUpper.m];
        [_mRangeUpperStepper setMinValue:_dataRangeLower.m];
        [_mRangeUpperStepper setMaxValue:_dataRangeUpper.m];
        
        [_mRangeDoubleSlider setNumberOfTickMarks:(_dataRangeUpper.m - _dataRangeLower.m)];
        [_mRangeDoubleSlider setTickMarkPosition:NSTickMarkPositionBelow];
        [_mRangeDoubleSlider setAllowsTickMarkValuesOnly:YES];
        [_mRangeDoubleSlider setMinValue:_dataRangeLower.m];
        [_mRangeDoubleSlider setMaxValue:_dataRangeUpper.m];
    }
    
    [_mRangeLowerTextField setIntegerValue:_rangeLower.m];
    [_mRangeUpperTextField setIntegerValue:_rangeUpper.m];
    
    [_mRangeLowerStepper setIntegerValue:_rangeLower.m];
    [_mRangeUpperStepper setIntegerValue:_rangeUpper.m];
    
	[_mRangeDoubleSlider setIntegerLoValue:_rangeLower.m];
	[_mRangeDoubleSlider setIntegerHiValue:_rangeUpper.m];
}

#pragma mark IBActions

- (IBAction)showSheet:(id)sender
{
    if(!_netCDFLoaderSheet)
        [[NSBundle mainBundle] loadNibNamed:@"NetCDFLoaderSheet" owner:self topLevelObjects:nil];
    
    [NSApp beginSheet:_netCDFLoaderSheet
       modalForWindow:sender
        modalDelegate:self
       didEndSelector:@selector(endSheet:)//didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}

- (IBAction)dismissSheet:(id)sender
{
    if( sender == _loadButton )
    {
        //netCDFVariable sshVar;
        //[[_activeVariables objectAtIndex:_sshIdx] getValue:&sshVar];
        
        netCDFDimension xDim;
        [[_activeDimensions objectAtIndex:_xDimIdx] getValue:&xDim];
        
        netCDFDimension yDim;
        [[_activeDimensions objectAtIndex:_yDimIdx] getValue:&yDim];
        
        [_ncdLoader setXDimName: xDim.name];
        [_ncdLoader setYDimName: yDim.name];
        
        [_ncdLoader setIsTFromFileList: _tDimIdx < 0];
        
        [_ncdLoader setLowerBounds:_rangeLower];
        [_ncdLoader setUpperBounds:_rangeUpper];
        [_ncdLoader setFullDataUpper:_dataRangeUpper];
        
        [_ncdLoader setIsFlowEnabled:([_flowFieldsCheckBox state] != NSControlStateValueOff)];
        
        [_ncdLoader loadVariables];
        
        [_appDelegate openFromFileList];
    }
    
    if( sender == _cancelButton )
    {
    }
    
    [NSApp endSheet:_netCDFLoaderSheet];
    [_netCDFLoaderSheet orderOut:nil];
}

- (void) endSheet:(id)sender
{
}

/*
 - (IBAction)closeMyCustomSheet: (id)sender
 {
 [NSApp endSheet:_ncLoadSheet];
 }
 
 - (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
 {
 [sheet orderOut:self];
 }*/

- (IBAction)setSSHVariable:(id)sender
{
    if( _sshIdx == (int)[sender indexOfSelectedItem] ) return;
    
    _sshIdx = (int)[sender indexOfSelectedItem];
    
    [self initInvalidValue];
    [self initDimensionData];
    [self initRangeData];
    
    [self refreshGUI];
}

- (IBAction)checkFlowFields:(id)sender
{
    [self triggerFlowVariableGUIActive];
}

- (IBAction)setUVariable:(id)sender
{
    if( _uIdx == (int)[sender indexOfSelectedItem] ) return;
    
    _uIdx = (int)[sender indexOfSelectedItem];
    
    [self refreshFlowVariableGUI];
}

- (IBAction)setVVariable:(id)sender
{
    if( _vIdx == (int)[sender indexOfSelectedItem] ) return;
    
    _vIdx = (int)[sender indexOfSelectedItem];
    
    [self refreshFlowVariableGUI];
}

- (IBAction)setLongitudeDimension:(id)sender
{
    if( _xDimIdx == (int)[[_xDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag] ) return;
    
    _xDimIdx = (int)[[_xDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag];
    
    [self refreshDimensionGUI];
    
    [self initRangeData];
    
    [self refreshXRangeGUIIncludingBounds:YES];
}

- (IBAction)setLatitudeDimension:(id)sender
{
    if( _yDimIdx == (int)[[_yDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag] ) return;
    
    _yDimIdx = (int)[[_yDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag];

    [self refreshDimensionGUI];
    
    [self initRangeData];
    
    [self refreshYRangeGUIIncludingBounds:YES];
}

- (IBAction)setDepthDimension:(id)sender
{
    if( _zDimIdx == (int)[[_zDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag] ) return;
    
    _zDimIdx = (int)[[_zDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag];
    
    [self refreshDimensionGUI];
    
    [self initRangeData];
    
    [self refreshZRangeGUIIncludingBounds:YES];
}

- (IBAction)setTimeDimension:(id)sender
{
    if( _tDimIdx == (int)[[_tDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag] ) return;
    
    _tDimIdx = (int)[[_tDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag];
    
    [self refreshDimensionGUI];
    
    [self initRangeData];
    
    [self refreshTRangeGUIIncludingBounds:YES];
}

- (IBAction)setMemberDimension:(id)sender
{
    if( _mDimIdx == (int)[[_mDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag] ) return;
    
    _mDimIdx = (int)[[_mDimPopUpButton itemAtIndex:[sender indexOfSelectedItem]] tag];
    
    [self refreshDimensionGUI];
    
    [self initRangeData];
    
    [self refreshMRangeGUIIncludingBounds:YES];
}

- (IBAction)setInvalidVariable:(id)sender
{
    
}

- (IBAction) setRange:(id)sender
{
    int v = [sender intValue];
    
	if( sender == _xRangeLowerTextField || sender == _xRangeLowerStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.x || v > _dataRangeUpper.x ) )
		{
			_rangeLower.x = v;
		}
		
		[self refreshXRangeGUI];
	}
	else if( sender == _xRangeUpperTextField || sender == _xRangeUpperStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.x || v > _dataRangeUpper.x ) )
		{
			_rangeUpper.x = v;
		}
		
		[self refreshXRangeGUI];
	}
    else if( sender == _yRangeLowerTextField || sender == _yRangeLowerStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.y || v > _dataRangeUpper.y ) )
		{
			_rangeLower.y = v;
		}
		
		[self refreshYRangeGUI];
	}
	else if( sender == _yRangeUpperTextField || sender == _yRangeUpperStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.y || v > _dataRangeUpper.y ) )
		{
			_rangeUpper.y = v;
		}
		
		[self refreshYRangeGUI];
	}
    else if( sender == _zRangeLowerTextField || sender == _zRangeLowerStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.z || v > _dataRangeUpper.z ) )
		{
			_rangeLower.z = v;
		}
		
		[self refreshZRangeGUI];
	}
	else if( sender == _zRangeUpperTextField || sender == _zRangeUpperStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.z || v > _dataRangeUpper.z ) )
		{
			_rangeUpper.z = v;
		}
		
		[self refreshZRangeGUI];
	}
    else if( sender == _tRangeLowerTextField || sender == _tRangeLowerStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.t || v > _dataRangeUpper.t ) )
		{
			_rangeLower.t = v;
		}
		
		[self refreshTRangeGUI];
	}
	else if( sender == _tRangeUpperTextField || sender == _tRangeUpperStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.t || v > _dataRangeUpper.t ) )
		{
			_rangeUpper.t = v;
		}
		
		[self refreshTRangeGUI];
	}
    else if( sender == _mRangeLowerTextField || sender == _mRangeLowerStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.m || v > _dataRangeUpper.m ) )
		{
			_rangeLower.m = v;
		}
		
		[self refreshMRangeGUI];
	}
	else if( sender == _mRangeUpperTextField || sender == _mRangeUpperStepper )
	{
		// sanitize textfield input
		if( !( v < _dataRangeLower.m || v > _dataRangeUpper.m ) )
		{
			_rangeUpper.m = v;
		}
		
		[self refreshMRangeGUI];
	}
}

- (IBAction) setRangeFromSlider:(id)sender
{
    if( sender == _xRangeDoubleSlider )
    {
        _rangeLower.x = [sender intLoValue];
        _rangeUpper.x = [sender intHiValue];
        
        [self refreshXRangeGUI];
    }
    else if( sender == _yRangeDoubleSlider )
    {
        _rangeLower.y = [sender intLoValue];
        _rangeUpper.y = [sender intHiValue];
        
        [self refreshYRangeGUI];
    }
    else if( sender == _zRangeDoubleSlider )
    {
        _rangeLower.z = [sender intLoValue];
        _rangeUpper.z = [sender intHiValue];
        
        [self refreshZRangeGUI];
    }
    else if( sender == _tRangeDoubleSlider )
    {
        _rangeLower.t = [sender intLoValue];
        _rangeUpper.t = [sender intHiValue];
        
        [self refreshTRangeGUI];
    }
    else if( sender == _mRangeDoubleSlider )
    {
        _rangeLower.m = [sender intLoValue];
        _rangeUpper.m = [sender intHiValue];
        
        [self refreshMRangeGUI];
    }
}

#pragma mark Split View Delegate

- (BOOL) splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return (subview == [[splitView subviews] objectAtIndex:1]);
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    return YES;
}

@end
