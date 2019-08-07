//
//  OVHistogramController.m
//  OVis
//
//  Created by Thomas Höllt on 26/09/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

// System Headers
#import <Quartz/Quartz.h>

// Custom Headers
#import "OVAppDelegate.h"
#import "OVAppDelegateProtocol.h"
#import "OVEnsembleData.h"
#import "OVViewSettings.h"
#import "OVEnsembleData+Statistics.h"
#import "OVVariable2D.h"

// Local Header
#import "OVHistogramController.h"

@implementation OVHistogramController

@synthesize leftVariable = _leftVariable;
@synthesize rightVariable = _rightVariable;

- (id) init
{
   self = [super init];

   if( self )
   {
      _appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
      
      _viewSettings = [_appDelegate viewSettings];
      
      _isDark = [_viewSettings isDark];
      
      float axesGray = _isDark ? 0.85 : 0.15;
      float labelGray = _isDark ? 0.85 : 0.05;

      _backGroundColor = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.0)
                                                          green:CPTFloat(0.0)
                                                           blue:CPTFloat(0.0)
                                                          alpha:CPTFloat(0.0)];
      if(_isDark)
      {
         _barColors[0] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.9)
                                                          green:CPTFloat(0.1)
                                                           blue:CPTFloat(0.9)
                                                          alpha:CPTFloat(0.8)];
         _barColors[1] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.8)
                                                          green:CPTFloat(0.0)
                                                           blue:CPTFloat(0.8)
                                                          alpha:CPTFloat(0.85)];
      }
      else
      {
         _barColors[0] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.25)
                                                          green:CPTFloat(0.25)
                                                           blue:CPTFloat(0.4)
                                                          alpha:CPTFloat(0.85)];
         _barColors[1] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.15)
                                                          green:CPTFloat(0.15)
                                                           blue:CPTFloat(0.3)
                                                          alpha:CPTFloat(0.85)];
      }
      _barColors[2] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.25)
                                                       green:CPTFloat(0.65)
                                                        blue:CPTFloat(0.9)
                                                       alpha:CPTFloat(0.85)];
      _barColors[3] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.15)
                                                       green:CPTFloat(0.55)
                                                        blue:CPTFloat(0.8)
                                                       alpha:CPTFloat(0.85)];
      _lineColor = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.15)
                                                    green:CPTFloat(0.15)
                                                     blue:CPTFloat(0.3)
                                                    alpha:CPTFloat(1.0)];
      _axesColor = [[CPTColor alloc] initWithComponentRed:CPTFloat(axesGray)
                                                    green:CPTFloat(axesGray)
                                                     blue:CPTFloat(axesGray)
                                                    alpha:CPTFloat(1.0)];
      _gridAxesColor = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.5)
                                                        green:CPTFloat(0.5)
                                                         blue:CPTFloat(0.5)
                                                        alpha:CPTFloat(0.5)];
      _labelColor = [[CPTColor alloc] initWithComponentRed:CPTFloat(labelGray)
                                                     green:CPTFloat(labelGray)
                                                      blue:CPTFloat(labelGray)
                                                     alpha:CPTFloat(1.0)];

      _data[0] = nil;
      _data[1] = nil;

      _leftVariable = nil;
      _rightVariable = nil;
   }

   return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    
    [self rebuildGraph];
}

-(void) refreshTheme
{
   if(_isDark == [_viewSettings isDark]) return;
   
   _isDark = [_viewSettings isDark];
   
   float axesGray = _isDark ? 0.85 : 0.15;
   float labelGray = _isDark ? 0.85 : 0.05;
   
   [_histogramGraph[0].plotAreaFrame setFill: [CPTFill fillWithColor:_backGroundColor]];
   [_histogramGraph[1].plotAreaFrame setFill: [CPTFill fillWithColor:_backGroundColor]];
   
   _axesColor = [[CPTColor alloc] initWithComponentRed:CPTFloat(axesGray)
                                                 green:CPTFloat(axesGray)
                                                  blue:CPTFloat(axesGray)
                                                 alpha:CPTFloat(1.0)];

   _labelColor = [[CPTColor alloc] initWithComponentRed:CPTFloat(labelGray)
                                                  green:CPTFloat(labelGray)
                                                   blue:CPTFloat(labelGray)
                                                  alpha:CPTFloat(1.0)];

   
   // Create a line style that we will apply to the axis and data line.
   CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
   lineStyle.lineColor = _axesColor;
   lineStyle.lineWidth = 1.0f;
   
   // Create a text style that we will use for the axis labels.
   CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
   textStyle.fontName = @"Lucida Grande";
   textStyle.fontSize = 13;
   textStyle.color = _labelColor;
   
   for( int i = 0; i < 2; i++ )
   {
      CPTXYAxisSet *axisSet = (CPTXYAxisSet *) [_histogramGraph[i] axisSet];
      
      axisSet.xAxis.titleTextStyle = textStyle;
      axisSet.xAxis.axisLineStyle = lineStyle;
      axisSet.xAxis.majorTickLineStyle = lineStyle;
      axisSet.xAxis.minorTickLineStyle = lineStyle;
      axisSet.xAxis.labelTextStyle = textStyle;
      
      axisSet.yAxis.titleTextStyle = textStyle;
      axisSet.yAxis.axisLineStyle = lineStyle;
      axisSet.yAxis.majorTickLineStyle = lineStyle;
      axisSet.yAxis.minorTickLineStyle = lineStyle;
      axisSet.yAxis.labelTextStyle = textStyle;
   }
   
   if(_isDark)
   {
      _barColors[0] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.9)
                                                       green:CPTFloat(0.1)
                                                        blue:CPTFloat(0.9)
                                                       alpha:CPTFloat(0.8)];
      _barColors[1] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.8)
                                                       green:CPTFloat(0.0)
                                                        blue:CPTFloat(0.8)
                                                       alpha:CPTFloat(0.85)];
   }
   else
   {
      _barColors[0] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.25)
                                                       green:CPTFloat(0.25)
                                                        blue:CPTFloat(0.4)
                                                       alpha:CPTFloat(0.85)];
      _barColors[1] = [[CPTColor alloc] initWithComponentRed:CPTFloat(0.15)
                                                       green:CPTFloat(0.15)
                                                        blue:CPTFloat(0.3)
                                                       alpha:CPTFloat(0.85)];
   }
   
   CPTGradient *fillGradient;
   fillGradient= [CPTGradient gradientWithBeginningColor:_barColors[0] endingColor:_barColors[1]];
   fillGradient.angle = (CGFloat)-45.0;
   
   CPTBarPlot *barPlot = (CPTBarPlot*)([_histogramGraph[0] plotAtIndex:0]);
   barPlot.fill = [CPTFill fillWithGradient:fillGradient];
}

- (void) rebuildGraph
{
    [self setUpGraph];
    //[self setUpKdePlot];
    [self setUpHistogramPlot];
    
    [_histogramGraph[0] reloadData];
    [_histogramGraph[1] reloadData];
}

- (void) setUpGraph
{
    EnsembleDimension* dim = [[_appDelegate ensembleData] ensembleDimension];
    int numBins = [[_appDelegate ensembleData] histogramBins];
    
    _histogramGraph[0] = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    _histogramGraph[1] = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
   
    for( int i = 0; i < 2; i++ )
    {
        _histogramGraph[i].paddingLeft = 0;
        _histogramGraph[i].paddingTop = 0;
        _histogramGraph[i].paddingRight = 0;
        _histogramGraph[i].paddingBottom = 0;
        
        _histogramGraph[i].plotAreaFrame.paddingTop = 10.0f;
        _histogramGraph[i].plotAreaFrame.paddingBottom = 50.0f;
        
        [_histogramGraph[i].plotAreaFrame setFill: [CPTFill fillWithColor:_backGroundColor]];
    }
    
    _histogramGraph[0].plotAreaFrame.paddingRight = 1.0f;
    _histogramGraph[0].plotAreaFrame.paddingLeft = 80.0f;
    _histogramGraph[1].plotAreaFrame.paddingRight = 80.0f;
    _histogramGraph[1].plotAreaFrame.paddingLeft = 0.0f;
    
    [_leftHistogramView setHostedGraph:_histogramGraph[0]];
    [_rightHistogramView setHostedGraph:_histogramGraph[1]];
    
    // Define the space for the bars. (12 Bars with a max height of 150)
    for( int i = 0; i < 2; i++ )
    {
        _plotSpace[i] = (CPTXYPlotSpace *)[_histogramGraph[i] defaultPlotSpace];
        _plotSpace[i].yRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:0.0f]
                                                            length:[NSNumber numberWithInt:numBins]];
        _plotSpace[i].xRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:0.0f]
                                                            length:[NSNumber numberWithLongLong:MAX(dim->m, 1)]];
    }
    
    
    // Create a line style that we will apply to the axis and data line.
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = _axesColor;
    lineStyle.lineWidth = 1.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = _gridAxesColor;
    gridLineStyle.lineWidth = 1.0f;
    
    // Create a text style that we will use for the axis labels.
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    //textStyle.fontName = @"Helvetica Neue Light";
    textStyle.fontName = @"Lucida Grande";
    textStyle.fontSize = 13;
    textStyle.color = _labelColor;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGeneratesDecimalNumbers:NO];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    [formatter setMaximumFractionDigits:2];
    
    
    float baseLine[2] = { 0.0f, 0.0f };
    NSString* varName[2] = { @"", @"" };
    if( _leftVariable )
    {
        varName[0] = [NSString stringWithFormat:@"%@ in %@",_leftVariable.name, _leftVariable.unit];
        float* range = _leftVariable.dataRange;
        if( range[0] > 0 && range[1] > 0 ) baseLine[0] = range[1];
        if( range[0] < 0 && range[1] < 0 ) baseLine[0] = range[0];
    }
    if( _rightVariable )
    {
        varName[1] = [NSString stringWithFormat:@"%@ in %@",_rightVariable.name, _rightVariable.unit];
        float* range = _rightVariable.dataRange;
        if( range[0] > 0 && range[1] > 0 ) baseLine[0] = range[1];
        if( range[0] < 0 && range[1] < 0 ) baseLine[0] = range[0];
    }
    
    // Modify the graph's axis with a label, line style, etc.
    for( int i = 0; i < 2; i++ )
    {
         CPTXYAxisSet *axisSet = (CPTXYAxisSet *) [_histogramGraph[i] axisSet];
         axisSet.xAxis.title = @"Number of members.";
         axisSet.xAxis.titleTextStyle = textStyle;
         axisSet.xAxis.titleOffset = 30.0f;
         axisSet.xAxis.axisLineStyle = lineStyle;
         axisSet.xAxis.majorTickLineStyle = lineStyle;
         axisSet.xAxis.minorTickLineStyle = lineStyle;
         axisSet.xAxis.labelTextStyle = textStyle;
         axisSet.xAxis.labelOffset = 3.0f;
         axisSet.xAxis.majorIntervalLength = [NSNumber numberWithFloat:10.0f];
         axisSet.xAxis.minorTicksPerInterval = 4.0;
         axisSet.xAxis.minorTickLength = 5.0f;
         axisSet.xAxis.majorTickLength = 7.0f;
         axisSet.xAxis.majorGridLineStyle = gridLineStyle;
         axisSet.xAxis.labelFormatter = formatter;
       
         axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];

         axisSet.yAxis.title = varName[i];
         axisSet.yAxis.titleTextStyle = textStyle;
         axisSet.yAxis.titleOffset = 60.0f;
         axisSet.yAxis.axisLineStyle = lineStyle;
         axisSet.yAxis.majorTickLineStyle = lineStyle;
         axisSet.yAxis.minorTickLineStyle = lineStyle;
         axisSet.yAxis.labelTextStyle = textStyle;
         axisSet.yAxis.labelOffset = 3.0f;
         axisSet.yAxis.majorIntervalLength = [NSNumber numberWithInt:numBins/10];
         axisSet.yAxis.minorTicksPerInterval = 1;
         axisSet.yAxis.minorTickLength = 5.0f;
         axisSet.yAxis.majorTickLength = 7.0f;
         axisSet.yAxis.labelFormatter = formatter;
   
         if( i == 0 )
         {
            axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
         }
         else
         {
            axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithUpperOffset:0];
            axisSet.yAxis.tickDirection = CPTSignPositive;
         }
    }
}

- (void) setUpKdePlot
{
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] init];
    
    CPTMutableLineStyle *scatterLineStyle = [[CPTMutableLineStyle alloc] init];
    scatterLineStyle.lineWidth              = 3.0;
    scatterLineStyle.lineColor              = _lineColor;
    scatterPlot.dataLineStyle = scatterLineStyle;
    //scatterPlot.areaFill = [CPTFill fillWithColor:[CPTColor redColor]];
    //scatterPlot.areaBaseValue = CPTDecimalFromFloat(0);
    
    scatterPlot.dataSource = self;
    scatterPlot.interpolation = CPTScatterPlotInterpolationCurved;
    scatterPlot.identifier = @"LeftScatterPlot";

    [_histogramGraph[0] addPlot:scatterPlot toPlotSpace:_plotSpace[0]];
}

- (void) setUpHistogramPlot
{
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    
    int numBins = [ensemble histogramBins];
    
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = CPTFloat(0.25);
    barLineStyle.lineColor = _axesColor;
    
    CPTGradient *fillGradient[2];
    fillGradient[0]= [CPTGradient gradientWithBeginningColor:_barColors[0] endingColor:_barColors[1]];
    fillGradient[1]= [CPTGradient gradientWithBeginningColor:_barColors[3] endingColor:_barColors[2]];
    fillGradient[0].angle = (CGFloat)-45.0;
    fillGradient[1].angle = (CGFloat)45.0;
    
    float offset = 0.0f;
    float width = 1.0f;
    float r = 0.0f;
    float r_tick = 0.0f;
    
    if( [ensemble isLoaded] )
    {
        for( int i = 0; i < 2; i++ )
        {
            if( ( i == 0 && !_leftVariable ) || ( i == 1 && !_rightVariable ) ) continue;
            
            CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
            barPlot.lineStyle = barLineStyle;
            barPlot.barsAreHorizontal = YES;
            barPlot.barWidthsAreInViewCoordinates = NO;
            barPlot.barCornerRadius = CPTFloat(3.0);
            barPlot.fill = [CPTFill fillWithGradient:fillGradient[i]];
            
            float *ensembleRange = (i==0)?_leftVariable.dataRange:_rightVariable.dataRange;
            r = ensembleRange[0] - ensembleRange[1];
            r_tick = r / 10;
            
            offset = 0.0f;
            width = r / (float)numBins;
            
            barPlot.plotRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:ensembleRange[1]]
                                                             length:[NSNumber numberWithFloat:r]];
            
            barPlot.barBasesVary = NO;
            barPlot.dataSource = self;
            barPlot.baseValue = [NSNumber numberWithFloat:0.0];
            barPlot.barOffset = [NSNumber numberWithFloat:offset];
            barPlot.barWidth = [NSNumber numberWithFloat:width];
            barPlot.identifier = (i == 0) ? @"LeftHistoPlot" : @"RightHistoPlot";
            
            [_histogramGraph[i] addPlot:barPlot toPlotSpace:_plotSpace[i]];
            
            
            CPTXYAxisSet *axisSet = (CPTXYAxisSet *) [_histogramGraph[i] axisSet];
            
            _plotSpace[i].yRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithFloat:ensembleRange[1]]
                                                                length:[NSNumber numberWithFloat:r]];
            axisSet.yAxis.majorIntervalLength = [NSNumber numberWithFloat:r_tick];
        }
    }
}

- (void) refresh
{
    OVEnsembleData* ensemble = [_appDelegate ensembleData];
    
    if( ![ensemble isLoaded] ) return;
    if( !_leftVariable || !_rightVariable ) return;
    
    iVector2 position = [[_appDelegate viewSettings] histogramPosition];
    
    int numBins = [ensemble histogramBins];
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithCapacity:numBins];
    
    float baseLine[2] = { 0.0f, 0.0f };
    NSString* varName[2] = { @"", @"" };
    varName[0] = [NSString stringWithFormat:@"%@ in %@",_leftVariable.name, _leftVariable.unit];
    float* range = _leftVariable.dataRange;
    if( range[0] > 0 && range[1] > 0 ) baseLine[0] = range[1];
    if( range[0] < 0 && range[1] < 0 ) baseLine[0] = range[0];
    varName[1] = [NSString stringWithFormat:@"%@ in %@",_rightVariable.name, _rightVariable.unit];
    range = _rightVariable.dataRange;
    if( range[0] > 0 && range[1] > 0 ) baseLine[1] = range[1];
    if( range[0] < 0 && range[1] < 0 ) baseLine[1] = range[0];
    
    for( int i = 0; i < 2; i++ )
    {
        int* histogram = [ensemble histogramAtPositionX:position.x Y:position.y ForVariable:(OVVariable2D*)((i==0)?_leftVariable:_rightVariable)];
        
        int maxCount = 0;
        
        for( int i = 0; i < numBins; i++ )
        {
            int v = histogram[numBins - 1 - i];
            
            maxCount = MAX( v, maxCount );
            
            tmp[i] = [NSDecimalNumber numberWithInt:v];
        }
        
        int axisStart = (i == 0) ? MAX(maxCount, 1) : 0;
        int axisLength = (i == 0) ? -MAX(maxCount, 1) : MAX(maxCount, 1);
        
        _plotSpace[i].xRange = [CPTPlotRange plotRangeWithLocation:[NSNumber numberWithInt:axisStart]
                                                            length:[NSNumber numberWithInt:axisLength]];
        
        
        int major = MAX(1,(int)(maxCount/5));
        
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *) [_histogramGraph[i] axisSet];
        axisSet.xAxis.majorIntervalLength = [NSNumber numberWithFloat:major];
        axisSet.xAxis.minorTicksPerInterval = major-1;
        //axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(baseLine[i]);
        
        axisSet.yAxis.title = varName[i];
        //axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(MAX(maxCount, 1));

        _data[i] = [tmp copy];
        
        [_histogramGraph[i] reloadData];
    }
}

#pragma mark CPTPlotDataSource Protocoll

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSString *identifier = (NSString *)[plot identifier];
    
    if ( [identifier isEqualToString: @"LeftHistoPlot"] || [identifier isEqualToString: @"LeftScatterPlot"] ) {
        
        return [_data[0] count];
    }
    else if ( [identifier isEqualToString: @"RightHistoPlot"] || [identifier isEqualToString: @"RighScatterPlot"] ) {
        
        return [_data[1] count];
    }
    
    return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)[plot identifier];
    
    if ( [identifier isEqualToString: @"LeftHistoPlot"] ) {
        
        num = (fieldEnum == CPTBarPlotFieldBarLocation) ? [NSDecimalNumber numberWithUnsignedInteger:index] : [_data[0] objectAtIndex:index];
    }
    else if ( [identifier isEqualToString: @"RightHistoPlot"] ) {
        
        num = (fieldEnum == CPTBarPlotFieldBarLocation) ? [NSDecimalNumber numberWithUnsignedInteger:index] : [_data[1] objectAtIndex:index];
    }
    else if ( [identifier isEqualToString: @"LeftScatterPlot"] ) {
        num = (fieldEnum == CPTScatterPlotFieldY) ? [NSDecimalNumber numberWithFloat:index+0.5] : [_data[0] objectAtIndex:index];
    }
    else if ( [identifier isEqualToString: @"RighScatterPlot"] ) {
        num = (fieldEnum == CPTScatterPlotFieldY) ? [NSDecimalNumber numberWithFloat:index+0.5] : [_data[1] objectAtIndex:index];
    }
    
    return num;
}

@end
