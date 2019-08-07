/*!	@header		OVPlatformAnnotation.h
	@discussion Custom Annotation derived from MKAnnotation for visualization of
				off-shore platforms in the 2D View.
	@author		Thomas Höllt
	@updated	2013-07-29 */

// System Headers
#import <MapKit/MapKit.h>

/*!	@class		OVGLView
	   @discussion	Custom Annotation derived from MKAnnotation for visualization of
				off-shore platforms in the 2D View.*/
@interface OVPlatformAnnotation : NSObject <MKAnnotation> {
	
	NSString *_title;
	NSString *_subtitle;
    
    BOOL _draggable;
	
	CLLocationCoordinate2D _coordinate;
	
	NSColor* _pinColor;
}

/*!	@property	title
	@brief		The title for the annotation, should be set to the name of the
				off-shore platform.*/
@property (nonatomic, copy) NSString* title;

/*!	@property	subtitle
	@brief		Subtitle for the callout, should be set to a String with the postion.*/
@property (nonatomic, copy) NSString* subtitle;

/*!	@property	draggable
    @brief		Flag to enable oder disable dragging.*/
@property (nonatomic) BOOL draggable;

/*!	@property	coordinate
	@brief		The position of the off-shore platform, represented by the annotation.*/
@property (nonatomic) CLLocationCoordinate2D coordinate;

/*!	@property	pinColor
	@brief		The color for the annotation pin.*/
@property (nonatomic) NSColor* pinColor;

/*!	@method		initWithCoordinates
	@discussion	Alternative init with location, name and description for the annotation.
	@param	location	The position (coordinate) of the platform.
	@param	name		The name (title) of the platform.
	@param	description	The descripton (subtitle) of the platform.*/
- (id)initWithCoordinates:(CLLocationCoordinate2D)location Name:(NSString *)name Description:(NSString *)description Draggable:(BOOL) isDraggable;

@end
