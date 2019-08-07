//
//	OVMapOverlay.mm
//

// System Headers
#import <CoreLocation/CoreLocation.h>

// Custom Headers
#import "OVAppDelegate.h"
#import "OVEnsembleData.h"

// Local Header
#import "OVMapOverlay.h"

@implementation OVMapOverlay

@synthesize coordinate = _center;
@synthesize boundingMapRect = _bounds;

- (id)init
{
	self = [super init];
	if (self) {
		// Initialization code here.
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
		
		_bounds = MKMapRectMake(0, 0, 0, 0);
		_center = CLLocationCoordinate2DMake(0, 0);
	}
	
	return self;
}

- (void) refreshData
{
	[self refreshCenter];
	[self refreshRectangle];
}

- (void) refreshCenter
{
	EnsembleLonLat *dim = _appDelegate.ensembleData.ensembleLonLat;
	_center = CLLocationCoordinate2DMake(fabsf(dim->lat_max + dim->lat_min) * 0.5, fabsf(dim->lon_max + dim->lon_min) * 0.5);
}

- (void) refreshRectangle
{
	EnsembleLonLat *dim = _appDelegate.ensembleData.ensembleLonLat;
	//Latitue and longitude for each corner point
	MKMapPoint upperLeft	 = MKMapPointForCoordinate(CLLocationCoordinate2DMake(dim->lat_max, dim->lon_min));
	MKMapPoint upperRight	= MKMapPointForCoordinate(CLLocationCoordinate2DMake(dim->lat_max, dim->lon_max));
	MKMapPoint bottomLeft	= MKMapPointForCoordinate(CLLocationCoordinate2DMake(dim->lat_min, dim->lon_min));
	
	//Building a map rect that represents the image projection on the map
	_bounds = MKMapRectMake(upperLeft.x, upperLeft.y, fabs(upperLeft.x - upperRight.x), fabs(upperLeft.y - bottomLeft.y));
}

-(void) dealloc {
}

@end