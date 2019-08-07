/*!	@header		OVTimeSeriesViewController.h
	@discussion	Controller for the OVis Time Series View.
	@author		Thomas Höllt
	@updated	2013-10-17 */

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class OVTimeSeriesView;
@class OVTimeSeriesContainerView;

/*!	@class		OVTimeSeriesViewController
	@discussion	Controller for the OVis Time Series View.*/
@interface OVTimeSeriesViewController : NSViewController {
	
	id<OVAppDelegateProtocol> _appDelegate;
    
    NSMutableArray* _variablesLeft;
    NSMutableArray* _variablesRight;
    
    NSInteger _selectedVariableIdxLeft;
    NSInteger _selectedVariableIdxRight;
    
    IBOutlet OVTimeSeriesView* glView;
    IBOutlet OVTimeSeriesContainerView* mainViewContainer;
	IBOutlet NSView* glyphPropertiesView;
	IBOutlet NSView* legendView;
	
	float propertiesHeight;
	IBOutlet NSLayoutConstraint *verticalSpaceTSViewBottom;
    IBOutlet NSLayoutConstraint *horizontalSpaceTSViewRight;
    
    IBOutlet NSTextField *leftVariableNameLabel;
    
    IBOutlet NSTextField *leftHeightLabelCenter;
    IBOutlet NSTextField *leftHeightLabelBottom;
    IBOutlet NSTextField *leftHeightLabelBottomHalf;
    IBOutlet NSTextField *leftHeightLabelTop;
    IBOutlet NSTextField *leftHeightLabelTopHalf;
    
    IBOutlet NSTextField *rightVariableNameLabel;
    
    IBOutlet NSTextField *rightHeightLabelCenter;
    IBOutlet NSTextField *rightHeightLabelBottom;
    IBOutlet NSTextField *rightHeightLabelBottomHalf;
    IBOutlet NSTextField *rightHeightLabelTop;
    IBOutlet NSTextField *rightHeightLabelTopHalf;
	
	IBOutlet NSPopUpButton *leftItemSelector;
	IBOutlet NSPopUpButton *leftPropertySelector;
	IBOutlet NSPopUpButton *rightItemSelector;
    IBOutlet NSPopUpButton *rightPropertySelector;
    
    IBOutlet NSPopUpButton *colormapSelector;
    
    IBOutlet NSLayoutConstraint *verticalTimeLabelSpace;
    NSMutableArray* _timeLabels;
    
    IBOutlet NSPopUpButton *timeViewSelector;
}

/*!	@method		refreshFromData
	@discussion	Refreshes the view from the ensemble.
	@param	newData	YES if new data was loaded, NO if current datset was edited.*/
- (void) refreshFromData:(BOOL) newData;

/*!	@method		refreshGUI
	@discussion	Refreshes GUI, adapting it to new data/data ranges.*/
- (void) refreshGUI;

/*!	@method		refreshLegendGUI
	@discussion	Refreshes GUI for Legend, adapting it to new data/data ranges.*/
- (void) refreshLegendGUI;

/*!	@method		refreshSelectionGUI
	@discussion	Refreshes GUI for Glyph data selection, adapting it to new data/data ranges.*/
- (void) refreshSelectionGUI;

/*!	@method		refreshTimeSeriesViewGUI
	@discussion	Refreshes GUI for view on the time series, adapting it to new data/data ranges.*/
- (void) refreshTimeSeriesViewGUI;

/*!	@method		toggleProperties
	@discussion	Toggles the property view on the bottom of the window.*/
- (void) toggleProperties;

/*!	@method		toggleLegend
	@discussion	Toggles the legend, showing the current colormap and scale.
	@param	sender	The sender of the event.*/
- (IBAction) toggleLegend:(id)sender;

/*!	@method		selectLeftGlyphItem
	@discussion	Sets the platform or path for the left side of the glyph.
	@param	sender	The sender of the event.*/
- (IBAction) selectLeftGlyphItem:(id)sender;

/*!	@method		selectLeftGlyphProperty
	@discussion	Sets the property for the left glyph side (kde/distance to center).
	@param	sender	The sender of the event.*/
- (IBAction) selectLeftGlyphProperty:(id)sender;

/*!	@method		selectRightGlyphItem
	@discussion	Sets the platform or path for the right side of the glyph.
	@param	sender	The sender of the event.*/
- (IBAction) selectRightGlyphItem:(id)sender;

/*!	@method		selectRightGlyphProperty
 @discussion	Sets the property for the right glyph side (kde/distance to center).
	@param	sender	The sender of the event.*/
- (IBAction) selectRightGlyphProperty:(id)sender;

/*!	@method		setActiveColormap
	@discussion	Sets the active colormap for the glyphs.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveColormap:(id)sender;

/*!	@method		setActiveColormapDiscrete
	@discussion	Toggles between discrete and contiuous version of the colormap.
	@param	sender	The sender of the event.*/
- (IBAction) setActiveColormapDiscrete:(id)sender;

/*!	@method		setTimeView
	@discussion	Sets the resolution for the view on the time axis..
	@param	sender	The sender of the event.*/
- (IBAction) setTimeView:(id)sender;

- (void) refreshTimeLabels;

@end