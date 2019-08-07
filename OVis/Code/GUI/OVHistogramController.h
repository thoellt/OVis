//
//  OVHistogramController.h
//  OVis
//
//  Created by Thomas Höllt on 26/09/13.
//  Copyright (c) 2013 Thomas Höllt. All rights reserved.
//

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"
#import <CorePlot/CorePlot.h>

@class OVVariable;

@interface OVHistogramController : NSObject  <CPTPlotDataSource>
{
   id<OVAppDelegateProtocol> _appDelegate;

   OVViewSettings *_viewSettings;
   
   bool _isDark;

   CPTXYGraph *_histogramGraph[2];
   CPTXYPlotSpace *_plotSpace[2];

   CPTColor *_backGroundColor;
   CPTColor *_barColors[4];
   CPTColor *_lineColor;
   CPTColor *_axesColor;
   CPTColor *_gridAxesColor;
   CPTColor *_labelColor;
   

   NSArray *_data[2];

   OVVariable *_leftVariable;
   OVVariable *_rightVariable;

   IBOutlet CPTGraphHostingView *_leftHistogramView;
   IBOutlet CPTGraphHostingView *_rightHistogramView;
}

@property (nonatomic) OVVariable* leftVariable;

@property (nonatomic) OVVariable* rightVariable;

/*!   @method      refreshTheme
   @discussion   Refresh colors according to theme.*/
- (void) refreshTheme;

/*!	@method		rebuildGraph
 @discussion	Build and setup the Graph and its contained Plots inside the view.*/
- (void) rebuildGraph;

/*!	@method		setUpGraph
 @discussion	Sets up the Graph inside the view.*/
- (void) setUpGraph;

/*!	@method		setUpKdePlot
 @discussion	Sets up the Kernel Density Estimate Plot. TODO */
- (void) setUpKdePlot;

/*!	@method		setUpHistogramPlot
 @discussion	Sets up the Histogram Plot.*/
- (void) setUpHistogramPlot;

/*!	@method		refresh
    @discussion	Refreshes the Graph. Call when position or parameters change.*/
- (void) refresh;

@end
