//
//	OVOffShorePlatform.mm
//

// Local Headers
#import "OVOffShorePlatform.h"

@implementation OVOffShorePlatform

@synthesize name = _name;
@synthesize isFixed = _isFixed;
@synthesize correspondingVariables = _correspondingVariables;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize annotation = _annotation;

- (id) init
{
    self = [super init];
	
	if( !self ) return nil;
    
    _name = nil;
    _isFixed = false;
    _correspondingVariables = nil;
    _latitude = 0.0;
    _longitude = 0.0;
    _annotation = nil;
    
    return self;
}

-(void) addVariable:(OVVariable1D*) variable
{
    if( !variable ) return;
    
    if( !_correspondingVariables )
    {
        _correspondingVariables = [[NSMutableArray alloc] init];
    }
    
    [_correspondingVariables addObject:variable];
}

@end