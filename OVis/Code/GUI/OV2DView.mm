//
//	OV2DView.mm
//

// Local Header
#import "OV2DView.h"

@implementation OV2DView

- (id) init {
	
	self = [super init];
	
	return self;
}

- (void) setShowsControls:(BOOL)showsControls {
	
	[super setShowsZoomControls:showsControls];
}

@end
