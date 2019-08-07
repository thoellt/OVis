//
//	OVPlatformAnnotation.mm
//

#import "OVPlatformAnnotation.h"

@implementation OVPlatformAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize draggable = _draggable;
@synthesize pinColor = _pinColor;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location Name:(NSString *)name Description:(NSString *)description Draggable:(BOOL) isDraggable
{
	self = [super init];
	if (self)
	{
		_coordinate = location;
		_title = name;
		_subtitle = description;
        
      _draggable = isDraggable;
		
		_pinColor = NSColor.systemGreenColor;
	}
	return self;
}

@end
