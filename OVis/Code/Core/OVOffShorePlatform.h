/*!	@header		OVOffShorePlatform.h
	@discussion	This class encapsules off shore structures with name, position
				and the annotation for the GUI.
	@author		Thomas Höllt
	@updated	2013-07-26 */

// System Headers
#import <Foundation/Foundation.h>

// Friend Classes
@class OVPlatformAnnotation;
@class OVVariable1D;

/*!	@class		OVOffShorePlatform
	@discussion	This class encapsules off shore structures with name, position
				and the annotation for the GUI.*/
@interface OVOffShorePlatform : NSObject
{
    NSString*       _name;
    BOOL            _isFixed;
    NSMutableArray* _correspondingVariables;
    float           _latitude;
    float           _longitude;
    OVPlatformAnnotation* _annotation;
}

/*!	@property	isFixed
    @brief		Flag for locking the platforms properties.*/
@property (nonatomic) BOOL isFixed;

/*!	@property	correspondingVariables
    @brief		Index of corresponding additional data variable.*/
@property (nonatomic) NSMutableArray* correspondingVariables;

/*!	@property	name
	@brief		NSString with the name of the platform.*/
@property (nonatomic) NSString *name;

/*!	@property	latitude
	@brief		Flaot value holding the latitude of the platform.*/
@property (nonatomic) float latitude;

/*!	@property	longitude
	@brief		Flaot value holding the longitude of the platform.*/
@property (nonatomic) float longitude;

/*!	@property	annotation
	@brief		OVPlatformAnnotation holding the annotation in the mapview for reverse lookup.*/
@property (nonatomic) OVPlatformAnnotation *annotation;

-(void) addVariable:(OVVariable1D*) variable;

@end