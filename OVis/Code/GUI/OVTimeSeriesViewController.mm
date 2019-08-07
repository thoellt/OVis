//
//	OVTimeSeriesWindowController.mm
//

// Custom Headers
#import "OVAppDelegate.h"
#import "OVColormap.h"
#import "OVViewSettings.h"
#import "OVEnsembleData.h"
#import "OVEnsembleData+Platforms.h"
#import "OVOffShorePlatform.h"
#import "OVTimeSeriesView.h"
#import "OVTimeSeriesContainerView.h"
#import "OVVariable.h"
#import "OVVariable1D.h"
#import "OVVariable2D.h"

// Local Header
#import "OVTimeSeriesViewController.h"

@implementation OVTimeSeriesViewController

#pragma mark View Creation

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
   self = [super initWithNibName:nibName bundle:nibBundle];

   if (self) {
      propertiesHeight = 50.f;

      _appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;

      _variablesLeft = [[NSMutableArray alloc] init];
      _variablesRight = [[NSMutableArray alloc] init];

      _selectedVariableIdxLeft = 0;
      _selectedVariableIdxRight = 0;

      _timeLabels = [[NSMutableArray alloc] init];
   }

   return self;
}

- (void)loadView
{
   [super loadView];

   // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
   [verticalSpaceTSViewBottom setConstant:propertiesHeight];
   [horizontalSpaceTSViewRight setConstant:20.0];
   [legendView setHidden:YES];

   [mainViewContainer setViewController:self];

   [self refreshGUI];

   // colormap
   [colormapSelector removeAllItems];
   [colormapSelector addItemWithTitle:@"None"];
   [[colormapSelector lastItem] setTag:-1];
   [[colormapSelector menu] addItem:[NSMenuItem separatorItem]];
   [[colormapSelector lastItem] setTag:-99];

   OVViewSettings* viewSettings = [_appDelegate viewSettings];

   int idx = 0;
   OVColormap* colormap = [viewSettings colormapAtIndex:idx];
   while( colormap )
   {
      [colormapSelector addItemWithTitle:[colormap name]];
      [[colormapSelector lastItem] setTag:idx];

      idx++;

      colormap = [viewSettings colormapAtIndex:idx];
   }

   [colormapSelector selectItemWithTag:[viewSettings activeColormapIndexForView:ViewIdTS]];
}

#pragma mark GUI

- (void) toggleProperties
{
	BOOL hidden = [verticalSpaceTSViewBottom constant] < 45.0;
	
	if( hidden )
		[verticalSpaceTSViewBottom setConstant:50.0];
	else
		[verticalSpaceTSViewBottom setConstant:20.0];
	
	[glyphPropertiesView setHidden:!hidden];
}

- (void) refreshGUI
{
    [self refreshSelectionGUI];
    
    [self refreshLegendGUI];
    
    [self refreshTimeSeriesViewGUI];
}

- (void) refreshLegendGUI
{
    // TODO VAR
    if( ![_appDelegate.ensembleData isLoaded] ) return;
    
    // Data
    // TODO VAR
    NSInteger selectedTag = [leftPropertySelector selectedTag];
    OVVariable2D* var = _variablesLeft[selectedTag];
    
    float *range = [var dataRange];
    float step = (range[0] - range[1]) * 0.25;
    
    [leftHeightLabelTop setStringValue:[NSString stringWithFormat:@"%.2f", range[0]]];
    [leftHeightLabelTopHalf setStringValue:[NSString stringWithFormat:@"%.2f", range[1] + step * 3]];
    [leftHeightLabelCenter setStringValue:[NSString stringWithFormat:@"%.2f", range[1] + step * 2]];
    [leftHeightLabelBottomHalf setStringValue:[NSString stringWithFormat:@"%.2f", range[1] + step]];
    [leftHeightLabelBottom setStringValue:[NSString stringWithFormat:@"%.2f", range[1]]];
    
    NSString* label = [NSString stringWithFormat:@"%@ in %@", var.name, var.unit];
    [leftVariableNameLabel setStringValue:label];
    
    selectedTag = [rightPropertySelector selectedTag];
    var = _variablesRight[selectedTag];
    
    range = [var dataRange];
    step = (range[0] - range[1]) * 0.25;
    
    [rightHeightLabelTop setStringValue:[NSString stringWithFormat:@"%.2f", range[0]]];
    [rightHeightLabelTopHalf setStringValue:[NSString stringWithFormat:@"%.2f", range[1] + step * 3]];
    [rightHeightLabelCenter setStringValue:[NSString stringWithFormat:@"%.2f", range[1] + step * 2]];
    [rightHeightLabelBottomHalf setStringValue:[NSString stringWithFormat:@"%.2f", range[1] + step]];
    [rightHeightLabelBottom setStringValue:[NSString stringWithFormat:@"%.2f", range[1]]];
    
    label = [NSString stringWithFormat:@"%@ in %@", var.name, var.unit];
    [rightVariableNameLabel setStringValue:label];
}

- (void) refreshSelectionGUI
{
	// Platforms
	NSMutableDictionary *platforms = [_appDelegate.ensembleData platforms];
	NSMutableDictionary *gliders = nil;
	
	// Left Side
	NSString *activeItem = [leftItemSelector selectedItem].title;

	[leftItemSelector removeAllItems];
	
	[leftItemSelector addItemWithTitle:@"Active"];
    
    [[rightPropertySelector menu] addItem:[NSMenuItem separatorItem]];
    [[rightPropertySelector lastItem] setTag:-99];
	
	if( [platforms count] > 0 ) [[leftItemSelector menu] addItem:[NSMenuItem separatorItem]];
	
	for(id key in platforms) {
		OVOffShorePlatform *p = [platforms objectForKey:key];
		[leftItemSelector addItemWithTitle:[p name]];
	}
	
	if( [gliders count] > 0 ) [[leftItemSelector menu] addItem:[NSMenuItem separatorItem]];
	
	//for(id key in gliders) {
		//OVGliderPath *p = [gliders objectForKey:key];
		//[leftItemSelector addItemWithTitle:[p name]];
	//}
	
	[leftItemSelector selectItemWithTitle:activeItem];
    
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    NSArray* variables2D = [ensemble variables2D];
    
    [_variablesLeft removeAllObjects];
    [leftPropertySelector removeAllItems];
    for( int i = 0; i < [variables2D count]; i++ )
    {
        [_variablesLeft addObject:variables2D[i]];
        [leftPropertySelector addItemWithTitle:[variables2D[i] name]];
        [[leftPropertySelector itemAtIndex:i] setTag:i];
    }
    
    NSMutableArray *selectedVariables = [[[_appDelegate ensembleData] getPlatformWithName:[_appDelegate.viewSettings leftGlyphActiveItem]] correspondingVariables];
    
    if( selectedVariables )
    {
        [[leftPropertySelector menu] addItem:[NSMenuItem separatorItem]];
        [[leftPropertySelector lastItem] setTag:-99];
        
        for( OVVariable1D* variable in selectedVariables )
        {
            if( variable.dimensionality == 1 )
            {
                [_variablesLeft addObject:variable];
                [leftPropertySelector addItemWithTitle:variable.name];
                [[leftPropertySelector lastItem] setTag:[_variablesLeft indexOfObject:variable]];
            }
        }
	}
    
    [leftPropertySelector selectItemWithTag:_selectedVariableIdxLeft];
    
	// Right Side
	activeItem = [rightItemSelector selectedItem].title;
	
	[rightItemSelector removeAllItems];
	
	[rightItemSelector addItemWithTitle:@"Active"];
    
    [[rightPropertySelector menu] addItem:[NSMenuItem separatorItem]];
    [[rightPropertySelector lastItem] setTag:-99];
	
	if( [platforms count] > 0 ) [[rightItemSelector menu] addItem:[NSMenuItem separatorItem]];
	
	for(id key in platforms) {
		OVOffShorePlatform *p = [platforms objectForKey:key];
		[rightItemSelector addItemWithTitle:[p name]];
	}
	
    if( [gliders count] > 0 ){
        
        [[rightItemSelector menu] addItem:[NSMenuItem separatorItem]];
        [[rightItemSelector lastItem] setTag:-99];
    }
	
	//for(id key in gliders) {
		//OVGliderPath *p = [gliders objectForKey:key];
		//[leftItemSelector addItemWithTitle:[p name]];
	//}
	
	[rightItemSelector selectItemWithTitle:activeItem];
    
    
    [_variablesRight removeAllObjects];
    [rightPropertySelector removeAllItems];
    for( int i = 0; i < [variables2D count]; i++ )
    {
        [_variablesRight addObject:variables2D[i]];
        [rightPropertySelector addItemWithTitle:[variables2D[i] name]];
        [[rightPropertySelector itemAtIndex:i] setTag:i];
    }
    
    selectedVariables = [[[_appDelegate ensembleData] getPlatformWithName:[_appDelegate.viewSettings rightGlyphActiveItem]] correspondingVariables];
    
    if( selectedVariables )
    {
        [[rightPropertySelector menu] addItem:[NSMenuItem separatorItem]];
        [[rightPropertySelector lastItem] setTag:-99];
        
        for( OVVariable1D* variable in selectedVariables )
        {
            if( variable.dimensionality == 1 )
            {
                [_variablesRight addObject:variable];
                [rightPropertySelector addItemWithTitle:variable.name];
                [[rightPropertySelector lastItem] setTag:[_variablesRight indexOfObject:variable]];
            }
        }
    }
    
    [rightPropertySelector selectItemWithTag:_selectedVariableIdxRight];
}

- (void) refreshTimeSeriesViewGUI
{
    NSInteger selectedTag = [timeViewSelector selectedTag];
    
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    NSInteger numTimeSteps = [ensemble timeRangeMax] - [ensemble timeRangeMin] + 1;
    NSDateComponents* timeStepLength = [ensemble timeStepLength];
    
    [timeViewSelector removeAllItems];
    
    [timeViewSelector addItemWithTitle:@"Full Resolution"];
    [[timeViewSelector lastItem] setTag:1];
    
    [[timeViewSelector menu] addItem:[NSMenuItem separatorItem]];
    [[timeViewSelector lastItem] setTag:-99];
    
    [timeViewSelector addItemWithTitle:@"Every 2nd"];
    [[timeViewSelector lastItem] setTag:2];
    
    [timeViewSelector addItemWithTitle:@"Every 3rd"];
    [[timeViewSelector lastItem] setTag:3];
    
    [timeViewSelector addItemWithTitle:@"Every 5th"];
    [[timeViewSelector lastItem] setTag:5];
    
    [timeViewSelector addItemWithTitle:@"Every 10th"];
    [[timeViewSelector lastItem] setTag:10];
    
    [[timeViewSelector menu] addItem:[NSMenuItem separatorItem]];
    [[timeViewSelector lastItem] setTag:-99];
    
    if( timeStepLength.year == 0 && timeStepLength.month == 0 && timeStepLength.day == 0 &&
        timeStepLength.hour == 0 && timeStepLength.minute == 0 && timeStepLength.second != 0 )
    {
        NSInteger timeStep = timeStepLength.second;
        NSInteger totalTime = timeStep* numTimeSteps;
        
        if( 15 <= totalTime && 15 % timeStep == 0 )
        {
            NSInteger stride = 15 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 15th second"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 30 <= totalTime && 30 % timeStep == 0 )
        {
            NSInteger stride = 30 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 30th second"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 60 <= totalTime && 60 % timeStep == 0 )
        {
            NSInteger stride = 60 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every minute"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 300 <= totalTime && 300 % timeStep == 0 )
        {
            NSInteger stride = 300 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 5th minute"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 900 <= totalTime && 900 % timeStep == 0 )
        {
            NSInteger stride = 900 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 15th minute"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 3600 <= totalTime && 3600 % timeStep == 0 )
        {
            NSInteger stride = 3600 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every hour"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
    }
    else if( timeStepLength.year == 0 && timeStepLength.month == 0 && timeStepLength.day == 0 &&
            timeStepLength.hour == 0 && timeStepLength.minute != 0 && timeStepLength.second == 0 )
    {
        NSInteger timeStep = timeStepLength.minute;
        NSInteger totalTime = timeStep * numTimeSteps;
        
        if( 15 <= totalTime && 15 % timeStep == 0 )
        {
            NSInteger stride = 15 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 15th minute"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 30 <= totalTime && 30 % timeStep == 0 )
        {
            NSInteger stride = 30 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 30th minute"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 60 <= totalTime && 60 % timeStep == 0 )
        {
            NSInteger stride = 60 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every hour"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 360 <= totalTime && 360 % timeStep == 0 )
        {
            NSInteger stride = 360 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 6th hour"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 720 <= totalTime && 720 % timeStep == 0 )
        {
            NSInteger stride = 720 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 12th hour"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 1440 <= totalTime && 1440 % timeStep == 0 )
        {
            NSInteger stride = 1440 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every day"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 10080 <= totalTime && 10080 % timeStep == 0 )
        {
            NSInteger stride = 10080 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every week"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
    }
    else if( timeStepLength.year == 0 && timeStepLength.month == 0 && timeStepLength.day == 0 &&
            timeStepLength.hour != 0 && timeStepLength.minute == 0 && timeStepLength.second == 0 )
    {
        NSInteger timeStep = timeStepLength.hour;
        NSInteger totalTime = timeStep * numTimeSteps;
        
        if( 6 <= totalTime && 6 % timeStep == 0 )
        {
            NSInteger stride = 6 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 6th hour"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 12 <= totalTime && 12 % timeStep == 0 )
        {
            NSInteger stride = 12 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 12th hour"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 24 <= totalTime && 24 % timeStep == 0 )
        {
            NSInteger stride = 24 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every day"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 72 <= totalTime && 72 % timeStep == 0 )
        {
            NSInteger stride = 72 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 3rd day"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 168 <= totalTime && 168 % timeStep == 0 )
        {
            NSInteger stride = 168 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every week"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 336 <= totalTime && 336 % timeStep == 0 )
        {
            NSInteger stride = 336 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 2nd week"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 720 <= totalTime && 720 % timeStep == 0 )
        {
            NSInteger stride = 720 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every month"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 4380 <= totalTime && 4380 % timeStep == 0 )
        {
            NSInteger stride = 4380 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every half year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 8760 <= totalTime && 8760 % timeStep == 0 )
        {
            NSInteger stride = 8760 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
    }
    else if( timeStepLength.year == 0 && timeStepLength.month == 0 && timeStepLength.day != 0 &&
            timeStepLength.hour == 0 && timeStepLength.minute == 0 && timeStepLength.second == 0 )
    {
        NSInteger timeStep = timeStepLength.day;
        NSInteger totalTime = timeStep * numTimeSteps;
        
        if( 7 <= totalTime && 7 % timeStep == 0 )
        {
            NSInteger stride = 7 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every week"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 14 <= totalTime && 14 % timeStep == 0 )
        {
            NSInteger stride = 14 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 2nd week"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 30 <= totalTime && 30 % timeStep == 0 )
        {
            NSInteger stride = 30 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every month"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 90 <= totalTime && 90 % timeStep == 0 )
        {
            NSInteger stride = 90 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 3rd month"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 180 <= totalTime && 180 % timeStep == 0 )
        {
            NSInteger stride = 180 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 6th month"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 365 <= totalTime && 364 % timeStep == 0 )
        {
            NSInteger stride = 364 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 365 <= totalTime && 365 % timeStep == 0 )
        {
            NSInteger stride = 365 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 3650 <= totalTime && 3650 % timeStep == 0 )
        {
            NSInteger stride = 3650 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 10th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
    }
    else if( timeStepLength.year == 0 && timeStepLength.month != 0 && timeStepLength.day == 0 &&
            timeStepLength.hour == 0 && timeStepLength.minute == 0 && timeStepLength.second == 0 )
    {
        NSInteger timeStep = timeStepLength.month;
        NSInteger totalTime = timeStep * numTimeSteps;
        
        if( 6 <= totalTime && 6 % timeStep == 0 )
        {
            NSInteger stride = 6 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 6th month"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 12 <= totalTime && 12 % timeStep == 0 )
        {
            NSInteger stride = 12 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 24 <= totalTime && 24 % timeStep == 0 )
        {
            NSInteger stride = 24 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 2nd year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 60 <= totalTime && 60 % timeStep == 0 )
        {
            NSInteger stride = 60 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 5th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 120 <= totalTime && 120 % timeStep == 0 )
        {
            NSInteger stride = 120 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 10th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 300 <= totalTime && 300 % timeStep == 0 )
        {
            NSInteger stride = 300 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 25th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 600 <= totalTime && 600 % timeStep == 0 )
        {
            NSInteger stride = 600 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 50th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 1200 <= totalTime && 1200 % timeStep == 0 )
        {
            NSInteger stride = 1200 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every century"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
    }
    else if( timeStepLength.year != 0 && timeStepLength.month == 0 && timeStepLength.day == 0 &&
            timeStepLength.hour == 0 && timeStepLength.minute == 0 && timeStepLength.second == 0 )
    {
        NSInteger timeStep = timeStepLength.year;
        NSInteger totalTime = timeStep * numTimeSteps;
        
        if( 10 <= totalTime && 10 % timeStep == 0 )
        {
            NSInteger stride = 10 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 10th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 20 <= totalTime && 20 % timeStep == 0 )
        {
            NSInteger stride = 20 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 20th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 50 <= totalTime && 50 % timeStep == 0 )
        {
            NSInteger stride = 50 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 50th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 100 <= totalTime && 100 % timeStep == 0 )
        {
            NSInteger stride = 100 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every century"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 250 <= totalTime && 250 % timeStep == 0 )
        {
            NSInteger stride = 250 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 250th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 500 <= totalTime && 500 % timeStep == 0 )
        {
            NSInteger stride = 500 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 500th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
        
        if( 1000 <= totalTime && 1000 % timeStep == 0 )
        {
            NSInteger stride = 1000 / timeStep;
            
            [timeViewSelector addItemWithTitle:@"Every 1000th year"];
            [[timeViewSelector lastItem] setTag:-stride];
        }
    }
    else
    {
        if( numTimeSteps > 20 ){
            [timeViewSelector addItemWithTitle:@"Every 20rd"];
            [[timeViewSelector lastItem] setTag:20];
        }
        
        if( numTimeSteps > 50 ){
            [timeViewSelector addItemWithTitle:@"Every 50th"];
            [[timeViewSelector lastItem] setTag:50];
            }
        if( numTimeSteps > 100 ){
            [timeViewSelector addItemWithTitle:@"Every 100th"];
            [[timeViewSelector lastItem] setTag:100];
        }
    }
    
    [timeViewSelector selectItemWithTag:selectedTag];
}

#pragma mark Data

- (void) refreshFromData:(BOOL) newData
{
	if( newData )
		[glView rebuildRenderer];
	else
		[glView refreshRenderer];
    
    [self refreshTimeLabels];
}

#pragma mark IBActions

- (IBAction) toggleLegend:(id)sender
{
	if( [sender state] ) {
		[horizontalSpaceTSViewRight setConstant:113.0];
	}
	else {
		[horizontalSpaceTSViewRight setConstant:20.0];
	}
	[legendView setHidden:![sender state]];
}

- (IBAction) selectLeftGlyphItem:(id)sender
{
	NSString *itemName = [[sender selectedItem] title];
    
    if( ![itemName isEqualToString: [_appDelegate.viewSettings leftGlyphActiveItem]] )
    {
        [_appDelegate.viewSettings setLeftGlyphActiveItem:itemName];
        
        _selectedVariableIdxLeft = 0;
        [_appDelegate.viewSettings setLeftGlyphActiveVariable:_variablesLeft[_selectedVariableIdxLeft]];
        
        [self refreshGUI];
        
        [self refreshFromData:NO];
    }
}

- (IBAction) selectLeftGlyphProperty:(id)sender
{
    _selectedVariableIdxLeft = [[sender selectedCell] tag];
    
    [_appDelegate.viewSettings setLeftGlyphActiveVariable:_variablesLeft[_selectedVariableIdxLeft]];
    
    [self refreshLegendGUI];
	
	[self refreshFromData:NO];
}

- (IBAction) selectRightGlyphItem:(id)sender
{
    NSString *itemName = [[sender selectedItem] title];
    
    if( ![itemName isEqualToString: [_appDelegate.viewSettings rightGlyphActiveItem]] )
    {
        [_appDelegate.viewSettings setRightGlyphActiveItem:itemName];
        
        _selectedVariableIdxRight = 0;
        [_appDelegate.viewSettings setRightGlyphActiveVariable:_variablesLeft[_selectedVariableIdxRight]];
        
        [self refreshGUI];
        
        [self refreshFromData:NO];
    }
}

- (IBAction) selectRightGlyphProperty:(id)sender
{
    _selectedVariableIdxRight = [[sender selectedCell] tag];
    
	[_appDelegate.viewSettings setRightGlyphActiveVariable:_variablesRight[_selectedVariableIdxRight]];
	
    [self refreshLegendGUI];
    
	[self refreshFromData:NO];
}

- (IBAction) setActiveColormap:(id)sender
{
	int activeColormap = (int)[sender selectedTag];
	[_appDelegate.viewSettings setActiveColormapIndex:activeColormap forView: ViewIdTS];
	
	[_appDelegate refreshViewFromData:ViewIdTS];
}

- (IBAction) setActiveColormapDiscrete:(id)sender
{
	int colormapIsDiscrete = (int)[sender state];
	[_appDelegate.viewSettings setColormapDiscrete:colormapIsDiscrete forView: ViewIdTS];
	
	[_appDelegate refreshViewFromData:ViewIdTS];
}

- (IBAction) setTimeView:(id)sender
{
    int stride = ABS((int)[sender selectedTag]);
    [[_appDelegate ensembleData] setTimeStepStride:stride];
    
    [_appDelegate refreshViewFromData:ViewIdTS];
}

- (void) refreshTimeLabels
{
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    
    if( ![ensemble isLoaded] ) return;
    
    [self refreshTimeSeriesViewGUI];
    
    NSDateComponents* timeStepLength = [ensemble timeStepLength];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    int firstTimeStepId = [ensemble timeRangeMin];
    NSDateComponents* firstTimeStepOffset = [[NSDateComponents alloc] init];
    [firstTimeStepOffset setYear:timeStepLength.year * firstTimeStepId];
    [firstTimeStepOffset setMonth:timeStepLength.month * firstTimeStepId];
    [firstTimeStepOffset setDay:timeStepLength.day * firstTimeStepId];
    [firstTimeStepOffset setHour:timeStepLength.hour * firstTimeStepId];
    [firstTimeStepOffset setMinute:timeStepLength.minute * firstTimeStepId];
    [firstTimeStepOffset setSecond:timeStepLength.second * firstTimeStepId];
    
    NSDate* startDate = [calendar dateByAddingComponents:firstTimeStepOffset toDate:[ensemble startDate] options:0];
    
    //NSLog(@"%ld/%ld/%ld %ld:%ld:%ld", timeStepLength.year, timeStepLength.month, timeStepLength.day, timeStepLength.hour, timeStepLength.minute, timeStepLength.second );
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    BOOL daysOnly = ( timeStepLength.hour == 0 && timeStepLength.minute == 0 && timeStepLength.second == 0 );
    
    if( daysOnly )
    {
        [dateFormatter setDateFormat:@"d. MMM yyyy"];
    }
    else
    {
        [dateFormatter setDateFormat:@"d. MMM yyyy HH:mm:ss"];
    }
    
    NSInteger labelWidth = daysOnly ? 55 : 90;
    NSInteger labelHeight = 34;
    NSInteger padding = 5;
    NSInteger leadingWhiteSpace = daysOnly ? 10 : 0;
    
    NSInteger numTimeSteps = [ensemble numTimeStepsWithStride];// [ensemble timeRangeMax] - [ensemble timeRangeMin] + 1;
    NSInteger timeStepStride = [ensemble timeStepStride];
    
    NSInteger viewWidth = mainViewContainer.frame.size.width;
    
    NSInteger maxLabels = MAX( 1, (viewWidth-2*leadingWhiteSpace) / (labelWidth+2*padding) - 1 );
    
    //NSLog(@"View Width = %ld, Label Width = %ld, maximum Number of Labels fitting = %ld", viewWidth, labelWidth, maxLabels );
    
    NSInteger glViewWidth = glView.frame.size.width;
    float glyphWidth = (float)glViewWidth / numTimeSteps;
    float glyphCenter = glyphWidth * 0.5;
    
    NSInteger stride = numTimeSteps / maxLabels;
    NSInteger residue = numTimeSteps % maxLabels;
    if( residue != 0 || stride == 0 ) stride++;
    
    residue = numTimeSteps % stride;
    NSInteger numLabels = numTimeSteps / stride;
    if( residue != 0 ) numLabels++;
    
    [_timeLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_timeLabels removeAllObjects];
    for( NSInteger i = 0; i < numLabels-1; i++ )
    {
        NSInteger xOffset = MAX( 0, 40 + (i * stride * glyphWidth) + glyphCenter - labelWidth * 0.5 );
        
        //NSLog(@"LabelID = %ld, position %ld", i, xOffset );
        
        NSTextField *label = [[NSTextField alloc] initWithFrame:CGRectMake(xOffset,8,labelWidth,labelHeight)];
        [[label cell] setWraps:YES];
        [label setAlignment:NSTextAlignmentCenter];
        [label setBordered: NO];
        [label setDrawsBackground:NO];
        [label setEditable:NO];
        
        NSDateComponents* timeStepOffset = [[NSDateComponents alloc] init];
        [timeStepOffset setYear:timeStepLength.year * i * stride * timeStepStride];
        [timeStepOffset setMonth:timeStepLength.month * i * stride * timeStepStride];
        [timeStepOffset setDay:timeStepLength.day * i * stride * timeStepStride];
        [timeStepOffset setHour:timeStepLength.hour * i * stride * timeStepStride];
        [timeStepOffset setMinute:timeStepLength.minute * i * stride * timeStepStride];
        [timeStepOffset setSecond:timeStepLength.second * i * stride * timeStepStride];
        
        //NSLog(@"%ld/%ld/%ld %ld:%ld:%ld", timeStepOffset.year, timeStepOffset.month, timeStepOffset.day, timeStepOffset.hour, timeStepOffset.minute, timeStepOffset.second );
        
        NSDate *date = [calendar dateByAddingComponents:timeStepOffset toDate:startDate options:0];
        [label setStringValue:[dateFormatter stringFromDate:date]];
        
        [_timeLabels addObject:label];
        [mainViewContainer addSubview:label];
    }
    
    NSInteger xOffset = MIN( viewWidth - labelWidth, viewWidth - 40 - glyphCenter - labelWidth * 0.5 );
    
    //NSLog(@"Last Label, position %ld", xOffset );
    
    NSTextField *label = [[NSTextField alloc] initWithFrame:CGRectMake(xOffset,8,labelWidth,labelHeight)];
    [[label cell] setWraps:YES];
    [label setAlignment:NSTextAlignmentCenter];
    [label setBordered: NO];
    [label setDrawsBackground:NO];
    [label setEditable:NO];
    
    //NSInteger numTimeStepsWithStride = (numTimeSteps / timeStepStride) * timeStepStride;
    
    NSDateComponents* timeStepOffset = [[NSDateComponents alloc] init];
    [timeStepOffset setYear:timeStepLength.year * (numTimeSteps-1) * timeStepStride];
    [timeStepOffset setMonth:timeStepLength.month * (numTimeSteps-1) * timeStepStride];
    [timeStepOffset setDay:timeStepLength.day * (numTimeSteps-1) * timeStepStride];
    [timeStepOffset setHour:timeStepLength.hour * (numTimeSteps-1) * timeStepStride];
    [timeStepOffset setMinute:timeStepLength.minute * (numTimeSteps-1) * timeStepStride];
    [timeStepOffset setSecond:timeStepLength.second * (numTimeSteps-1) * timeStepStride];
    
    NSDate *date = [calendar dateByAddingComponents:timeStepOffset toDate:startDate options:0];
    [label setStringValue:[dateFormatter stringFromDate:date]];
    
    [_timeLabels addObject:label];
    [mainViewContainer addSubview:label];
}

@end
