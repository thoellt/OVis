//
//	OVPropertiesWindowController.mm
//

// System Headers

// Custom Headers
#import "OVAppDelegateProtocol.h"
#import "OVColormap.h"
#import "OVViewSettings.h"
#import "OVEnsembleData.h"
#import "OVPropertiesView.h"

#import "SMDoubleSlider.h"

// Local Header
#import "OVPropertiesViewController.h"

@implementation OVPropertiesViewController

#pragma mark View Creation

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    
    if (self) {
		// Initialization code here.
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
		_ensembleData = [_appDelegate ensembleData];
		_viewSettings = [_appDelegate viewSettings];
		
		_timeSingleTimer = nil;
		_memberSingleTimer = nil;
       
       _isDark = [_viewSettings isDark];
	}
	
	return self;
}

#pragma mark GUI

- (void)awakeFromNib
{
    [self refreshGUI];
}

- (void)updateViewConstraints
{
   [super updateViewConstraints];
   
   [self refreshBackgroundColors];
}

- (void) refreshGUI
{
   _isDark = [_viewSettings isDark];
   
   float baseGrayValues[3] = {0.804, 0.929, 0.898};
   if(_isDark)
   {
      baseGrayValues[0] = 1.0 - baseGrayValues[0];
      baseGrayValues[1] = 1.0 - baseGrayValues[1];
      baseGrayValues[2] = 1.0 - baseGrayValues[2];
   }
   
   CGColor *backgrundColor = CGColorCreateGenericRGB(baseGrayValues[0], baseGrayValues[0], baseGrayValues[0], 1.0);
   CGColor *oddColor       = CGColorCreateGenericRGB(baseGrayValues[1], baseGrayValues[1], baseGrayValues[1], 1.0);
   CGColor *evenColor      = CGColorCreateGenericRGB(baseGrayValues[2], baseGrayValues[2], baseGrayValues[2], 1.0);
   
   CALayer *viewLayer[6] = {[CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer], [CALayer layer]};
   
   [viewLayer[0] setBackgroundColor:evenColor]; //RGB plus Alpha Channel
   [viewSectionStatistics setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
   [viewSectionStatistics setLayer:viewLayer[0]];
   
   [viewLayer[1] setBackgroundColor:oddColor]; //RGB plus Alpha Channel
   [viewSection3D setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
   [viewSection3D setLayer:viewLayer[1]];
   
   [viewLayer[2] setBackgroundColor:evenColor]; //RGB plus Alpha Channel
   [viewSection2D setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
   [viewSection2D setLayer:viewLayer[2]];
   
   [viewLayer[3] setBackgroundColor:oddColor]; //RGB plus Alpha Channel
   [viewSectionRisk setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
   [viewSectionRisk setLayer:viewLayer[3]];
   
   [viewLayer[4] setBackgroundColor:evenColor]; //RGB plus Alpha Channel
   [viewSectionCurrent setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
   [viewSectionCurrent setLayer:viewLayer[4]];
   
   [viewLayer[5] setBackgroundColor:backgrundColor]; //RGB plus Alpha Channel
   [self.view setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
   [self.view setLayer:viewLayer[5]];
   
   [self refreshBackgroundColors];
   
	[self refreshPropertiesGUI];
	[self refresh3DGUI];
	[self refresh2DGUI];
	[self refreshRiskGUI];
	[self refreshCurrentGUI];
}

- (void) refreshBackgroundColors
{
   if([_viewSettings isDark] == _isDark) return;
   
   _isDark = [_viewSettings isDark];
   
   float baseGrayValues[3] = {0.804, 0.929, 0.898};
   if(_isDark)
   {
      baseGrayValues[0] = 1.0 - baseGrayValues[0];
      baseGrayValues[1] = 1.0 - baseGrayValues[1];
      baseGrayValues[2] = 1.0 - baseGrayValues[2];
   }
   
   CGColor *backgrundColor = CGColorCreateGenericRGB(baseGrayValues[0], baseGrayValues[0], baseGrayValues[0], 1.0);
   CGColor *oddColor       = CGColorCreateGenericRGB(baseGrayValues[1], baseGrayValues[1], baseGrayValues[1], 1.0);
   CGColor *evenColor      = CGColorCreateGenericRGB(baseGrayValues[2], baseGrayValues[2], baseGrayValues[2], 1.0);
   
   [[viewSectionStatistics layer] setBackgroundColor:evenColor];
   [[viewSection3D layer] setBackgroundColor:oddColor];
   [[viewSection2D layer] setBackgroundColor:evenColor];
   [[viewSectionRisk layer] setBackgroundColor:oddColor];
   [[viewSectionCurrent layer] setBackgroundColor:evenColor];
   
   [[self.view  layer] setBackgroundColor:backgrundColor];
}

- (void) refreshPropertiesGUI
{
	EnsembleDimension *dim = [_ensembleData ensembleDimension];
	
	[timeRangeLoTextField setIntegerValue:0];
	[timeRangeHiTextField setIntegerValue:dim->t > 0 ? dim->t - 1 : 0];
	[timeRangeLoStepper setMinValue:0];
	[timeRangeLoStepper setMaxValue:dim->t > 0 ? dim->t - 1 : 0];
	[timeRangeLoStepper setIntegerValue:0];
	[timeRangeHiStepper setMinValue:0];
	[timeRangeHiStepper setMaxValue:dim->t > 0 ? dim->t - 1 : 0];
	[timeRangeHiStepper setIntegerValue:dim->t > 0 ? dim->t - 1 : 0];
	[timeRangeDoubleSlider setNumberOfTickMarks:dim->t > 0 ? dim->t : 1];
	[timeRangeDoubleSlider setTickMarkPosition:NSTickMarkBelow];
	[timeRangeDoubleSlider setAllowsTickMarkValuesOnly:YES];
	[timeRangeDoubleSlider setMinValue:0];
	[timeRangeDoubleSlider setMaxValue:dim->t > 0 ? dim->t - 1 : 0];
	[timeRangeDoubleSlider setIntegerLoValue:[_ensembleData timeRangeMin]];
	[timeRangeDoubleSlider setIntegerHiValue:[_ensembleData timeRangeMax]];
	
	BOOL timeSingle = [_ensembleData timeShowSingle];
	[timeSingleButton setState:timeSingle];
	[timeSingleTextField setIntegerValue:[_ensembleData timeSingleId]];
	[timeSingleTextField setHidden:!timeSingle];
	[timeSingleSlider setEnabled:timeSingle];
	[timeSingleSlider setMinValue:[_ensembleData timeRangeMin]];
	[timeSingleSlider setMaxValue:[_ensembleData timeRangeMax]];
	[timeSingleSlider setIntegerValue:[_ensembleData timeSingleId]];
	[timeSingleAnimateButton setEnabled:timeSingle];
	
	// Member Range
	[memberRangeLoTextField setIntegerValue:0];
	[memberRangeHiTextField setIntegerValue:dim->m > 0 ? dim->m - 1 : 0];
	[memberRangeLoStepper setMinValue:0];
	[memberRangeLoStepper setMaxValue:dim->m > 0 ? dim->m - 1 : 0];
	[memberRangeLoStepper setIntegerValue:0];
	[memberRangeHiStepper setMinValue:0];
	[memberRangeHiStepper setMaxValue:dim->m > 0 ? dim->m - 1 : 0];
	[memberRangeHiStepper setIntegerValue:dim->m > 0 ? dim->m - 1 : 0];
	[memberRangeDoubleSlider setNumberOfTickMarks:dim->m > 0 ? dim->m : 1];
	[memberRangeDoubleSlider setTickMarkPosition:NSTickMarkBelow];
	[memberRangeDoubleSlider setAllowsTickMarkValuesOnly:YES];
	[memberRangeDoubleSlider setMinValue:0];
	[memberRangeDoubleSlider setMaxValue:dim->m > 0 ? dim->m - 1 : 0];
	[memberRangeDoubleSlider setIntegerLoValue:[_ensembleData memberRangeMin]];
	[memberRangeDoubleSlider setIntegerHiValue:[_ensembleData memberRangeMax]];
	
	// Member Single
	BOOL memberSingle = [_ensembleData memberShowSingle];
	[memberSingleButton setState:memberSingle];
	[memberSingleTextField setIntegerValue:[_ensembleData memberSingleId]];
	[memberSingleTextField setHidden:!memberSingle];
	[memberSingleSlider setEnabled:memberSingle];
	[memberSingleSlider setMinValue:[_ensembleData memberRangeMin]];
	[memberSingleSlider setMaxValue:[_ensembleData memberRangeMax]];
	[memberSingleSlider setIntegerValue:[_ensembleData memberSingleId]];
	[memberSingleAnimateButton setEnabled:memberSingle];
}

- (void) refresh3DGUI
{
    [surface3DVariablePopUP removeAllItems];
    [statistic3DVariablePopUP removeAllItems];
    [noise3DVariablePopUP removeAllItems];
    
    NSArray* variableNames = [_ensembleData allVariableNamesWithDimension:2];
    
    if( [variableNames count] > 0 )
    {
        for( int i = 0; i < [variableNames count]; i++ )
        {
            [surface3DVariablePopUP addItemWithTitle:variableNames[i]];
            [surface3DVariablePopUP.lastItem setTag:i];
            
            [statistic3DVariablePopUP addItemWithTitle:variableNames[i]];
            [statistic3DVariablePopUP.lastItem setTag:i];
            
            [noise3DVariablePopUP addItemWithTitle:variableNames[i]];
            [noise3DVariablePopUP.lastItem setTag:i];
        }
        [surface3DVariablePopUP selectItemWithTag:[_viewSettings activeSurfaceVariable3D]];
        [statistic3DVariablePopUP selectItemWithTag:[_viewSettings activePropertyVariable3D]];
        [noise3DVariablePopUP selectItemWithTag:[_viewSettings activeNoisePropertyVariable3D]];
        
        [surface3DPopUP removeAllItems];
        if( [_ensembleData isVariableStatic:[_viewSettings activeSurfaceVariable3D]] )
        {
            [surface3DPopUP addItemWithTitle:@"Value"];
            [[surface3DPopUP itemWithTitle:@"Value"] setTag:EnsemblePropertyBathymetry];
            
            [_viewSettings setActiveSurface3D:EnsemblePropertyBathymetry];
            
            [surface3DPopUP selectItemWithTag:[_viewSettings activeSurface3D]];
        }
        else
        {
            [surface3DPopUP addItemWithTitle:@"Mean"];
            [[surface3DPopUP itemWithTitle:@"Mean"] setTag:EnsemblePropertyMean];
            
            [surface3DPopUP addItemWithTitle:@"Median"];
            [[surface3DPopUP itemWithTitle:@"Median"] setTag:EnsemblePropertyMedian];
            
            [surface3DPopUP addItemWithTitle:@"MaxMode"];
            [[surface3DPopUP itemWithTitle:@"MaxMode"] setTag:EnsemblePropertyMaximumLikelihood];
            
            [[surface3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[surface3DPopUP lastItem] setTag:-99];
            
            [surface3DPopUP addItemWithTitle:@"Range"];
            [[surface3DPopUP itemWithTitle:@"Range"] setTag:EnsemblePropertyRange];
            
            [surface3DPopUP addItemWithTitle:@"StdDev"];
            [[surface3DPopUP itemWithTitle:@"StdDev"] setTag:EnsemblePropertyStandardDeviation];
            
            [surface3DPopUP addItemWithTitle:@"Variance"];
            [[surface3DPopUP itemWithTitle:@"Variance"] setTag:EnsemblePropertyVariance];
            
            [[surface3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[surface3DPopUP lastItem] setTag:-99];
            
            [surface3DPopUP addItemWithTitle:@"Risk"];
            [[surface3DPopUP itemWithTitle:@"Risk"] setTag:EnsemblePropertyRisk];
            
            if( [_viewSettings activeSurface3D] == EnsemblePropertyBathymetry )
            {
                [_viewSettings setActiveSurface3D:EnsemblePropertyMean];
            }
            [surface3DPopUP selectItemWithTag:[_viewSettings activeSurface3D]];
        }
        
        [statistic3DPopUP removeAllItems];
        if( [_ensembleData isVariableStatic:[_viewSettings activePropertyVariable3D]] )
        {
            [statistic3DPopUP addItemWithTitle:@"Value"];
            [[statistic3DPopUP itemWithTitle:@"Value"] setTag:EnsemblePropertyBathymetry];
            
            [_viewSettings setActiveProperty3D:EnsemblePropertyBathymetry];
            
            [statistic3DPopUP selectItemWithTag:[_viewSettings activeProperty3D]];
        }
        else
        {
            [statistic3DPopUP addItemWithTitle:@"None"];
            [[statistic3DPopUP itemWithTitle:@"None"] setTag:EnsemblePropertyNone];
            
            [[statistic3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[statistic3DPopUP lastItem] setTag:-99];
            
            [statistic3DPopUP addItemWithTitle:@"Mean"];
            [[statistic3DPopUP itemWithTitle:@"Mean"] setTag:EnsemblePropertyMean];
            
            [statistic3DPopUP addItemWithTitle:@"Median"];
            [[statistic3DPopUP itemWithTitle:@"Median"] setTag:EnsemblePropertyMedian];
            
            [statistic3DPopUP addItemWithTitle:@"MaxMode"];
            [[statistic3DPopUP itemWithTitle:@"MaxMode"] setTag:EnsemblePropertyMaximumLikelihood];
            
            [[statistic3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[statistic3DPopUP lastItem] setTag:-99];
            
            [statistic3DPopUP addItemWithTitle:@"Range"];
            [[statistic3DPopUP itemWithTitle:@"Range"] setTag:EnsemblePropertyRange];
            
            [statistic3DPopUP addItemWithTitle:@"StdDev"];
            [[statistic3DPopUP itemWithTitle:@"StdDev"] setTag:EnsemblePropertyStandardDeviation];
            
            [statistic3DPopUP addItemWithTitle:@"Variance"];
            [[statistic3DPopUP itemWithTitle:@"Variance"] setTag:EnsemblePropertyVariance];
            
            [[statistic3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[statistic3DPopUP lastItem] setTag:-99];
            
            [statistic3DPopUP addItemWithTitle:@"Risk"];
            [[statistic3DPopUP itemWithTitle:@"Risk"] setTag:EnsemblePropertyRisk];
            
            if( [_viewSettings activeProperty3D] == EnsemblePropertyBathymetry )
            {
                [_viewSettings setActiveProperty3D:EnsemblePropertyNone];
            }
            [statistic3DPopUP selectItemWithTag:[_viewSettings activeProperty3D]];
        }
        
        [noise3DPopUP removeAllItems];
        if( [_ensembleData isVariableStatic:[_viewSettings activeNoisePropertyVariable3D]] )
        {
            [noise3DPopUP addItemWithTitle:@"Value"];
            [[noise3DPopUP itemWithTitle:@"Value"] setTag:EnsemblePropertyBathymetry];
            
            [_viewSettings setActiveNoiseProperty3D:EnsemblePropertyBathymetry];
            
            [noise3DPopUP selectItemWithTag:[_viewSettings activeNoiseProperty3D]];
        }
        else
        {
            [noise3DPopUP addItemWithTitle:@"None"];
            [[noise3DPopUP itemWithTitle:@"None"] setTag:EnsemblePropertyNone];
            
            [[noise3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[noise3DPopUP lastItem] setTag:-99];
            
            [noise3DPopUP addItemWithTitle:@"Mean"];
            [[noise3DPopUP itemWithTitle:@"Mean"] setTag:EnsemblePropertyMean];
            
            [noise3DPopUP addItemWithTitle:@"Median"];
            [[noise3DPopUP itemWithTitle:@"Median"] setTag:EnsemblePropertyMedian];
            
            [noise3DPopUP addItemWithTitle:@"MaxMode"];
            [[noise3DPopUP itemWithTitle:@"MaxMode"] setTag:EnsemblePropertyMaximumLikelihood];
            
            [[noise3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[noise3DPopUP lastItem] setTag:-99];
            
            [noise3DPopUP addItemWithTitle:@"Range"];
            [[noise3DPopUP itemWithTitle:@"Range"] setTag:EnsemblePropertyRange];
            
            [noise3DPopUP addItemWithTitle:@"StdDev"];
            [[noise3DPopUP itemWithTitle:@"StdDev"] setTag:EnsemblePropertyStandardDeviation];
            
            [noise3DPopUP addItemWithTitle:@"Variance"];
            [[noise3DPopUP itemWithTitle:@"Variance"] setTag:EnsemblePropertyVariance];
            
            [[noise3DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[noise3DPopUP lastItem] setTag:-99];
            
            [noise3DPopUP addItemWithTitle:@"Risk"];
            [[noise3DPopUP itemWithTitle:@"Risk"] setTag:EnsemblePropertyRisk];
            
            if( [_viewSettings activeNoiseProperty3D] == EnsemblePropertyBathymetry )
            {
                [_viewSettings setActiveNoiseProperty3D:EnsemblePropertyNone];
            }
            [noise3DPopUP selectItemWithTag:[_viewSettings activeNoiseProperty3D]];
        }
    }
    
	[colormapFlat3DButton setState:[_viewSettings isColormapFlatForView:ViewId3D]];
	[colormapDiscrete3DButton setState:[_viewSettings isColormapDiscreteForView:ViewId3D]];
    
    [colormap3DPopUP removeAllItems];
    [colormap3DPopUP addItemWithTitle:@"None"];
    [[colormap3DPopUP lastItem] setTag:-1];
    [[colormap3DPopUP menu] addItem:[NSMenuItem separatorItem]];
    [[colormap3DPopUP lastItem] setTag:-99];
    
    int idx = 0;
    OVColormap* colormap = [_viewSettings colormapAtIndex:idx];
    while( colormap )
    {
        [colormap3DPopUP addItemWithTitle:[colormap name]];
        [[colormap3DPopUP lastItem] setTag:idx];
        
        idx++;
        
        colormap = [_viewSettings colormapAtIndex:idx];
    }
    
	[colormap3DPopUP selectItemWithTag:[_viewSettings activeColormapIndexForView:ViewId3D]];
}

- (void) refresh2DGUI
{
    [statistic2DVariablePopUP removeAllItems];
    [noise2DVariablePopUP removeAllItems];
    
    NSArray* variableNames = [_ensembleData allVariableNamesWithDimension:2];
    
    if( [variableNames count] > 0 )
    {
        for( int i = 0; i < [variableNames count]; i++ )
        {
            [statistic2DVariablePopUP addItemWithTitle:variableNames[i]];
            [statistic2DVariablePopUP.lastItem setTag:i];
            
            [noise2DVariablePopUP addItemWithTitle:variableNames[i]];
            [noise2DVariablePopUP.lastItem setTag:i];
        }
        [statistic2DVariablePopUP selectItemWithTag:[_viewSettings activePropertyVariable2D]];
        [noise2DVariablePopUP selectItemWithTag:[_viewSettings activeNoisePropertyVariable2D]];
        
        [statistic2DPopUP removeAllItems];
        if( [_ensembleData isVariableStatic:[_viewSettings activePropertyVariable2D]] )
        {
            [statistic2DPopUP addItemWithTitle:@"Value"];
            [[statistic2DPopUP itemWithTitle:@"Value"] setTag:EnsemblePropertyBathymetry];
            
            [_viewSettings setActiveProperty2D:EnsemblePropertyBathymetry];
            
            [statistic2DPopUP selectItemWithTag:[_viewSettings activeProperty2D]];
        }
        else
        {
            [statistic2DPopUP addItemWithTitle:@"None"];
            [[statistic2DPopUP itemWithTitle:@"None"] setTag:EnsemblePropertyNone];
            
            [[statistic2DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[statistic2DPopUP lastItem] setTag:-99];
            
            [statistic2DPopUP addItemWithTitle:@"Mean"];
            [[statistic2DPopUP itemWithTitle:@"Mean"] setTag:EnsemblePropertyMean];
            
            [statistic2DPopUP addItemWithTitle:@"Median"];
            [[statistic2DPopUP itemWithTitle:@"Median"] setTag:EnsemblePropertyMedian];
            
            [statistic2DPopUP addItemWithTitle:@"MaxMode"];
            [[statistic2DPopUP itemWithTitle:@"MaxMode"] setTag:EnsemblePropertyMaximumLikelihood];
            
            [[statistic2DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[statistic2DPopUP lastItem] setTag:-99];
            
            [statistic2DPopUP addItemWithTitle:@"Range"];
            [[statistic2DPopUP itemWithTitle:@"Range"] setTag:EnsemblePropertyRange];
            
            [statistic2DPopUP addItemWithTitle:@"StdDev"];
            [[statistic2DPopUP itemWithTitle:@"StdDev"] setTag:EnsemblePropertyStandardDeviation];
            
            [statistic2DPopUP addItemWithTitle:@"Variance"];
            [[statistic2DPopUP itemWithTitle:@"Variance"] setTag:EnsemblePropertyVariance];
            
            [[statistic2DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[statistic2DPopUP lastItem] setTag:-99];
            
            [statistic2DPopUP addItemWithTitle:@"Risk"];
            [[statistic2DPopUP itemWithTitle:@"Risk"] setTag:EnsemblePropertyRisk];
            
            if( [_viewSettings activeProperty2D] == EnsemblePropertyBathymetry )
            {
                [_viewSettings setActiveProperty2D:EnsemblePropertyNone];
            }
            [statistic2DPopUP selectItemWithTag:[_viewSettings activeProperty2D]];
        }
        
        [noise2DPopUP removeAllItems];
        if( [_ensembleData isVariableStatic:[_viewSettings activeNoisePropertyVariable2D]] )
        {
            [noise2DPopUP addItemWithTitle:@"Value"];
            [[noise2DPopUP itemWithTitle:@"Value"] setTag:EnsemblePropertyBathymetry];
            
            [_viewSettings setActiveNoiseProperty2D:EnsemblePropertyBathymetry];
            
            [noise2DPopUP selectItemWithTag:[_viewSettings activeNoiseProperty2D]];
        }
        else
        {
            [noise2DPopUP addItemWithTitle:@"None"];
            [[noise2DPopUP itemWithTitle:@"None"] setTag:EnsemblePropertyNone];
            
            [[noise2DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[noise2DPopUP lastItem] setTag:-99];
            
            [noise2DPopUP addItemWithTitle:@"Mean"];
            [[noise2DPopUP itemWithTitle:@"Mean"] setTag:EnsemblePropertyMean];
            
            [noise2DPopUP addItemWithTitle:@"Median"];
            [[noise2DPopUP itemWithTitle:@"Median"] setTag:EnsemblePropertyMedian];
            
            [noise2DPopUP addItemWithTitle:@"MaxMode"];
            [[noise2DPopUP itemWithTitle:@"MaxMode"] setTag:EnsemblePropertyMaximumLikelihood];
            
            [[noise2DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[noise2DPopUP lastItem] setTag:-99];
            
            [noise2DPopUP addItemWithTitle:@"Range"];
            [[noise2DPopUP itemWithTitle:@"Range"] setTag:EnsemblePropertyRange];
            
            [noise2DPopUP addItemWithTitle:@"StdDev"];
            [[noise2DPopUP itemWithTitle:@"StdDev"] setTag:EnsemblePropertyStandardDeviation];
            
            [noise2DPopUP addItemWithTitle:@"Variance"];
            [[noise2DPopUP itemWithTitle:@"Variance"] setTag:EnsemblePropertyVariance];
            
            [[noise2DPopUP menu] addItem:[NSMenuItem separatorItem]];
            [[noise2DPopUP lastItem] setTag:-99];
            
            [noise2DPopUP addItemWithTitle:@"Risk"];
            [[noise2DPopUP itemWithTitle:@"Risk"] setTag:EnsemblePropertyRisk];
            
            if( [_viewSettings activeNoiseProperty2D] == EnsemblePropertyBathymetry )
            {
                [_viewSettings setActiveNoiseProperty2D:EnsemblePropertyNone];
            }
            [noise2DPopUP selectItemWithTag:[_viewSettings activeNoiseProperty2D]];
        }
    }
    
	[statistic2DPopUP selectItemWithTag:[_viewSettings activeProperty2D]];
    
    [colormapFlat2DButton setState:[_viewSettings isColormapFlatForView:ViewId2D]];
	[colormapDiscrete2DButton setState:[_viewSettings isColormapDiscreteForView:ViewId2D]];
    
    [colormap2DPopUP removeAllItems];
    [colormap2DPopUP addItemWithTitle:@"None"];
    [[colormap2DPopUP lastItem] setTag:-1];
    [[colormap2DPopUP menu] addItem:[NSMenuItem separatorItem]];
    
    int idx = 0;
    OVColormap* colormap = [_viewSettings colormapAtIndex:idx];
    while( colormap )
    {
        [colormap2DPopUP addItemWithTitle:[colormap name]];
        [[colormap2DPopUP lastItem] setTag:idx];
        
        idx++;
        
        colormap = [_viewSettings colormapAtIndex:idx];
    }
    
	[colormap2DPopUP selectItemWithTag:[_viewSettings activeColormapIndexForView:ViewId2D]];
}

- (void) refreshRiskGUI
{
    // TODO VAR
    if( ![_ensembleData isLoaded] ) return;
    
    // TODO VAR
	float* isoRange = [_ensembleData dataRangeForVariable:0];
	int absMax = MAX( fabsf(isoRange[0]), fabsf(isoRange[1])) * 100;
	
	int initialVal = absMax >= 17 ? 17 : 0;
	
	[_ensembleData setRiskHeightIsoValue:(initialVal) * 0.01f];
	
	[riskHeightIsoTextField setIntegerValue:initialVal];
	
	[riskHeightIsoStepper setMinValue:-absMax];
	[riskHeightIsoStepper setMaxValue:absMax];
	[riskHeightIsoStepper setIntegerValue:initialVal];
	
	[riskHeightIsoSlider setMinValue:-absMax];
	[riskHeightIsoSlider setMaxValue:absMax];
	[riskHeightIsoSlider setIntegerValue:initialVal];
	[riskHeightIsoSlider setNumberOfTickMarks:2*absMax+1];
	
	[_appDelegate refreshViewFromData:ViewIdTS];
	
	[_ensembleData setRiskIsoValue:0.0f];
	
	[riskIsoTextField setIntegerValue:0];
	
	[riskIsoStepper setMinValue:0];
	[riskIsoStepper setMaxValue:100];
	[riskIsoStepper setIntegerValue:0];
	
	[riskIsoSlider setMinValue:0];
	[riskIsoSlider setMaxValue:100];
	[riskIsoSlider setIntegerValue:0];
	[riskIsoSlider setNumberOfTickMarks:100];
}

- (void) refreshCurrentGUI
{
    BOOL isTracingEnabled = [_viewSettings isPathlineTracingEnabled];
    
    [enableCurrentTracingButton setState:isTracingEnabled ? NSOnState : NSOffState];
    
    
    [colormapCurrentPopUP removeAllItems];
    [colormapCurrentPopUP addItemWithTitle:@"None"];
    [[colormapCurrentPopUP lastItem] setTag:-1];
    [[colormapCurrentPopUP menu] addItem:[NSMenuItem separatorItem]];
    
    int idx = 0;
    OVColormap* colormap = [_viewSettings colormapAtIndex:idx];
    while( colormap )
    {
        [colormapCurrentPopUP addItemWithTitle:[colormap name]];
        [[colormapCurrentPopUP lastItem] setTag:idx];
        
        idx++;
        
        colormap = [_viewSettings colormapAtIndex:idx];
    }
    
	[colormapCurrentPopUP selectItemWithTag:[_viewSettings activeColormapPathline]];

	
	[currentScaleStepper setMinValue:1];
	[currentScaleStepper setMaxValue:200];
	
	[currentScaleSlider setMinValue:1];
	[currentScaleSlider setMaxValue:200];
	[currentScaleSlider setNumberOfTickMarks:20];
    
    [self refreshPathlineScaleControls];
	
	
	[currentAlphaStepper setMinValue:1];
	[currentAlphaStepper setMaxValue:2000000];
	
	[currentAlphaSlider setMinValue:1];
	[currentAlphaSlider setMaxValue:2000000];
	[currentAlphaSlider setNumberOfTickMarks:20];
    
    [self refreshPathlineAlphaControls];
}

#pragma mark Animation

- (void) increaseSingleTimeStep: (NSTimer *)timer
{
	if( ![_ensembleData timeShowSingle] ) return;
	
	int activeId = [_ensembleData timeSingleId];
	int maxId = [_ensembleData timeRangeMax];
	
	if( activeId >= maxId )
	{
		activeId = [_ensembleData timeRangeMin];
		
	} else {
		activeId++;
	}
	
	[_ensembleData setTimeSingleId:activeId];
	
	activeId = [_ensembleData timeSingleId];
	[timeSingleSlider setIntValue:activeId];
	[timeSingleTextField setIntValue:activeId];
}

- (void) increaseSingleMember: (NSTimer *)timer
{
	if( ![_ensembleData memberShowSingle] ) return;
	
	int activeId = [_ensembleData memberSingleId];
	int maxId = [_ensembleData memberRangeMax];
	
	if( activeId >= maxId )
	{
		activeId = [_ensembleData memberRangeMin];
		
	} else {
		activeId++;
	}
	
	[_ensembleData setMemberSingleId:activeId];
	
	activeId = [_ensembleData memberSingleId];
	[memberSingleSlider setIntValue:activeId];
	[memberSingleTextField setIntValue:activeId];
}

#pragma mark IBActions

- (IBAction) setTimeRange:(id)sender
{
	if( sender == timeRangeLoStepper || sender == timeRangeLoTextField )
	{
		int v = [sender intValue];
		
		// sanitize textfield input
		if( !( v < [timeRangeLoStepper minValue] || v > [timeRangeLoStepper maxValue] ) )
		{
			[_ensembleData setTimeRangeMin:v];
		}
		
		[self refreshTimeRangeControls];
	}
	else if( sender == timeRangeHiStepper || sender == timeRangeHiTextField )
	{
		int v = [sender intValue];
		
		// sanitize textfield input
		if( !( v < [timeRangeHiStepper minValue] || v > [timeRangeHiStepper maxValue] ) )
		{
			[_ensembleData setTimeRangeMax:v];
		}
		
		[self refreshTimeRangeControls];
	}
}

- (IBAction) setTimeRangeFromSlider:(id)sender
{
	[_ensembleData setTimeRangeMin:[sender intLoValue]];
	
	[_ensembleData setTimeRangeMax:[sender intHiValue]];
	
	[self refreshTimeRangeControls];
}

- (IBAction) setTimeSingle:(id)sender
{
	BOOL active = [sender state];
	
	[_ensembleData setTimeShowSingle:active];
	
	[timeSingleTextField setHidden:!active];
	[timeSingleSlider setEnabled:active];
	[timeSingleAnimateButton setEnabled:active];
}

- (IBAction) setTimeSingleId:(id)sender
{
	int idx = [sender intValue];
	[_ensembleData setTimeSingleId:idx];
	
	idx = [_ensembleData timeSingleId];
	[timeSingleTextField setIntValue:idx];
}

- (IBAction) setTimeSingleAnimate:(id)sender
{
	BOOL active = [sender state];
	
	[_viewSettings setAnimateTime:active];
	
	if( active ){
		
		if( !_timeSingleTimer )
			_timeSingleTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(increaseSingleTimeStep:) userInfo:nil repeats:YES];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_timeSingleTimer forMode:NSDefaultRunLoopMode];
	}
	else {
		
		[_timeSingleTimer invalidate];
		_timeSingleTimer = nil;
	}
}

- (IBAction) setMemberRange:(id)sender
{
	if( sender == memberRangeLoStepper || sender == memberRangeLoTextField )
	{
		int v = [sender intValue];
		
		// sanitize textfield input
		if( !(v < [memberRangeLoStepper minValue] || v > [memberRangeLoStepper maxValue] ) )
		{
			[_ensembleData setMemberRangeMin:v];
		}
		
		[self refreshMemberRangeControls];
	}
	else if( sender == memberRangeHiStepper || sender == memberRangeHiTextField )
	{
		int v = [sender intValue];
		
		// sanitize textfield input
		if( !( v < [memberRangeHiStepper minValue] || v > [memberRangeHiStepper maxValue] ) )
		{
			[_ensembleData setMemberRangeMax:v];
		}
		
		[self refreshMemberRangeControls];
	}
}

- (IBAction) setMemberRangeFromSlider:(id)sender
{
	[_ensembleData setMemberRangeMin:[sender intLoValue]];	
	
	[_ensembleData setMemberRangeMax:[sender intHiValue]];
	
	[self refreshMemberRangeControls];
}

- (IBAction) setMemberSingle:(id)sender
{
	BOOL active = [sender state];
	
	[_ensembleData setMemberShowSingle:active];
	
	[memberSingleTextField setHidden:!active];
	[memberSingleSlider setEnabled:active];
	[memberSingleAnimateButton setEnabled:active];
}

- (IBAction) setMemberSingleId:(id)sender
{
	[_ensembleData setMemberSingleId:[sender intValue]];
	[memberSingleTextField setIntValue:[_ensembleData memberSingleId]];
}

- (IBAction) setMemberSingleAnimate:(id)sender
{
	BOOL active = [sender state];
	
	[_viewSettings setAnimateMember:active];
	
	if( active ){
		
		if( !_memberSingleTimer )
			_memberSingleTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(increaseSingleMember:) userInfo:nil repeats:YES];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_memberSingleTimer forMode:NSDefaultRunLoopMode];
	}
	else {
		
		[_memberSingleTimer invalidate];
		_memberSingleTimer = nil;
	}
}

- (IBAction) setActiveSurface3D:(id)sender
{
	OVEnsembleProperty activeStatistic = (OVEnsembleProperty)[sender selectedTag];
	[_viewSettings setActiveSurface3D:activeStatistic];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveSurfaceVariable3D:(id)sender
{
	NSInteger activeVariable = [sender selectedTag];
	[_viewSettings setActiveSurfaceVariable3D:activeVariable];
	
    [self refresh3DGUI];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveStatistic3D:(id)sender
{
	OVEnsembleProperty activeStatistic = (OVEnsembleProperty)[sender selectedTag];
	[_viewSettings setActiveProperty3D:activeStatistic];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveStatisticVariable3D:(id)sender
{
	NSInteger activeVariable = [sender selectedTag];
	[_viewSettings setActivePropertyVariable3D:activeVariable];
	
    [self refresh3DGUI];
    
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveColormap3D:(id)sender
{
	int activeColormap = (int)[sender selectedTag];
	[_viewSettings setActiveColormapIndex:activeColormap forView: ViewId3D];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveColormapFlat3D:(id)sender
{
	int colormapIsFlat = (int)[sender state];
	[_viewSettings setColormapFlat:colormapIsFlat forView: ViewId3D];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveColormapDiscrete3D:(id)sender
{
	int colormapIsDiscrete = (int)[sender state];
	[_viewSettings setColormapDiscrete:colormapIsDiscrete forView: ViewId3D];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveNoiseStatistic3D:(id)sender
{
	OVEnsembleProperty activeNoiseStatistic = (OVEnsembleProperty)[sender selectedTag];
	[_viewSettings setActiveNoiseProperty3D:activeNoiseStatistic];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveNoiseStatisticVariable3D:(id)sender
{
	NSInteger activeVariable = [sender selectedTag];
	[_viewSettings setActiveNoisePropertyVariable3D:activeVariable];
	
    [self refresh3DGUI];
	
	[_appDelegate refreshViewFromData:ViewId3D];
}

- (IBAction) setActiveStatistic2D:(id)sender
{
	OVEnsembleProperty activeStatistic = (OVEnsembleProperty)[sender selectedTag];
	[_viewSettings setActiveProperty2D:activeStatistic];
	
	[_appDelegate refreshViewFromData:ViewId2D];
}

- (IBAction) setActiveStatisticVariable2D:(id)sender
{
	NSInteger activeVariable = [sender selectedTag];
	[_viewSettings setActivePropertyVariable2D:activeVariable];
    
    [self refresh2DGUI];
	
	[_appDelegate refreshViewFromData:ViewId2D];
}

- (IBAction) setActiveColormap2D:(id)sender
{
	int activeColormap = (int)[sender selectedTag];
	[_viewSettings setActiveColormapIndex:activeColormap forView: ViewId2D];
	
	[_appDelegate refreshViewFromData:ViewId2D];
}

- (IBAction) setActiveColormapFlat2D:(id)sender
{
	int colormapIsFlat = (int)[sender state];
	[_viewSettings setColormapFlat:colormapIsFlat forView: ViewId2D];
	
	[_appDelegate refreshViewFromData:ViewId2D];
}

- (IBAction) setActiveColormapDiscrete2D:(id)sender
{
	int colormapIsDiscrete = (int)[sender state];
	[_viewSettings setColormapDiscrete:colormapIsDiscrete forView: ViewId2D];
	
	[_appDelegate refreshViewFromData:ViewId2D];
}

- (IBAction) setActiveNoiseStatistic2D:(id)sender
{
	OVEnsembleProperty activeNoiseStatistic = (OVEnsembleProperty)[sender selectedTag];
	[_viewSettings setActiveNoiseProperty2D:activeNoiseStatistic];
	
	[_appDelegate refreshViewFromData:ViewId2D];
}

- (IBAction) setActiveNoiseStatisticVariable2D:(id)sender
{
	NSInteger activeVariable = [sender selectedTag];
	[_viewSettings setActiveNoisePropertyVariable2D:activeVariable];
    
    [self refresh2DGUI];
	
	[_appDelegate refreshViewFromData:ViewId2D];
}

- (IBAction) setRiskHeightIsoValue:(id)sender
{
	int v = [sender intValue];
	
	// sanitize textfield input
	if( !(v < [riskHeightIsoStepper minValue] || v > [riskHeightIsoStepper maxValue] ) )
	{
		[_ensembleData setRiskHeightIsoValue:(float)(v) * 0.01f];
	}
	
	[self refreshRiskHeightControls];
	
	[_appDelegate refreshAllViewsFromData];
}

- (IBAction) setRiskIsoValue:(id)sender
{
	int v = [sender intValue];
	
	// sanitize textfield input
	if( !(v < [riskIsoStepper minValue] || v > [riskIsoStepper maxValue] ) )
	{
		[_ensembleData setRiskIsoValue:(float)(v) * 0.01f];
	}
	
	[self refreshRiskControls];
}

- (IBAction) enableCurrentTracing:(id)sender
{
    [_viewSettings setIsPathlineTracingEnabled:[enableCurrentTracingButton state] == NSOnState];
    
    [_appDelegate refreshAllViewsFromData];
}

- (IBAction) clearCurrentTrace:(id)sender
{
    //[_ensembleData clearPathlineTexture];
    
	[_viewSettings setIsPathlineTraceAvailable:NO];
	
    [_appDelegate refreshAllViewsFromData];
}

- (IBAction) setActiveColormapPathline:(id)sender
{
	int activeColormap = (int)[sender selectedTag];
	[_viewSettings setActiveColormapPathline:activeColormap];
	
    [_appDelegate refreshAllViewsFromData];
}

- (IBAction) setPathlineScale:(id)sender
{
    int v = [sender intValue];
    
    // sanitize textfield input
	if( !(v < [currentScaleStepper minValue] || v > [currentScaleStepper maxValue] ) )
	{
        [_viewSettings setPathlineScale:v];
	}
	
	[self refreshPathlineScaleControls];
    
    [_appDelegate refreshAllViewsFromData];
}

- (IBAction) setPathlineAlpha:(id)sender
{
    int v = [sender intValue];
    
    // sanitize textfield input
	if( !(v < [currentAlphaStepper minValue] || v > [currentAlphaStepper maxValue] ) )
	{
        [_viewSettings setPathlineAlpha:v];
	}
	
	[self refreshPathlineAlphaControls];
    
    [_appDelegate refreshAllViewsFromData];
}

#pragma mark GUI Helpers

- (void) refreshTimeRangeControls
{
	int v = [_ensembleData timeRangeMin];
	
	[timeRangeLoTextField setIntValue:v];
	[timeRangeLoStepper setIntValue:v];
	[timeRangeDoubleSlider setIntLoValue:v];
	
	[timeSingleSlider setMinValue:v];
	
	v= [_ensembleData timeRangeMax];
	
	[timeRangeHiTextField setIntValue:v];
	[timeRangeHiStepper setIntValue:v];
	[timeRangeDoubleSlider setIntHiValue:v];
	
	[timeSingleSlider setMaxValue:v];
	
	[self setTimeSingleId:timeSingleSlider];
}

- (void) refreshMemberRangeControls
{
	int v= [_ensembleData memberRangeMin];
	
	[memberRangeLoTextField setIntValue:v];
	[memberRangeLoStepper setIntValue:v];
	[memberRangeDoubleSlider setIntLoValue:v];
	
	[memberSingleSlider setMinValue:v];
	
	v= [_ensembleData memberRangeMax];
	
	[memberRangeHiTextField setIntValue:v];
	[memberRangeHiStepper setIntValue:v];
	[memberRangeDoubleSlider setIntHiValue:v];
	
	[memberSingleSlider setMaxValue:v];
	
	[self setMemberSingleId:memberSingleSlider];
}

- (void) refreshRiskHeightControls
{
	float v = [_ensembleData riskHeightIsoValue] * 100.0f;
	
	v = ( v < 0 ) ? v - 0.5f : v + 0.5f;
	
	[riskHeightIsoStepper setIntValue:(int)v];
	[riskHeightIsoTextField setIntValue:(int)v];
	[riskHeightIsoSlider setIntValue:(int)v];
}

- (void) refreshRiskControls
{
	float v = [_ensembleData riskIsoValue] * 100.0f;
	
	v = ( v < 0 ) ? v - 0.5f : v + 0.5f;
	
	[riskIsoStepper setIntValue:(int)v];
	[riskIsoTextField setIntValue:(int)v];
	[riskIsoSlider setIntValue:(int)v];
}

- (void) refreshPathlineScaleControls
{
	float v = [_viewSettings pathlineScale];
	
	[currentScaleStepper setIntValue:(int)v];
	[currentScaleTextField setIntValue:(int)v];
	[currentScaleSlider setIntValue:(int)v];
}

- (void) refreshPathlineAlphaControls
{
	float v = [_viewSettings pathlineAlpha];
	
	[currentAlphaStepper setIntValue:(int)v];
	[currentAlphaTextField setIntValue:(int)v];
	[currentAlphaSlider setIntValue:(int)v];
}

@end
