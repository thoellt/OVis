/*!	@header		OV2DView.h
	@discussion	Custom 2D View for OVis derived from MKMapView.
	@author		Thomas Höllt
	@updated	2013-07-29 */

// System Headers
#import <MapKit/MapKit.h>

/*!	@class		OV2DView
	@discussion	Custom 2D View for OVis derived from MKMapView.*/
@interface OV2DView : MKMapView {
}

/*!	@method		setShowsControls
	@discussion	Set whether or not to show map overlay controls in the map view.
	@param	showsControls	BOOL value, YES to show controls, NO to hide.*/
- (void) setShowsControls:(BOOL)showsControls;

@end
