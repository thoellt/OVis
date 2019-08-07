/*!	@header		OVMapOverlay.h
	@discussion Map Overlay derived from MKOverlay for the statistic visualization
				in the 2D View.
	@author		Thomas Höllt
	@updated	2013-07-29 */

// System Headers
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

// Custom Headers
#import "OVAppDelegateProtocol.h"

/*!	@class		OVGLView
	@discussion	Map Overlay derived from MKOverlay for the statistic visualization
				in the 2D View.*/
@interface OVMapOverlay : NSObject <MKOverlay> {
	
	id<OVAppDelegateProtocol> _appDelegate;
	
	MKMapRect _bounds;
	CLLocationCoordinate2D _center;
}

/*!	@property	coordinate
	@brief		The center coordinate for the overlay.*/
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/*!	@property	coordinate
	@brief		The bounding rectangle for the overlay.*/
@property (nonatomic, readonly) MKMapRect boundingMapRect;

/*!	@method		refreshData
	@discussion	Refreshes center and bounding rectangle from the ensemble. Calls
				refreshCenter and refreshRectangle.*/
- (void) refreshData;

/*!	@method		refreshCenter
	@discussion	Refreshes the center from the ensemble.*/
- (void) refreshCenter;

/*!	@method		refreshRectangle
	@discussion	Refreshes the bounding rectangle from the ensemble.*/
- (void) refreshRectangle;

@end