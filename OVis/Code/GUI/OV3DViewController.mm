//
//	OV3DViewController.mm
//

// System Headers
#import <Cocoa/Cocoa.h>
#import <AppKit/NSColor.h>

// Custom Headers
#import "OVViewSettings.h"
#import "OV3DView.h"

// Local Header
#import "OV3DViewController.h"

@implementation OV3DViewController

#pragma mark View Creation

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
    
	if (self) {
		// Initialization code here.
		_appDelegate = (id<OVAppDelegateProtocol>) [NSApplication sharedApplication].delegate;
	}
	
	return self;
}

- (void)awakeFromNib
{
}

#pragma mark Data

- (void) refreshFromData:(BOOL) newData
{
	if( newData )
		[glView rebuildRenderer];
	else
		[glView refreshRenderer];
}

- (void) refreshGLBuffers
{
    [glView refreshPathlineBuffers];
}

@end
