//
//	OVEnsembleData+Platforms.mm
//

// Custom Headers
#import "OVOffShorePlatform.h"
#import "OVVariable1D.h"

// Local Headers
#import "OVEnsembleData+Platforms.h"

@implementation OVEnsembleData (Platforms)

#pragma mark - Platform Handling

- (OVOffShorePlatform *) addPlatformWithName:(NSString*) name lat:(float) lat lon:(float) lon fixed:(BOOL) isFixed variable: (OVVariable1D*) variable
{
    NSString* tmpName = name;
    int suffix = 1;
    
    while( [_platforms objectForKey:name] )
    {
        name = [NSString stringWithFormat:@"%@ %d", tmpName, suffix++];
    }
    
    OVOffShorePlatform *platform = [[OVOffShorePlatform alloc] init];
	
	[platform setName:name];
    [platform setIsFixed:isFixed];
    [platform addVariable:variable];
	[platform setLatitude:lat];
	[platform setLongitude:lon];
    [platform setAnnotation:nil];
	
	_activePlatform = name;
	
	[_platforms setObject:platform forKey:name];
	
	return platform;
}

- (OVOffShorePlatform *) addPlatformWithName:(NSString*) name lat:(float) lat lon:(float) lon fixed:(BOOL) isFixed
{
    return [self addPlatformWithName:name lat:lat lon:lon fixed:isFixed variable:nil];
}

- (OVOffShorePlatform *) addPlatformWithName:(NSString*) name lat:(float) lat lon:(float) lon
{
    return [self addPlatformWithName:name lat:lat lon:lon fixed:NO variable:nil];
}

- (void) updatePositionOfPlatformWithName:(NSString*) name toLat:(float) lat lon:(float) lon
{
	OVOffShorePlatform *platform = [_platforms objectForKey:name];
    
    if( !platform ) return;
	
    if( [platform isFixed] ) return;
    
	[platform setLatitude:lat];
	[platform setLongitude:lon];
}

- (void) updateLatitudeOfPlatformWithName:(NSString*) name toLat:(float) lat
{
	OVOffShorePlatform *platform = [_platforms objectForKey:name];
    
    if( !platform ) return;
	
    if( [platform isFixed] ) return;
    
	[platform setLatitude:lat];
}

- (void) updateLongitudeOfPlatformWithName:(NSString*) name toLon:(float) lon
{
	OVOffShorePlatform *platform = [_platforms objectForKey:name];
    
    if( !platform ) return;
	
    if( [platform isFixed] ) return;
    
	[platform setLongitude:lon];
}

- (void) updatePositionOfActivePlatformToLat:(float) lat lon:(float) lon
{
    [self updatePositionOfPlatformWithName:_activePlatform toLat:lat lon:lon];
}

- (void) updateLatitudeOfActivePlatformToLat:(float) lat
{
    [self updateLatitudeOfPlatformWithName:_activePlatform toLat:lat];
}

- (void) updateLongitudeOfActivePlatformToLon:(float) lon
{
    [self updateLongitudeOfPlatformWithName:_activePlatform toLon:lon];
}

- (void) setActvePlatformByName:(NSString*) name
{
	_activePlatform = name;
}

- (void) removePlatformWithName:(NSString*) name
{
	[_platforms removeObjectForKey:name];
}

#pragma mark - Platform Accessors

- (OVOffShorePlatform*) getActivePlatform
{
	if( _activePlatform )
		return [_platforms objectForKey:_activePlatform];
	return nil;
}

- (OVOffShorePlatform*) getPlatformWithName:(NSString*) name
{
    if( [name isEqualToString:@"Active"] )
    {
        return [self getActivePlatform];
    }
    
	return [_platforms objectForKey:name];
}

@end
