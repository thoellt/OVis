/*!	@header		OVAppDelegateProtocol.h
	@discussion	Protocol for the OVAppDelegate. Handles bridge between UI and
				Core and different UI Elements.
	@author		Thomas Höllt
	@updated	2013-08-01 */

// System Headers
#import <Foundation/Foundation.h>

// Custom Headers
#import "general.h"

// Friend Classes
@class OVCLCompute;
@class OVEnsembleData;
@class OVGLContextManager;
@class OVViewSettings;

/*!	@protocol	OVAppDelegateProtocol
	@discussion	Protocol for the OVAppDelegate. Handles bridge between UI and
				Core and different UI Elements.*/
@protocol OVAppDelegateProtocol <NSObject>

/*!	@method		refreshAllViewsFromData:
	@discussion	Refreshes all views after checking for changes in the data.
				Call this method, when parameters for the current dataset, i.e.
				the parameter range, the active property, etc. have changed.
				All views check for modified data and refresh texture buffers etc.*/
- (void) refreshAllViewsFromData;

/*!	@method		refreshAllViewsFromDataIncludingGUI
	@discussion	Refreshes all views after checking for changes in the data.
				Call this method with includeGUI = NO, when only parameters
				for the current dataset, i.e. the parameter range, the active
				property, etc. have changed.
				All views check for modified data and refresh texture buffers etc.
				Call this method, when new data is loaded with includeGUI = YES.
				In this case all views will rebuild their respective renderers
				and reload data.
				Additionally all GUI elements will be upodated.
	@param	includeGUI	BOOL value that defines whether or not the GUI should also be
				refreshed. The GUI should be refreshed whenever new data was loaded.*/
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
				refreshed. The GUI should be refreshed whenever new data was loaded.*/
- (void) refreshViewFromData:(OVViewId) viewId includingGUI: (BOOL) includeGUI;

/*!	@method		refreshGUIforView
	@discussion	Refreshes the GUI for the provided view.
	@param	viewId	OVViewId of the view that shall be refreshed.*/
- (void) refreshGUIforView: (OVViewId) viewId;

/*!	@method		refreshGLBuffers
    @discussion	Refreshes the OpenGL Buffers for the provided view.
    @param	viewId	OVViewId of the view that shall be refreshed.*/
- (void) refreshGLBuffers: (OVViewId) viewId;

/*!	@method		viewSettings
	@discussion	Returns the global OVViewSettings object.*/
- (OVViewSettings*) viewSettings;

/*!	@method		ensembleData
	@discussion	Returns the global OVEnsembleData object.*/
- (OVEnsembleData*) ensembleData;

/*!	@method		glContextManager
	@discussion	Returns the global OVGLContextManager object.*/
- (OVGLContextManager*) glContextManager;

/*!	@method		clCompute
	@discussion	Returns the global entry point for OpenCL compute.*/
- (OVCLCompute*) clCompute;

- (void) openFromFileList;

@end
