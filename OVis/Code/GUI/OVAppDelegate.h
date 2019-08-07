/*!	@header		OVAppDelegate.h
	@discussion	The OVAppDelegate is the entry point to the application.
				It also bridges most of the functionality between core and UI
				via the OVAppDelegateProtocol and handles some UI itself.
	@author		Thomas Höllt
	@updated	2013-08-01
 */

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "general.h"

// Friend Classes
@class OVCLCompute;
@class OVEnsembleData;
@class OVGLContextManager;
@class OVNCLoaderController;
@class OVViewSettings;

@class OVMainWindow;
@class OV2DViewController;
@class OV3DViewController;
@class OVHistogramViewController;
@class OVPropertiesViewController;
@class OVTimeSeriesViewController;
@class OVPreferencesWindowController;

/*!	@class	OVAppDelegate
	@discussion	The OVAppDelegate is the entry point to the application.
				It also bridges most of the functionality between core and UI
				via the OVAppDelegateProtocol and handles some UI itself.*/
@interface OVAppDelegate : NSObject <NSApplicationDelegate> {
    
	IBOutlet NSMenuItem* show2DProperties;
	IBOutlet NSMenuItem* showTSProperties;
    
    IBOutlet NSPanel* _ncLoadSheet;
    
    IBOutlet NSSplitView *_verticalSplitView;
    IBOutlet NSSplitView *_topSplitView;
    IBOutlet NSSplitView *_bottomSplitView;
    
    IBOutlet OVMainWindow* _mainWindow;
    IBOutlet NSMenuItem* _toggleMainWindowMenuItem;
    
    IBOutlet NSWindow* _preferencesWindow;
    
	IBOutlet NSScrollView *_propertiesScrollView;
	IBOutlet NSView *_propertiesClipView;
    
    IBOutlet NSView* _2DView;
    IBOutlet NSView* _3DView;
    IBOutlet NSView* _timeSeriesView;
    IBOutlet NSView* _histogramView;
    
    IBOutlet NSMenuItem* _importFilesMenuItem;

@private
    NSArray* _fileList;
    
    BOOL _needsEnableUpdate;
    BOOL _isMainWindowVisible;
    BOOL _importFilesMenuItemEnabled;
        
	OVViewSettings* _viewSettings;
	OVEnsembleData* _ensembleData;
	OVGLContextManager* _glContextManager;
    
    OVNCLoaderController*           _netCDFLoaderController;
    
    OV2DViewController* _twoDViewController;
    OV3DViewController* _threeDViewController;
	OVPropertiesViewController*   _propertiesViewController;
    OVHistogramViewController*    _histogramViewController;
    OVTimeSeriesViewController*    _timeSeriesViewController;
    
    OVPreferencesWindowController*    _preferencesWindowController;
}

/*!	@property	viewSettings
	@brief		The global view settings for the application.*/
@property (strong, nonatomic) OVViewSettings *viewSettings;

/*!	@property	ensembleData
	@brief		The global ensemble data for the application.*/
@property (strong, nonatomic) OVEnsembleData *ensembleData;

/*!	@property	glContextManager
	@brief		Manager for OpenGL contexts for the application. Necessary for
				resource sharing between contexts.*/
@property (strong, nonatomic) OVGLContextManager *glContextManager;

/*!	@property	clCompute
	@brief		Access to OpenCl compute capabilities.*/
@property (strong, nonatomic) OVCLCompute *clCompute;

/*!	@method		refreshAllViewsFromData
	@discussion	Refreshes all views after checking for changes in the data.
				Call this method, when parameters for the current dataset, i.e.
				the parameter range, the active property, etc. have changed.
				All views check for modified data and refresh texture buffers etc.*/
- (void) refreshAllViewsFromData;

/*!	@method			refreshAllViewsFromDataIncludingGUI
	@discussion		Refreshes all views after checking for changes in the data.
					Call this method with includeGUI = NO, when only parameters
					for the current dataset, i.e. the parameter range, the active
					property, etc. have changed.
					All views check for modified data and refresh texture buffers etc.
					Call this method, when new data is loaded with includeGUI = YES.
					In this case all views will rebuild their respective renderers
					and reload data.
					Additionally all GUI elements will be upodated.
	@param	includeGUI	BOOL value that defines whether or not the GUI should also be
					refreshed. The GUI should be refreshed whenever new data was
					loaded.*/
- (void) refreshAllViewsFromDataIncludingGUI: (BOOL) includeGUI;

/*!	@method		refreshViewFromData
	@discussion	Refreshes the provided view after checking for changes in the data.
				Call this method, when parameters for the current dataset, i.e.
				the parameter range, the active property, etc. have changed, that
				affect only a single view.
				The provided view checks for modified data and refresh texture buffers etc.
	@param	viewId	OVViewId of the view that shall be refreshed.*/
- (void) refreshViewFromData:(OVViewId) viewId;

/*!	@method		refreshViewFromData
	@discussion	Refreshes all views after checking for changes in the data.
				Call this method with includeGUI = NO, when only parameters
				for the current dataset, i.e. the parameter range, the active
				property, etc. have changed.
				All views check for modified data and refresh texture buffers etc.
				Call this method, when new data is loaded with includeGUI = YES.
				In this case all views will rebuild their respective renderers
				and reload data.
				Additionally all GUI elements will be upodated.
	@param	viewId	OVViewId of the view that shall be refreshed.
	@param	includeGUI	BOOL value that defines whether or not the GUI should also be
					refreshed. The GUI should be refreshed whenever new data was
					loaded.*/
- (void) refreshViewFromData:(OVViewId) viewId includingGUI: (BOOL) includeGUI;

/*!	@method		refreshGUIforView
	@discussion	Refreshes the GUI for the provided view.
	@param	viewId	OVViewId of the view that shall be refreshed.*/
- (void) refreshGUIforView: (OVViewId) viewId;

/*!	@method		refreshGLBuffers
    @discussion	Refreshes the OpenGL Buffers for the provided view.
    @param	viewId	OVViewId of the view that shall be refreshed.*/
- (void) refreshGLBuffers: (OVViewId) viewId;

/*!	@method		toggleMainWindow
    @discussion	Toggles Visibility of the main Window.
    @param	sender	The sender of the event.*/
- (IBAction) toggleMainWindow:(id)sender;

/*!	@method		showPreferencesWindow
    @discussion	Opens the preferences Window.
    @param	sender	The sender of the event.*/
- (IBAction) showPreferencesWindow:(id)sender;

/*!	@method		showPropertiesView
	@discussion	Shows (and if necessary builds) the Properties View.
	@param	sender	The sender of the event.*/
- (IBAction) showPropertiesView:(id)sender;

/*!	@method		show2DView
	@discussion	Shows (and if necessary builds) the 2D View.
	@param	sender	The sender of the event.*/
- (IBAction) show2DView:(id)sender;

/*!	@method		show3DView
	@discussion	Shows (and if necessary builds) the 3D View.
	@param	sender	The sender of the event.*/
- (IBAction) show3DView:(id)sender;

/*!	@method		showTimeSeriesView
	@discussion	Shows (and if necessary builds) the Time Series View.
	@param	sender	The sender of the event.*/
- (IBAction) showTimeSeriesView:(id)sender;

/*!	@method		showHistogramView
 @discussion	Shows (and if necessary builds) the Histogram View.
 @param	sender	The sender of the event.*/
- (IBAction) showHistogramView:(id)sender;

/*!	@method		toggle2DWindowProperties
	@discussion	Toggles the Properties GUI specific to and within the 2D View.
	@param	sender	The sender of the event.*/
- (IBAction) toggle2DWindowProperties:(id)sender;

/*!	@method		activeColormapIndexForView
	@discussion	Toggles the Properties GUI specific to and within the Time Series View.
	@param	sender	The sender of the event.*/
- (IBAction) toggleTimeSeriesWindowProperties:(id)sender;

/*!   @method      themeChanged
    @discussion   Triggers updates when the system switches into or out of dark mode.
    @param   notification   The notification of the event.*/
- (void) themeChanged:(NSNotification *)notification;

/*!	@method		openFile
	@discussion	Opens an .ovis file with the data specified in the .ovis file.
				After loading it adapts the application to the new data.
	@param	sender	The sender of the event.*/
- (IBAction) openFile:(id)sender;

/*!	@method		importFile
    @discussion	Import an .ova file with the data specified in the .ova file.
                After loading it adapts the application to the new data.
    @param	sender	The sender of the event.*/
- (IBAction) importFile:(id)sender;


@end
