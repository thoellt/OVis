/*!	@header		OVEnsembleData+Loader.h
	@discussion	Loader Category for OVEnsembleData. Handles loading new data.
	@author		Thomas Höllt
	@updated	2013-07-26 */

#import "OVEnsembleData.h"

@class OVVariable2D;

@interface OVEnsembleData (Loader)

/*!	@method		openEnsembleFromOVisFile
    @discussion	Loads data from a single url pointing to an ovis file provided as an argument.
    @param	url	NSURL, pointing to the file to be opened.*/
- (BOOL) openEnsembleFromOVisFile:(NSURL *)url;

/*!	@method		importDataFromOvaFiles
    @discussion	Imports additional data from a list of urls pointing to ova files provided as an argument.
    @param	urls	NSArray, pointing to the files to be opened.*/
- (void) importDataFromOvaFiles:(NSArray *)urls;

- (void) createValidEntriesTableWithSize: (size_t) size;

- (void) scanRangeForVariable:(OVVariable2D*) variable;

- (void) updateMetaDataForDimensionX: (size_t)dimX Y: (size_t)dimY Z: (size_t)dimZ T: (size_t)dimT M: (size_t)dimM;

- (void) updateMetaDataForMinLat: (float)minLat maxLat: (float)maxLat minLon: (float)minLon maxLon: (float)maxLon;

- (void) fileOpenAlertWithText: (NSString*) text;

@end
