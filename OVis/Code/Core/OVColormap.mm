//
//	OVColormap.mm
//

// Local Header
#import "OVColormap.h"

@implementation OVColormap

@synthesize name	 = _name;
@synthesize colormap = _colormap;
@synthesize size	 = _size;


#pragma mark - Init

- (id) init
{
	return [self initWithData:nil ofSize:0];
}

- (id) initWithData: (RGB *) data ofSize: (int) dataSize
{
	return [self initWithData:nil ofSize:0 name:nil];
}

- (id) initWithData: (RGB *) data ofSize: (int) dataSize name: (NSString*) name
{
	self = [super init];
	
	if( self )
	{
		if( data )
		{
			_colormap = new RGB[dataSize];
			for( int i = 0; i < dataSize; i++ )
			{
				_colormap[i] = data[i];
			}
		} else {
			_colormap = nil;
		}
		_size = dataSize;
        
        _name = name;
	}
	
	return self;
}

#pragma mark - Accessors

- (RGB) colorAtNormalizedIndex: (float) index discrete: (BOOL) isDiscrete
{
	if( isDiscrete )
		return [self discreteColorAtNormalizedIndex:index];
	else
		return [self continuousColorAtNormalizedIndex:index];
}

- (RGB) continuousColorAtNormalizedIndex: (float) index
{
	assert( index >= 0.0f && index <= 1.0f );
	
	RGB color = { 0, 0, 0 };
	
	if( _colormap )
	{
		float scaledIndex = index * (_size - 1);
		Byte lowerIndex = (Byte) scaledIndex;
		Byte upperIndex = MIN(lowerIndex + 1, _size - 1);
		
		float upperScale = scaledIndex - lowerIndex;
		float lowerScale = 1.0f - upperScale;
		
		color.r = lowerScale * _colormap[lowerIndex].r + upperScale * _colormap[upperIndex].r;
		color.g = lowerScale * _colormap[lowerIndex].g + upperScale * _colormap[upperIndex].g;
		color.b = lowerScale * _colormap[lowerIndex].b + upperScale * _colormap[upperIndex].b;
	}
	return color;
}

- (RGB) discreteColorAtNormalizedIndex: (float) index
{
	assert( index >= 0.0f && index <= 1.0f );
	
	RGB color = { 0, 0, 0 };
	
	if( _colormap )
	{
		color = _colormap[ (Byte)( index * (_size - 1) + 0.5 ) ];
	}
	return color;
}

- (RGB) colorAtIndex: (int) index
{
	assert( index >= 0 && index < _size );
	
	RGB color = { 0, 0, 0 };
	
	if( _colormap )
	{
		color = _colormap[ (Byte)index ];
	}
	return color;
}

@end