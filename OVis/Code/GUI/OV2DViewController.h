/*!	@header		OV2DViewController.h
	@discussion	Controller for the OVis 2D View.
	@author		Thomas Höllt
	@updated	2013-12-17 */

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// Friend Classes
@class OVViewSettings;
@class OV2DView;
@class OVMapOverlay;
@class OVMapOverlayRenderer;

/*!	@class		OV2DViewController
    @discussion	Controller for the OVis 2D View.*/
@interface OV2DViewController : NSViewController {
	
	id<OVAppDelegateProtocol> _appDelegate;
	OVViewSettings *_viewSettings;
	
	OV2DView *_mapview;
	OVMapOverlay *_mainOverlay;
	OVMapOverlayRenderer *_mainOverlayRenderer;
	
	BOOL _isDraggingPin;
	NSString *_draggingPinName;
	
	IBOutlet NSLayoutConstraint *verticalSpace2DViewBottom;
	
	IBOutlet NSPopUpButton *activePlatformPopUp;
	IBOutlet NSButton *addPlatformButton;
	IBOutlet NSButton *removePlatformButton;
	IBOutlet NSTextField *latTextField;
	IBOutlet NSTextField *lonTextField;
	IBOutlet NSTextField *addPlatformNameTextField;
	IBOutlet NSPopover *addPlatformPopover;
}

/*!	@property	mapview
	@brief		The controlled OV2DView.*/
@property (nonatomic, readwrite, retain) IBOutlet OV2DView *mapview;

/*!	@method		refreshFromData
	@discussion	Refreshes the controlled map view by reloading the data. Should
				be called everytime the parameters, colormap, statistics, etc. change.
    @param	newData	BOOL value indicating if new data was loaded. Call with YES
                after loading a new dataset, with NO otherwise.*/
- (void) refreshFromData:(BOOL) newData;

/*!	@method		refreshGUI
    @discussion	Refreshes GUI, adapting it to new data/data ranges.*/
- (void) refreshGUI;

/*!	@method		reloadMap
	@discussion	Reloads the vie data for the map and updates the view according to
				position and zoom level. Should be called when new data was loaded.
	@param	animate	BOOL value, encapsuled in an NSNumber, to support async calling,
				that indicates whether or not a change of position shall be carried
				out animated or not.*/
- (void) reloadMap:(NSNumber*) animate;

/*!	@method		toggleProperties
	@discussion	Toggles the property view on the bottom of the view.*/
- (void) toggleProperties;

/*!	@method		refreshPins
	@discussion	Refreshes the pins on the map view with the data gathered from
				the ensemble.*/
- (void) refreshPins;

/*!	@method		refreshCoordsFromPinWithTitle
	@discussion	Refreshes the coordinates for the off shore platform, with the
				provided name, from the location of the pin of this platform
				in the map view.
	@param	title	The name of the off shore platform to update.*/
- (void) refreshCoordsFromPinWithTitle: (NSString*) title;

/*!	@method		refreshCalloutForPinWithTitle
	@discussion	Refreshes the callout for the off shore platform, with the
				provided name.
	@param	title	The name of the off shore platform to update.*/
- (void) refreshCalloutForPinWithTitle: (NSString*) title;

/*!	@method		refreshLonLatGUI
	@discussion	Refreshes the GUI for Latitude and Longitude input in the view.*/
- (void) refreshLonLatGUI;

/*!	@method		refreshPlatformGUI
	@discussion	Refreshes the complete GUI for platform editing in the view.*/
- (void) refreshPlatformGUI;

/*!	@method		setViewToMatchEnsemble
	@discussion	Sets the view to match the data, after calling the complete dataset
				will be visible.
	@param	sender	The sender of the event.*/
- (IBAction) setViewToMatchEnsemble:(id)sender;

/*!	@method		showAddPlatformPopOver
	@discussion	Shows the popover to enter the name for a new off shore platform.
	@param	sender	The sender of the event.*/
- (IBAction) showAddPlatformPopOver:(id)sender;

/*!	@method		cancelAddPlatform
	@discussion	Cancels adding a new off shore platform.
	@param	sender	The sender of the event.*/
- (IBAction) cancelAddPlatform:(id)sender;

/*!	@method		addPlatform
	@discussion	Adds a new off shore platform.
	@param	sender	The sender of the event.*/
- (IBAction) addPlatform:(id)sender;

/*!	@method		removePlatform
	@discussion	Removes the currently active off shore platform.
	@param	sender	The sender of the event.*/
- (IBAction) removePlatform:(id)sender;

/*!	@method		selectPlatform
	@discussion	Selects a new active off shore platform.
	@param	sender	The sender of the event.*/
- (IBAction) selectPlatform:(id)sender;

/*!	@method		setLatitude
	@discussion	Sets the latitude of the currently active off shore platform.
	@param	sender	The sender of the event.*/
- (IBAction) setLatitude:(id)sender;

/*!	@method		setLongitude
	@discussion	Sets the longitude of the currently active off shore platform.
	@param	sender	The sender of the event.*/
- (IBAction) setLongitude:(id)sender;

@end