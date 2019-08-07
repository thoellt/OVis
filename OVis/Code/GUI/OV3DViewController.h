/*!	@header		OV3DViewController.h
	@discussion	Controller for the OVis 3D View.
	@author		Thomas Höllt
	@updated	2013-10-17 */

// System Headers
#import <Cocoa/Cocoa.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

// FriendClasses
@class OV3DView;

/*!	@class		OV3DViewController
	@discussion	Controller for the OVis 3D View.*/
@interface OV3DViewController : NSViewController{
	
	id<OVAppDelegateProtocol> _appDelegate;
	
	IBOutlet OV3DView *glView;
}

/*!	@method		refreshFromData
	@discussion	Refreshes the controlled map view by reloading the data. Should
				be called everytime the parameters, colormap, statistics, etc. change.
	@param	newData	BOOL value indicating if new data was loaded. Call with YES
				after loading a new dataset, with NO otherwise.*/
- (void) refreshFromData:(BOOL) newData;

- (void) refreshGLBuffers;

@end
