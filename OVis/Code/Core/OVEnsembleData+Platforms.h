/*!	@header		OVEnsembleData+Platforms.h
	@discussion	Platforms Category for OVEnsembleData. Handles off shore
				platforms used for time series statistics.
	@author		Thomas Höllt
	@updated	2014-09-03 */

#import "OVEnsembleData.h"

// Friend Classes
@class OVOffShorePlatform;
@class OVVariable1D;

@interface OVEnsembleData (Platforms)

/*!	@method		addPlatformWithName
    @discussion	Creates and adds an OVOffShorePlatform object to the dictionary
                of platforms using a given name and position in lat/lon.
    @param	name	NSString with the name for the platform. Must be unique,
                if the name already exists the platform will be overwritten.
    @param	lat	Latitude of the platform.
    @param	lon	Longitude of the platform.
    @param	isFixed	Flag used to disable editing of a platform, i.e. for loaded data.
    @param	variable    The corresponding Variable if loaded from file.
    @result		The OVOffShorePlatform object that has been created and added
                to the dictionary.*/
- (OVOffShorePlatform *) addPlatformWithName:(NSString*) name lat:(float) lat lon:(float) lon fixed:(BOOL) isFixed variable: (OVVariable1D*) variable;

/*!	@method		addPlatformWithName
    @discussion	Creates and adds an OVOffShorePlatform object to the dictionary
                of platforms using a given name and position in lat/lon.
    @param	name	NSString with the name for the platform. Must be unique,
                if the name already exists the platform will be overwritten.
    @param	lat	Latitude of the platform.
    @param	lon	Longitude of the platform.
    @param	isFixed	Flag used to disable editing of a platform, i.e. for loaded data.
    @result		The OVOffShorePlatform object that has been created and added
                to the dictionary.*/
- (OVOffShorePlatform *) addPlatformWithName:(NSString*) name lat:(float) lat lon:(float) lon fixed:(BOOL) isFixed;

/*!	@method		addPlatformWithName
	@discussion	Creates and adds an OVOffShorePlatform object to the dictionary
				of platforms using a given name and position in lat/lon.
	@param	name	NSString with the name for the platform. Must be unique,
				if the name already exists the platform will be overwritten.
	@param	lat	Latitude of the platform.
	@param	lon	Longitude of the platform.
	@result		The OVOffShorePlatform object that has been created and added
				to the dictionary.*/
- (OVOffShorePlatform *) addPlatformWithName:(NSString*) name lat:(float) lat lon:(float) lon;

/*!	@method		updatePositionOfPlatformWithName
	@discussion	Updates the postion of the platform with the given name to
				the given lat/lon coordinates.
	@param	name	NSString with the name for the platform to be updated.
	@param	lat	New latitude for the platform.
	@param	lon	New longitude for the platform.*/
- (void) updatePositionOfPlatformWithName:(NSString*) name toLat:(float) lat lon:(float) lon;

/*!	@method		updateLatitudeOfPlatformWithName
    @discussion	Updates the latitude of the platform with the given name to
                the given lat coordinate.
    @param	name	NSString with the name for the platform to be updated.
    @param	lat	New latitude for the platform.*/
- (void) updateLatitudeOfPlatformWithName:(NSString*) name toLat:(float) lat;

/*!	@method		updateLongitudeOfPlatformWithName
    @discussion	Updates the longitude of the platform with the given name to
                the given lon coordinate.
    @param	name	NSString with the name for the platform to be updated.
    @param	lon	New longitude for the platform.*/
- (void) updateLongitudeOfPlatformWithName:(NSString*) name toLon:(float) lon;

/*!	@method		updatePositionOfActivePlatformToLat
    @discussion	Updates the postion of the active platform to the given lat/lon coordinates.
    @param	lat	New latitude for the platform.
    @param	lon	New longitude for the platform.*/
- (void) updatePositionOfActivePlatformToLat:(float) lat lon:(float) lon;

/*!	@method		updateLatitudeOfActivePlatformToLat
    @discussion	Updates the latitude of the active platform to the given lat coordinate.
    @param	lat	New latitude for the platform. */
- (void) updateLatitudeOfActivePlatformToLat:(float) lat;

/*!	@method		updatePositionOfActivePlatformToLat
    @discussion	Updates the longitude of the active platform to the given lon coordinate.
    @param	lon	New longitude for the platform.*/
- (void) updateLongitudeOfActivePlatformToLon:(float) lon;

/*!	@method		removePlatformWithName
	@discussion	Removes the platform with the given name from the dictionary.
	@param	name	NSString with the name for the platform to be removed.*/
- (void) removePlatformWithName:(NSString*) name;

/*!	@method		setActvePlatformByName
	@discussion	Makes the platform with the given name the active platform.
	@param	name	NSString with the name for the platform to be set active.*/
- (void) setActvePlatformByName:(NSString*) name;

/*!	@method		getActivePlatform
	@discussion	Returns the active platform.
	@result		The OVOffShorePlatform object corresponding to the active platform.*/
- (OVOffShorePlatform*) getActivePlatform;

/*!	@method		getPlatformWithName
	@discussion	Returns the platform with the given name.
	@param	name	NSString with the name for the platform to be returned.
	@result		The OVOffShorePlatform object with the given name.*/
- (OVOffShorePlatform*) getPlatformWithName:(NSString*) name;

@end
