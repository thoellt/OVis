/*!	@header		OVColormap.h
	@discussion	This class encapsules colormaps for all views. Colors can be
				returned using a continuous lookup or a discrete version.
	@author		Thomas Höllt
	@updated	2013-07-26 */

// System Headers
#import <Foundation/Foundation.h>

// Local Headers
#import "general.h"

// Friend Classes

/*!	@class		OVColormap
	@discussion	This class encapsules colormaps for all views. Colors can be
				returned using a continuous lookup or a discrete version.*/
@interface OVColormap : NSObject {
	
@private
	
	NSString*	 _name;
	
	RGB*		_colormap;
	int         _size;
}

/*!	@method		initWithData
	@discussion	Initializes the OVColormap object with an RGB array of colors.
	@param	data		The data for the colormap.
	@param	dataSize	The size of the colormap in number of RGB tuples.
	@result		OVColormap object that has been created.*/
- (id) initWithData: (RGB *) data ofSize: (int) dataSize;

/*!	@method		initWithData
    @discussion	Initializes the OVColormap object with an RGB array of colors.
    @param	data		The data for the colormap.
    @param	dataSize	The size of the colormap in number of RGB tuples.
    @param	name	The name of the color map used for the GUI.
    @result		OVColormap object that has been created.*/
- (id) initWithData: (RGB *) data ofSize: (int) dataSize name: (NSString*) name;

/*!	@method		colorAtNormalizedIndex
	@discussion	Returns the color at the given normalized index (in [0..1]).
				Can return the color for discrete and continous versions of
				the colormap.
	@param	index		The index in the colormap, normalized to [0..1].
	@param	isDiscrete	A flag for using the discrete or continuous colormap.
	@result		RGB struct containing the computed color.*/
- (RGB) colorAtNormalizedIndex: (float) index discrete: (BOOL) isDiscrete;

/*!	@method		continuousColorAtNormalizedIndex
	@discussion	Returns the color at the given normalized index (in [0..1])
				using the continous version of the colormap.
	@param	index	The index in the colormap, normalized to [0..1].
	@result		RGB struct containing the computed color.*/
- (RGB) continuousColorAtNormalizedIndex: (float) index;

/*!	@method		discreteColorAtNormalizedIndex
	@discussion	Returns the color at the given normalized index (in [0..1])
				using the discrete version of the colormap.
	@param	index	The index in the colormap, normalized to [0..1].
	@result		RGB struct containing the computed color.*/
- (RGB) discreteColorAtNormalizedIndex: (float) index;

/*!	@method		colorAtIndex
    @discussion	Returns the color at the given index.
    @param	index	The index in the colormap.
    @result		RGB struct containing the computed color.*/
- (RGB) colorAtIndex: (int) index;

/*!	@property	name
	@brief		NSString for the name of the colormap.*/
@property (nonatomic) NSString *name;

/*!	@property	colormap
	@brief		Pointer to an array of RGB structs containing the colormap data.*/
@property (nonatomic) RGB *colormap;

/*!	@property	size
	@brief		Int value holding the size (number of RGBs) in the colormap.*/
@property (nonatomic) int size;

@end